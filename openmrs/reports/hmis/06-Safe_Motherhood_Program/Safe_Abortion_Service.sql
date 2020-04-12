
SELECT final.`Safe Abortion Service`,
  sum(final.Medical) AS medical,
  IF(final.Surgical='NA','NA',sum(final.Surgical)) AS surgical
FROM
(SELECT
    'Post Abortion complications' AS 'Safe Abortion Service',
    SUM(IF(PAC_Compilications.Cause LIKE '%Medical abortion%',PAC_Compilications.Count, 0)) AS 'Medical',
    SUM(IF(PAC_Compilications.Cause LIKE '%Surgical abortion%', PAC_Compilications.Count, 0)) AS 'Surgical'
  FROM
    (
     SELECT 
     cn2.name AS Cause, 
	  COUNT(DISTINCT(o1.person_id)) AS 'Count'
FROM
    obs o1
        INNER JOIN
    concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('PAC cause')
        AND o1.voided = 0
        AND cn1.voided = 0
		INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('SA-Surgical abortion','SA-Medical abortion')
        AND cn2.voided = 0
        INNER JOIN
    encounter e ON o1.encounter_id = e.encounter_id
        INNER JOIN
    person p1 ON o1.person_id = p1.person_id
    INNER JOIN visit v ON v.visit_id = e.visit_id
    WHERE
DATE(o1.obs_datetime) BETWEEN '#startDate#' AND '#endDate#' group by Cause) PAC_Compilications

 UNION ALL

  SELECT
    'Post Abortion Care Service Availed' AS 'Safe Abortion Service',
    PAC_Cause.Count AS 'Medical',
    'NA' AS 'Surgical'
  FROM
    (
     SELECT 
     cn1.name AS Cause, 
	  COUNT(DISTINCT(o1.person_id)) AS 'Count'
FROM
    obs o1
        INNER JOIN
    concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('SA-PAC procedure')
        AND o1.voided = 0
        AND cn1.voided = 0
        INNER JOIN
    encounter e ON o1.encounter_id = e.encounter_id
        INNER JOIN
    person p1 ON o1.person_id = p1.person_id
    INNER JOIN visit v ON v.visit_id = e.visit_id
    WHERE
DATE(o1.obs_datetime) BETWEEN '#startDate#' AND '#endDate#') AS PAC_Cause
UNION ALL

  SELECT
    'Post Abortion complications' AS 'Safe Abortion Service',
    PAC_Cause.Count AS 'Medical',
    'NA' AS 'Surgical'
  FROM
    (
     SELECT 
     cn1.name AS Cause, 
	  COUNT(DISTINCT(o1.person_id)) AS 'Count'
FROM
    obs o1
        INNER JOIN
    concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('PAC-Medical complication','PAC-Surgical complication')
        AND o1.voided = 0
        AND cn1.voided = 0
        INNER JOIN
    encounter e ON o1.encounter_id = e.encounter_id
        INNER JOIN
    person p1 ON o1.person_id = p1.person_id
    INNER JOIN visit v ON v.visit_id = e.visit_id
    WHERE
DATE(o1.obs_datetime) BETWEEN '#startDate#' AND '#endDate#') AS PAC_Cause
 UNION ALL SELECT 'Post Abortion Care Service Availed', 0 ,0
 UNION ALL SELECT 'Post Abortion complications', 0 ,0
) final
GROUP BY final.`Safe Abortion Service`
ORDER BY final.`Safe Abortion Service`
;
