# BETL

BETL is a data warehouse automation framework. I allows you to generate ETL and DDL. Orchestration needs an ETL tool, but you can use the BETL meta data to build a generic orchestration process. 

Go directly to [installation](https://github.com/basvdberg/BETL/wiki/1.-Installation) or [getting started](https://github.com/basvdberg/BETL/wiki/2.-Getting-started)


![BETL Components](https://github.com/basvdberg/BETL-Core/blob/main/image/betl_overview.png)

## What is BETL
* Free, open source, GNU GPL
* Meta data driven
* 100 % T-SQL
* Generic (usable in many different data warehousing scenarios)
* Real time Code generator (in contrast to design time code generators like e.g. BIML). Changes to meta data and templates are effective immediately. There is no need to build or deploy anything in your development environment. 

## What is BETL not
* A modeling method (e.g. Datavault, Kimball or Anchor modeling)
* A DWH architecture (e.g. staging-> raw dwh -> integrated dwh -> datamart ). 
* Dependent ( e.g. dependent on vendor or tooling other than T-SQL and handle bars. no external libaries.). 
* Restrictive ( all or nothing. You can choose which functionality you require in your project.)
* Visual (currently it's only T-SQL. My next focus would be to build a [meta data gui](https://github.com/basvdberg/BetlApp) )

## Main reasons for using BETL
 * Improve your productivity. However you need to invest some time to get to know BETL. 
 * Improve the quality of your ETL by seperating **what to do** and **how to do it**. 
 * Makes your work more fun. You will need to think about generic business rules and templates instead of implementing local ETL changes. 
 * It forces developers to folow certain design guidelines and best practices. E.g. naming conventions, change detection, logging, TSQL Batch insert performance, etc.

## Pre requisits for **using** BETL
 * T-SQL intermediate level. 
 * A general understanding of the [Handlebars template language](https://handlebarsjs.com/).
 * You need a SQL Server database (in Azure or on premise). 
 
## Pre requisits for **contributing** to BETL
 * T-SQL advanced level. Generate dynamic T-SQL using stored procedures, functions, custom data types. 
 * Knowledge of data warehousing best practices.

BETL can be used standalone or combined with Azure data factory or SSIS. 

## Related projects

 * I am working on a [graphical user interface](https://github.com/basvdberg/BetlApp) for the mapping meta data. However this is still work in progress. A good workaround is to construct the mapping and orchestration meta data using views. 
 * The [previous version of BETL](https://github.com/basvdberg/BETL-old) was made for an on premise Microsoft environment and is being used by 2 large customers in the Netherlands. Most of the template code is contained in a large stored procedure called push. 

