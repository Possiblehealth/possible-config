SELECT 
sum(final.c1) as 'Number of new cases in OPD and emergency',
sum(final.c2) as 'Number of Fever or acute respiratory symptoms',
sum(final.c3) as'No. of cases with Influenza Like Illness',
sum(final.c4) as 'Number of new cases hospitalized due to (SARI)',
sum(final.c5) as 'Number of death due to SARI',
sum(final.c6) as 'No. of cases with ILI/SARI sample collected/referred for influenza test',
sum(final.c7) as 'Number of Suspected',
sum(final.c8) as 'Number of isolated in hospital',
sum(final.c9) as 'Number of referred to other hospital',
sum(final.c10) as 'Number of Sample collected',
sum(final.c11) as 'Number of un-occupied Isolation beds'
FROM
-- --------------------------- No. of new cases in OPD and emergency--------------------------
(SELECT
SUM(total_opd_er) as c1,
0 as c2,
0 as c3,
0 as c4,
0 as c5,
0 as c6,
0 as c7,
0 as c8,
0 as c9,
0 as c10,
0 as c11
FROM
(SELECT 
       COUNT(DISTINCT(p.patient_id)) as total_opd_er
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Department Sent To')
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('OPD','Emergency ward')
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    INNER JOIN patient p ON p1.person_id = p.patient_id
	INNER JOIN visit v ON  p.patient_id = v.patient_id
    WHERE
        DATE(p.date_created) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_opd_er
-- --------------------------- Number of Fever or acute respiratory symptoms--------------------------
UNION ALL
SELECT
0,SUM(total_fever_acute_respiratory_symptoms) as c2,0,0,0,0,0,0,0,0,0
FROM    
(SELECT 
		count(distinct(o1.person_id)) as total_fever_acute_respiratory_symptoms
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Coded Diagnosis')
        INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('Fever, unspecified','Lower Respiratory Tract Infection',
        'Upper Respiratory Tract Infection','Pneumonia','Severe Pneumonia',
        'Bronchitis (Acute & Chronic)','SARI-Severe Acute Respiratory Infection')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_fever_acute_respiratory_symptoms
-- -------------------------- No. of cases with Influenza Like Illness'-- -------------------------- 
UNION ALL
SELECT
0,0,SUM(total_Influenza_Like_Illness) as c3,0,0,0,0,0,0,0,0
FROM    
(SELECT 
		count(distinct(o1.person_id)) as total_Influenza_Like_Illness
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Coded Diagnosis')
        INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('Acute nasopharyngitis (Common cold)','Fever, unspecified',
						'Cough','Myalgia')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
         DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_Influenza_Like_Illness
 -- -------------------------- Number of new cases hospitalized due to (SARI) -- --------------------------
UNION ALL
SELECT
0,0,0,SUM(total_SARI) as c4,0,0,0,0,0,0,0
FROM    
(SELECT 
		count(distinct(o1.person_id)) as total_SARI
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Coded Diagnosis')
	INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('SARI-Severe Acute Respiratory Infection')
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    INNER JOIN patient p ON p1.person_id = p.patient_id
	INNER JOIN visit v ON  p.patient_id = v.patient_id
    INNER JOIN visit_attribute AS va ON va.visit_id = v.visit_id AND va.value_reference = 'IPD'
	INNER JOIN visit_attribute_type vat ON vat.visit_attribute_type_id = va.attribute_type_id 
    AND vat.name = 'Visit Status' 
    WHERE
         DATE(v.date_started) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_SARI
-- -------------------------- Number of death due to SARI -- --------------------------
UNION ALL
SELECT
0,0,0,0,SUM(total_SARI_death) as c5,0,0,0,0,0,0
FROM    
(SELECT count(distinct(second.sari) ) as total_SARI_death
FROM
(SELECT 
      o1.person_id as death
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Death note-Death type')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#'))as first
        LEFT OUTER JOIN
(SELECT 
		o1.person_id as sari
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Coded Diagnosis')
        INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('SARI-Severe Acute Respiratory Infection')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#'))as second ON second.sari=first.death) as total_SARI_death
-- --------------------------No. of cases with ILI/SARI sample collected/referred for influenza test-- --------------------------
UNION ALL
SELECT
0,0,0,0,0,SUM(total_sample_collected) as c6,0,0,0,0,0
FROM    
(SELECT 
        count(DISTINCT o1.person_id) as total_sample_collected
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Coivd-Sample collected')
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('Yes')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_sample_collected
-- --------------------------total_suspected---------------------
UNION ALL
SELECT
0,0,0,0,0,0,SUM(total_suspected) as c7,0,0,0,0
FROM
(SELECT 
     DISTINCT  count(o1.person_id) as total_suspected
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Covid-Suspection')
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('Yes')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_suspected
-- --------------------------Number of isolated in hospital-- -------------------------
UNION ALL
SELECT
0,0,0,0,0,0,0,SUM(total_isolation) as c8,0,0,0
FROM
(SELECT 
       count(DISTINCT(o1.person_id)) as total_isolation
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Covid-Management')
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
	AND cn2.name IN ('Covid-Admission')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_isolation
-- --------------------------referred to other hospital---------------------
UNION ALL
SELECT
0,0,0,0,0,0,0,0,SUM(total_referred) as c9,0,0
FROM
(SELECT count(distinct(second.referred) ) as total_referred
FROM
(SELECT 
      o1.person_id as symptom
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Covid-Symptoms')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#'))as first
        LEFT OUTER JOIN
(SELECT 
		o1.person_id as referred
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Disposition')
        INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('Referred for Investigations','Referred for Further Care')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#'))as second ON second.referred=first.symptom) as total_referred
-- ---------------------total_sample-------------------------
UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,SUM(total_sample) as c10,0
FROM
(SELECT 
        DISTINCT count(o1.person_id) as total_sample
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Coivd-Sample collected')
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('Yes')
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
         DATE(e.encounter_datetime) BETWEEN DATE('#startDate#') AND DATE('#endDate#')) as total_sample
-- ---------------------Number of un-occupied Isolation beds-------------------------
UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,SUM(total_unoccupied_bed) as c11
FROM
(SELECT count(*) as total_unoccupied_bed
FROM bed b
JOIN bed_location_map blm on b.bed_id = blm.bed_id
JOIN location l on l.location_id = blm.location_id
AND l.name IN('Covid Isolation Ward','Isolation Ward') 
WHERE b.status = 'AVAILABLE') as total_unoccupied_bed
) final
