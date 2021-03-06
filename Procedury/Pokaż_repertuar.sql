USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[pokaż_repertuar]    Script Date: 29.06.2022 23:07:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
Procedura z wykorzystaniem natywnej funkcji inline pokazuje 
repertuar na wybrany przez użytkownika dzień
*/
ALTER         procedure [mem].[pokaż_repertuar]
(@data as date = null)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER  
  AS   
  BEGIN ATOMIC   
  WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
--------------------------------------------	
	set @data = ISNULL(@data, getdate())
	select nazwa_filmu
		 , STRING_AGG(godzina, ',') within group (order by godzina) as godziny
	  from mem.f_wyświetlane_filmy(@data)
  group by Nazwa_filmu
end 