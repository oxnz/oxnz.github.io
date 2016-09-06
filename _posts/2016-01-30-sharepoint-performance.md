---
layout: post
title: "Sharepoint performance issues"
categories: [windows]
tags: [sharepoint]
---

### Introduction

This article describes various performance-related issues may occured on your sharepoint farm.

<!--more-->

## Table of Contents

* TOC
{:toc}

## System Prepare

### Reset Duplicate SIDs

```
C:\Windows\system32\sysprep\sysprep.exe /generalize /restart
whoami /user
```

## Create

```
New-OfficeWebAppsFarm -InternalURL xxx -AllowHttp -EditingEnabled
New-SPWOPIBinding -ServerName <String> [-Action <String>] [-AllowHTTP <SwitchParameter>] [-Application <String>] [-AssignmentCollection <SPAssignmentCollection>] [-Confirm [<SwitchParameter>]] [-Extension <String>] [-FileName <String>] [-ProgId <String>] [-WhatIf [<SwitchParameter>]]
New-SPWOPIBinding -ServerName "owa.bpitsp.com"
Set-SPWOPIZone [[-Zone] <String>] [-AssignmentCollection <SPAssignmentCollection>] [-Confirm [<SwitchParameter>]] [-WhatIf [<SwitchParameter>]]
Set-SPWOPIZone -Zone "internal-http"
```

[Set-SPWOPIZone](https://technet.microsoft.com/en-us/library/jj219451.aspx)

## Site Collection and Site Management

* new site
* new sub-site
* new document library
* new document
* [Move site collections between databases in SharePoint 2013](https://technet.microsoft.com/en-us/library/cc825328.aspx?f=255&MSPPError=-2147217396)
* [SharePoint Database is too big](https://social.msdn.microsoft.com/Forums/en-US/781797ac-df99-4ad0-b132-5dd16baaac3c/sharepoint-database-is-too-big?forum=sharepointgeneralprevious)

dbo.roleassignment

## Inspect SQL Server 2012

### count all tables

```sql
select obj.name, idx.rows
from sys.sysobjects as obj
inner join
sys.sysindexes as idx
on obj.id = idx.id
where
(obj.type = 'u') and (idx.indid in (0, 1))
order by idx.rows desc;
```

### inspect sites

```sql
select top 10 SiteId from dbo.RoleAssignment;
select count(*) from dbo.RoleAssignment group by SiteId;
select Id, Deleted, AppSiteDomainId, UsersCount, DiskUsed from dbo.AllSites;
select count(*) from dbo.Perms where ScopeUrl like '%/wikisite/%';
```

### Insepct queries

```sql
SELECT
(total_elapsed_time / execution_count)/1000 N'Avg Time (ms)'
,total_elapsed_time/1000 N'Total Time (ms)'
,total_worker_time/1000 N'Total CPU Time (ms)'
,total_physical_reads N'Total Physical Reads'
,total_logical_reads/execution_count N'Logical Reads Every Time'
,total_logical_reads N'Total Logical Reads'
,total_logical_writes N'Total Logical Writes'
,execution_count N'Exec Times'
,SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
((CASE statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE qs.statement_end_offset END
- qs.statement_start_offset)/2) + 1) N'Exec Stmt'
,creation_time N'Stmt Compile Time'
,last_execution_time N'Last Exec Time'
FROM
sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE
SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
((CASE statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE qs.statement_end_offset END
- qs.statement_start_offset)/2) + 1) not like '%fetch%'
ORDER BY
total_elapsed_time / execution_count DESC;
```

### References

* [Tuning SQL Server 2012 for SharePoint 2013: (01) Key SQL Server and SharePoint Server Integration Concepts](https://channel9.msdn.com/series/tuning-sql-server-2012-for-sharepoint-2013/tuning-sql-server-2012-for-sharepoint-2013-01-key-sql-server-and-sharepoint-server-integration-conce)
* [Troubleshooting slow sharepoint 2013 list views](http://sharepoint-community.net/profiles/blogs/troubleshooting-slow-sharepoint-2013-list-views)

### Research

* dbo.roleassignment
* dbo.docstreams

### Sharepoint 2013 Command Line Admin

```
$siteUrl = "http://spapp01/sites/wiki"
$web = Get-SPWeb $siteUrl
$listref = $web.Lists[$list]
```

## Extremely slow at first load

>
There is a 'known issue' with SharePoint's initial load. SharePoint runs on the .Net framework on IIS, which goes to sleep by itself, or in your case an IISRESET restarts all the services.
>
Though the IIS services are running, nothing is going on until that first request is made to the website. At that moment, the .Net Framework has to compile all of the DLLs that comprises SharePoint and its features. So the initial load will take a long time, and the more services/features you're using (User Profile, Metadata, etc), the longer it'll feel as it all wakes up.

Could you please tell us, How much Ram you assigned to the VM? What Software Installed on the VM, everything on one or mutliple VMs.

## Couple of Common things to optimize the perfromance

* Stop the unnecessary services /Services Application in farm. I.e Search Services, MMS, performance point etc. Please only configure the services application which you need during your development.
* Stop any unecessary Web Application and related App Pool.
* Visual Studio IntelliTrace, stop it help you in debugging.
* Set SQL maximum server memory to a fixed number otherwise SQL grab all memory
* Set all user databases to SIMPLE recovery mode
* set the memory limit for Distributed Cache Service to 300 MB


Some other significant entries that I noticed from the Logs are:

0x0EE8 SharePoint Foundation Monitoring
b4ly Verbose Leaving Monitored Scope (GetProcessSecurityTokenForServiceContext). Execution Time=57510.6440902405
I also noticed another entry, which helped me rule out the possibility of any wait for certificate validation:

SharePoint Foundation Monitoring b4ly Verbose Leaving Monitored Scope (SPCertificateValidator.Validate). Execution Time=10.3105282934004
Another entry I noticed which I’ve no idea is about (since I use windows auth):

Monitored Scope (SPClaimProviderOperations.ClaimsForEntity()). Execution Time=22051.8979367489
Any ideas on the purpose or function of GetProcessSecurityTokenForServiceContext ? Does it relate to the User profile service and the Metadata Service. What about SPClaimProviderOperations.ClaimsForEntity

##The following are among the factors that can cause performance of mass uploads to suffer:

### The recovery model for the content database (a SQL Server setting) is set to full by default.
While this is certainly the appropriate setting for a production environment, as it allows for recovery using transaction logs, it can slow the content loading of a migration. Set the recovery mode to simple, which causes the contents of the transaction log to be truncated each time a checkpoint is issued for the database. Just remember two things: First, set it back to Full when finished. Second, remember this mode means that the database recovery point can only be as recent as the last database backup, so you’ll probably want to back up before your migration—and there are many good reasons for that, anyway.

### Search indexing,
if it kicks in, consumes resources that you might need on your WFEs and SQL servers for processing the migration of files. Make sure that search jobs are scheduled appropriately—or paused—while you do your mass upload.

### Anti-virus software,
if it is scanning every document that is uploaded, or is scanning the database or BLOB store directly, can slow things down tremendously. Assuming that your documents were scanned when they were uploaded to their original location, you probably don’t need to incur that penalty when simply moving those documents to SharePoint.

### BLOB storage can affect performance—for better or worse.
As you know, I’ve done a lot of writing and speaking about BLOB storage and content database scalability. BLOBs (binary large objects) are the binary, unstructured chunk of data that is the document as it is stored in SQL in the AllDocStreams table of your content database. You can externalize BLOBs using EBS or RBS, which means you store BLOBs in a location other than your content database, and the database gets a pointer to the document. When you externalize BLOBs, you reduce the writes to your database. By default, when you upload a document, it gets written to the transaction log first, then gets committed to the database.  That’s two writes for every document. By externalizing BLOBs, there is conceptually a performance benefit. But it really depends on the performance of the storage tier to which you move BLOBs, and depending on the performance of the EBS or RBS provider (the software that manages the communication between EBS/RBS, which are Microsoft APIs, and your BLOB storage platform). For example, if you’re externalizing BLOBs to cloud storage—like Amazon or Rackspace for example, it’s likely performance will be penalized.  But if you’re externalizing to a high-performance storage tier, performance can definitely increase for this mass-upload scenario.

### Database growth sizing.
The default database size and growth settings for SQL databases are really not appropriate for most SharePoint databases, particularly those that will contain BLOBs. Set the size of your content database to something that represents the size of the data you’re going to upload. Consider the space that metadata will take, as well. That way, SQL doesn’t have to “grow” the database as you upload—the space is already there. As a side note, size and growth affect performance as your environment scales—there are some great blog posts on the “interwebs” to help you determine an appropriate setting, but I recommend setting an initial size that represents your expected content size (including metadata and BLOBs, if stored in SQL) over the first few months of your service, and a growth setting of 10% of that size. But be smart about it—there are a lot of variables in that calculation that all depend on your usage patterns.

## Storage performance

Of course, can affect the uploads.  Consider creative solutions—like moving the database to which you’re uploading to a separate set of spindles, a separate SQL instance, or a separate SQL server, during the upload. Then move it to its “final home” after uploading is complete.  Keep in mind you might even be able to do a migration in a lab then bring the content database into production. Just detach and reattach the content databases.

### The web front end (WFE) can be a bottleneck

Consider uploading to a dedicated web front end that is not being hit by users (though it’s typically the SQL side that’s the bottleneck)… you can target your migration using DNS or load balancer settings.

### The bottleneck might be the connection between the WFE and SQL Server

Use a dedicated high-speed (Gig-E or 10Gig-E) network between WFE and SQL servers. Use teaming if NICs support it.

### The client side can also be a bottleneck

as can requests that aren’t load balanced. Consider running the migration directly on the WFE or from multiple clients, depending on your infrastructure.

### The source can be the bottleneck

Consider all of the previous issues as to where the files are coming from?  Should you perform the upload from the file server, for example? Should you move or copy the files to disks that are local to the WFE to maximize performance of the actual upload? That kind of two-step process may help you migrate during specific time windows of  your service level agreements.

## References

* [Deploy Office Web Apps Server](https://technet.microsoft.com/en-us/library/jj219455.aspx)
* [Software boundaries and limits for SharePoint 2013](https://technet.microsoft.com/en-us/library/cc262787%28v=office.15%29.aspx?f=255&MSPPError=-2147217396)

