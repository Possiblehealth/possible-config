SELECT
    final.`Age Group` AS 'Age Group',
    final.`Sex` AS 'Sex',
    final.`Children at End of Last Month` AS 'Children at End of Last Month',
    SUM(final.`New Admission`) AS 'New Admission',
    SUM(final.`Re-admission`) AS 'Re-admission',
    SUM(final.`Transfer In`) AS 'Transfer In',
    SUM(final.`Discharge - Recovered`) AS 'Discharge - Recovered',
    SUM(final.`Discharge - Death`) AS 'Discharge - Death',
    SUM(final.`Discharge - Defaulter`) AS 'Discharge - Defaulter',
    SUM(final.`Discharge - Not Improved`) AS 'Discharge - Not Improved',
    SUM(final.`Discharge - Refer to Hospital`) AS 'Discharge - Refer to Hospital',
    SUM(final.`Transfer Out`) AS 'Transfer Out',
    (SUM(final.`Children at End of Last Month`) + SUM(final.`New Admission`) + SUM(final.`Re-admission`) + SUM(final.`Transfer In`) - SUM(final.`Discharge - Recovered`) - SUM(final.`Discharge - Death`) - SUM(final.`Discharge - Defaulter`) - SUM(final.`Discharge - Not Improved`) - SUM(final.`Discharge - Refer to Hospital`) - SUM(final.`Transfer Out`)) AS 'Children at End of This Month'
    FROM
        (SELECT 
            withoutDefaulters.*,
                defaultersCount.Count AS 'Discharge - Defaulter'
        FROM
            (SELECT
            IF(age < 6, '< 6 month', '6-59 month') AS 'Age Group',
                gender AS 'Sex',
                (CASE
                    WHEN age < 6 AND gender = 'F' THEN femaleLessThanSix
                    WHEN age < 6 AND gender = 'M' THEN maleLessThanSix
                    WHEN age > 6 AND gender = 'F' THEN femaleMoreThanSix
                    WHEN age > 6 AND gender = 'M' THEN maleMoreThanSix
                    ELSE 0
                END) AS 'Children at End of Last Month',
                SUM(IF(adtType = 'NEW', 1, 0)) AS 'New Admission',
                SUM(IF(adtType = 'Defaulter – DF', 1, 0)) AS 'Re-admission',
                SUM(IF(adtType = 'Transfer In', 1, 0)) AS 'Transfer In',
                SUM(IF(adtType = 'Recovered', 1, 0)) AS 'Discharge - Recovered',
                SUM(IF(adtType = 'Death', 1, 0)) AS 'Discharge - Death',
                SUM(IF(adtType = 'Not Improved', 1, 0)) AS 'Discharge - Not Improved',
                SUM(IF(adtType = 'IMAM, Refer to Hospital', 1, 0)) AS 'Discharge - Refer to Hospital',
                SUM(IF(adtType = 'Transfer Out - TO', 1, 0)) AS 'Transfer Out',
                0 AS 'Children at End of This Month'
        FROM
            (SELECT
            TIMESTAMPDIFF(MONTH, p.birthdate, v.date_started) AS age,
                oAdtType.answer_full_name AS adtType,
                p.gender AS gender,
                im.female_less_than_six AS femaleLessThanSix,
                im.male_less_than_six AS maleLessThanSix,
                im.female_more_than_six AS femaleMoreThanSix,
                im.male_more_than_six AS maleMoreThanSix,
                IF(oAdtType.obs_datetime >= DATE('#startDate#'), p.person_id, NULL) thisMonthPatient,
                IF(oAdtType.obs_datetime < DATE('#startDate#'), p.person_id, NULL) lastMonthPatient
        FROM
            person p
        JOIN visit v ON p.person_id = v.patient_id
        JOIN encounter e ON v.visit_id = e.visit_id
        JOIN nonVoidedQuestionAnswerObs oAdtType ON e.encounter_id = oAdtType.encounter_id
        INNER JOIN imam im ON 1 = 1
        WHERE
            ! p.voided AND ! v.voided AND ! e.voided
                AND DATE(oAdtType.obs_datetime) BETWEEN DATE_SUB(DATE('#startDate#'), INTERVAL 1 MONTH) AND DATE('#endDate#')
                AND TIMESTAMPDIFF(MONTH, p.birthdate, v.date_started) < 60
                AND oAdtType.question_full_name IN ('Admission Type' , 'Status At Discharge')
                ) IMAM
        GROUP BY `Age Group` , `Sex`
        ) AS withoutDefaulters
        LEFT JOIN (SELECT 
            COUNT(DISTINCT t3.patient_id) AS `Count`,
                IF(TIMESTAMPDIFF(MONTH, p.birthdate, v.date_started) < 6, '< 6 month', '6-59 month') AS 'Age Group',
                p.gender AS `Sex`
        FROM
            nonVoidedQuestionAnswerObs prevObs
        LEFT JOIN nonVoidedQuestionAnswerObs currentObs ON currentObs.person_id = prevObs.person_id
            AND currentObs.obs_datetime <= DATE_ADD(prevObs.obs_datetime, INTERVAL 28 DAY)
            AND currentObs.obs_datetime > prevObs.obs_datetime
            AND DATE(currentObs.obs_datetime) <= '#endDate#'
            AND currentObs.question_full_name = 'Admission Type'
        INNER JOIN patient_identifier t3 ON prevObs.person_id = t3.patient_id
            AND t3.identifier_type = 3
            AND ! t3.voided
        INNER JOIN encounter e ON e.encounter_id = prevObs.encounter_id
            AND ! e.voided
        INNER JOIN visit v ON v.visit_id = e.visit_id AND ! v.voided
        INNER JOIN person p ON p.person_id = prevObs.person_id
            AND ! p.voided
        WHERE
            currentObs.obs_id IS NULL
                AND prevObs.obs_datetime >= DATE_SUB('#startDate#', INTERVAL 28 DAY)
                AND DATE(prevObs.obs_datetime) <= DATE_SUB('#endDate#', INTERVAL 28 DAY)
                AND prevObs.question_full_name = 'Admission Type'
                AND TIMESTAMPDIFF(MONTH, p.birthdate, v.date_started) < 60
        GROUP BY `Age Group` , `Sex`) AS defaultersCount ON defaultersCount.Sex = withoutDefaulters.Sex
            AND withoutDefaulters.`Age Group` = defaultersCount.`Age Group` 
            UNION ALL SELECT '< 6 month', 'F', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
            UNION ALL SELECT '< 6 month', 'M', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
            UNION ALL SELECT '< 6 month', 'O', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
            UNION ALL SELECT '6-59 month', 'F', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
            UNION ALL SELECT '6-59 month', 'M', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
            UNION ALL SELECT '6-59 month', 'O', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) final
    GROUP BY final.`Age Group` , final.`Sex`
    ORDER BY final.`Age Group` DESC;
