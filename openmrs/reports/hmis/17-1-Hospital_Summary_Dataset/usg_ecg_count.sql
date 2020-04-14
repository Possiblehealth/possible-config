SELECT 
    SUM(final.usg) AS USG,
    SUM(final.ecg) AS ECG
FROM
(SELECT 
	SUM(IF(first_concept.name IN ('ANC-USG placenta position','USG-Cleaned before use'), 1, 0)) AS usg,
	SUM(IF(first_concept.name = 'ECG note', 1, 0)) AS ecg,
    COUNT(DISTINCT (first_concept.person_id)) AS count
FROM
    (SELECT 
		question_concept_name.name AS answer_name
    FROM
        concept c
    INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
    INNER JOIN concept_name question_concept_name ON c.concept_id = question_concept_name.concept_id
	AND question_concept_name.concept_name_type = 'FULLY_SPECIFIED'
	AND question_concept_name.voided IS FALSE
    WHERE
        question_concept_name.name IN ('ANC-USG placenta position','USG-Cleaned before use', 'ECG note')
    ORDER BY answer_name DESC) first_answers
        LEFT OUTER JOIN
    (SELECT DISTINCT
        o1.person_id as person_id,
		cn1.concept_id AS question,
		cn1.name AS name
    FROM
        obs o1
        
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('ANC-USG placenta position','USG-Cleaned before use','ECG note')
        AND o1.voided = 0
        AND cn1.voided = 0
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
           ) first_concept ON first_concept.name = first_answers.answer_name
GROUP BY first_answers.answer_name)final;
