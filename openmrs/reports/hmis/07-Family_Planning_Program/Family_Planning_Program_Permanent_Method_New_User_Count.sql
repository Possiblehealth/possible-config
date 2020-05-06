SELECT 
	gender.gender              AS gender,
	sum(case when first_concept.gender = 'F' and gender.gender = 'F' then 1 
	when first_concept.gender = 'M' and gender.gender = 'M' then 1  else 0 end 
    ) as permanent_fp_method_count
FROM
(SELECT 
  DISTINCT
        o1.person_id,
        p1.gender,
            cn2.concept_id AS answer,
            cn1.concept_id AS question
FROM
    obs o1
        INNER JOIN
    concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name in ('FRH-Long acting and permanent method','FRH-New method chosen')
        AND o1.voided = 0
        AND cn1.voided = 0
        INNER JOIN
    concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED' 
        And cn2.name in ('Vasectomy','Minilap')
        AND cn2.voided = 0
        INNER JOIN
    encounter e ON o1.encounter_id = e.encounter_id
        INNER JOIN
    visit v1 ON v1.visit_id = e.visit_id
        INNER JOIN
    person p1 ON o1.person_id = p1.person_id

WHERE
	DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
    )first_concept
    RIGHT OUTER JOIN (SELECT 'M' AS gender UNION SELECT 'F' AS gender) gender on first_concept.gender= gender.gender
              
    GROUP BY gender.gender
    Order By gender.gender;
    
