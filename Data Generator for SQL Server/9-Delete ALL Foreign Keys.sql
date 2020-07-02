DECLARE @tsql NVARCHAR(4000);
DECLARE @tbl_FK_Del TABLE ([TSQL] NVARCHAR(4000));

INSERT INTO @tbl_FK_Del([TSQL])
SELECT
	'ALTER TABLE [' + [TABLE_SCHEMA] + '].[' + [TABLE_NAME] + '] DROP CONSTRAINT [' + [CONSTRAINT_NAME] + '];'
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE [CONSTRAINT_TYPE] = 'FOREIGN KEY';

DECLARE FK_Del CURSOR LOCAL FOR SELECT [TSQL] FROM @tbl_FK_Del;

OPEN FK_Del;

FETCH NEXT FROM FK_Del INTO @tsql;

WHILE (@@fetch_status = 0)
BEGIN
	EXEC sp_executesql @tsql = @tsql;
	FETCH NEXT FROM FK_Del INTO @tsql;
END

CLOSE FK_Del;
DEALLOCATE FK_Del;