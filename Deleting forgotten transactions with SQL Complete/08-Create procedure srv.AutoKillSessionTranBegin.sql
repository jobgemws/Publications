IF OBJECT_ID('srv.AutoKillSessionTranBegin') IS NOT NULL
BEGIN 
    DROP PROC srv.AutoKillSessionTranBegin 
END
GO
CREATE PROC srv.AutoKillSessionTranBegin
    @SessionID int,
    @TransactionID bigint
AS
    SET NOCOUNT ON 
    SET XACT_ABORT ON  
GO