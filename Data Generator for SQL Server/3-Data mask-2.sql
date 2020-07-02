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
