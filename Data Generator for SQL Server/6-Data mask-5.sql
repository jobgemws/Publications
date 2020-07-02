SELECT [FirstName] AS [ValueOld], CAST(NULL AS NVARCHAR(255)) AS [ValueNew]
INTO #dbo_Employee_FirstName
FROM [dbo].[Employee]
GROUP BY [FirstName];

UPDATE #dbo_Employee_FirstName
SET [ValueNew]=[test].[GetRandString](1, 0, 1, 1, 0, 0)+[test].[GetRandString](LEN([ValueOld])-1, 0, 0, 1, 0, 0);

UPDATE trg
SET trg.[FirstName]=src.[ValueNew]
FROM #dbo_Employee_FirstName AS src
INNER JOIN [dbo].[Employee] AS trg ON trg.[FirstName]=src.[ValueOld];

DROP TABLE #dbo_Employee_FirstName;

SELECT [LastName] AS [ValueOld], CAST(NULL AS NVARCHAR(255)) AS [ValueNew]
INTO #dbo_Employee_LastName
FROM [dbo].[Employee]
GROUP BY [LastName];

UPDATE #dbo_Employee_LastName
SET [ValueNew]=[test].[GetRandString](1, 0, 1, 1, 0, 0)+[test].[GetRandString](LEN([ValueOld])-1, 0, 0, 1, 0, 0);

UPDATE trg
SET trg.[LastName]=src.[ValueNew]
FROM #dbo_Employee_LastName AS src
INNER JOIN [dbo].[Employee] AS trg ON trg.[LastName]=src.[ValueOld];

DROP TABLE #dbo_Employee_LastName;

SELECT [DocNumber] AS [ValueOld], CAST(NULL AS NCHAR(10)) AS [ValueNew]
INTO #dbo_Employee_DocNumber
FROM [dbo].[Employee]
GROUP BY [DocNumber];

UPDATE #dbo_Employee_DocNumber
SET [ValueNew]=[test].[GetRandString](2, 1, 0, 1, 0, 0)+N'-'+[test].[GetRandString](7, 1, 0, 0, 0, 0);

UPDATE trg
SET trg.[DocNumber]=src.[ValueNew]
FROM #dbo_Employee_DocNumber AS src
INNER JOIN [dbo].[Employee] AS trg ON trg.[DocNumber]=src.[ValueOld];

DROP TABLE #dbo_Employee_DocNumber;

DECLARE @StartDate datetime='1900-01-01T00:00:00';

SELECT [DocDate] AS [DocDateOld], [BirthDate] AS [BirthDateOld], CAST(NULL AS DATE) AS [DocDateNew], CAST(NULL AS DATE) AS [BirthDateNew]
INTO #dbo_Employee_DocDateBirthDate
FROM [dbo].[Employee]
GROUP BY [BirthDate], [DocDate];

UPDATE #dbo_Employee_DocDateBirthDate
SET [BirthDateNew]=CAST(CAST(CAST(@StartDate AS FLOAT) + (CAST(GETDATE() AS FLOAT) - CAST(@StartDate AS FLOAT)) * RAND(CHECKSUM(NEWID())) AS DATETIME) AS DATE);

UPDATE #dbo_Employee_DocDateBirthDate
SET [DocDateNew]=CAST(CAST(CAST(CAST([BirthDateNew] AS DATETIME) AS FLOAT) + (CAST(GETDATE() AS FLOAT) - CAST(CAST([BirthDateNew] AS DATETIME) AS FLOAT)) * RAND(CHECKSUM(NEWID())) AS DATETIME) AS DATE);


UPDATE trg
SET trg.[BirthDate]=src.[BirthDateNew]
  , trg.[DocDate]  =src.[DocDateNew]
FROM #dbo_Employee_DocDateBirthDate AS src
INNER JOIN [dbo].[Employee] AS trg ON trg.[BirthDate]=src.[BirthDateOld] AND trg.[DocDate]=src.[DocDateOld];

DROP TABLE #dbo_Employee_DocDateBirthDate;

SELECT [CountRequest] AS [ValueOld], CAST(NULL AS INT) AS [ValueNew]
INTO #dbo_Employee_CountRequest
FROM [dbo].[Employee]
GROUP BY [CountRequest];

UPDATE #dbo_Employee_CountRequest
SET [ValueNew]=CAST((([ValueOld]*2 + 1) - [ValueOld]/2) * RAND(CHECKSUM(NEWID())) + [ValueOld]/2 AS INT);

UPDATE trg
SET trg.[CountRequest]=[ValueNew]
FROM #dbo_Employee_CountRequest AS src
INNER JOIN [dbo].[Employee] AS trg ON trg.[CountRequest]=src.[ValueOld];

DROP TABLE #dbo_Employee_CountRequest;

SELECT [PaymentAmount] AS [ValueOld], CAST(NULL AS DECIMAL(18,2)) AS [ValueNew]
INTO #dbo_Employee_PaymentAmount
FROM [dbo].[Employee]
GROUP BY [PaymentAmount];

UPDATE #dbo_Employee_PaymentAmount
SET [ValueNew]=CAST((([ValueOld]*2 + 1) - [ValueOld]/2) * RAND(CHECKSUM(NEWID())) + [ValueOld]/2 AS DECIMAL(18,2));

UPDATE trg
SET trg.[PaymentAmount]=[ValueNew]
FROM #dbo_Employee_PaymentAmount AS src
INNER JOIN [dbo].[Employee] AS trg ON trg.[PaymentAmount]=src.[ValueOld];

DROP TABLE #dbo_Employee_PaymentAmount;

SELECT [RemoteAccessCertificate] AS [ValueOld], CAST(NULL AS VARBINARY(MAX)) AS [ValueNew]
INTO #dbo_Employee_RemoteAccessCertificate
FROM [dbo].[Employee]
GROUP BY [RemoteAccessCertificate];

UPDATE #dbo_Employee_RemoteAccessCertificate
SET [ValueNew]=[test].[GetRandVarbinary](LEN([ValueOld]));

UPDATE trg
SET trg.[RemoteAccessCertificate]=[ValueNew]
FROM #dbo_Employee_RemoteAccessCertificate AS src
INNER JOIN [dbo].[Employee] AS trg ON trg.[RemoteAccessCertificate]=src.[ValueOld];

DROP TABLE #dbo_Employee_RemoteAccessCertificate;

SELECT [Address] AS [ValueOld], CAST(NULL AS NVARCHAR(MAX)) AS [ValueNew]
INTO #dbo_Employee_Address
FROM [dbo].[Employee]
GROUP BY [Address];

UPDATE #dbo_Employee_Address
SET [ValueNew]=CASE WHEN ([ValueOld] IS NOT NULL) THEN [test].[GetRandString](LEN([ValueOld]), 0, 0, 1, 0, 0) ELSE NULL END;

UPDATE trg
SET trg.[Address]=[ValueNew]
FROM #dbo_Employee_Address AS src
INNER JOIN [dbo].[Employee] AS trg ON trg.[Address]=src.[ValueOld];

DROP TABLE #dbo_Employee_Address;
