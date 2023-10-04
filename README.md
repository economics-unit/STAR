# STAR
This is the code that was used in the Smarter Spending in Population Health programme looking at resource allocation for COPD across 5 integrated care systems in the UK. 

The code works as follows:

star_fun2.R - This is a function which allows you to create one 'efficiency frontier' (more information here - https://www.youtube.com/watch?v=XYSgj89dfnk) for the pathway of a chronic condition. 
star_fun3.R - This is a function which allows you to create to compare two different efficiency frontiers. 
star_fun_data_spec_template.xlsx - this is an excel template that needs to be populated for the above two functions to run. 
LVRS.sql - sql code allowing activity and cost data on lung volume reduction surgery for people with COPD to be pulled from sus data. 
EC.sql - pulls emergency attendences and costs for acute exacerbations of COPD from sus data. 
OPA.sql - pulls outpatiatent appointment activity and costs for people with COPD from sus data. 
Spirom.sql - pulls secondary care spirometry test data and costs from SQL

NOTE all sql codes require you to build a list of organisatoinal codes to run it from. 

Credits:
  R Code:
          Jack Ettinger, Senior Health Economist
          Lisa Cummins, Lead Health Economist
  SQL Code:
          Jack Ettinger, Senior Health Economist
          Libby Zou, Data scientist
          Rayne Wang, Data scientist 
          
