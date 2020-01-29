--update the table of running transactions that have no active queries
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
	when not matched by source then delete