USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[kasowanie]    Script Date: 29.06.2022 23:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Zadaniem procedury jest usunięcie danych z tabel repertuar,rezerwacja
danych dotyczący seansów,które już się odbyły. Dane przekazane do dwóch innych tabel 
*/ 
ALTER     proc [mem].[kasowanie]
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER  
AS   
BEGIN ATOMIC   
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english') 
-------------------------------------------------------
declare @data     as date = getdate()
declare @id_dzień as int
set @id_dzień = 
				(
					 select id_dnia 
					   from mem.kalendarz 
					  where dzień = @data
				 )
-------------------------------------------------------
insert into mem.historia_rezerwacji
select id_rezerwacji
	 , id_repertuaru
	 , id_miejsca
	 , email
	 , id_rodzaju_biletu 
  from mem.rezerwacja
 where id_repertuaru in 
						(
							select id_repertuaru 
							  from mem.repertuar 
							 where id_data < @id_dzień
						)
-------------------------------------------------------
insert into mem.historia_repertuaru
select id_repertuaru
	 , id_sali
	 , id_filmu
	 , id_data
	 , godzina 
  from mem.repertuar
 where id_data < @id_dzień
-------------------------------------------------------
delete from mem.rezerwacja
      where id_data < @id_dzień
-------------------------------------------------------
delete from mem.repertuar
      where id_data < @id_dzień
end