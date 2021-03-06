USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[wybór_miejsca]    Script Date: 29.06.2022 23:09:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	 Za sprawą procedury, użytkownik wybiera miejsce na wyznaczony seans.
	 Ponowny wybór tego samego miejsca przez tą samą sesję, 
	 powoduje usunięcie miejsca z wybranych. 
	 Procedura sprawdza czy miejsce jest wolne. Wybór miejsca dozwolony 
	 jest do 15 minut przed sensem. Do Procedury dodano tabele która 
	 będzie otwierać się kilka sekund uzyte ze względu na brak opcji "wait fordelay"
*/
ALTER   proc [mem].[wybór_miejsca]
@nazwa_filmu as varchar(50),
@data_seansu as date,
@godzina_seansu as varchar(5),
@miejsce as smallint
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER  
AS   
BEGIN ATOMIC   
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english') 
-------------------------------------------------------
-----Przypisanie zmiennych
declare @id_sesji as smallint 
		select @id_sesji = @@spid
declare @id_filmu as smallint
		select @id_filmu = id_filmu 
		  from mem.filmy 
		 where nazwa_filmu = @nazwa_filmu
declare @id_dnia  as smallint
		select @id_dnia = id_dnia 
		from mem.kalendarz 
	   where dzień = @data_seansu		
declare @id_repertuaru as int
declare @pojemność as smallint	
----Przypisanie zmiennych @id_repertuaru oraz @pojemność które zostaną wykorzystane w daleszej cześci kodu
		   select @id_repertuaru = r.id_repertuaru
				, @pojemność = sk.pojemność
		     from mem.repertuar   as r
	   inner join mem.sale_kinowe as sk
		       on sk.id_sali = r.id_sali
			where r.id_filmu = @id_filmu 
			  and r.id_data = @id_dnia 
			  and r.godzina = @godzina_seansu
----Sprawdzenie ile użytkownik wybrał już miejsc
declare @licz_id as smallint
    set @licz_id = (select count(id_sesji) 
	                  from mem.tymczasowa_rezerwacja
				     where id_sesji = @id_sesji)
----Sprawdzenie czy miejsce na wybrany repertuar nie zostało zarezerwowane poprzednio przez innego użytkownika
declare @id_miejsca1 as int
						select @id_miejsca1 = id_miejsca 
						  from mem.rezerwacja 
						 where id_repertuaru = @id_repertuaru 
						   and id_miejsca = @miejsce
----Sprawdzenie czy miejsce na wybrany repertuar nie zostało wybrane poprzednio przez innego użytkownika
declare @id_miejsca2 as int
						select @id_miejsca2 = id_miejsca 
						  from mem.tymczasowa_rezerwacja 
						 where id_repertuaru = @id_repertuaru 
						   and id_miejsca = @miejsce 
						   and id_sesji <> @id_sesji
----Sprawdzenie czy miejsce na wybrany repertuar nie zostało zarezerwowane poprzednio przez obecnego użytkownika
----w przypadku odpowiedzi twerdzącej procedura usuwa dane miejsce. 
declare @id_miejsca3 as int
						select @id_miejsca3 = id_miejsca 
						  from mem.tymczasowa_rezerwacja 
						 where id_repertuaru = @id_repertuaru 
						   and id_miejsca = @miejsce 
						   and id_sesji = @id_sesji
-----Przypisanie odpowiednich zmiennych i wykonanie całego polecenia
if datediff(minute,getdate(),(concat_ws(' ',@data_seansu,@godzina_seansu))) < 15
begin
	select 'Wybór możliwy tylko do 15 minut' as komunikat
end
else
	if @miejsce > @pojemność or @miejsce < 1
			begin
				select 'Miejsce niepoprawne' as komunikat 
			end
	else 
	if @id_miejsca1 is not null
		begin
			Select 'Miejsce już zarezerwowne przez inną osobę' as komunikat
		end
	else
	begin
			if @id_miejsca2 is not null
				begin 
					Select 'Miejsce już wybrane przez inną osobę' as komunikat
				end
			else 
				begin
					if @id_miejsca3 is not null
						begin 
							delete from mem.tymczasowa_rezerwacja
							      where id_sesji = @id_sesji 
								    and id_miejsca = @miejsce 
									and id_repertuaru = @id_repertuaru
							Select 'Skasowano miejsce nr  '+ cast(@miejsce as char(3)) as wybór
						end
						else
						begin
							if @licz_id < 3
								begin
									insert into mem.tymczasowa_rezerwacja(id_repertuaru,id_miejsca,id_sesji,id_data)
									values(@id_repertuaru,@miejsce,@id_sesji,@id_dnia)
									Select 'Wybrano miejsce nr  '+ cast(@miejsce as char(3)) as wybór
								end
							else 
								begin
									select 'Możesz wybrać tylko 3 miejsca' as komunikat
								end
						end
				end
	end
-------------------------------------------------------
-------------------------------------------------------
end