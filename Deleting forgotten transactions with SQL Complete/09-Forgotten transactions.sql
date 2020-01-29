insert into @tbl (
						SessionID,
						TransactionID,
						IsSessionNotRequest,
						TransactionBeginTime
					 )
	select t.[session_id] as SessionID
		 , t.[transaction_id] as TransactionID
		 , case when exists(select top(1) 1 from sys.dm_exec_requests as r where r.[session_id]=t.[session_id]) then 0 else 1 end as IsSessionNotRequest
		 , (select top(1) ta.[transaction_begin_time] from sys.dm_tran_active_transactions as ta where ta.[transaction_id]=t.[transaction_id]) as TransactionBeginTime
	from sys.dm_tran_session_transactions as t
	where t.[is_user_transaction]=1
	and not exists(select top(1) 1 from sys.dm_exec_requests as r where r.[transaction_id]=t.[transaction_id]);
	
	;merge srv.SessionTran as st
	using @tbl as t
	on st.[SessionID]=t.[SessionID] and st.[TransactionID]=t.[TransactionID]
	when matched then
		update set [UpdateUTCDate]			= getUTCDate()
				 , [CountTranNotRequest]	= st.[CountTranNotRequest]+1			
				 , [CountSessionNotRequest]	= case when (t.[IsSessionNotRequest]=1) then (st.[CountSessionNotRequest]+1) else 0 end
				 , [TransactionBeginTime]	= coalesce(t.[TransactionBeginTime], st.[TransactionBeginTime])
	when not matched by target and (t.[TransactionBeginTime] is not null) then
		insert (
				[SessionID]
				,[TransactionID]
				,[TransactionBeginTime]
			   )
		values (
				t.[SessionID]
				,t.[TransactionID]
				,t.[TransactionBeginTime]
			   )
	when not matched by source then delete;