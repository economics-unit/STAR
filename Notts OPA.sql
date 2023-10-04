/*OPA code for Notts.  */
-- has been QA'ed
-- uses strategy_unit analysis to identify initial opinion or structured review OPAs https://www.midlandsdecisionsupport.nhs.uk/wp-content/uploads/2021/10/dsu_classify_op_appendix_v0.1.pdf


DROP TABLE IF EXISTS NHSE_Sandbox_HEU.temp.Notts_OPAFIRST
    CREATE TABLE NHSE_Sandbox_HEU.temp.Notts_OPAFIRST
        (
        [OPA_Ident] BIGINT,
        [Der_Pseudo_NHS_Number] BIGINT,
        [Appointment_Date] datetime,
        [Der_Attendance_Type] varchar(12),
        [Der_Provider_Code] varchar(5))



   INSERT INTO NHSE_Sandbox_HEU.temp.Notts_OPAFIRST
    SELECT OPA_Ident
    ,[Der_Pseudo_NHS_Number]e
    ,[Appointment_Date]
    ,Der_Attendance_Type
    ,Der_Provider_Code
    FROM
    (
SELECT ROW_NUMBER() OVER(PARTITION BY [Der_Pseudo_NHS_Number] ORDER BY [Appointment_Date] ASC) AS OP_ORDER
    , OPA_Ident
    ,Der_Pseudo_NHS_Number
    ,Appointment_Date
    ,Der_Attendance_Type
	, Local_Patient_ID
    ,Der_Provider_Code
    FROM [dbo].[tbl_Data_SEM_OPA] as OPA
    WHERE
    OPA.Der_Financial_Year = '2021/22' AND
      (Treatment_Function_Code = '340'
    OR Der_Procedure_All LIKE '%E9%'
    OR Der_Procedure_All LIKE '%R36%'
    OR Der_Procedure_All LIKE '%R37%'
    OR Der_Procedure_All LIKE '%R42%'
    OR Der_Procedure_All LIKE '%B32%'
    OR Der_Procedure_All LIKE '%X551%'
    OR Der_Procedure_All LIKE '%Q411%')
    AND GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
    AND Age_at_End_of_Episode_SUS >= 18
    AND Der_Pseudo_NHS_Number is not null
        ) as tb
where tb.OP_ORDER = 1



select 
count(OPA.OPA_ident),
sum(Tariff_Total_Payment) as total_cost
from NHSE_Sandbox_HEU.temp.Notts_OPAFIRST as OPA 
LEFT JOIN  [dbo].[tbl_Data_SEM_OPA_2122_Cost] as cost 
ON cost.OPA_Ident = OPA.OPA_Ident
LEFT JOIN [dbo].[tbl_Data_SEM_APCE] as APCE
ON Local_Patient_ID = APCE.LOCAL_Patient_ID
LEFT JOIN NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP AS GP
ON GP.GP_code = GP_Practice_Code
WHERE APCE.Der_Diagnosis_All LIKE '%J44%' 
GROUP BY Der_Attendance_Type, gp.ICP_Name


