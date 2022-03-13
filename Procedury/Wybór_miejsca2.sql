USE [Bilet_kinowy_inmemory]
GO
/****** Object:  StoredProcedure [mem].[wybór_miejsca2]    Script Date: 13.03.2022 21:52:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	 Za sprawą procedury, użytkownik wybiera miejsce na wyznaczony seans.
	 Ponowny wybór tego samego miejsca przez tą samą sesję, 
	 powoduje usunięcie miejsca z wybranych.
	 Procedura sprawdza czy miejsce jest wolne. Wybór miejsca dozwolony 
	 jest do 15 minut przed sensem
*/
ALTER     proc [mem].[wybór_miejsca2]
@nazwa_filmu as varchar(50),
@data_seansu as date,
@godzina_seansu as varchar(5),
@miejsce as smallint
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER  
AS   
BEGIN ATOMIC   
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english') 
select id from dbo.t1
	declare @id_sesji as smallint
		select @id_sesji = @@spid
	declare @id_filmu as smallint
		select @id_filmu = id_filmu from mem.filmy where nazwa_filmu = @nazwa_filmu
	declare @id_dnia as smallint
		select @id_dnia = id_dnia from mem.kalendarz where dzień = @data_seansu		
	declare @id_repertuaru as smallint
	declare @pojemność as smallint
select 
@id_repertuaru = r.id_repertuaru,
@pojemność = sk.pojemność
from mem.repertuar as r
inner join
mem.sale_kinowe as sk
on sk.id_sali = r.id_sali
where r.id_filmu = @id_filmu 
and r.id_data = @id_dnia and r.godzina = @godzina_seansu
	declare @id_miejsca as smallint
	set @id_miejsca = 
	(
		select id_miejsca from mem.tymczasowa_rezerwacja where 
		id_repertuaru = @id_repertuaru and id_miejsca = @miejsce 
		and id_sesji = @id_sesji
	)
	declare @id_miejsca2 as smallint
	set @id_miejsca2 = (select id_miejsca from mem.rezerwacja where id_miejsca = @miejsce and id_repertuaru
							= @id_repertuaru)
declare @licz_id as smallint
set @licz_id = (select count(id_sesji) from mem.tymczasowa_rezerwacja
				 where id_sesji = @id_sesji)
if @licz_id <=2 
begin
	if @miejsce > @pojemność or @miejsce < 1
		begin
			select 'Miejsce niepoprawne'
		end
	else
		begin
			if datediff(minute,getdate(),(concat_ws(' ',@data_seansu,@godzina_seansu))) >= 15 
				begin 
					if @id_miejsca2 is null
					begin 
						if @id_miejsca is null
							begin
								insert into mem.tymczasowa_rezerwacja(id_repertuaru,id_miejsca,id_sesji,id_data)
								values(@id_repertuaru,@miejsce,@id_sesji,@id_dnia)
					end
		else
					begin
						delete from mem.tymczasowa_rezerwacja
						where id_sesji = @id_sesji and id_miejsca = @miejsce and id_repertuaru = @id_repertuaru 
					end
				end

				else
					begin
						select 'Miejsca już zarezerwowano wcześniej'
					end	
		end
			else
					begin
						Select 'Rezerwacja już niemożliwa. Tylko do 15 minut przed seansem'
					end
			end
		end
else
begin
		select 'Możesz zarezerwować tylko trzy miejsca'
end
end
