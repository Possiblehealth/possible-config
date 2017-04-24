SELECT
  final.BirthWeight AS 'Birth Weight',
  sum(final.TotalNo) AS 'Total No',
  sum(final.Asphyxia) AS Asphyxia,
  sum(final.Defect) AS Defect,
  sum(final.Others) AS Others
FROM
-- ----------------------------------------------
(SELECT T1.Weight_Category AS BirthWeight,
Sum(IF(InfantStatus IN ('Others','Defect','Asphyxia'), 1, 0)) AS TotalNo,
Sum(IF(InfantStatus = 'Asphyxia', 1, 0)) AS Asphyxia,
Sum(IF(InfantStatus = 'Defect', 1, 0)) AS Defect,
Sum(IF(InfantStatus = 'Others', 1, 0)) AS Others
FROM
(SELECT
InfantBirthWeights.Weight_Category,
InfantBirthStatus.InfantStatus
FROM
(SELECT t1.encounter_id,CASE
WHEN t1.value_numeric < 2000 THEN 'Very low (< 2 kg)'
WHEN t1.value_numeric >= 2000 AND t1.value_numeric < 2500 THEN 'Low (2 to < 2.5 kg)'
ELSE 'Normal (>= 2.5 kg)'
END AS Weight_Category
FROM obs t1
INNER JOIN encounter t3 ON t1.encounter_id = t3.encounter_id
INNER JOIN visit t4 ON t3.visit_id = t4.visit_id
INNER JOIN concept_name t5 ON t1.concept_id = t5.concept_id AND t5.voided = 0
AND t5.concept_name_type = 'FULLY_SPECIFIED'
WHERE t5.name IN ('Delivery Note, Liveborn weight')
AND t1.voided = 0 AND
(t1.obs_datetime >='#startDate#' AND t1.obs_datetime <= '#endDate#')) AS InfantBirthWeights
INNER JOIN
(SELECT t1.encounter_id, CASE
WHEN t2.name = 'Asphyxiated' THEN 'Asphyxia'
WHEN t2.name NOT IN ('Normal','Asphyxiated','Stillbirth', 'Jaundice', 'New born status, Hypothermia') THEN 'Defect'
ELSE 'Others'
END
AS InfantStatus FROM obs t1
INNER JOIN concept_name t2 ON t1.value_coded = t2.concept_id
AND t2.voided = 0 AND t2.concept_name_type = 'FULLY_SPECIFIED' AND t2.Name <> 'Stillbirth'
INNER JOIN encounter t3 ON t1.encounter_id = t3.encounter_id
INNER JOIN visit t4 ON t3.visit_id = t4.visit_id
INNER JOIN concept_name t5 ON t1.concept_id = t5.concept_id AND t5.voided = 0
AND t5.concept_name_type = 'FULLY_SPECIFIED'
WHERE t5.name IN ('Delivery Note, New Born Status')
AND t1.voided = 0 AND
(t1.obs_datetime >='#startDate#' AND t1.obs_datetime <= '#endDate#')) AS InfantBirthStatus
ON InfantBirthWeights.encounter_id = InfantBirthStatus.encounter_id) AS T1
GROUP BY T1.Weight_Category
-- ----------------------------------------------
UNION ALL SELECT 'Normal (>= 2.5 kg)',0,0,0,0
UNION ALL SELECT 'Low (2 to < 2.5 kg)',0,0,0,0
UNION ALL SELECT 'Very low (< 2 kg)',0,0,0,0
)final
GROUP BY final.BirthWeight
ORDER BY CASE final.BirthWeight
WHEN 'Normal (>= 2.5 kg)' THEN 1
WHEN 'Low (2 to < 2.5 kg)' THEN 2
ELSE 3 END;
