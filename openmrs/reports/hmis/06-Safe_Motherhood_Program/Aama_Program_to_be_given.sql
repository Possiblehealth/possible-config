SELECT 
sum(final.c1) as 'Transporation incentive to be given',
sum(final.c2) as 'ANC incentive to be given'
FROM
-- --------------------------- Transporation incentive to be given--------------------------
(SELECT
SUM(total_deliverd) as c1,0 as c2
FROM
(SELECT 
       COUNT(DISTINCT(o1.person_id)) as total_deliverd
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Delivery note')
        AND o1.voided = 0
        AND cn1.voided = 0
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
      INNER JOIN visit v ON v.visit_id = e.visit_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_deliverd

-- ---------------------------ANC incentive to be given--------------------------
UNION ALL
SELECT
0,SUM(total_delivery_completed) as c2
FROM    
(SELECT 
		count(distinct(o1.person_id)) as total_delivery_completed
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Delivery-Completed 4 ANC visits per protocol')
        AND o1.voided = 0
        AND cn1.voided = 0
		AND o1.value_coded = 1
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
      INNER JOIN visit v ON v.visit_id = e.visit_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_delivery_completed
) final
