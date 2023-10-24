-- Заполнение таблиц слов
--Если вам не нужно такое кол-во, то ограничте SELECT командой TOP()

--тут задать путь до файлов
DECLARE 
@path_verbs_morf nvarchar(255) = '',
@path_nouns_morf nvarchar(255) = '',
@path_adjectives_morf nvarchar(255) = '',
@TSQL nvarchar(MAX) = ''

SET @TSQL = '
INSERT INTO [dbo].[words-russian-verbs-morf] (
	   [IID]
      ,[word]
      ,[code]
      ,[code_parent]
      ,[plural]
      ,[gender]
      ,[transit]
      ,[perfect]
      ,[face]
      ,[kind]
      ,[time]
      ,[inf]
      ,[vozv]
      ,[nakl])
SELECT 
--TOP(1000)
* FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0;Database='+@path_verbs_morf+';HDR=YES'', ''SELECT * FROM [Лист1$A1:N]'') 
'

EXECUTE sp_executesql @TSQL,N''


SET @TSQL = '
INSERT INTO [dbo].[words-russian-nouns-morf] (
	   [IID]
      ,[word]
      ,[code]
      ,[code_parent]
      ,[plural]
      ,[gender]
      ,[wcase]
      ,[soul]
      ,[ID]
	 )
SELECT 
--TOP(1000)
* FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0;Database='+@path_nouns_morf+';HDR=YES'', ''SELECT * FROM [Лист1$A1:I]'') 
'

EXECUTE sp_executesql @TSQL,N''

SET @TSQL = '
INSERT INTO [dbo].[words-russian-adjectives-morf] (
	  [IID]
      ,[word]
      ,[code]
      ,[code_parent]
      ,[type_sub]
      ,[plural]
      ,[gender]
      ,[wcase]
      ,[comp]
      ,[short]
	 )
SELECT 
--TOP(1000)
* FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0;Database='+@path_adjectives_morf+';HDR=YES'', ''SELECT * FROM [Лист1$A1:J]'')
'
EXECUTE sp_executesql @TSQL,N''
