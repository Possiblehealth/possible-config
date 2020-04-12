SELECT 
    first_question.answer_name AS 'Diseases',
    COUNT(DISTINCT (first_concept.person_id)) AS 'Total Patient'
FROM
    (SELECT 
        question_concept_name.concept_id AS question,
            question_concept_name.name AS answer_name
    FROM
        concept c
    INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
    INNER JOIN concept_name question_concept_name ON c.concept_id = question_concept_name.concept_id
        AND question_concept_name.concept_name_type = 'FULLY_SPECIFIED'
        AND question_concept_name.voided IS FALSE
    LEFT JOIN concept_name question_concept_short_name ON question_concept_name.concept_id = question_concept_short_name.concept_id
        AND question_concept_short_name.concept_name_type = 'SHORT'
        AND question_concept_short_name.voided
        IS FALSE
    WHERE
        question_concept_name.name IN ('CBIMNCI 2 to 59-Falciparum malaria', 'CBIMNCI 2 to 59-Non falciparum malaria', 'CBIMNCI 2 to 59-Measles','CBIMNCI 2 to 59-Complicated malaria' ,'Childhood Illness-Fever present','CBIMNCI 2 to 59-Anaemia', 'CBIMNCI 2 to 59-Other diagnosis')
    ORDER BY answer_name DESC) first_question
        LEFT OUTER JOIN
    (SELECT 
        o1.person_id, cn1.concept_id AS question,
        (select name from concept_name where concept_id = o1.value_coded AND
			o1.voided IS FALSE and concept_name_type = 'FULLY_SPECIFIED' and voided = '0') as Diag
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('CBIMNCI 2 to 59-Falciparum malaria', 'CBIMNCI 2 to 59-Non falciparum malaria', 'CBIMNCI 2 to 59-Measles','CBIMNCI 2 to 59-Complicated malaria' ,'Childhood Illness-Fever present','CBIMNCI 2 to 59-Anaemia', 'CBIMNCI 2 to 59-Other diagnosis')
        AND o1.voided = 0
        AND cn1.voided = 0
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) first_concept ON first_concept.question = first_question.question AND first_concept.Diag = "TRUE"
GROUP BY first_question.answer_name
Order By first_question.answer_name;
