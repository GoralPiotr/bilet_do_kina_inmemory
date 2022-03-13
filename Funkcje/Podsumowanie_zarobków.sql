USE [Bilet_kinowy_inmemory]
GO
/****** Object:  UserDefinedFunction [mem].[podsumowanie_zarobków]    Script Date: 13.03.2022 22:09:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
*/
Za sprawą funkcji, możemy dowiedzieć się ile wyniósł przychód ze sprzedaży biletów
/*
ALTER   function [mem].[podsumowanie_zarobków] (@id_filmu as smallint)
returns table
WITH SCHEMABINDING,
     NATIVE_COMPILATION
Return
	select a.id_filmu,a.id_data, cast(SUM(zarobek) as decimal (6,2)) as zarobek 
	from
	(
		select rep.id_filmu,rep.id_data, godzina,
		case when rep.godzina < '15:30:00' 
		then ceiling(SUM(rb.cena_biletu) - SUM(rb.cena_biletu)*0.25)
		else SUM(rb.cena_biletu) end as Zarobek
		from mem.rodzaje_biletów as rb
		inner join mem.rezerwacja as r
		on r.id_rodzaju_biletu = rb.id_rodzaju_biletu
		inner join mem.repertuar as rep
		on rep.id_repertuaru = r.id_repertuaru
		group by id_filmu,rep.godzina,rep.id_data
	) as a
	where a.id_filmu = @id_filmu or @id_filmu is null
	group by a.id_filmu,a.id_data