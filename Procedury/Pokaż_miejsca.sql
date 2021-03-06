USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[pokaż_miejsca]    Script Date: 29.06.2022 23:06:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
Procedura pokazuje wolne miejsca na wybrany przez użytkownika seans.
*/
ALTER     proc [mem].[pokaż_miejsca]
@nazwa_filmu as varchar(50),
@data_seansu as date,
@godzina_seansu as varchar(5)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER  
  AS   
  BEGIN ATOMIC   
  WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english') 
----Deklaracja zmiennych
declare @id_filmu      as int
	select @id_filmu = id_filmu 
	  from mem.filmy 
	  where nazwa_filmu = @nazwa_filmu
declare @id_dnia       as int
	select @id_dnia = id_dnia 
	  from mem.kalendarz 
	 where dzień = @data_seansu
declare @id_repertuaru as int
declare @pojemność     as int
----Odnalezienie odpowiednich danych wskazanych w paramterach i przekazanie ich do zmiennych
	select 
		   @pojemność     = sk.pojemność
		 , @id_repertuaru = r.id_repertuaru 
	  from mem.repertuar   as r
inner join mem.sale_kinowe as sk
	    on sk.id_sali = r.id_sali
	 where r.id_filmu = @id_filmu 
	   and r.id_data  = @id_dnia 
	   and r.godzina  = @godzina_seansu
----Wskazanie wolnych miejsc, które mogą zostać wybrane przez użytkownika
	select id_liczby as 'wolne miejsca' 
	  from mem.liczby
	 where id_liczby <= @pojemność 
	   and id_liczby not in
		(
			select id_miejsca 
			  from mem.tymczasowa_rezerwacja
			 where id_repertuaru = @id_repertuaru
		 union all
			select id_miejsca 
			  from mem.rezerwacja
			 where id_repertuaru = @id_repertuaru
		)
end