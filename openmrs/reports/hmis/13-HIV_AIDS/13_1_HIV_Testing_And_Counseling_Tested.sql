SELECT 
entries .age AS 'HTC Programme-Tested',	
		SUM(entries.`Sex worker-M`) AS 'Sex worker-M',
        SUM(entries.`Sex worker-F`) AS 'Sex worker-F',		
        SUM(entries.`Sex worker-TG`) AS 'Sex worker-TG',
        SUM(entries.`Who Inject Drugs-M`) AS 'Who Inject Drugs-M',
		SUM(entries.`Who Inject Drugs-F`) AS 'Who Inject Drugs-F',		
        SUM(entries.`Who Inject Drugs-TG`) AS 'Who Inject Drugs-TG',		
        SUM(entries.`MSM and transgenders-M`) AS 'MSM and transgenders-M',
		SUM(entries.`MSM and transgenders-F`) AS 'MSM and transgenders-F',
		SUM(entries.`MSM and transgenders-TG`) AS 'MSM and transgenders-TG',
		SUM(entries.`Blood/Organ Recipient-M`) AS 'Blood/Organ Recipient-M',
		SUM(entries.`Blood/Organ Recipient-F`) AS 'Blood/Organ Recipient-F',		
        SUM(entries.`Blood/Organ Recipient-TG`) AS 'Blood/Organ Recipient-TG',
		SUM(entries.`Client of Sex worker-M`) AS 'Client of Sex worker-M',
		SUM(entries.`Client of Sex worker-F`) AS 'Client of Sex worker-F',		
        SUM(entries.`Client of Sex worker-O`) AS 'Client of Sex worker-O',		
        SUM(entries.`Migrant- M`) AS 'Migrant- M',
		SUM(entries.`Migrant- F`) AS 'Migrant- F',
        SUM(entries.`Migrant- TG`) AS 'Migrant- TG',
        SUM(entries.`Spouse of Migrant- M`) AS 'Spouse of Migrant- M',
		SUM(entries.`Spouse of Migrant- F`) AS 'Spouse of Migrant- F',
        SUM(entries.`Spouse of Migrant- TG`) AS 'Spouse of Migrant- TG',
        SUM(entries.`Others-M`) AS 'Others-M',
		SUM(entries.`Others-F`) AS 'Others-F',		        
        SUM(entries.`Others-TG`) AS 'Others-TG'
    
FROM
(SELECT age,
SUM(IF( report.risk_group = 'Sex worker' && report.gender = 'M',1,0)) AS 'Sex worker-M',
		SUM(IF(report.risk_group = 'Sex worker' && report.gender = 'F',1,0)) AS 'Sex worker-F',		
        SUM(IF(report.risk_group = 'Sex worker' && report.gender = 'O',1,0)) AS 'Sex worker-TG',
        SUM(IF(report.risk_group = 'People who inject drugs' && report.gender = 'M',1,0)) AS 'Who Inject Drugs-M',
		SUM(IF(report.risk_group = 'People who inject drugs' && report.gender = 'F',1,0)) AS 'Who Inject Drugs-F',		
        SUM(IF(report.risk_group = 'People who inject drugs' && report.gender = 'O',1,0)) AS 'Who Inject Drugs-TG',		
        SUM(IF(report.risk_group = 'MSM and transgenders' && report.gender = 'M',1,0)) AS 'MSM and transgenders-M',
		SUM(IF(report.risk_group = 'MSM and transgenders' && report.gender = 'F',1,0)) AS 'MSM and transgenders-F',
		SUM(IF( report.risk_group = 'MSM and transgenders' && report.gender = 'O',1,0)) AS 'MSM and transgenders-TG',
		SUM(IF( report.risk_group = 'Blood or organ recipient' && report.gender = 'M',1,0)) AS 'Blood/Organ Recipient-M',
		SUM(IF( report.risk_group = 'Blood or organ recipient' && report.gender = 'F',1,0)) AS 'Blood/Organ Recipient-F',		
        SUM(IF( report.risk_group = 'Blood or organ recipient' && report.gender = 'O',1,0)) AS 'Blood/Organ Recipient-TG',
		SUM(IF( report.risk_group = 'Client of Sex worker' && report.gender = 'M',1,0)) AS 'Client of Sex worker-M',
		SUM(IF( report.risk_group = 'Client of Sex worker' && report.gender = 'F',1,0)) AS 'Client of Sex worker-F',		
        SUM(IF(report.risk_group = 'Client of Sex worker' && report.gender = 'O',1,0)) AS 'Client of Sex worker-O',		
        SUM(IF( report.risk_group = 'Migrant' && report.gender = 'M',1,0)) AS 'Migrant- M',
		SUM(IF( report.risk_group = 'Migrant' && report.gender = 'F',1,0)) AS 'Migrant- F',
        SUM(IF( report.risk_group = 'Migrant' && report.gender = 'O',1,0)) AS 'Migrant- TG',
        SUM(IF( report.risk_group = 'Spouse of migrant' && report.gender = 'M',1,0)) AS 'Spouse of Migrant- M',
		SUM(IF(report.risk_group = 'Spouse of migrant' && report.gender = 'F',1,0)) AS 'Spouse of Migrant- F',
        SUM(IF( report.risk_group = 'Spouse of migrant' && report.gender = 'O',1,0)) AS 'Spouse of Migrant- TG',
        SUM(IF( report.gender = 'M' &&  report.risk_group='Others'  ,1,0)) AS 'Others-M',
		SUM(IF(report.gender = 'F' &&  report.risk_group='Others' ,1,0)) AS 'Others-F',		        
        SUM(IF( report.gender = 'O' &&  report.risk_group='Others' ,1,0)) AS 'Others-TG'
FROM
(SELECT 
       DISTINCT
        patients.pid as ppid,
        tested_before.tid as ttid,
            tested_before.gend as gender,
            patients.risk_group,
            IF(TIMESTAMPDIFF(YEAR, tested_before.birthdate, tested_before.startdate) <= 14, '≤ 14 Years', '> 15 years') AS age

    FROM
      (SELECT 
        person.person_id as pid,
            risk_group_values.concept_full_name AS risk_group,
            visit.date_started
    FROM
        visit
    JOIN encounter ON visit.visit_id = encounter.visit_id
        AND DATE(encounter.encounter_datetime) BETWEEN '#startdate#' AND '#enddate#'
    INNER JOIN obs AS risk_group ON risk_group.encounter_id = encounter.encounter_id
        AND risk_group.voided = 0
    INNER JOIN concept_view ON risk_group.concept_id = concept_view.concept_id
        AND concept_view.concept_full_name = 'HTC-Risk group'
    INNER JOIN concept_view AS risk_group_values ON risk_group.value_coded = risk_group_values.concept_id
    INNER JOIN person ON risk_group.person_id = person.person_id) AS patients
    LEFT OUTER JOIN (
    SELECT 
        person.person_id as tid,
        person.gender as gend,
		visit.date_started as startdate,
        person.birthdate as birthdate,
		value_tested.concept_full_name AS previous_test_result
    FROM
        visit
    JOIN encounter ON visit.visit_id = encounter.visit_id
        AND DATE(encounter.encounter_datetime) BETWEEN '#startdate#' AND '#enddate#'
    INNER JOIN obs AS previously_tested ON previously_tested.encounter_id = encounter.encounter_id
        AND previously_tested.voided = 0
    INNER JOIN concept_view AS previously_tested_concept ON previously_tested.concept_id = previously_tested_concept.concept_id
        AND previously_tested_concept.concept_full_name = 'HTC-Informed consent'
    INNER JOIN concept_view AS value_tested ON value_tested.concept_id = previously_tested.value_coded
    INNER JOIN person ON previously_tested.person_id = person.person_id
    ) 
    AS tested_before ON patients.pid = tested_before.tid
  )AS report 
   group by report .age
   UNION ALL SELECT '≤ 14 Years',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
UNION ALL SELECT '> 15 years',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
)entries
Group BY entries .age desc

;
