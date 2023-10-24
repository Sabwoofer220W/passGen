
DECLARE 
-- ��������� ��������� ����� �����������
@rnd1		varchar(5) = CAST(CAST(RAND() * 9 +1 as INT) as varchar),	-- ������ ������ != 0
@rnd2		varchar(5) = CAST(CAST(RAND() * 10 as INT) as varchar),		-- ������ ������
@rnd3		varchar(5) = CAST(CAST(RAND() * 10 as INT) as varchar),		-- ������ ������
@rnd4		varchar(5),		-- ���������� ��� �������� � ������ ����� ������
@pur_id1	int,			-- ���������� ��� ����������� - �������������
@pur_id2	int,			-- ���������� ��� ����������� - �������������
@pur_id3	int,			-- ���������� ��� ����������� - �������������
@wcase_id	varchar(5),		-- ���������� ��� ����������� - �����
@wcase_id2	varchar(5),		-- ���������� ��� ����������� - �����
@face_id	varchar(5),		-- ���������� ��� ����������� - ����
@gender		varchar(150),	-- ���������� ��� ����������� - ���
@gender2	varchar (50),	-- ���������� ��� ����������� - ���
@R			varchar(5),		-- ���������� ��� ����������� - ��������� (����� 2)
@R2			varchar(5),		-- ���������� ��� ����������� - ��������� (����� 1)
@1			varchar (50),	-- ���������� ��� ��������� - ����� 2
@2			varchar (50),	-- ���������� ��� ��������� - ����� 3
@3			varchar (50),	-- ���������� ��� ��������� - ����� 4
--//////////////////////////////////////////////////////////////////////////////////////////
@4			varchar (150),	-- ���������� ��� ��������� - ��������� ����� �� ������� 
@6			varchar (50),	-- ���������� ��� ��������� - ������
@Kol_simv	int				-- ���������� ��� �������	- ���������� �������� �� ������� �����
--/////////////////////////////////////////////////////////////////////////////////////////
-- ������ ���������� �������� �� ������� �����
set @Kol_simv = 3
-- �������� ����� ������ (������)
set	@rnd4		= @rnd1+@rnd2+@rnd3
-- ���������� ��������������� � ����������� �� ��������� ����� ��� ������� ����
set @pur_id1	= case when @rnd3 in ('1','3') then 0 else 1 end 
set @pur_id2	= case when @rnd3 in ('1')		then 0 else 1 end
-- ���������� ��� � ����������� �� ��������� ����� ��� ������� �����2
set @gender		= case when @rnd3 ='3' then '���'  else '%' end
-- ������������ �����2 ���������� '�' ���� �� ���� 
set @R			= case when @rnd3 ='3' then '�'  else '%' end
-- ���������� ����� �����2 � ����������� �� ��������� ����� ��� ������� ����
set @wcase_id	= case when @rnd3 ='1' then '��' 
					when @rnd3 in ('2','4','0') then '���'
					when @rnd3 in ('3','5','6','7','8','9') then '���' end
-- ���������� ����� �����3 � ����������� �� ��������� ����� ��� ������� ����
set @wcase_id2	= case when @rnd3 ='1' then '��' 	else '���' end
-- �������� �� ��������� ������� ���������� ���� � ����� �����
SELECT [word]	into #1tmp
	FROM [dbo].[words-russian-nouns-morf]
	where [word] not like '%-%' and [word] like '____%' and right([word], 1) like @R and [plural] = @pur_id1 and [wcase] = @wcase_id and [gender] like @gender and soul =1  
SELECT  [word]	into #2tmp
	FROM [dbo].[words-russian-verbs-morf]
	where [word] not like '%-%' and [word] like '____%' and [plural] = @pur_id2 and face = '3-�' and [time]='����' and  transit !='�����'
SELECT  [word]	into #3tmp
	FROM [dbo].[words-russian-nouns-morf]
	where [word] not like '%-%' and [word] like '____%' and [plural] =0	and [wcase] ='���' and soul =1
-- �������� �� ������ ���������� ����� �� �������
-- ��������� ������ ������ � ������� �������
-- ��� ���� 2,3,4
set @1 = (select top 1 * from (select top 1 percent * from #1tmp order by newid()) s) 
set @1 = STUFF(@1, 1,1, UPPER(left(@1, 1)))
set @2 = (select top 1 * from (select top 1 percent * from #2tmp order by newid()) s )
set @2 =STUFF(@2, 1,1, UPPER(left(@2, 1)))
set @3 = (select top 1 * from (select top 1 percent * from #3tmp order by newid()) s )
set @3 =STUFF(@3, 1,1, UPPER(left(@3, 1)))
-- ���������� ��� ��� �����1 � ����������� �� ����� ������ � ���� �����2
set @gender2	= case	when @rnd3 = '1' then (select ''+gender+'' from [dbo].[words-russian-nouns-morf] where word = @1 and gender like @gender and  [plural] = @pur_id1 and [wcase] = @wcase_id and soul =1  and right([word], 1) like @R)
						else '' end
-- ���������� ��������� �����1 � ����������� �� ����� ������
set @R2			= case	when @rnd3 !='1' then '�'  
						else '%' end
-- ���������� ��������������� �����1 � ����������� �� ���� �����1
set @pur_id3	= case	when @gender2 = '' THEN '1' 
						else '0' end
-- �������� �� ��������� ������� ���������� �����1
select [word]
	into #4tmp
	from [dbo].[words-russian-adjectives-morf]
	where  [gender] like @gender2 and [word] like '____%'  and [plural] = @pur_id3 and [wcase] = @wcase_id2  and comp is null and right([word], 1) like @R2
-- �������� �� ������ ���������� ����� �� �������
-- ��������� ������ ������ � ������� �������
-- ��� �����1
set @6 = (select top 1 * from (select top 1 percent * from #4tmp order by newid()) s) 
set @6 = STUFF(@6, 1,1, UPPER(left(@6, 1)))
-- �������� ��������� ����� �� �������
set @4 =(select @rnd4+' '+@6+' '+@1+' '+@2+' '+@3)
select @4
-- ������ ��������� ��� ������� ����� (��� ������� ������� ��������, �.�. ��������� ������� ���������� � ������)
set @1 = (select translate((STUFF(@1, 1,1,(translate(left(@1, 1) , '��������������������������������','QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')))),'��������������������������������','qwertyuiop[]asdfghjkl;''zxcvbnm,.'))
set @2 = (select translate((STUFF(@2, 1,1,(translate(left(@2, 1) , '��������������������������������','QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')))),'��������������������������������','qwertyuiop[]asdfghjkl;''zxcvbnm,.'))
set @3 = (select translate((STUFF(@3, 1,1,(translate(left(@3, 1) , '��������������������������������','QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')))),'��������������������������������','qwertyuiop[]asdfghjkl;''zxcvbnm,.'))
set @6 = (select translate((STUFF(@6, 1,1,(translate(left(@6, 1) , '��������������������������������','QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')))),'��������������������������������','qwertyuiop[]asdfghjkl;''zxcvbnm,.'))
-- �������� ������
select @rnd4+left(@6, @Kol_simv)+left(@1, @Kol_simv)+left(@2, @Kol_simv)+left(@3, @Kol_simv)  
-- ������� ��������� �������
DROP TABLE #1tmp
DROP TABLE #2tmp
DROP TABLE #3tmp
DROP TABLE #4tmp

