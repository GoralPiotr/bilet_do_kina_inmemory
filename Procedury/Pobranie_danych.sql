USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [dbo].[pobranie_danych]    Script Date: 24.03.2022 21:37:39 ******/
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
-------------------------------------------------------
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
-------------------------------------------------------
exec mem.dodaj_filmy 
@dane
-------------------------------------------------------
insert into d_repertuar
exec mem.dodaj_repertuar
@dane

end 