USE [Bilet_kinowy_inmemory]
GO
/****** Object:  UserDefinedFunction [mem].[suma_zarobków]    Script Date: 13.03.2022 22:14:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Funkcja UDF pokazująca sumę zarobków za danycn film
*/
ALTER   function [mem].[suma_zarobków] (@id_filmu as int)
returns money
WITH NATIVE_COMPILATION, SCHEMABINDING,EXECUTE AS OWNER 
AS   
BEGIN ATOMIC   
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
declare @suma as money
set @suma = 
(
select cast(SUM(zarobek) as decimal (5,2)) as zarobek from 
(
	select rep.id_filmu, 
	case when rep.godzina < '15:30:00' 
	then ceiling(SUM(rb.cena_biletu) - SUM(rb.cena_biletu)*0.25)
	else SUM(rb.cena_biletu) end as Zarobek
	from mem.rodzaje_biletów as rb
	inner join mem.historia_rezerwacji as r
	on r.id_rodzaju_biletu = rb.id_rodzaju_biletu
	inner join mem.historia_repertuaru as rep
	on rep.id_repertuaru = r.id_repertuaru
	where rep.id_filmu = @id_filmu
	group by id_filmu,rep.godzina
) as a
group by a.id_filmu
)
Return isnull(@suma,0)
end

