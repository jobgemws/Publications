USE SRV;
GO

IF OBJECT_ID('srv.usp_SessionTran_Select') IS NOT NULL
BEGIN 
    DROP PROC srv.usp_SessionTran_Select 
END
GO
CREATE PROC srv.usp_SessionTran_Select
    @SessionID int,
    @TransactionID bigint
AS
    SET NOCOUNT ON 
    SET XACT_ABORT ON  

    BEGIN TRAN

    SELECT SessionID, TransactionID, CountTranNotRequest, CountSessionNotRequest, TransactionBeginTime, InsertUTCDate, UpdateUTCDate 
    FROM   srv.SessionTran
    WHERE  SessionID = @SessionID AND TransactionID = @TransactionID  

    COMMIT
GO

-- Insert procedure was excluded by the option

-- Update procedure was excluded by the option

-- Delete procedure was excluded by the option