# BETL Core

BETL Core is a data warehouse automation framework.



## What is BETL
* Free, open source, GNU GPL
* Meta data driven
* Generic (usable in many different data warehousing scenarios)

## What is BETL not
* A modeling method (e.g. Datavault, Kimball or Anchor modeling)
* A DWH architecture (e.g. staging-> raw dwh -> integrated dwh -> datamart ). 
* dependent ( e.g. dependend on vendor or tooling other than T-SQL and handle bars. no external libaries.). 
* Restrictive ( all or nothing. You can choose which functionality you require in your project.)
* Visual (currently it's only T-SQL. My next focus would be to build a meta data gui)

## Main reasons for using BETL
 * Improve your productivity. However you need to invest some time to get to know BETL. 
 * Improve the quality of your ETL by seperating **what to do** and **how to do it**. 
 * Makes your work more fun. You will need to think about generic business rules and templates instead of implementing local ETL changes. 
 * It forces developers to folow certain design guidelines and best practices. E.g. naming conventions, change detection, logging, TSQL Batch insert performance, etc.

## Pre requisits for **using** BETL
 * T-SQL intermediate level. 
 * Azure Data factory
 * A general understanding of the [Handlebars template language](https://handlebarsjs.com/).
 
## Pre requisits for **contributing** to BETL
 * T-SQL advanced level. Generate dynamic T-SQL using stored procedures, functions, custom data types. 
 * Knowledge of data warehousing best practices.


Find more about BETL here: http://www.etlautomation.com.
<ul>
  <li>BETL for Azure architecture</li>
  <li>Getting started</li>
</ul>

The [previous version of BETL](https://github.com/basvdberg/BETL) was made for an on premise Microsoft environment and is being used by 2 large customers in the Netherlands. 
