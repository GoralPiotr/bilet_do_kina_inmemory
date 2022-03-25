USE [Bilet_kinowy_inmemory]
GO
 Przechowanie danych uzyskanych z zewnêtrznego pliku xml
/****** Object:  UserDefinedTableType [mem].[xmlowa]    Script Date: 24.03.2022 22:41:41 ******/
CREATE TYPE [mem].[xmlowa] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_sali] [smallint] NULL,
	[Nazwa_filmu] [varchar](50) COLLATE Polish_CI_AS NULL,
	[dzieñ] [date] NULL,
	[godzina] [time](0) NULL,
	 PRIMARY KEY NONCLUSTERED HASH 
(
	[id]
)WITH ( BUCKET_COUNT = 131072)
)
WITH ( MEMORY_OPTIMIZED = ON )
GO


