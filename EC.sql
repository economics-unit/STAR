select top 100 Der_AEA_Diagnosis_All, [DQ_Primary_Diagnosis_Completed]
from [dbo].[tbl_Data_SUS_EC]
where Der_AEA_Diagnosis_All IS NOT NULL


USE NHSE_SUSPlus_Live



---- SNOMED CODES -----

--- used table to look at coding across all of Northampton ---
DROP TABLE IF EXISTS NHSE_Sandbox.temp.COPD_snomed 
CREATE TABLE NHSE_Sandbox.temp.COPD_snomed 
(snomed_ct NVARCHAR(20) NULL)
INSERT INTO NHSE_Sandbox.temp.COPD_snomed 
VALUES 
-- COPD https://snomedbrowser.com/Codes/Details/13645005 -- 
('195951007'),('13645005'),('47938003'), ('106001000119101'), ('196001008') ,('135836000'),('313296004'), ('313297008')
,('313299006') , ('293991000000106'),
--Dsyponea https://snomedbrowser.com/Codes/Details/267036007
('267036007'), ('39950000'), ('161941007'), ('60845006'), ('17216000'), ('72365000'), ('73322006'), ('23141003'),('25209001'),('852051000000107'), 
('391124000'), ('391125004'), ('391126003'), ('407588003')

-- EXPLORATORY ANALYSIS OF CODING ---


select count(DISTINCT ec.EC_Ident),
sum(cost.Tariff_Total_Payment),
diag.EC_Diagnosis_01
from [dbo].[tbl_Data_SUS_EC] as ec
left join [dbo].[tbl_Data_SUS_EC_2122_Cost]as cost
on cost.EC_Ident = ec.EC_Ident
left join [dbo].[tbl_Data_SUS_EC_Diagnosis] as diag
on diag.EC_Ident = ec.EC_Ident
WHERE  diag.EC_Diagnosis_01 IN (select snomed_ct from NHSE_Sandbox.temp.COPD_snomed) OR 
diag.EC_Diagnosis_02 IN (select snomed_ct from NHSE_Sandbox.temp.COPD_snomed) AND
ec.Der_Financial_Year = '2021/22' AND
GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox.temp.GP_List
group by diag.EC_Diagnosis_01

/* main records for COPD and AECOPD - therefore are taking these forward to final analysis */
---NOTE initial look suggests ~500,000 records for only 15,000 people with COPD in Northants. Must be some duplication? ---


---FINAL CODE ---

DROP TABLE IF EXISTS NHSE_Sandbox.temp.EC
SELECT 
cost.Tariff_Total_Payment,
ec.ec_ident,
diag.EC_Diagnosis_01,
GP.ICP_Name,
Der_Provider_Code,
EC.Der_Provider_Site_Code
INTO NHSE_Sandbox.temp.EC
FROM [dbo].[tbl_Data_SUS_EC] as ec
left join [dbo].[tbl_Data_SUS_EC_2122_Cost]as cost
on cost.EC_Ident = ec.EC_Ident 
left join [dbo].[tbl_Data_SUS_EC_Diagnosis] as diag
on diag.EC_Ident = ec.EC_Ident
left join NHSE_Sandbox.temp.GP_List as gp
ON ec.GP_Practice_Code = gp.GP_code
WHERE (diag.EC_Diagnosis_01 = '13645005' OR diag.EC_Diagnosis_01 = '195951007') AND
--diag.EC_Diagnosis_02 = '13645005' OR diag.EC_Diagnosis_02 = '195951007' AND
ec.Der_Financial_Year = '202122' AND
ec.GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox.temp.GP_List)


select 
	count (DISTINCT ec_ident),
	sum(Tariff_Total_Payment),
	ICP_Name
from NHSE_Sandbox.temp.EC
Group by ICP_Name










