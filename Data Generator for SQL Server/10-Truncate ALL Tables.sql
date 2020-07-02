DECLARE @tsql NVARCHAR(4000);
DECLARE @tbl_Truncate_Tbl TABLE ([TSQL] NVARCHAR(4000));

INSERT INTO @tbl_Truncate_Tbl ([TSQL])
SELECT
	'TRUNCATE TABLE [' + [TABLE_SCHEMA] + '].[' + [TABLE_NAME] + '];'
FROM INFORMATION_SCHEMA.TABLES
WHERE [TABLE_TYPE]='BASE TABLE';

DECLARE Truncate_Tbl CURSOR LOCAL FOR SELECT [TSQL] FROM @tbl_Truncate_Tbl;

OPEN Truncate_Tbl;

FETCH NEXT FROM Truncate_Tbl INTO @tsql;

WHILE (@@fetch_status = 0)
BEGIN
	EXEC sp_executesql @tsql = @tsql;
	FETCH NEXT FROM Truncate_Tbl INTO @tsql;
END

CLOSE Truncate_Tbl;
DEALLOCATE Truncate_Tbl;
