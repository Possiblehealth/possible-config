select
first_answers.category,


    IFNULL(SUM(CASE
                WHEN LOWER(method) LIKE '%condom%' THEN method_count
				WHEN LOWER(method) LIKE '%pill%' THEN method_count
				WHEN LOWER(method) LIKE '%depo provera%' THEN method_count
                ELSE 0 END), 0)  AS 'short',
	IFNULL(SUM(CASE
                WHEN LOWER(method) LIKE '%male sterilization%' THEN method_count
				WHEN LOWER(method) LIKE '%iucd%' THEN method_count
                WHEN LOWER(method) LIKE '%implant%' THEN method_count
                WHEN LOWER(method) LIKE '%female sterilization%' THEN method_count
			ELSE 0 END), 0) AS 'long'
from
    (SELECT DISTINCT
            question_concept_name.name AS category,
            question_concept_name.concept_id as question
    FROM
        concept c
    INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
    INNER JOIN concept_name question_concept_name ON c.concept_id = question_concept_name.concept_id
        AND question_concept_name.concept_name_type = 'FULLY_SPECIFIED'
        AND question_concept_name.voided IS FALSE
    INNER JOIN concept_answer ca ON c.concept_id = ca.concept_id
    INNER JOIN concept_name answer_concept_fully_specified_name ON ca.answer_concept = answer_concept_fully_specified_name.concept_id
        AND answer_concept_fully_specified_name.concept_name_type = 'FULLY_SPECIFIED'
        AND answer_concept_fully_specified_name.name NOT IN ('Not applicable')
    WHERE
        question_concept_name.name IN ('SA-Surgical procedure' , 'SA-Medical procedure')
            ) first_answers
    LEFT OUTER JOIN
    (SELECT 
	DISTINCT(o1.person_id) as person_id,
            cn2.concept_id AS answer,
            cn2.name as answer_name,
            cn1.concept_id AS question
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('SA-Surgical procedure' , 'SA-Medical procedure')
        AND o1.voided = 0
        AND cn1.voided = 0
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
        AND cn2.name NOT IN ('Not applicable')
        AND cn2.voided = 0
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN visit v1 ON v1.visit_id = e.visit_id
    WHERE
        CAST(e.encounter_datetime AS DATE) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
        ) first_concept ON first_concept.question = first_answers.question
  LEFT OUTER join        
(SELECT DISTINCT
      o1.person_id as per_id,
        COUNT(DISTINCT o1.person_id) AS method_count,
        cn2.concept_id AS answer,
		cn2.name as method
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Accepted family planning methods')
        AND o1.voided = 0
        AND cn1.voided = 0
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
        AND cn2.voided = 0
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    INNER JOIN visit v ON v.visit_id = e.visit_id
    WHERE       
CAST(v.date_started AS DATE) BETWEEN DATE('#startDate#') AND DATE('#endDate#') group by per_id) second_concept ON 
        first_concept.person_id = second_concept.per_id   
        GROUP BY first_answers.category;

