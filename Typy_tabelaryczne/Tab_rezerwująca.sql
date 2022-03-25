USE [Bilet_kinowy_inmemory]
GO 
 Tabela wykorzystywana do tymczasowego przechowania danych dotycz¹cych rezerwacji miejsca
/****** Object:  UserDefinedTableType [mem].[tab_rezerwuj¹ca]    Script Date: 24.03.2022 22:40:26 ******/
CREATE TYPE [mem].[tab_rezerwuj¹ca] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_repertuaru] [int] NOT NULL,
	[id_miejsca] [smallint] NOT NULL,
	[Id_data] [smallint] NOT NULL,
	[email] [varchar](30) COLLATE Polish_CI_AS NOT NULL,
	[id_rodzaju_biletu] [smallint] NULL,
	 PRIMARY KEY NONCLUSTERED HASH 
(
	[id]
)WITH ( BUCKET_COUNT = 4)
)
WITH ( MEMORY_OPTIMIZED = ON )
GO


