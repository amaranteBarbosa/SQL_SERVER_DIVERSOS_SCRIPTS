/*
Reasons behind Recovery Pending State in SQL Server

Some of the reasons causing such an issue are:

The database didn’t shut down properly and there is at least one uncommitted transaction active during the shutdown, 
resulting in deletion of the active transaction log file.

User tried moving the log files to a new drive to overcome server performance issues but ended up corrupting the log files in the process.

Database Recovery cannot be initiated due to insufficient memory space or disk storage.
*/


/*
1. Mark Database in Emergency Mode and Initiate Forceful Repair
Database EMERGENCY mode marks the database as READ_ONLY, disables logging, and grants access only to system administrators. 
Essentially, setting the db in this mode can bring the inaccessible database online. 

Note: Usually a database comes out of EMERGENCY mode automatically. 

Once you have opened the db in EMERGENCY mode, try repairing the database using the DBCC CHECKDB command 
with the ‘REPAIR_ALLOW_DATA_LOSS’ option. To do so, open SSMS and execute the following set of queries:
*/

ALTER DATABASE [DBName] SET EMERGENCY;
GO
ALTER DATABASE [DBName] set single_user
GO
DBCC CHECKDB ([DBName], REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS;
GO
ALTER DATABASE [DBName] set multi_user
GO

/*
2. Mark Database in Emergency Mode, Detach the Main Database and Re-attach It
This solution also requires to mark db in EMERGENCY mode. Once done, take the database offline (detach) and then bring it online (re-attach). 
To do so, execute the following set of queries in SSMS:
*/

ALTER DATABASE [DBName] SET EMERGENCY;
ALTER DATABASE [DBName] set multi_user
EXEC sp_detach_db ‘[DBName]’
EXEC sp_attach_single_file_db @DBName = ‘[DBName]’, @physname = N'[mdf path]’







