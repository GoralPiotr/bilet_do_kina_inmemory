USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[rezerwacja_biletu]    Script Date: 29.06.2022 23:08:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Za sprawą procedury, użytkownik dokonuje rezerwacji wybranych uprzednio miejsc.
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
-----Przypisanie do zmiennej @id_sesji, która zostanie wykorzystana w innym miejscu
declare @id_sesji as int
    set @id_sesji = (select @@SPID)
-----Przypisanie zmiennej tabelarycznej
declare @procrezerwująca as mem.tab_rezerwująca 
-----Dodanie danych do zmiennej tablearycznej
insert into @procrezerwująca (id_repertuaru,id_miejsca,id_data,email)
	 select tr.id_repertuaru
		  , tr.id_miejsca
		  , tr.id_data
		  , @email
	   from mem.tymczasowa_rezerwacja as tr
	  where tr.id_sesji = @id_sesji 
		and tr.id_miejsca not in 
								(
								  select id_miejsca 
								    from mem.rezerwacja
								   where id_repertuaru in 
								                         (select id_repertuaru 
														    from mem.tymczasowa_rezerwacja))
----usunięcie miejsc z tabeli mem.tymczasowa_rezerwacja,które zostały wybrane przez sesje użytkownika		
delete from mem.tymczasowa_rezerwacja
	  where id_sesji = @id_sesji
----Przypisanie zmiennej do wybranego paramteru odnosnie rodzaju biletów
declare @id_rodzaju_biletu1 as smallint
set @id_rodzaju_biletu1 =
						(
							select id_rodzaju_biletu 
							  from mem.rodzaje_biletów 
							 where nazwa_biletu = @rodzaj_biletu1
						)
declare @id_rodzaju_biletu2 as smallint
set @id_rodzaju_biletu2 =
						(
							select id_rodzaju_biletu 
							  from mem.rodzaje_biletów 
							 where nazwa_biletu = @rodzaj_biletu2
						)
declare @id_rodzaju_biletu3 as smallint
set @id_rodzaju_biletu3 =
						(
							select id_rodzaju_biletu 
							  from mem.rodzaje_biletów 
							 where nazwa_biletu = @rodzaj_biletu3
						)
----Aktualizacji zmiennej tabelarycznej o dokonany wybór biletów
update @procrezerwująca
   set id_rodzaju_biletu  = @id_rodzaju_biletu1
 where id = 1
update @procrezerwująca
   set id_rodzaju_biletu  = @id_rodzaju_biletu2
 where id = 2
update @procrezerwująca
   set id_rodzaju_biletu  = @id_rodzaju_biletu3
 where id = 3
----do tabeli mem.rezerwacja doddajemy pełne dane ze zmiennej tabelarycznej
insert into mem.rezerwacja(id_repertuaru,id_miejsca,id_data,email,id_rodzaju_biletu)
	 select id_repertuaru
		  , id_miejsca
		  , id_data
		  , email
		  , id_rodzaju_biletu 
	   from @procrezerwująca
----Podsumowanie złożonego zamówienia wraz z całkowitą kwotą zakupu
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