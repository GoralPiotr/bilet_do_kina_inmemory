USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[dodaj_repertuar]    Script Date: 29.06.2022 23:05:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Procedura ma zadanie połączyć wynik z pliku xml z danymi zawartymi 
w bazie danych aby uzyskać wynik w postaci relacyjnej. Wynik zostanie
dodany do tabeli mem.repertuar
*/
ALTER     procedure [mem].[dodaj_repertuar]
(@dane mem.xmlowa readonly)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER  
  AS   
  BEGIN ATOMIC   
  WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
----Połączenie danych z tabel ze zmiena tabelaryczną
select tab.id_sali
	 , tab.id_filmu
	 , tab.id_dnia as id_data
	 , tab.godzina 
 from 
 (
	select d.id_sali
		 , f.id_filmu
		 , k.id_dnia
		 , godzina 
	  from @dane     as d
inner join mem.filmy as f
	    on f.Nazwa_filmu = d.Nazwa_filmu
inner join mem.kalendarz as k 
	    on k.dzień = d.dzień
) as tab
where not exists (
					select r.id_data
						 , r.id_sali
						 , r.godzina 
					  from mem.repertuar as r
					 where r.id_data = tab.id_dnia
					   and r.id_sali = tab.id_sali
					   and r.godzina = tab.godzina
				 )
end 