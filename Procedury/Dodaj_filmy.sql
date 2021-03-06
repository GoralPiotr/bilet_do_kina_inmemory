USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[dodaj_filmy]    Script Date: 29.06.2022 23:04:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 Za sprawą natywnie skompliowanej procedury dodajemy 
 filmy do tabeli mem.filmy. Zostają dodane tylko filmy, 
 który nie było wcześniej w bazie
*/
ALTER     procedure [mem].[dodaj_filmy]
(@dane mem.xmlowa readonly)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER  
  AS   
  BEGIN ATOMIC   
  WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
----Odczytane dane zostają dodane do tabeli mem.filmy
insert into mem.filmy
select distinct 
	   d.nazwa_filmu 
  from @dane as d
 where d.nazwa_filmu 
				not in  (
						  select nazwa_filmu 
						    from mem.filmy
						)
end