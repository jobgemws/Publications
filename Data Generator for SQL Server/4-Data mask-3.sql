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
