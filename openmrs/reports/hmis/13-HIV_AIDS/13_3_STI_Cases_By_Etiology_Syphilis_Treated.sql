SELECT 
    first_answers.answer_name AS 'Risk Groups/ Key Population Group',
    SUM(CASE
        WHEN
            second_answers.answer_name = 'TRUE'
                AND first_concept.answer IS NOT NULL
                AND second_concept.answer IS NOT NULL
        THEN
            1
        ELSE 0
    END) AS 'Patient Count'
FROM
    (SELECT 
       distinct ca.answer_concept AS answer,
            IFNULL(answer_concept_short_name.name, answer_concept_fully_specified_name.name) AS answer_name
    FROM
        concept c
    INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
    INNER JOIN concept_name question_concept_name ON c.concept_id = question_concept_name.concept_id
        AND question_concept_name.concept_name_type = 'FULLY_SPECIFIED'
        AND question_concept_name.voided IS FALSE
    INNER JOIN concept_answer ca ON c.concept_id = ca.concept_id
    INNER JOIN concept_name answer_concept_fully_specified_name ON ca.answer_concept = answer_concept_fully_specified_name.concept_id
        AND answer_concept_fully_specified_name.concept_name_type = 'FULLY_SPECIFIED'
        AND answer_concept_fully_specified_name.voided
        IS FALSE
    LEFT JOIN concept_name answer_concept_short_name ON ca.answer_concept = answer_concept_short_name.concept_id
        AND answer_concept_short_name.concept_name_type = 'SHORT'
        AND answer_concept_short_name.voided
        IS FALSE
    WHERE
        question_concept_name.name = 'STI-Risk group'
            AND cd.name = 'Coded') first_answers
        INNER JOIN
    (SELECT 
       DISTINCT answer_concept_fully_specified_name.concept_id AS answer,
            answer_concept_fully_specified_name.name AS answer_name
    FROM
        concept c
    INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
    INNER JOIN concept_name question_concept_name ON c.concept_id = question_concept_name.concept_id
        AND question_concept_name.concept_name_type = 'FULLY_SPECIFIED'
        AND question_concept_name.voided IS FALSE
    INNER JOIN global_property gp ON gp.property IN ('concept.true' , 'concept.false')
    INNER JOIN concept_name answer_concept_fully_specified_name ON answer_concept_fully_specified_name.concept_id = gp.property_value
        AND answer_concept_fully_specified_name.concept_name_type = 'FULLY_SPECIFIED'
        AND answer_concept_fully_specified_name.voided
        IS FALSE
    WHERE
        question_concept_name.name = 'STI-Syphilis treated'
            AND cd.name = 'Boolean'
    ORDER BY answer_name DESC) second_answers
        INNER JOIN
    reporting_age_group rag ON rag.report_group_name = 'All Ages'
        LEFT OUTER JOIN
    (SELECT 
       distinct o1.person_id,
            cn2.concept_id AS answer,
            cn1.concept_id AS question,
            v1.visit_id AS visit_id,
            v1.date_stopped AS datetime
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name = 'STI-Risk group'
        AND o1.voided = 0
        AND cn1.voided = 0
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
        AND cn2.voided = 0
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN visit v1 ON v1.visit_id = e.visit_id
        AND v1.date_stopped IS NOT NULL
    WHERE
        CAST(v1.date_stopped AS DATE) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) first_concept ON first_concept.answer = first_answers.answer
        LEFT OUTER JOIN
    (SELECT 
       DISTINCT o1.person_id,
            cn2.concept_id AS answer,
            cn1.concept_id AS question,
            v1.visit_id AS visit_id,
            v1.date_stopped AS datetime
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name = 'STI-Syphilis treated'
        AND o1.voided = 0
        AND cn1.voided = 0
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
        AND cn2.voided = 0
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN visit v1 ON v1.visit_id = e.visit_id
        AND v1.date_stopped IS NOT NULL
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) second_concept ON second_concept.answer = second_answers.answer
        AND first_concept.person_id = second_concept.person_id
        AND first_concept.visit_id = second_concept.visit_id
        LEFT OUTER JOIN
    person p ON first_concept.person_id = p.person_id
GROUP BY  first_answers.answer_name;
