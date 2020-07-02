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
