USE [Bilet_kinowy_inmemory]
GO
/****** Object:  Trigger [dbo].[d_dodajrepertuar]    Script Date: 24.03.2022 22:43:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Trigger stworzony ponieważ natywnie skompliowane procedury
nie posiadają funkcjonalności next value for a sama baza nie pozwala 
na opcję reseed w przypadku gdy chcemy zresetować funkcjonalność identity.
Trigger powoduje że zamiast przesłania danych do tabeli dyskowej
d_repertuar, dane zostają przekazane do tabeli mem.repertuar. 
*/
ALTER trigger [dbo].[d_dodajrepertuar] 
on [dbo].[d_repertuar] instead of insert
as
begin
insert into mem.repertuar
     select next value for mem.id_rep
	  , id_sali
	  , id_filmu
	  , id_data
	  , godzina 
      from  inserted
end