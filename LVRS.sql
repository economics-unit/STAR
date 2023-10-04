SE NHSE_SUSPlus_Live

DROP TABLE IF EXISTS NHSE_Sandbox.temp.area_LVRS
SELECT APCS_Ident, 
	Der_Procedure_All,
	GP_Practice_Code,
	Der_Diagnosis_All, 
	Der_Financial_Year
	INTO NHSE_Sandbox.temp.area_LVRS
FROM [dbo].[tbl_Data_SEM_APCS]
WHERE Der_Procedure_All LIKE '%E546%' AND 
GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox.temp.Area_gp) AND
Der_Financial_Year = '2021/22'



SELECT 
	sum(cost.Tariff_Total_Payment) AS cost_spell,
	count(DISTINCT apcs.APCS_Ident)
from NHSE_Sandbox.temp.area_LVRS as APCS
LEFT JOIN 
	[dbo].[tbl_Data_SEM_APCS_2122_Cost] as cost 
	ON cost.APCS_Ident = APCS.APCS_Ident
	AND cost.Der_Financial_Year = apcs.Der_Financial_Year
where --APCS.Der_Procedure_All LIKE '%E546%' --AND 
(APCS.Der_Diagnosis_all LIKE '%J439%' OR APCS.Der_Diagnosis_all LIKE '%J438%') 



SELECT 
	sum(Tariff_Total_Payment) AS cost_spell,
	count(apcs.APCS_Ident)
from NHSE_Sandbox.temp.area_LVRS as APCS
LEFT JOIN 
	[dbo].[tbl_Data_SEM_APCS_2122_Cost] as cost 
	ON cost.APCS_Ident = APCS.APCS_Ident
	AND cost.Der_Financial_Year = apcs.Der_Financial_Year
LEFT JOIN NHSE_Sandbox.temp.Area_gp as GP
	ON GP_Practice_Code = GP.GP_code
where --APCS.Der_Procedure_All LIKE '%E546%' --AND 
(APCS.Der_Diagnosis_all LIKE '%J439%' OR APCS.Der_Diagnosis_all LIKE '%J438%')
