USE master;
GO

CREATE DATABASE JobEmplDB_Test
ON PRIMARY
( NAME = JobEmplDB_Test1,
    FILENAME = 'D:\DBData\JobEmplDB_Test1.mdf',
    SIZE = 64MB,
    FILEGROWTH = 8MB ),
( NAME = JobEmplDB_Test2,
    FILENAME = 'D:\DBData\JobEmplDB_Test2.ndf',
    SIZE = 64MB,
    FILEGROWTH = 8GB ),
FILEGROUP DBTableGroup
( NAME = JobEmplDB_TestTableGroup1,
    FILENAME = 'D:\DBData\JobEmplDB_TestTableGroup1.ndf',
    SIZE = 8GB,
    FILEGROWTH = 1GB ),
( NAME = JobEmplDB_TestTableGroup2,
    FILENAME = 'D:\DBData\JobEmplDB_TestTableGroup2.ndf',
    SIZE = 8GB,
    FILEGROWTH = 1GB ),
FILEGROUP DBIndexGroup
( NAME = JobEmplDB_TestIndexGroup1,
    FILENAME = 'D:\DBData\JobEmplDB_TestIndexGroup1.ndf',
    SIZE = 16GB,
    FILEGROWTH = 1GB ),
( NAME = JobEmplDB_TestIndexGroup2,
    FILENAME = 'D:\DBData\JobEmplDB_TestIndexGroup2.ndf',
    SIZE = 16GB,
    FILEGROWTH = 1GB )
LOG ON
( NAME = JobEmplDB_Testlog,
    FILENAME = 'E:\DBLog\JobEmplDB_Testlog.ldf',
    SIZE = 8GB,
    FILEGROWTH = 1GB ) ;
GO
