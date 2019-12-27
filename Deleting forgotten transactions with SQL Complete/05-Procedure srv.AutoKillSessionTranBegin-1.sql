SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE [srv].[AutoKillSessionTranBegin] @minuteOld2 INT = 30, --old age of a running transaction
@countIsNotRequests2 INT = 5 --number of hits in the table
AS
BEGIN
	/*
		--definition of frozen transactions (forgotten ones that do not have active requests) with their subsequent removal
	*/

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


	DECLARE @tbl TABLE (
		SessionID INT
	   ,TransactionID BIGINT
	   ,IsSessionNotRequest BIT
	   ,TransactionBeginTime DATETIME
	);

	--collect information (transactions and their sessions that have no requests, i.e., transactions that are started and forgotten)
	INSERT INTO @tbl (SessionID,
	TransactionID,
	IsSessionNotRequest,
	TransactionBeginTime)
		SELECT
			t.[session_id] AS SessionID
		   ,t.[transaction_id] AS TransactionID
		   ,CASE
				WHEN EXISTS (SELECT TOP (1)
							1
						FROM sys.dm_exec_requests AS r
						WHERE r.[session_id] = t.[session_id]) THEN 0
				ELSE 1
			END AS IsSessionNotRequest
		   ,(SELECT TOP (1)
					dtat.[transaction_begin_time]
				FROM sys.dm_tran_active_transactions AS dtat
				WHERE dtat.[transaction_id] = t.[transaction_id])
			AS TransactionBeginTime
		FROM sys.dm_tran_session_transactions AS t
		WHERE t.[is_user_transaction] = 1
		AND NOT EXISTS (SELECT TOP (1)
				1
			FROM sys.dm_exec_requests AS r
			WHERE r.[transaction_id] = t.[transaction_id]);

	--update the table of running transactions that have no active queries
	;
	MERGE srv.SessionTran AS st USING @tbl AS t
	ON st.[SessionID] = t.[SessionID]
		AND st.[TransactionID] = t.[TransactionID]
	WHEN MATCHED
		THEN UPDATE
			SET [UpdateUTCDate] = GETUTCDATE()
			   ,[CountTranNotRequest] = st.[CountTranNotRequest] + 1
			   ,[CountSessionNotRequest] =
				CASE
					WHEN (t.[IsSessionNotRequest] = 1) THEN (st.[CountSessionNotRequest] + 1)
					ELSE 0
				END
			   ,[TransactionBeginTime] = COALESCE(t.[TransactionBeginTime], st.[TransactionBeginTime])
	WHEN NOT MATCHED BY TARGET
		AND (t.[TransactionBeginTime] IS NOT NULL)
		THEN INSERT ([SessionID]
			, [TransactionID]
			, [TransactionBeginTime])
				VALUES (t.[SessionID], t.[TransactionID], t.[TransactionBeginTime])
	WHEN NOT MATCHED BY SOURCE
		THEN DELETE;

	--list of sessions to delete (containing frozen transactions)
	DECLARE @kills TABLE (
		SessionID INT
	);

	--detailed information for the archive
	DECLARE @kills_copy TABLE (
		SessionID INT
	   ,TransactionID BIGINT
	   ,CountTranNotRequest TINYINT
	   ,CountSessionNotRequest TINYINT
	   ,TransactionBeginTime DATETIME
	);

	--collect those sessions that need to be killed
	INSERT INTO @kills_copy (SessionID,
	TransactionID,
	CountTranNotRequest,
	CountSessionNotRequest,
	TransactionBeginTime)
		SELECT
			SessionID
		   ,TransactionID
		   ,CountTranNotRequest
		   ,CountSessionNotRequest
		   ,TransactionBeginTime
		FROM srv.SessionTran
		WHERE [CountTranNotRequest] >= @countIsNotRequests2
		AND [CountSessionNotRequest] >= @countIsNotRequests2
		AND [TransactionBeginTime] <= DATEADD(MINUTE, -@minuteOld2, GETDATE());

	--archive what we are going to delete (detailed information about deleted sessions, connections and transactions)
	INSERT INTO [srv].[KillSession] ([session_id]
	, [transaction_id]
	, [login_time]
	, [host_name]
	, [program_name]
	, [host_process_id]
	, [client_version]
	, [client_interface_name]
	, [security_id]
	, [login_name]
	, [nt_domain]
	, [nt_user_name]
	, [status]
	, [context_info]
	, [cpu_time]
	, [memory_usage]
	, [total_scheduled_time]
	, [total_elapsed_time]
	, [endpoint_id]
	, [last_request_start_time]
	, [last_request_end_time]
	, [reads]
	, [writes]
	, [logical_reads]
	, [is_user_process]
	, [text_size]
	, [language]
	, [date_format]
	, [date_first]
	, [quoted_identifier]
	, [arithabort]
	, [ansi_null_dflt_on]
	, [ansi_defaults]
	, [ansi_warnings]
	, [ansi_padding]
	, [ansi_nulls]
	, [concat_null_yields_null]
	, [transaction_isolation_level]
	, [lock_timeout]
	, [deadlock_priority]
	, [row_count]
	, [prev_error]
	, [original_security_id]
	, [original_login_name]
	, [last_successful_logon]
	, [last_unsuccessful_logon]
	, [unsuccessful_logons]
	, [group_id]
	, [database_id]
	, [authenticating_database_id]
	, [open_transaction_count]
	, [most_recent_session_id]
	, [connect_time]
	, [net_transport]
	, [protocol_type]
	, [protocol_version]
	, [encrypt_option]
	, [auth_scheme]
	, [node_affinity]
	, [num_reads]
	, [num_writes]
	, [last_read]
	, [last_write]
	, [net_packet_size]
	, [client_net_address]
	, [client_tcp_port]
	, [local_net_address]
	, [local_tcp_port]
	, [connection_id]
	, [parent_connection_id]
	, [most_recent_sql_handle]
	, [LastTSQL]
	, [transaction_begin_time]
	, [CountTranNotRequest]
	, [CountSessionNotRequest])
		SELECT
			ES.[session_id]
		   ,kc.[TransactionID]
		   ,ES.[login_time]
		   ,ES.[host_name]
		   ,ES.[program_name]
		   ,ES.[host_process_id]
		   ,ES.[client_version]
		   ,ES.[client_interface_name]
		   ,ES.[security_id]
		   ,ES.[login_name]
		   ,ES.[nt_domain]
		   ,ES.[nt_user_name]
		   ,ES.[status]
		   ,ES.[context_info]
		   ,ES.[cpu_time]
		   ,ES.[memory_usage]
		   ,ES.[total_scheduled_time]
		   ,ES.[total_elapsed_time]
		   ,ES.[endpoint_id]
		   ,ES.[last_request_start_time]
		   ,ES.[last_request_end_time]
		   ,ES.[reads]
		   ,ES.[writes]
		   ,ES.[logical_reads]
		   ,ES.[is_user_process]
		   ,ES.[text_size]
		   ,ES.[language]
		   ,ES.[date_format]
		   ,ES.[date_first]
		   ,ES.[quoted_identifier]
		   ,ES.[arithabort]
		   ,ES.[ansi_null_dflt_on]
		   ,ES.[ansi_defaults]
		   ,ES.[ansi_warnings]
		   ,ES.[ansi_padding]
		   ,ES.[ansi_nulls]
		   ,ES.[concat_null_yields_null]
		   ,ES.[transaction_isolation_level]
		   ,ES.[lock_timeout]
		   ,ES.[deadlock_priority]
		   ,ES.[row_count]
		   ,ES.[prev_error]
		   ,ES.[original_security_id]
		   ,ES.[original_login_name]
		   ,ES.[last_successful_logon]
		   ,ES.[last_unsuccessful_logon]
		   ,ES.[unsuccessful_logons]
		   ,ES.[group_id]
		   ,ES.[database_id]
		   ,ES.[authenticating_database_id]
		   ,ES.[open_transaction_count]
		   ,EC.[most_recent_session_id]
		   ,EC.[connect_time]
		   ,EC.[net_transport]
		   ,EC.[protocol_type]
		   ,EC.[protocol_version]
		   ,EC.[encrypt_option]
		   ,EC.[auth_scheme]
		   ,EC.[node_affinity]
		   ,EC.[num_reads]
		   ,EC.[num_writes]
		   ,EC.[last_read]
		   ,EC.[last_write]
		   ,EC.[net_packet_size]
		   ,EC.[client_net_address]
		   ,EC.[client_tcp_port]
		   ,EC.[local_net_address]
		   ,EC.[local_tcp_port]
		   ,EC.[connection_id]
		   ,EC.[parent_connection_id]
		   ,EC.[most_recent_sql_handle]
		   ,(SELECT TOP (1)
					text
				FROM sys.dm_exec_sql_text(EC.[most_recent_sql_handle]))
			AS [LastTSQL]
		   ,kc.[TransactionBeginTime]
		   ,kc.[CountTranNotRequest]
		   ,kc.[CountSessionNotRequest]
		FROM @kills_copy AS kc
		INNER JOIN sys.dm_exec_sessions ES WITH (READUNCOMMITTED)
			ON kc.[SessionID] = ES.[session_id]
		INNER JOIN sys.dm_exec_connections EC WITH (READUNCOMMITTED)
			ON EC.session_id = ES.session_id;

	--collecting sessions
	INSERT INTO @kills (SessionID)
		SELECT
			[SessionID]
		FROM @kills_copy
		GROUP BY [SessionID];

	DECLARE @SessionID INT;

	--direct deletion of selected sessions
	WHILE (EXISTS (SELECT TOP (1)
			1
		FROM @kills)
	)
	BEGIN
	SELECT TOP (1)
		@SessionID = [SessionID]
	FROM @kills;

	BEGIN TRY
		EXEC sp_executesql N'kill @SessionID'
						  ,N'@SessionID INT'
						  ,@SessionID;
	END TRY
	BEGIN CATCH
	END CATCH;

	DELETE FROM @kills
	WHERE [SessionID] = @SessionID;
	END;

	SELECT
		st.[SessionID]
	   ,st.[TransactionID] INTO #tbl
	FROM srv.SessionTran AS st
	WHERE st.[CountTranNotRequest] >= 250
	OR st.[CountSessionNotRequest] >= 250
	OR EXISTS (SELECT TOP (1)
			1
		FROM @kills_copy kc
		WHERE kc.[SessionID] = st.[SessionID]);

	--deletion of processed records, as well as those that cannot be deleted and they are too long in the table for consideration
	DELETE FROM st
		FROM #tbl AS t
		INNER JOIN srv.SessionTran AS st
			ON t.[SessionID] = st.[SessionID]
			AND t.[TransactionID] = st.[TransactionID];

	DROP TABLE #tbl;
END;
