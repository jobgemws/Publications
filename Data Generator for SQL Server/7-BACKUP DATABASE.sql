BACKUP DATABASE [JobEmplDB_Test] TO DISK = N'E:\Backup\JobEmplDB_Test.bak' WITH NOFORMAT,
									NOINIT,
									NAME = N'JobEmplDB_Test-Full Database Backup',
									SKIP,
									NOREWIND,
									NOUNLOAD,
									COMPRESSION,
									STATS = 10,
									CHECKSUM;
GO

DECLARE @backupSetId AS INT;

SELECT
	@backupSetId = position
FROM msdb..backupset
WHERE database_name = N'JobEmplDB_Test'
AND backup_set_id = (SELECT
		MAX(backup_set_id)
	FROM msdb..backupset
	WHERE database_name = N'JobEmplDB_Test');

IF (@backupSetId IS NULL)
BEGIN
	RAISERROR (N'Verify failed. Backup information for database ''JobEmplDB_Test'' not found.', 16, 1);
END

RESTORE VERIFYONLY FROM DISK = N'E:\Backup\JobEmplDB_Test.bak' WITH FILE = @backupSetId,
						NOUNLOAD,
						NOREWIND;
GO
