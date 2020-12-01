# BETL for Azure
BETL for Azure is a complete revision of BETL. BETL is an ETL Engine, which in my world is a synonym for ETL automation software, ETL generation tool/framework or data warehouse automation software. 

Nowadays everybody who works in a large data warehouse environment uses an ETL engine to <b>generate ETL by using meta data</b>. There are some commercial products like WhereScape, XpertBI, TimeXtender or I-Refactory, but I prefer to keep matters into my own hands and my experience is that commercial products don't give you the flexibility to build the ETL engine exactly how you want it. 

BETL is licensed under the <b>GNU GPL</b>, so feel free to dive into the source code and make your own extensions. My hope is that by sharing this knowledge we can all benefit from each other. And perhaps some day I can sell myself as a betl consultant. 

BETL for Azure is made for Azure, but can also be modified for an on premise environment. However there is a T-SQL dependency, so other databases than Microsoft will be difficult. 
<!--
<H1>Definitions</h1>
Let's start with some definitions:
<table>
  <tr>
    <td>Name</td><td>Description</td>
  </tr>
  <tr>
    <td>ETL</td><td>The proces of extracting some data and loading it into a target environment. During this process the data can also be transformed.</td>
  </tr>
</table> 
Find more about BETL here: http://www.etlautomation.com.

-->

<ul>
  <li>BETL for Azure architecture</li>
  <li>Getting started</li>
</ul>
## What is BETL
* Free, open source, GNU GPL
* Meta data driven
* Generic (usable in many different data warehousing scenarios)

## What is BETL NOT
* A modeling method (e.g. Datavault, Kimball or Anchor modeling)
* A DWH architecture (e.g. staging-> raw dwh -> integrated dwh -> datamart ). 
* dependent ( e.g. dependend on vendor or tooling other than T-SQL and handle bars. no external libaries.). 
* Restrictive ( all or nothing. You can choose which functionality you require in your project.)
* Visual (currently it's only T-SQL. My next focus would be to build a meta data gui)

## Main reasons for using BETL
 * Improve your productivity. However you need to invest some time to get to know BETL. 
 * Improve the quality of your ETL by seperating ##what to do## and ##how to do it##. 
 * Makes your work more fun. You will need to think about generic business rules and templates instead of implementing local ETL changes. 
 * It forces developers to folow certain design guidelines and best practices. E.g. naming conventions, change detection, logging, TSQL Batch insert performance, etc.

## Pre requisits for **using** BETL
 * T-SQL intermediate level. 
 * Azure Data factory
 * [Handlebars template language](https://handlebarsjs.com/) 
  
## Pre requisits for **contributing** to BETL
 * T-SQL advanced level. Generate dynamic T-SQL using stored procedures, functions, custom data types. 
 * Knowledge of data warehousing best practices.

Previous BETL version : https://github.com/basvdberg/BETL
The previous version of BETL was made for an on premise Microsoft environment and is being used by 2 large customers in the Netherlands. 
