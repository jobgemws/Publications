DECLARE @schema_name SYSNAME;
DECLARE @table_name SYSNAME;
DECLARE @constraint_name SYSNAME;
DECLARE @constraint_object_id INT;
DECLARE @referenced_object_name SYSNAME;
DECLARE @is_disabled BIT;
DECLARE @is_not_for_replication BIT;
DECLARE @is_not_trusted BIT;
DECLARE @delete_referential_action TINYINT;
DECLARE @update_referential_action TINYINT;
DECLARE @tsql NVARCHAR(4000);
DECLARE @tsql2 NVARCHAR(4000);
DECLARE @fkCol SYSNAME;
DECLARE @pkCol SYSNAME;
DECLARE @col1 BIT;
DECLARE @action CHAR(6);
DECLARE @referenced_schema_name SYSNAME;
DECLARE @tbl_create_FK TABLE (
	[Script] NVARCHAR(MAX)
);

DECLARE FKcursor CURSOR LOCAL FOR SELECT
	OBJECT_SCHEMA_NAME(parent_object_id)

   ,OBJECT_NAME(parent_object_id)
   ,name
   ,OBJECT_NAME(referenced_object_id)

   ,object_id

   ,is_disabled
   ,is_not_for_replication
   ,is_not_trusted

   ,delete_referential_action
   ,update_referential_action
   ,OBJECT_SCHEMA_NAME(referenced_object_id)

FROM sys.foreign_keys

ORDER BY 1, 2;

OPEN FKcursor;

FETCH NEXT FROM FKcursor INTO @schema_name, @table_name, @constraint_name

, @referenced_object_name, @constraint_object_id

, @is_disabled, @is_not_for_replication, @is_not_trusted

, @delete_referential_action, @update_referential_action, @referenced_schema_name;

WHILE @@fetch_status = 0

BEGIN



IF @action <> 'CREATE'

	SET @tsql = 'ALTER TABLE '

	+ QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name)

	+ ' DROP CONSTRAINT ' + QUOTENAME(@constraint_name) + ';';

ELSE

BEGIN

	SET @tsql = 'ALTER TABLE '

	+ QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name)

	+
	CASE @is_not_trusted

		WHEN 0 THEN ' WITH CHECK '

		ELSE ' WITH NOCHECK '

	END

	+ ' ADD CONSTRAINT ' + QUOTENAME(@constraint_name)

	+ ' FOREIGN KEY (';

	SET @tsql2 = '';

	DECLARE ColumnCursor CURSOR LOCAL FOR SELECT
		COL_NAME(fk.parent_object_id, fkc.parent_column_id)

	   ,COL_NAME(fk.referenced_object_id, fkc.referenced_column_id)

	FROM sys.foreign_keys fk

	INNER JOIN sys.foreign_key_columns fkc

		ON fk.object_id = fkc.constraint_object_id

	WHERE fkc.constraint_object_id = @constraint_object_id

	ORDER BY fkc.constraint_column_id;

	OPEN ColumnCursor;

	SET @col1 = 1;

	FETCH NEXT FROM ColumnCursor INTO @fkCol, @pkCol;

	WHILE @@fetch_status = 0

	BEGIN

	IF (@col1 = 1)

		SET @col1 = 0;

	ELSE

	BEGIN

		SET @tsql = @tsql + ',';

		SET @tsql2 = @tsql2 + ',';

	END;

	SET @tsql = @tsql + QUOTENAME(@fkCol);

	SET @tsql2 = @tsql2 + QUOTENAME(@pkCol);

	FETCH NEXT FROM ColumnCursor INTO @fkCol, @pkCol;

	END;

	CLOSE ColumnCursor;

	DEALLOCATE ColumnCursor;

	SET @tsql = @tsql + ' ) REFERENCES ' + QUOTENAME(@referenced_schema_name) + '.' + QUOTENAME(@referenced_object_name)

	+ ' (' + @tsql2 + ')';

	SET @tsql = @tsql

	+ ' ON UPDATE ' +
	CASE @update_referential_action

		WHEN 0 THEN 'NO ACTION '

		WHEN 1 THEN 'CASCADE '

		WHEN 2 THEN 'SET NULL '

		ELSE 'SET DEFAULT '

	END

	+ ' ON DELETE ' +
	CASE @delete_referential_action

		WHEN 0 THEN 'NO ACTION '

		WHEN 1 THEN 'CASCADE '

		WHEN 2 THEN 'SET NULL '

		ELSE 'SET DEFAULT '

	END

	+
	CASE @is_not_for_replication

		WHEN 1 THEN ' NOT FOR REPLICATION '

		ELSE ''

	END

	+ ';';

END;

INSERT INTO @tbl_create_FK ([Script])
	SELECT
		@tsql;

IF @action = 'CREATE'

BEGIN

	SET @tsql = 'ALTER TABLE '

	+ QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name)

	+
	CASE @is_disabled

		WHEN 0 THEN ' CHECK '

		ELSE ' NOCHECK '

	END

	+ 'CONSTRAINT ' + QUOTENAME(@constraint_name)

	+ ';';

	INSERT INTO @tbl_create_FK ([Script])
		SELECT
			@tsql;

END;

FETCH NEXT FROM FKcursor INTO @schema_name, @table_name, @constraint_name

, @referenced_object_name, @constraint_object_id

, @is_disabled, @is_not_for_replication, @is_not_trusted

, @delete_referential_action, @update_referential_action, @referenced_schema_name;

END;

CLOSE FKcursor;
DEALLOCATE FKcursor;

DECLARE FK_Create CURSOR LOCAL FOR SELECT
	[Script]
FROM @tbl_create_FK;

DECLARE @tbl_FK_Del TABLE ([TSQL] NVARCHAR(4000));

INSERT INTO @tbl_FK_Del([TSQL])
SELECT
	'ALTER TABLE [' + [TABLE_SCHEMA] + '].[' + [TABLE_NAME] + '] DROP CONSTRAINT [' + [CONSTRAINT_NAME] + '];'
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE [CONSTRAINT_TYPE] = 'FOREIGN KEY';

DECLARE @tbl_Truncate_Tbl TABLE ([TSQL] NVARCHAR(4000));

DECLARE FK_Del CURSOR LOCAL FOR SELECT [TSQL] FROM @tbl_FK_Del;

INSERT INTO @tbl_Truncate_Tbl ([TSQL])
SELECT
	'TRUNCATE TABLE [' + [TABLE_SCHEMA] + '].[' + [TABLE_NAME] + '];'
FROM INFORMATION_SCHEMA.TABLES
WHERE [TABLE_TYPE]='BASE TABLE';

DECLARE Truncate_Tbl CURSOR LOCAL FOR SELECT [TSQL] FROM @tbl_Truncate_Tbl;

OPEN FK_Create;
OPEN FK_Del;
OPEN Truncate_Tbl;

--BEGIN TRAN
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
EXEC sp_MSforeachtable "ALTER TABLE ? DISABLE TRIGGER ALL";

FETCH NEXT FROM FK_Del INTO @tsql;

WHILE (@@fetch_status = 0)
BEGIN
	PRINT @tsql;
	
	EXEC sp_executesql @tsql = @tsql;
	FETCH NEXT FROM FK_Del INTO @tsql;
END

FETCH NEXT FROM Truncate_Tbl INTO @tsql;

WHILE (@@fetch_status = 0)
BEGIN
	PRINT @tsql;
	
	EXEC sp_executesql @tsql = @tsql;
	FETCH NEXT FROM Truncate_Tbl INTO @tsql;
END

FETCH NEXT FROM FK_Create INTO @tsql;

WHILE (@@fetch_status = 0)
BEGIN
	PRINT @tsql;

	EXEC sp_executesql @tsql = @tsql;
	FETCH NEXT FROM FK_Create INTO @tsql;
END

EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";
EXEC sp_MSforeachtable "ALTER TABLE ? ENABLE TRIGGER ALL";
--ROLLBACK TRAN

CLOSE FK_Create;
CLOSE FK_Del;
CLOSE Truncate_Tbl;

DEALLOCATE FK_Create;
DEALLOCATE FK_Del;
DEALLOCATE Truncate_Tbl;
