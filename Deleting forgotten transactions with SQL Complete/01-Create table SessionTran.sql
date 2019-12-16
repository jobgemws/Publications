SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [srv].[SessionTran](
	[SessionID] INT NOT NULL,
	[TransactionID] BIGINT NOT NULL,
	[CountTranNotRequest] TINYINT NOT NULL,
	[CountSessionNotRequest] TINYINT NOT NULL,
	[TransactionBeginTime] DATETIME NOT NULL,
	[InsertUTCDate] DATETIME NOT NULL,
	[UpdateUTCDate] DATETIME NOT NULL,
 CONSTRAINT [PK_SessionTran] PRIMARY KEY CLUSTERED 
(
	[SessionID] ASC,
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [srv].[SessionTran] ADD  CONSTRAINT [DF_SessionTran_Count]  DEFAULT ((0)) FOR [CountTranNotRequest]
GO

ALTER TABLE [srv].[SessionTran] ADD  CONSTRAINT [DF_SessionTran_CountSessionNotRequest]  DEFAULT ((0)) FOR [CountSessionNotRequest]
GO

ALTER TABLE [srv].[SessionTran] ADD  CONSTRAINT [DF_SessionTran_InsertUTCDate]  DEFAULT (getutcdate()) FOR [InsertUTCDate]
GO

ALTER TABLE [srv].[SessionTran] ADD  CONSTRAINT [DF_SessionTran_UpdateUTCDate]  DEFAULT (getutcdate()) FOR [UpdateUTCDate]
GO
