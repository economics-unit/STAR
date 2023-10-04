/******* HOSPITAL ADMISSIONS: COST AND ACTIVITY - Notts**********/ 
/* the purpose of this analysis is to evidence the number of hospital admissions
for AECOPD and the mean cost to feed into the STAR model as part of the Smarter 
Spending in Population Health Programme */
iated with people living in Coventry rather
than in the hospital themselves. */
USE NHSE_SUSPlus_Live


/********* GP PRACTICE CODES *********************************************/
/* GP practice codes for Coventry place where provided by an analyst working in Coventry City Council. */
/*these codes where then checked on ODS portal to make sure they were live over the relevant period (2020/21 to align to most rcent QOF prevelance)
Numbers of total AECOPD hospital admissions per GP practice where then sense checked here */

--running time: 02:08 min
DROP TABLE IF EXISTS NHSE_Sandbox_HEU.temp.Notts_AECOPD 

SELECT 
	GP_Practice_Code
	,APCS_Ident
	,CASE WHEN Der_Diagnosis_all LIKE '||J44%' then 'primary'+ SUBSTRING(Der_Diagnosis_all,3,4)
		WHEN Der_Diagnosis_all LIKE '||J40%' then 'primary'+ SUBSTRING(Der_Diagnosis_all,3,4)
		WHEN Der_Diagnosis_all LIKE '||J41%' then 'primary'+ SUBSTRING(Der_Diagnosis_all,3,4)
		WHEN Der_Diagnosis_all LIKE '||J42%' then 'primary'+ SUBSTRING(Der_Diagnosis_all,3,4)
		WHEN Der_Diagnosis_all LIKE '||J43%' then 'primary'+ SUBSTRING(Der_Diagnosis_all,3,4)
		WHEN Der_Diagnosis_all LIKE '%J440%' then 'J440'
		WHEN Der_Diagnosis_all LIKE '%J449%' then 'J449'
		WHEN Der_Diagnosis_all LIKE '%J441%' then 'J441' 
		WHEN Der_Diagnosis_all LIKE '%J22%' then 'J22'
	END AS COPD_Code
	--,NoofSpell  = count(APCS_Ident)

	INTO NHSE_Sandbox_HEU.temp.Notts_AECOPD 

FROM [dbo].[tbl_Data_SEM_APCS] 
WHERE
      APCS_Ident IS NOT NULL 
	  AND Der_Financial_Year = '2021/22' 
	  AND 
		(
		   Der_Diagnosis_all LIKE '%J44[019]%' 
		OR Der_Diagnosis_All LIKE '%J22%' 
		OR Der_Diagnosis_All LIKE '||J4%'
		) 
	  AND Der_Age_at_CDS_Activity_Date >=18
	  AND GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
	  AND Age_At_Start_of_Spell_SUS>=18  -- one record is excluded

SELECT GP_Practice_Code
	,COUNT(*)
FROM NHSE_Sandbox_HEU.temp.Notts_AECOPD 
GROUP BY GP_Practice_Code

/* There was no disparities between fingertips prevelance and AECOPDs that raised concerns about the use of the GP practice code */


/******************* TOTAL HOSPITAL ADMISSIONS for AECOPD *****************************************/
/* There are many ICD-10 codes that could relate to an AECOPD based upon different coding practises.
 */
/*this analysis compares two different coding strategies to identify AECOPD. 
--
--The first is the validated method used in paper by Rothnie et al.(https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5123723/) 
--Rothnie one looks at following codes at any position in the spell
--	AECOPD J440 OR J441
--	LRTI   J22
--	COPD   J449
--	hence, Der_Diagnosis_all LIKE '%J44[019]%' OR Der_Diagnosis_all LIKE '%J22%'
--
--
--the second uses the fingertips methodology (https://fingertips.phe.org.uk/search/COPD#page/6/gid/1938132888/pat/159/par/K02000001/ati/15/are/E92000001/iid/92302/age/202/sex/4/cat/-1/ctp/-1/yrr/1/cid/4/tbm/1)
--
--fingertips one is looking at Emergency hospital admissions for COPD (ICD-10: J40-J44) in adults aged 35+, hence
--	admission method = Emergency
--	primary diagnosis/subsequent diagnosis = J40-J44?  
--	AGE >=35 */ 


/**************ROTHNIE ET AL. ********************************************/
/** This analysis has used the strategy outlined in the paper by Rothnie et al. https://pubmed.ncbi.nlm.nih.gov/27920578/ 
which had a sensitivity of 87.5%.
 the strategy used in that paper was: a specific AECOPD or  LRTI  ICD-10  code  in  any  position  in  any  FCE,
or  the  COPD ICD-10 code in the first position only in any FCE in a hospitalization (sensitivity 87.5%).  This was coded as below: **/

SELECT DISTINCT
	CASE WHEN Der_Diagnosis_all LIKE '%J440%' then 'J440' -- LZ: This means the code J440 could appear as primary or subsequent diagnosis
	WHEN Der_Diagnosis_all LIKE '%J441%' then 'J441'
	WHEN Der_Diagnosis_all LIKE '%J449%' then 'J449' --LZ: This means the code J441 could appear as primary or subsequent diagnosis
	WHEN Der_Diagnosis_all LIKE '||J44%' then 'J44'  --LZ: any J44x except J440/J441 appears as primary diagnosis
	WHEN Der_Diagnosis_all LIKE '%J22%' then 'J22'
	ELSE 'different code'
	END AS COPD_Code,
	COUNT( DISTINCT APCS_Ident)
FROM [dbo].[tbl_Data_SEM_APCS]

WHERE
      APCS_Ident IS NOT NULL AND
	  Der_Financial_Year = '2021/22' AND  
	  GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
	  AND Der_Age_at_CDS_Activity_Date >=18
GROUP BY CASE WHEN Der_Diagnosis_all LIKE '%J440%' then 'J440'
	WHEN Der_Diagnosis_all LIKE '%J441%' then 'J441'
	WHEN Der_Diagnosis_all LIKE '%J449%' then 'J449'
	WHEN Der_Diagnosis_all LIKE '||J44%' then 'J44'
	WHEN Der_Diagnosis_all LIKE '%J22%' then 'J22'
	ELSE 'different code'
	END

	/* this method gives extraordinarily high numbers. Number is same as total COPD prevelence in Coventry. Have checked with other analysts. 
	Pragmatic solution is to remove J22 from the analysis */
	/************************ HRG code check ***************************************************/

	/* HRG code for AECOPD is Dz65, check to see how many records are not linked to correct HRG */
select [Spell_Core_HRG_SUS],
count(APCS_Ident)
from [dbo].[tbl_Data_SEM_APCS]
WHERE
      APCS_Ident IS NOT NULL 
	  AND Der_Financial_Year = '2021/22' 
	  AND [Spell_Core_HRG_SUS] NOT LIKE '%DZ65%' AND
	  Der_Diagnosis_All LIKE '||J44%'
	  AND Der_Age_at_CDS_Activity_Date >=18
	  AND GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
	  AND Age_At_Start_of_Spell_SUS>=18  -- one record is excluded
	  group by [Spell_Core_HRG_SUS]

/* only 50 or so not linked to correct HRG code, mostly other Dz codes */

/* Count of AECOPD admissions according to Rothnie et al. coding strategy is 2,537 for 2021/22 OF WHICH 1,346 are for the LRTI code */

/******************************* Fingertips *************************************/

/* fingertips uses a primary diagnosis is COPD J440 to J441 have done below for comparison with Rothnie et al.  */

SELECT count( DISTINCT APCS_Ident)
FROM NHSE_Sandbox_HEU.temp.Coventry_AECOPD
WHERE COPD_Code LIKE 'primaryJ44%'


/************************* COSTS OF AECOPD  *****************************************************/

/*using the above coding in rothnie et al, we first looked at the distribution of costs for an AECOPD in Notts */
/* This revealed a right skewed distribution, as is common with cost data with a large tail. As we plan to use the mean, the top 1%  of results were removed so that they do not affect the mean cost */

/* with the coding J44 any position */

SELECT 
	count(DISTINCT apcs.APCS_Ident),
	sum(cost.Tariff_Total_Payment) AS cost_spell,
	ICP_Name
FROM NHSE_Sandbox_HEU.temp.Notts_AECOPD AS apcs
	INNER JOIN [dbo].[tbl_Data_SEM_APCS_2122_Cost] AS cost 
		ON cost.APCS_Ident = apcs.APCS_Ident
		AND cost.Der_Financial_Year = '2021/22'
		AND cost.Tariff_Total_Payment IS NOT NULL
		LEFT JOIN NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP as GP
		ON apcs.GP_Practice_Code = GP.GP_code
WHERE apcs.COPD_Code LIKE '%J44[019]%' 
GROUP BY ICP_Name


/* FINAL CODE J44 in any position. */

DECLARE @cost_ref_roth FLOAT = 
	(
	SELECT MIN(Tariff_Total_Payment)
	FROM (
			SELECT 
				top(1) PERCENT WITH TIES -- choose the top 1% tariff total payment as the reference
				cost.Tariff_Total_Payment
			FROM NHSE_Sandbox_HEU.temp.Notts_AECOPD apcs
				INNER JOIN [dbo].[tbl_Data_SEM_APCS_2122_Cost] as cost 
					ON cost.APCS_Ident = apcs.APCS_Ident
					AND cost.Der_Financial_Year = '2021/22'
					AND cost.Tariff_Total_Payment IS NOT NULL
			WHERE apcs.COPD_Code LIKE '%J44[019]%'
			ORDER BY cost.Tariff_Total_Payment DESC
			)COST
		)

SELECT @cost_ref_roth

SELECT DISTINCT
	COUNT( DISTINCT apcs.APCS_Ident) AS spells_COPD_any,
	SUM(cost.Tariff_Total_Payment) AS cost_spell,
	ICP_Name
FROM NHSE_Sandbox_HEU.temp.Notts_AECOPD as apcs
	INNER JOIN [dbo].[tbl_Data_SEM_APCS_2122_Cost] as cost 
		ON cost.APCS_Ident = apcs.APCS_Ident
	LEFT JOIN NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP as GP
		ON apcs.GP_Practice_Code = GP.GP_code
WHERE
      apcs.APCS_Ident IS NOT NULL AND
	  GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
	AND apcs.COPD_Code LIKE '%J44[019]%'
	AND cost.Tariff_Total_Payment IS NOT NULL
	AND cost.Tariff_Total_Payment <= @cost_ref_roth
GROUP BY 
	ICP_Name




/* FINAL CODE FINGERTIPS */

DECLARE @cost_ref_fing FLOAT = 
	(
	SELECT MIN(Tariff_Total_Payment)
	FROM (
			SELECT 
				top(1) PERCENT WITH TIES -- choose the top 1% tariff total payment as the reference
				cost.Tariff_Total_Payment
			FROM NHSE_Sandbox_HEU.temp.Notts_AECOPD apcs
				INNER JOIN [dbo].[tbl_Data_SEM_APCS_2122_Cost] as cost 
					ON cost.APCS_Ident = apcs.APCS_Ident
					AND cost.Der_Financial_Year = '2021/22'
					AND cost.Tariff_Total_Payment IS NOT NULL
			WHERE COPD_Code LIKE 'primaryJ4%'
			ORDER BY cost.Tariff_Total_Payment DESC
			)COST
		)

SELECT @cost_ref_fing
SELECT DISTINCT
	COUNT( DISTINCT apcs.APCS_Ident) AS spells_COPD_any,
	SUM(cost.Tariff_Total_Payment) AS cost_spell,
	ICP_Name
FROM NHSE_Sandbox_HEU.temp.Notts_AECOPD as apcs
	INNER JOIN [dbo].[tbl_Data_SEM_APCS_2122_Cost] as cost 
		ON cost.APCS_Ident = apcs.APCS_Ident
	LEFT JOIN NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP as GP
		ON apcs.GP_Practice_Code = GP.GP_code
WHERE
      apcs.APCS_Ident IS NOT NULL AND
	  GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
	AND COPD_Code LIKE 'primaryJ4%'
			AND cost.Tariff_Total_Payment IS NOT NULL
		AND cost.Tariff_Total_Payment <= @cost_ref_fing
GROUP BY ICP_Name


/* FINAL CODE: AECOPD CODE J44 ONLY */

DECLARE @cost_ref_AECOPD FLOAT = 
	(
	SELECT MIN(Tariff_Total_Payment)
	FROM (
			SELECT 
				top(1) PERCENT WITH TIES -- choose the top 1% tariff total payment as the reference
				cost.Tariff_Total_Payment
			FROM NHSE_Sandbox_HEU.temp.Notts_AECOPD apcs
				INNER JOIN [dbo].[tbl_Data_SEM_APCS_2122_Cost] as cost 
					ON cost.APCS_Ident = apcs.APCS_Ident
				LEFT JOIN NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP as GP
					ON apcs.GP_Practice_Code = GP_code
					AND cost.Der_Financial_Year = '2021/22'
					AND cost.Tariff_Total_Payment IS NOT NULL
			WHERE COPD_Code LIKE '%primaryJ44%'
			ORDER BY cost.Tariff_Total_Payment DESC
			)COST
		)

SELECT @cost_ref_AECOPD
SELECT DISTINCT
	COUNT( DISTINCT apcs.APCS_Ident) AS spells_COPD_any,
	SUM(cost.Tariff_Total_Payment) AS cost_spell,
	ICP_Name
FROM NHSE_Sandbox_HEU.temp.Notts_AECOPD as apcs
	INNER JOIN [dbo].[tbl_Data_SEM_APCS_2122_Cost] as cost 
		ON cost.APCS_Ident = apcs.APCS_Ident
	LEFT JOIN NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP
	ON apcs.GP_Practice_Code = GP_code
WHERE
      apcs.APCS_Ident IS NOT NULL AND
	  GP_Practice_Code IN (SELECT GP_code FROM NHSE_Sandbox_HEU.temp.HEU_097_Notts_GP)
	AND COPD_Code LIKE '%primaryJ44%'
			AND cost.Tariff_Total_Payment IS NOT NULL
		AND cost.Tariff_Total_Payment <= @cost_ref_AECOPD
group by ICP_Name









