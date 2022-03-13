USE [Bilet_kinowy_inmemory]
GO
/****** Object:  Schema [mem]    Script Date: 13.03.2022 21:25:08 ******/
CREATE SCHEMA [mem]
GO
/****** Object:  Table [mem].[kalendarz]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[kalendarz]
(
	[id_dnia] [smallint] IDENTITY(1,1) NOT NULL,
	[dzień] [date] NULL,

INDEX [dz_kalendarz] NONCLUSTERED 
(
	[dzień] ASC
),
 PRIMARY KEY NONCLUSTERED HASH 
(
	[id_dnia]
)WITH ( BUCKET_COUNT = 1024)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  Table [mem].[filmy]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[filmy]
(
	[id_filmu] [smallint] IDENTITY(1,1) NOT NULL,
	[nazwa_filmu] [varchar](50) COLLATE Polish_CI_AS NOT NULL,

INDEX [filmy_nazwa_filmu] NONCLUSTERED HASH 
(
	[nazwa_filmu]
)WITH ( BUCKET_COUNT = 1024),
 PRIMARY KEY NONCLUSTERED HASH 
(
	[id_filmu]
)WITH ( BUCKET_COUNT = 1024)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  Table [mem].[repertuar]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[repertuar]
(
	[id_repertuaru] [smallint] IDENTITY(1,1) NOT NULL,
	[id_sali] [smallint] NOT NULL,
	[id_filmu] [smallint] NOT NULL,
	[id_data] [smallint] NOT NULL,
	[godzina] [time](0) NOT NULL,

INDEX [if_film_id_data_godz] UNIQUE NONCLUSTERED 
(
	[id_filmu] ASC,
	[id_data] ASC,
	[godzina] ASC
),
 PRIMARY KEY NONCLUSTERED HASH 
(
	[id_repertuaru]
)WITH ( BUCKET_COUNT = 1024)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  View [mem].[Wyświetlane_filmy]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create      view [mem].[Wyświetlane_filmy] 
as
select 
	 f.Nazwa_filmu
	,r.godzina
	,k.dzień
from mem.repertuar as r
inner join mem.filmy as f
on f.id_filmu = r.id_filmu
inner join mem.kalendarz as k
on k.id_dnia = r.id_data
GO
/****** Object:  Table [mem].[rezerwacja]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[rezerwacja]
(
	[id_rezerwacji] [smallint] IDENTITY(1,1) NOT NULL,
	[id_repertuaru] [smallint] NOT NULL,
	[id_miejsca] [smallint] NOT NULL,
	[id_data] [smallint] NOT NULL,
	[email] [varchar](30) COLLATE Polish_CI_AS NOT NULL,
	[id_rodzaju_biletu] [smallint] NOT NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[id_rezerwacji]
)WITH ( BUCKET_COUNT = 16384),
INDEX [rez_id_miejsca] NONCLUSTERED HASH 
(
	[id_miejsca]
)WITH ( BUCKET_COUNT = 512),
INDEX [rez_id_reper] NONCLUSTERED HASH 
(
	[id_repertuaru]
)WITH ( BUCKET_COUNT = 1024)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  View [mem].[liczba_widzów]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create view [mem].[liczba_widzów] as
	select id_filmu,COUNT(id_filmu) as ilość_osób,godzina_spr from 
	(
	select id_filmu, godzina,
	case when godzina >=  '15:00' then 'po 15:00'
	else 'przed 15:00' 
	end as godzina_spr
	
	from mem.rezerwacja as hrez
	inner join mem.repertuar as hrep
	on hrez.id_repertuaru = hrep.id_repertuaru
	) as t
	group by id_filmu,godzina_spr
GO
/****** Object:  Table [mem].[historia_rezerwacji]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[historia_rezerwacji]
(
	[id_rezerwacji] [smallint] NOT NULL,
	[id_repertuaru] [smallint] NOT NULL,
	[id_miejsca] [smallint] NOT NULL,
	[email] [varchar](30) COLLATE Polish_CI_AS NOT NULL,
	[id_rodzaju_biletu] [smallint] NOT NULL,

INDEX [his_id_rep] NONCLUSTERED 
(
	[id_repertuaru] ASC
),
 PRIMARY KEY NONCLUSTERED HASH 
(
	[id_rezerwacji]
)WITH ( BUCKET_COUNT = 1024)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  Table [mem].[historia_repertuaru]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[historia_repertuaru]
(
	[id_repertuaru] [smallint] NOT NULL,
	[id_sali] [smallint] NOT NULL,
	[id_filmu] [smallint] NOT NULL,
	[id_data] [smallint] NOT NULL,
	[godzina] [time](0) NOT NULL,

INDEX [his_id_film] NONCLUSTERED 
(
	[id_filmu] ASC
),
 PRIMARY KEY NONCLUSTERED HASH 
(
	[id_repertuaru]
)WITH ( BUCKET_COUNT = 1024)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  View [mem].[liczba_widzów_historia]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	create   view [mem].[liczba_widzów_historia] as
	select id_filmu,COUNT(t.id_repertuaru) as ilość_osób,godzina_spr from 
	(
	select id_filmu, godzina,hrez.id_repertuaru,
	case when godzina >=  '15:00' then 'po 15:00'
	else 'przed 15:00' 
	end as godzina_spr
	
	from mem.historia_rezerwacji as hrez
	right join mem.historia_repertuaru as hrep
	on hrez.id_repertuaru =hrep.id_repertuaru
	) as t
	group by id_filmu,godzina_spr
GO
/****** Object:  View [dbo].[liczba_widzów]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	create   view [dbo].[liczba_widzów] as
	select id_filmu,COUNT(t.id_repertuaru) as ilość_osób,godzina_spr from 
	(
	select id_filmu, godzina, hrez.id_repertuaru,
	case when godzina >=  '15:00' then 'po 15:00'
	else 'przed 15:00' 
	end as godzina_spr
	
	from mem.rezerwacja as hrez
	right join mem.repertuar as hrep
	on hrez.id_repertuaru = hrep.id_repertuaru
	) as t
	group by id_filmu,godzina_spr
GO
/****** Object:  Table [dbo].[t1]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t1]
(
	[id] [int] NOT NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[id]
)WITH ( BUCKET_COUNT = 524288)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  Table [mem].[kalendarz2]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[kalendarz2](
	[id_dnia] [smallint] IDENTITY(1,1) NOT NULL,
	[dzień] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [mem].[liczby]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[liczby]
(
	[id_liczby] [smallint] NOT NULL,

 CONSTRAINT [lic_id_liczby]  PRIMARY KEY NONCLUSTERED 
(
	[id_liczby] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  Table [mem].[rodzaje_biletów]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[rodzaje_biletów]
(
	[id_rodzaju_biletu] [smallint] NOT NULL,
	[nazwa_biletu] [varchar](10) COLLATE Polish_CI_AS NOT NULL,
	[cena_biletu] [smallmoney] NOT NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[id_rodzaju_biletu]
)WITH ( BUCKET_COUNT = 16),
INDEX [rodz_nazwa_biletu] NONCLUSTERED HASH 
(
	[nazwa_biletu]
)WITH ( BUCKET_COUNT = 16)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  Table [mem].[sale_kinowe]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[sale_kinowe]
(
	[id_sali] [smallint] IDENTITY(1,1) NOT NULL,
	[nazwa_sali] [char](7) COLLATE Polish_CI_AS NOT NULL,
	[pojemność] [int] NOT NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[id_sali]
)WITH ( BUCKET_COUNT = 16),
INDEX [sal_pojemność] NONCLUSTERED 
(
	[pojemność] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  Table [mem].[tymczasowa_rezerwacja]    Script Date: 13.03.2022 21:25:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [mem].[tymczasowa_rezerwacja]
(
	[id_repertuaru] [smallint] NOT NULL,
	[id_miejsca] [smallint] NOT NULL,
	[id_sesji] [smallint] NOT NULL,
	[czas_wyboru] [datetime] NOT NULL,
	[id_data] [smallint] NOT NULL,

INDEX [tym_id_reper] NONCLUSTERED HASH 
(
	[id_repertuaru]
)WITH ( BUCKET_COUNT = 2048),
INDEX [tym_id_sesji] NONCLUSTERED HASH 
(
	[id_sesji]
)WITH ( BUCKET_COUNT = 2048),
 CONSTRAINT [UNIKALNE_KOL]  UNIQUE NONCLUSTERED 
(
	[id_repertuaru] ASC,
	[id_miejsca] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO
ALTER TABLE [mem].[tymczasowa_rezerwacja] ADD  CONSTRAINT [DATA_DODANIA]  DEFAULT (getdate()) FOR [czas_wyboru]
GO
ALTER TABLE [mem].[repertuar]  WITH CHECK ADD  CONSTRAINT [fk_id_filmu] FOREIGN KEY([id_filmu])
REFERENCES [mem].[filmy] ([id_filmu])
GO
ALTER TABLE [mem].[repertuar] CHECK CONSTRAINT [fk_id_filmu]
GO
ALTER TABLE [mem].[repertuar]  WITH CHECK ADD  CONSTRAINT [fk_id_sali] FOREIGN KEY([id_sali])
REFERENCES [mem].[sale_kinowe] ([id_sali])
GO
ALTER TABLE [mem].[repertuar] CHECK CONSTRAINT [fk_id_sali]
GO
ALTER TABLE [mem].[rezerwacja]  WITH CHECK ADD  CONSTRAINT [fk_id_repertuaru] FOREIGN KEY([id_repertuaru])
REFERENCES [mem].[repertuar] ([id_repertuaru])
GO
ALTER TABLE [mem].[rezerwacja] CHECK CONSTRAINT [fk_id_repertuaru]
GO
ALTER TABLE [mem].[rezerwacja]  WITH CHECK ADD  CONSTRAINT [fk_id_rodzaj_bil] FOREIGN KEY([id_rodzaju_biletu])
REFERENCES [mem].[rodzaje_biletów] ([id_rodzaju_biletu])
GO
ALTER TABLE [mem].[rezerwacja] CHECK CONSTRAINT [fk_id_rodzaj_bil]
GO
