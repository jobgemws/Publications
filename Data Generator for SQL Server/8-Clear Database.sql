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
