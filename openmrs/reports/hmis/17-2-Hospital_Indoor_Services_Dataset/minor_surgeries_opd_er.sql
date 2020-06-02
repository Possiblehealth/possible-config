SELECT
first_answers.question,
gender.gender AS 'Gender',
SUM(CASE
WHEN
first.er_or_opd IS NOT NULL
AND second.minor_surgery IS NOT NULL
AND p.gender IS NOT NULL
THEN
1
ELSE 0
END) AS 'Patient Count'
FROM
(SELECT
question_concept_name.name as question
FROM
concept c
INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
INNER JOIN concept_name question_concept_name ON c.concept_id = question_concept_name.concept_id
AND question_concept_name.concept_name_type = 'FULLY_SPECIFIED'
AND question_concept_name.voided IS FALSE
WHERE
question_concept_name.name IN ('ER-Free health service code','OPD-Free health service code')
) first_answers
INNER JOIN
(SELECT 'M' AS gender UNION SELECT 'F' AS gender) gender
LEFT OUTER JOIN

(SELECT
distinct(o1.person_id) as er_or_opd,
cn1.name as question
FROM
obs o1
INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
AND cn1.concept_name_type = 'FULLY_SPECIFIED'
AND cn1.name IN ('ER-Free health service code','OPD-Free health service code')
INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
INNER JOIN person p1 ON o1.person_id = p1.person_id
WHERE
DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
)as first on first.question=first_answers.question
LEFT OUTER JOIN
(SELECT
o1.person_id as minor_surgery
FROM
obs o1
INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
AND cn1.concept_name_type = 'FULLY_SPECIFIED'
AND cn1.name IN ('Procedure-Procedure')
INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
AND cn2.concept_name_type = 'FULLY_SPECIFIED'
INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
INNER JOIN person p1 ON o1.person_id = p1.person_id
WHERE
DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
)as second ON second.minor_surgery=first.er_or_opd
LEFT OUTER JOIN
person p ON second.minor_surgery = p.person_id
AND p.gender = gender.gender
GROUP BY first_answers.question, gender.gender
ORDER BY first_answers.question, gender.gender;

