USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [dbo].[pobranie_danych]    Script Date: 29.06.2022 23:04:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Za sprawą procedury pobieramy dane z pliku xml 
Dane zostają przekonwertowane do formy relacyjnej 
i umieszczone w zmiennej tablearycznej skąd przesyłamy je
do natywnie skompilowanej procedury. 
*/
ALTER   PROCEDURE [dbo].[pobranie_danych]
WITH EXECUTE AS owner
AS
begin
-------------------------------------------------------
declare @dane as mem.xmlowa
-----Pobranie danych z pliku XML
declare @x as xml
	select @x = bulkcolumn from openrowset(bulk 'D:\SQL\XML\repertuar2.xml',single_blob) as tabela; 
declare @idoc int
	EXEC sp_xml_preparedocument @idoc OUTPUT, @x	
	insert into @dane 
		 SELECT * FROM OPENXML(@idoc, '/Seanse/film', 2)
		   WITH (
				  id_sali smallint, 
				  Nazwa_filmu varchar(50), 
				  dzień date,
				  godzina time(0)
			    )	
EXEC sp_xml_removedocument  @idoc
----Dane przekazane do procedury w celu daleszej obróbki. 
exec mem.dodaj_filmy 
@dane
/*
Dane uzyskane z procedury mem.dodaj_filmy zostają dodane 
do tabeli dyskowej d_repertuar. Na tabeli założony jest trigger
który przesyła dane do tabeli mem.repertuar. Powodem 
takie rozwiązanie jest brak w tabelach pamieciowych opcji next value for
oraz reesed. 
*/
insert into d_repertuar
exec mem.dodaj_repertuar
@dane
end 