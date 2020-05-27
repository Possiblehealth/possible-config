SELECT 
SUM(c1)as protein_count,
SUM(final.c2) as other_bio_chemistry_count,
SUM(final.c3) as gm_stain_count,
SUM(final.c4) as body_fluid_culture_count,
SUM(final.c5) as body_fluid_afb_count,
SUM(final.c6) as TPHA_total,
SUM(final.c6p) as TPHA_Positive,
SUM(final.c6n) as TPHA_Negative,
SUM(final.c7) as Sugar_F,
SUM(final.c8) as Sugar_PP,
SUM(final.c9) as Sugar_R,
SUM(final.c10) as HIV_Total,
SUM(final.c10p) as HIV_Positive,
SUM(final.c10n) as HIV_Negative,
SUM(final.c11) as PT_INR,
SUM(final.c12) as Other_Hematology,
SUM(final.c13) as HBsAg_Total,
SUM(final.c13p) as HBsAg_Positive,
SUM(final.c13n) as HBsAg_Negative,
SUM(final.c14) as HCV_total,
SUM(final.c14p) as HCV_Postive,
SUM(final.c14n) as HCV_Negative,
SUM(final.c15) as CPK_NAC,
SUM(final.c16) as AFBsputum,
SUM(final.c16p) as AFBsputum_Positive
FROM
-- --------------------------- all protein--------------------------
(SELECT
SUM(total_count1) as c1,
0 as c2,
0 as c3,
0 as c4,
0 as c5,
0 as c6,
0 as c6p,
0 as c6n,
0 as c7,
0 as c8,
0 as c9,
0 as c10,
0 as c10p,
0 as c10n,
0 as c11,
0 as c12,
0 as c13,
0 as c13p,
0 as c13n,
0 as c14,
0 as c14p,
0 as c14n,
0 as c15,
0 as c16,
0 as c16p
FROM
(SELECT DISTINCT

  ts.name       AS dep,
  t.name        AS test,
  count(r.id)   AS total_count1,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('Protein (CSF)','Protein (Pericardial Fluid)','Protein (Pleural Fluid)','Total Protein')
 
GROUP BY ts.name, t.name, t.id
order by ts.name) as protein
-- --------------------------other bio-chemistry---------------------
UNION ALL
SELECT
0,SUM(total_count2) as c2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test2,
  count(r.id)   AS total_count2,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('ADA (Pleural_Fluid)','ADA (Peritoneal_Fluid)','ADA (Pericardial_Fluid)','ADA (Serum)','ADA (CSF)','ADA (Synovial Fluid)',
		'75g OGTT 2 hours','75g OGTT FASTING','75g OGTT','75g OGTT 1 hour','Chloride')
 
GROUP BY ts.name, t.name, t.id
order by ts.name) as other_bio_chemistry_count
-- ---------------------gm_stain-------------------------
UNION ALL
SELECT
0,0,SUM(total_count3) as c3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test3,
  count(r.id)   AS total_count3,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('Gram Stain (Blood)','Gram Stain (CSF)','Gram Stain (Pericardial Fluid)','Gram Stain (Pleural Fluid)','Gram Stain (Pus)',
  'Gram Stain (Semen)','Gram Stain (Serum)','Gram Stain (Slit Skin)','Gram Stain (Sputum)','Gram Stain (Stool)','Gram Stain (Urine)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as gm_stain
-- --------------body_fluid_culture------------------------------
UNION ALL
SELECT
0,0,0,SUM(total_count4) as c4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test4,
  count(r.id)   AS total_count4,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('Culture (Pericardial Fluid)','Culture (Peritoneal Fluid)','Culture (Pleural Fluid)','Culture (Synovial Fluid)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as body_fluid_culture
-- ----------------body_fluid_afb--------------------
UNION ALL
SELECT
0,0,0,0,SUM(total_count5) as c5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test5,
  count(r.id)   AS total_count5,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('AFB Stain (Blood)','AFB Stain (CSF)','AFB Stain (Pericardial Fluid)','AFB Stain (Pleural Fluid)','AFB Stain (Pus)',
  'AFB Stain (Semen)','AFB Stain (Serum)','AFB Stain (Stool)','AFB Stain (Urine)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as body_fluid_afb
-- ---------------------------TPHA--------------------------
UNION ALL
SELECT
0,0,0,0,0,SUM(total_count6) as c6,SUM(positive) as c6p, SUM(negative) as c6n,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test6,
  count(r.id)   AS total_count6,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('VDRL(TPHA) (Blood)','VDRL(TPHA) (Serum)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as TPHA
-- ----------------Sugar F--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,SUM(total_count7) as c7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test7,
  count(r.id)   AS total_count7,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('Blood Sugar Fasting','Glucose(F)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as Sugar_F
-- ----------------Sugar PP--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,SUM(total_count8) as c8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test8,
  count(r.id)   AS total_count8,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('Blood Sugar P.P','Glucose(P.P)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as Sugar_PP
-- ----------------Sugar R--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,SUM(total_count9) as c9,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test9,
  count(r.id)   AS total_count9,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('Blood Sugar Random','Glucose(R)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as Sugar_R
-- ----------------HIV--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,0,SUM(total_count10) as c10,SUM(positive) as c10p, SUM(negative) as c10n,0,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test10,
  count(r.id)   AS total_count10,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('HIV (Blood)','HIV (Serum)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as HIV
-- ----------------PT-INR--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,0,0,0,0,SUM(total_count11) as c11,0,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test11,
  count(r.id)   AS total_count11,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('PT','INR')

GROUP BY ts.name, t.name, t.id
order by ts.name) as PT_INR
-- ----------------Other Haematology--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SUM(total_count12) as c12,0,0,0,0,0,0,0,0,0
FROM
(SELECT DISTINCT
  ts.name       AS department,
  t.name        AS test12,
  count(r.id)   AS total_count12,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
 WHERE t.name IN ('Cross Match-major','Absolute Eosinophil Count')
GROUP BY ts.name, t.name, t.id
order by ts.name) as Other_Hematology
-- ----------------HBsAg--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SUM(total_count13) as c13,SUM(positive) as c13p, SUM(negative) as c13n,0,0,0,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test13,
  count(r.id)   AS total_count13,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('HBsAg (Serum)','HBsAg (Blood)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as HBsAg
-- ----------------HCV--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SUM(total_count14) as c14,SUM(positive) as c14p, SUM(negative) as c14n,0,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test14,
  count(r.id)   AS total_count14,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('HCV (Blood)','HCV (Serum)')

GROUP BY ts.name, t.name, t.id
order by ts.name) as HCV
-- ---------------CPK-NAC--------------------

UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SUM(total_count15) as c15,0,0
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test15,
  count(r.id)   AS total_count15,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('CK-NAC','CPK')

GROUP BY ts.name, t.name, t.id
order by ts.name) as CPK_NAC
-- ---------------AFB--------------------
UNION ALL
SELECT
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SUM(total_count16) as c16,SUM(positive) as c16p
FROM
(SELECT DISTINCT

  ts.name       AS department,
  t.name        AS test16,
  count(r.id)   AS total_count16,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r1.id) ELSE NULL END AS positive,
  CASE WHEN t.id IN (SELECT test_id FROM clinlims.test_result WHERE tst_rslt_type = 'D') THEN count(r2.id) ELSE NULL END AS negative
FROM clinlims.test_section ts
  INNER JOIN clinlims.test t ON ts.id = t.test_section_id AND t.is_active = 'Y'
  LEFT OUTER JOIN clinlims.analysis a ON t.id = a.test_id
  LEFT OUTER JOIN clinlims.result r ON a.id = r.analysis_id and cast(r.lastupdated as date) BETWEEN '#startDate#' AND '#endDate#'and r.value != ''
  LEFT OUTER JOIN clinlims.result r1 ON r1.result_type = 'D' and r1.value != '' and r.id=r1.id and r1.abnormal=true
  LEFT OUTER JOIN clinlims.result r2 on r2.result_type = 'D' and r2.value != '' and r.id=r2.id and r2.abnormal=false
  WHERE t.name IN ('AFB Sputum A','AFB Sputum B')

GROUP BY ts.name, t.name, t.id
order by ts.name) as AFBsputum
) final
