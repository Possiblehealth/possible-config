SELECT 
  gender.gender as gender, 
  count(person) as count_minor_surgeries 
FROM 
  (
    SELECT 
      'M' AS gender 
    UNION 
    SELECT 
      'F' AS gender
  ) gender 
  LEFT JOIN (
    SELECT 
      o.person_id as person, 
      p.gender as gender, 
      va.value_reference as visit_type, 
      e.encounter_datetime 
    FROM 
      obs o 
      INNER JOIN concept_name cn1 ON o.concept_id = cn1.concept_id 
      AND cn1.concept_name_type = 'FULLY_SPECIFIED' 
      AND cn1.name = 'Procedure-Procedure' 
      AND o.voided = 0 
      AND cn1.voided = 0 
      INNER JOIN encounter e ON o.encounter_id = e.encounter_id 
      INNER JOIN visit v ON v.visit_id = e.visit_id 
      INNER JOIN visit_attribute on v.visit_id = visit_attribute.visit_id 
      INNER JOIN visit_attribute AS va ON va.visit_id = v.visit_id 
      AND va.value_reference = 'IPD' 
      INNER JOIN person p ON o.person_id = p.person_id 
      AND p.voided = 0 
      AND DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
    group by 
      e.encounter_datetime
  ) a ON a.gender = gender.gender 
GROUP BY 
  gender.gender 
order by 
  gender.gender;
