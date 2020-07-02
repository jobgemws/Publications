USE [JobEmplDB]
GO

DECLARE @count int=1000;

DECLARE @LengthFirstName INT=8;
DECLARE @LengthLastName INT=8;
DECLARE @StartBirthDate DATE='1960-01-01';
DECLARE @FinishBirthDate DATE=DATEADD(YEAR, -18, GETDATE());
DECLARE @StartCountRequest INT=0;
DECLARE @FinishCountRequest INT=2048;
DECLARE @StartPaymentAmount DECIMAL(18,2)=0;
DECLARE @FinishPaymentAmount DECIMAL(18,2)=100000;
DECLARE @LengthRemoteAccessCertificate INT=16;
DECLARE @LengthAddress INT=1024;

DECLARE @count_get_unique_DocNumber INT=1000;

DECLARE @FirstName NVARCHAR(255);
DECLARE @LastName NVARCHAR(255);
DECLARE @BirthDate DATE;
DECLARE @DocDate DATE;
DECLARE @DocNumber NCHAR(10);
DECLARE @CountRequest INT;
DECLARE @PaymentAmount DECIMAL(18,2);
DECLARE @RemoteAccessCertificate VARBINARY(MAX);
DECLARE @Address NVARCHAR(MAX);

DECLARE @count_get_unique_DocNumber_ind INT;

DECLARE @tbl_DocNumber TABLE ([DocNumber] NCHAR(10) NULL);

WHILE(@count>0)
BEGIN
	SET @count-=1;

	SET @FirstName=[test].[GetRandString](1,0,1,1,0,0)+[test].[GetRandString](@LengthFirstName-1,0,0,1,0,0);
	SET @LastName=[test].[GetRandString](1,0,1,1,0,0)+[test].[GetRandString](@LengthLastName-1,0,0,1,0,0);
	SET @BirthDate =CAST(CAST(CAST(CAST(@StartBirthDate AS DATETIME) AS FLOAT) + (CAST(CAST(@FinishBirthDate AS DATETIME) AS FLOAT) - CAST(CAST(@StartBirthDate  AS DATETIME) AS FLOAT)) * RAND(CHECKSUM(NEWID())) AS DATETIME) AS DATE);
	SET @DocDate =CAST(CAST(CAST(DATEADD(YEAR, 16, CAST(@BirthDate AS DATETIME)) AS FLOAT) + (CAST(GETDATE() AS FLOAT) - CAST(DATEADD(YEAR, 16, CAST(@BirthDate AS DATETIME)) AS FLOAT)) * RAND(CHECKSUM(NEWID())) AS DATETIME) AS DATE);
	SET @CountRequest=CAST(((@FinishCountRequest + 1) - @StartCountRequest) * RAND(CHECKSUM(NEWID())) + @StartCountRequest AS INT);
	SET @PaymentAmount=CAST(((@FinishPaymentAmount + 1) - @StartPaymentAmount) * RAND(CHECKSUM(NEWID())) + @StartPaymentAmount AS DECIMAL(18, 2));
	SET @RemoteAccessCertificate=[test].[GetRandVarbinary](@LengthRemoteAccessCertificate);
	SET @Address=[test].[GetRandString](@LengthAddress,0,0,1,0,0);

	SET @count_get_unique_DocNumber_ind=@count_get_unique_DocNumber;

	WHILE(@count_get_unique_DocNumber_ind>0)
	BEGIN
		SET @count_get_unique_DocNumber_ind-=1;

		SET @DocNumber=[test].[GetRandString](2,1,0,0,0,0)+N'-'+[test].[GetRandString](7,1,0,0,0,0);

		INSERT INTO [dbo].[Employee]
           ([FirstName]
           ,[LastName]
           ,[BirthDate]
           ,[DocDate]
           ,[DocNumber]
           ,[CountRequest]
           ,[PaymentAmount]
           ,[RemoteAccessCertificate]
           ,[Address])
		OUTPUT INSERTED.[DocNumber] INTO @tbl_DocNumber
		SELECT @FirstName
           ,@LastName
           ,@BirthDate
           ,@DocDate
           ,@DocNumber
           ,@CountRequest
           ,@PaymentAmount
           ,@RemoteAccessCertificate
           ,@Address
		WHERE NOT EXISTS(SELECT TOP(1) 1 FROM [dbo].[Employee] AS e WHERE e.[DocNumber]=@DocNumber);

		IF(EXISTS(SELECT TOP(1) 1 FROM @tbl_DocNumber WHERE [DocNumber] IS NOT NULL))
		BEGIN
			SET @count_get_unique_DocNumber_ind=0;

			DELETE FROM @tbl_DocNumber;

			CONTINUE;
		END
	END

	DELETE FROM @tbl_DocNumber;
end
GO
