USE [Bilet_kinowy_inmemory]
GO
/****** Object:  UserDefinedFunction [mem].[f_wyświetlane_filmy2]    Script Date: 13.03.2022 22:06:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* za sprawą funkcji wyświetlamy repertuar w wskazanym dniu
*/
ALTER function [mem].[f_wyświetlane_filmy2] 
(@dzień as date)
RETURNS TABLE
WITH SCHEMABINDING,
     NATIVE_COMPILATION
as
Return (
         select f.Nazwa_filmu
              , r.godzina
              , k.dzień
           from mem.repertuar as r
     inner join mem.filmy     as f
             on f.id_filmu = r.id_filmu
     inner join mem.kalendarz as k
             on k.id_dnia = r.id_data
          where k.dzień >= @dzień 
            and k.dzień < DATEADD(dd,1,@dzień))