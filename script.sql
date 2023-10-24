
DECLARE 
-- формируем случайное число посимвольно
@rnd1		varchar(5) = CAST(CAST(RAND() * 9 +1 as INT) as varchar),	-- первый символ != 0
@rnd2		varchar(5) = CAST(CAST(RAND() * 10 as INT) as varchar),		-- второй символ
@rnd3		varchar(5) = CAST(CAST(RAND() * 10 as INT) as varchar),		-- третий символ
@rnd4		varchar(5),		-- переменная для перевода в строку ЧИСЛО ПАРОЛЯ
@pur_id1	int,			-- переменная для определения - множественное
@pur_id2	int,			-- переменная для определения - множественное
@pur_id3	int,			-- переменная для определения - множественное
@wcase_id	varchar(5),		-- переменная для определения - падеж
@wcase_id2	varchar(5),		-- переменная для определения - падеж
@face_id	varchar(5),		-- переменная для определения - лицо
@gender		varchar(150),	-- переменная для определения - пол
@gender2	varchar (50),	-- переменная для определения - пол
@R			varchar(5),		-- переменная для определения - окончания (слово 2)
@R2			varchar(5),		-- переменная для определения - окончания (слово 1)
@1			varchar (50),	-- переменная для получения - слова 2
@2			varchar (50),	-- переменная для получения - слова 3
@3			varchar (50),	-- переменная для получения - слова 4
--//////////////////////////////////////////////////////////////////////////////////////////
@4			varchar (150),	-- переменная для получения - парольной фразы на РУССКОМ 
@6			varchar (50),	-- переменная для получения - ПАРОЛЯ
@Kol_simv	int				-- переменная для задания	- КОЛИЧЕСТВО СИМВОЛОВ ИЗ КАЖДОГО СЛОВА
--/////////////////////////////////////////////////////////////////////////////////////////
-- задаем КОЛИЧЕСТВО СИМВОЛОВ ИЗ КАЖДОГО СЛОВА
set @Kol_simv = 3
-- получаем ЧИСЛО ПАРОЛЯ (строка)
set	@rnd4		= @rnd1+@rnd2+@rnd3
-- определяем множественность в зависимости от последней цифры для выборок слов
set @pur_id1	= case when @rnd3 in ('1','3') then 0 else 1 end 
set @pur_id2	= case when @rnd3 in ('1')		then 0 else 1 end
-- определяем ПОЛ в зависимости от последней цифры для выборок слова2
set @gender		= case when @rnd3 ='3' then 'муж'  else '%' end
-- ограничиваем слово2 окончанием 'а' если их трое 
set @R			= case when @rnd3 ='3' then 'а'  else '%' end
-- определяем падеж слова2 в зависимости от последней цифры для выборок слов
set @wcase_id	= case when @rnd3 ='1' then 'им' 
					when @rnd3 in ('2','4','0') then 'род'
					when @rnd3 in ('3','5','6','7','8','9') then 'вин' end
-- определяем падеж слова3 в зависимости от последней цифры для выборок слов
set @wcase_id2	= case when @rnd3 ='1' then 'им' 	else 'вин' end
-- выбираем во временные таблицы подходяшие друг к другу слова
SELECT [word]	into #1tmp
	FROM [dbo].[words-russian-nouns-morf]
	where [word] not like '%-%' and [word] like '____%' and right([word], 1) like @R and [plural] = @pur_id1 and [wcase] = @wcase_id and [gender] like @gender and soul =1  
SELECT  [word]	into #2tmp
	FROM [dbo].[words-russian-verbs-morf]
	where [word] not like '%-%' and [word] like '____%' and [plural] = @pur_id2 and face = '3-е' and [time]='наст' and  transit !='непер'
SELECT  [word]	into #3tmp
	FROM [dbo].[words-russian-nouns-morf]
	where [word] not like '%-%' and [word] like '____%' and [plural] =0	and [wcase] ='вин' and soul =1
-- выбираем по одному случайному слову из выборки
-- переводим первый символ в верхний регистр
-- для слов 2,3,4
set @1 = (select top 1 * from (select top 1 percent * from #1tmp order by newid()) s) 
set @1 = STUFF(@1, 1,1, UPPER(left(@1, 1)))
set @2 = (select top 1 * from (select top 1 percent * from #2tmp order by newid()) s )
set @2 =STUFF(@2, 1,1, UPPER(left(@2, 1)))
set @3 = (select top 1 * from (select top 1 percent * from #3tmp order by newid()) s )
set @3 =STUFF(@3, 1,1, UPPER(left(@3, 1)))
-- определяем пол для слова1 в зависимости от числа пароля и пола слова2
set @gender2	= case	when @rnd3 = '1' then (select ''+gender+'' from [dbo].[words-russian-nouns-morf] where word = @1 and gender like @gender and  [plural] = @pur_id1 and [wcase] = @wcase_id and soul =1  and right([word], 1) like @R)
						else '' end
-- определяем окончание слова1 в зависимости от числа пароля
set @R2			= case	when @rnd3 !='1' then 'х'  
						else '%' end
-- определяем множественность слова1 в зависимости от пола слова1
set @pur_id3	= case	when @gender2 = '' THEN '1' 
						else '0' end
-- выбираем во временную таблицу подходяшие слова1
select [word]
	into #4tmp
	from [dbo].[words-russian-adjectives-morf]
	where  [gender] like @gender2 and [word] like '____%'  and [plural] = @pur_id3 and [wcase] = @wcase_id2  and comp is null and right([word], 1) like @R2
-- выбираем по одному случайному слову из выборки
-- переводим первый символ в верхний регистр
-- для слова1
set @6 = (select top 1 * from (select top 1 percent * from #4tmp order by newid()) s) 
set @6 = STUFF(@6, 1,1, UPPER(left(@6, 1)))
-- получаем ПАРОЛЬНУЮ ФРАЗУ НА РУССКОМ
set @4 =(select @rnd4+' '+@6+' '+@1+' '+@2+' '+@3)
select @4
-- меняем раскладку для каждого слова (для первого символа отдельно, т.к. заглавные символы набираются с шифтом)
set @1 = (select translate((STUFF(@1, 1,1,(translate(left(@1, 1) , 'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ','QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')))),'йцукенгшщзхъфывапролджэячсмитьбю','qwertyuiop[]asdfghjkl;''zxcvbnm,.'))
set @2 = (select translate((STUFF(@2, 1,1,(translate(left(@2, 1) , 'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ','QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')))),'йцукенгшщзхъфывапролджэячсмитьбю','qwertyuiop[]asdfghjkl;''zxcvbnm,.'))
set @3 = (select translate((STUFF(@3, 1,1,(translate(left(@3, 1) , 'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ','QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')))),'йцукенгшщзхъфывапролджэячсмитьбю','qwertyuiop[]asdfghjkl;''zxcvbnm,.'))
set @6 = (select translate((STUFF(@6, 1,1,(translate(left(@6, 1) , 'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ','QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')))),'йцукенгшщзхъфывапролджэячсмитьбю','qwertyuiop[]asdfghjkl;''zxcvbnm,.'))
-- получаем ПАРОЛЬ
select @rnd4+left(@6, @Kol_simv)+left(@1, @Kol_simv)+left(@2, @Kol_simv)+left(@3, @Kol_simv)  
-- удаляем временные таблицы
DROP TABLE #1tmp
DROP TABLE #2tmp
DROP TABLE #3tmp
DROP TABLE #4tmp

