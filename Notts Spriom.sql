-- getting secondary care spirometry for Notts ---



USE NHSE_SUSPlus_Live


---- TOTAL COUNT ----

SELECT COUNT (DISTINCT OPA.OPA_Ident),
	Der_Attendance_Type,
	GP.ICP_Name,
	sum(Tariff_Total_Payment)
	--,Der_Provider_Code
	FROM [dbo].[tbl_Data_SEM_OPA] as OPA
	LEFT JOIN NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP as GP
	ON OPA.GP_Practice_Code = GP.GP_code
	LEFT JOIN  [dbo].[tbl_Data_SEM_OPA_2122_Cost] as cost 
	ON cost.OPA_Ident = OPA.OPA_Ident
	WHERE
		OPA.Der_Financial_Year = '2021/22' AND
		Der_Procedure_All LIKE '%E932%' AND
		GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
		group by Der_Attendance_Type, GP.ICP_Name

--- AVERAGE COST ----

SELECT COUNT (DISTINCT OPA.OPA_Ident),
	Der_Attendance_Type,
	ICP_Name,
	sum(Tariff_Total_Payment)
	--,Der_Provider_Code
	FROM [dbo].[tbl_Data_SEM_OPA] as OPA
	LEFT JOIN NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP as GP
	ON OPA.GP_Code = GP.GP_code
	LEFT JOIN  [dbo].[tbl_Data_SEM_OPA_2122_Cost] as cost 
	ON cost.OPA_Ident = OPA.OPA_Ident
	WHERE
		OPA.Der_Financial_Year = '2021/22' AND
		Der_Procedure_All LIKE '%E932%' AND
		Tariff_Total_Payment IS NOT NULL 
		GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
		group by Der_Attendance_Type, ICP_Name


