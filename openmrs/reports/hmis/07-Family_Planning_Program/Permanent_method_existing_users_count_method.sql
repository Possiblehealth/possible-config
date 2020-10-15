SELECT 
  SUM(new_continue.new_female)+ SUM(new_continue.prev_female)+ SUM(new_continue.tubectomy) AS continous_female, 
  SUM(new_continue.new_male)+ SUM(new_continue.prev_male) AS continous_male 
FROM 
  (
    SELECT 
      sum(final.new_female) as 'new_female', 
      sum(final.new_male) as 'new_male', 
      sum(final.prev_female) as 'prev_female', 
      sum(final.prev_male) as 'prev_male', 
      sum(final.tubectomy) as 'tubectomy' 
    FROM 
      -- --------------------------- No. of new permanent--------------------------
      (
        SELECT 
          IFNULL(
            SUM(
              CASE WHEN new_month.gender = 'F' THEN 1 ELSE 0 END
            ), 
            0
          ) AS new_female, 
          IFNULL(
            SUM(
              CASE WHEN new_month.gender = 'M' THEN 1 ELSE 0 END
            ), 
            0
          ) AS new_male, 
          0 as prev_female, 
          0 as prev_male, 
          0 as tubectomy 
        FROM 
          (
            SELECT 
              DISTINCT o1.person_id, 
              p1.gender, 
              cn2.concept_id AS answer, 
              cn1.concept_id AS question 
            FROM 
              obs o1 
              INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id 
              AND cn1.concept_name_type = 'FULLY_SPECIFIED' 
              AND cn1.name in (
                'FRH-Long acting and permanent method', 
                'FRH-New method chosen'
              ) 
              AND o1.voided = 0 
              AND cn1.voided = 0 
              INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id 
              AND cn2.concept_name_type = 'FULLY_SPECIFIED' 
              And cn2.name in ('Vasectomy', 'Minilap') 
              AND cn2.voided = 0 
              INNER JOIN encounter e ON o1.encounter_id = e.encounter_id 
              INNER JOIN visit v1 ON v1.visit_id = e.visit_id 
              INNER JOIN person p1 ON o1.person_id = p1.person_id 
            WHERE 
              DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
          ) new_month 
                
-- --------------------------- No. of old permanent--------------------------

        UNION ALL 
        SELECT 
          0, 
          0, 
          prev_female, 
          prev_male, 
          0 
        FROM 
          (
            select 
              contiFemale_user as prev_female, 
              contiMale_user as prev_male 
            from 
              familyPlanning
          ) as pre_month 
-- --------------------------- No. of tubectomy-------------------------

        UNION ALL 
        SELECT 
          0, 
          0, 
          0, 
          0, 
          SUM(tubectomy_patient) as tubectomy 
        FROM 
          (
            SELECT 
              COUNT(
                DISTINCT(o1.person_id)
              ) as tubectomy_patient 
            FROM 
              obs o1 
              INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id 
              AND cn1.concept_name_type = 'FULLY_SPECIFIED' 
              AND cn1.name in (
                'Discharge-Contraceptive Chosen'
              ) 
              AND o1.voided = 0 
              AND cn1.voided = 0 
              INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id 
              AND cn2.concept_name_type = 'FULLY_SPECIFIED' 
              And cn2.name in ('Tubectomy') 
              AND cn2.voided = 0 
              INNER JOIN encounter e ON o1.encounter_id = e.encounter_id 
              INNER JOIN visit v1 ON v1.visit_id = e.visit_id 
              INNER JOIN person p1 ON o1.person_id = p1.person_id 
            WHERE 
              DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
          ) as tubectomy_patient
      ) final
  ) new_continue;

