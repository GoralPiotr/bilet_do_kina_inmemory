USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[rezerwacja_biletu]    Script Date: 24.03.2022 22:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Za sprawą procedury, użytkownik dokonuje rezerwacji wybranych 
uprzednio miejsc.
Następuje obliczenie ceny całkowitej, zarezerwowanych biletów
*/
ALTER     proc [mem].[rezerwacja_biletu]
@email varchar(50),
@rodzaj_biletu1 varchar(10) = 'Normalny',
@rodzaj_biletu2 varchar(10) = 'Normalny',
@rodzaj_biletu3 varchar(10) = 'Normalny'
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER  
  AS   
  BEGIN ATOMIC   
  WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
-------------------------------------------------------
declare @id_sesji as int
set @id_sesji = (select @@SPID)
-------------------------------------------------------
declare @procrezerwująca as mem.tab_rezerwująca 
-------------------------------------------------------
insert into @procrezerwująca (id_repertuaru,id_miejsca,id_data,email)
select 
	 tr.id_repertuaru
	,tr.id_miejsca
	,tr.id_data
	,@email
from mem.tymczasowa_rezerwacja as tr
where tr.id_sesji = @id_sesji 
and tr.id_miejsca not in (select id_miejsca from mem.rezerwacja
where id_repertuaru in (select id_repertuaru from mem.tymczasowa_rezerwacja))
-------------------------------------------------------			
delete from mem.tymczasowa_rezerwacja
where id_sesji = @id_sesji
-------------------------------------------------------
declare @id_rodzaju_biletu1 as smallint
set @id_rodzaju_biletu1 =
(
	select id_rodzaju_biletu from mem.rodzaje_biletów 
	where nazwa_biletu = @rodzaj_biletu1
)
declare @id_rodzaju_biletu2 as smallint
set @id_rodzaju_biletu2 =
(
	select id_rodzaju_biletu from mem.rodzaje_biletów 
	where nazwa_biletu = @rodzaj_biletu2
)
declare @id_rodzaju_biletu3 as smallint
set @id_rodzaju_biletu3 =
(
	select id_rodzaju_biletu from mem.rodzaje_biletów 
	where nazwa_biletu = @rodzaj_biletu3
)
-------------------------------------------------------
update @procrezerwująca
set id_rodzaju_biletu  = @id_rodzaju_biletu1
where id = 1
update @procrezerwująca
set id_rodzaju_biletu  = @id_rodzaju_biletu2
where id = 2
update @procrezerwująca
set id_rodzaju_biletu  = @id_rodzaju_biletu3
where id = 3
-------------------------------------------------------
select 
	 id_repertuaru
	,id_miejsca
	,id_data
	,email
	,id_rodzaju_biletu 
from @procrezerwująca
-------------------------------------------------------
insert into mem.rezerwacja(id_repertuaru,id_miejsca,id_data,email,id_rodzaju_biletu)
select 
	 id_repertuaru
	,id_miejsca
	,id_data
	,email
	,id_rodzaju_biletu 
from @procrezerwująca
-------------------------------------------------------
declare @suma as money
set @suma = (
				select 
					sum(rb.cena_biletu) 
				from @procrezerwująca as r 
				inner join mem.rodzaje_biletów as rb
				on rb.id_rodzaju_biletu = r.id_rodzaju_biletu
			)
declare @godzina_seansu as varchar(5)
set @godzina_seansu = (
						select 
							distinct godzina 
						from @procrezerwująca as rr 
						inner join mem.repertuar as r
						on rr.id_repertuaru = r.id_repertuaru
					  )
declare @zniżka as money
if @godzina_seansu < '15:30'
	begin
		set @zniżka = 0.25
	end
else
	begin
		set @zniżka = 0
	end
select ceiling(@suma - (@suma * @zniżka)) as 'kwota do zapłaty'
end