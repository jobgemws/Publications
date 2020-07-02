USE [JobEmplDB]
GO

DECLARE @count INT=1000;

DECLARE @tbl_Employee TABLE ([ID] INT IDENTITY(1,1), [EmployeeID] INT);
DECLARE @tbl_Company TABLE ([ID] INT IDENTITY(1,1), [CompanyID] INT);
DECLARE @tbl_Position TABLE ([ID] INT IDENTITY(1,1), [PositionID] INT);
DECLARE @tbl_Project TABLE ([ID] INT IDENTITY(1,1), [ProjectID] INT);

INSERT INTO @tbl_Employee([EmployeeID])
SELECT [EmployeeID]
FROM [dbo].[Employee];

INSERT INTO @tbl_Company([CompanyID])
SELECT [CompanyID]
FROM [dbo].[Company];

INSERT INTO @tbl_Position([PositionID])
SELECT [PositionID]
FROM [dbo].[Position];

INSERT INTO @tbl_Project([ProjectID])
SELECT [ProjectID]
FROM [dbo].[Project];

DECLARE @Employee_ind INT;
DECLARE @Company_ind INT;
DECLARE @Position_ind INT;
DECLARE @Project_ind INT;

DECLARE @count_Employee INT=(SELECT COUNT(*) FROM @tbl_Employee);
DECLARE @count_Company INT=(SELECT COUNT(*) FROM @tbl_Company);
DECLARE @count_Position INT=(SELECT COUNT(*) FROM @tbl_Position);
DECLARE @count_Project INT=(SELECT COUNT(*) FROM @tbl_Project);

DECLARE @DocDate DATE;

DECLARE @EmployeeID INT;
DECLARE @CompanyID INT;
DECLARE @PositionID INT;
DECLARE @ProjectID INT;
DECLARE @StartDate DATE;
DECLARE @FinishDate DATE;
DECLARE @Description NVARCHAR(MAX);
DECLARE @Achievements NVARCHAR(MAX);
DECLARE @ReasonsForLeavingTheProject NVARCHAR(MAX);
declare @ReasonsForLeavingTheCompany NVARCHAR(MAX);

WHILE(@count>0)
BEGIN
	SET @count-=1;

	SET @Employee_ind=CAST(((@count_Employee + 1) - 1) * RAND(CHECKSUM(NEWID())) + 1 AS INT);
	SET @Company_ind=CAST(((@count_Company + 1) - 1) * RAND(CHECKSUM(NEWID())) + 1 AS INT);
	SET @Position_ind=CAST(((@count_Position + 1) - 1) * RAND(CHECKSUM(NEWID())) + 1 AS INT);
	SET @Project_ind=CAST(((@count_Project + 1) - 1) * RAND(CHECKSUM(NEWID())) + 1 AS INT);

	SET @EmployeeID=(SELECT TOP(1) [EmployeeID] FROM @tbl_Employee WHERE [ID]=@Employee_ind);
	SET @CompanyID=(SELECT TOP(1) [CompanyID] FROM @tbl_Company WHERE [ID]=@Company_ind);
	SET @PositionID=(SELECT TOP(1) [PositionID] FROM @tbl_Position WHERE [ID]=@Position_ind);
	SET @ProjectID=(SELECT TOP(1) [ProjectID] FROM @tbl_Project WHERE [ID]=@Project_ind);

	SELECT TOP(1) @DocDate=[DocDate]
	FROM [dbo].[Employee]
	WHERE [EmployeeID]=@EmployeeID;

	SET @StartDate=CAST(CAST(CAST(CAST(@DocDate AS DATETIME) AS FLOAT) + (CAST(CAST(GETDATE() AS DATETIME) AS FLOAT) - CAST(CAST(@DocDate  AS DATETIME) AS FLOAT)) * RAND(CHECKSUM(NEWID())) AS DATETIME) AS DATE);
	SET @FinishDate=CAST(CAST(CAST(CAST(@StartDate AS DATETIME) AS FLOAT) + (CAST(CAST(GetDate() AS DATETIME) AS FLOAT) - CAST(CAST(@StartDate  AS DATETIME) AS FLOAT)) * RAND(CHECKSUM(NEWID())) AS DATETIME) AS DATE);
	
	SET @Description=[test].[GetRandString](CAST(((255 + 1) - 1) * RAND(CHECKSUM(NEWID())) + 16 AS INT),0,0,1,0,0);
	SET @Achievements=[test].[GetRandString](CAST(((255 + 1) - 1) * RAND(CHECKSUM(NEWID())) + 16 AS INT),0,0,1,0,0);
	SET @ReasonsForLeavingTheProject=[test].[GetRandString](CAST(((255 + 1) - 1) * RAND(CHECKSUM(NEWID())) + 16 AS INT),0,0,1,0,0);
	SET @ReasonsForLeavingTheCompany=[test].[GetRandString](CAST(((255 + 1) - 1) * RAND(CHECKSUM(NEWID())) + 16 AS INT),0,0,1,0,0);

	INSERT INTO [dbo].[JobHistory]
           ([EmployeeID]
           ,[CompanyID]
           ,[PositionID]
           ,[ProjectID]
           ,[StartDate]
           ,[FinishDate]
           ,[Description]
           ,[Achievements]
           ,[ReasonsForLeavingTheProject]
           ,[ReasonsForLeavingTheCompany])
	SELECT  @EmployeeID
           ,@CompanyID
           ,@PositionID
           ,@ProjectID
           ,@StartDate
           ,@FinishDate
           ,@Description
           ,@Achievements
           ,@ReasonsForLeavingTheProject
           ,@ReasonsForLeavingTheCompany;
END
GO
