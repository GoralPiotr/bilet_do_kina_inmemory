USE [Bilet_kinowy_inmemory]
GO
/****** Object:  UserDefinedFunction [mem].[licz_widzów]    Script Date: 13.03.2022 22:13:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- zadanie wylicz ile osób poszło na dany film
-- z rozróżnieniem do 15:30
ALTER   function [mem].[licz_widzów] (@id_filmu as smallint)
returns smallint 
WITH NATIVE_COMPILATION, SCHEMABINDING
AS   
BEGIN ATOMIC   
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
declare @suma as smallint
set @suma = 
(
	select COUNT(id_filmu) liczba_osób from mem.historia_rezerwacji as hrez
	inner join mem.historia_repertuaru as hrep
	on hrez.id_repertuaru =hrep.id_repertuaru
	where id_filmu = @id_filmu
	group by id_filmu
)
return isnull(@suma,0)
end