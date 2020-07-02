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
