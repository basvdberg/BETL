	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-04-19 BvdB performs a very basic parsing of a sql statement. returns colom clause before first from 
	and first table after first from.  first record in @List is table, others are columns. 
declare @sql as varchar(8000) = '--aap
SELECT rel.naam_parent1 as top_relatie    ,rel.relatie_nummer as relatienummer    ,rel.naam as relatienaam    ,rel.kostenplaats_omschrvijving as kostenplaats    ,rpa as primaire_resource     ,regioteam    ,regioklantmanager as regioklantmanager    ,rel.cp_vz_naam_formeel as cp_naam    ,rel.cp_vz_email as cp_email    ,rel.cp_vz_telefoon as cp_telefoon       ,verzuimgevalnr    ,activiteit_id as activiteitID1       ,kld_herstel.datum as datum_invoer_herstel       ,kld_toegevoegd.datum as datum_toegevoegd    ,kld_verstuurd.datum as datum_versturen_uitnodiging    ,kld_verstuurd.jaar    ,kld_verstuurd.kortmaandnaam as maand       ,uitgenodigd.omschrijving as uitgenodigd       ,niet_uitgenodigd.reden_niet_uitgenodigd       ,ingevuld.ckto_ingevuld       ,kld_ingevuld.datum datum_ckto_ingevuld   FROM [feit_ckto_response] ckto   left outer join dim_Relatie as rel on ckto.dkey_relatie = rel.dkey_relatie --  left outer join dim_professional prof on rel.dkey_primaire_resource = prof.dkey_professional   left outer join dim_kalender as kld_herstel on ckto.dkey_datum_invoer_herstel = kld_herstel.dkey_kalender   left outer join dim_kalender as kld_toegevoegd on ckto.dkey_datum_toegevoegd = kld_toegevoegd.dkey_kalender   left outer join dim_kalender as kld_verstuurd on ckto.dkey_datum_versturen_uitnodiging = kld_verstuurd.dkey_kalender   left outer join dim_kalender as kld_ingevuld on ckto.dkey_datum_ckto_ingevuld = kld_ingevuld.dkey_kalender   left outer join dim_ja_nee as uitgenodigd on ckto.dkey_uitgenodigd_voor_ckto_ja_nee = uitgenodigd.jn_key   left outer join dim_reden_niet_uitgenodigd as niet_uitgenodigd on ckto.dkey_reden_niet_uitgenodigd = niet_uitgenodigd.dkey_reden_niet_uitgenodigd   left outer join dim_ckto_ingevuld as ingevuld on ckto.dkey_ckto_ingevuld = ingevuld.dkey_ckto_ingevuld
'
set @sql ='SELECT [hub_relatie_sid]
      ,[type_account]
      ,[account_id]
      ,[account_code]
           ,[korting5_percentage]
FROM [feit_totaallijst_bb]
WHERE aap '
set @sql = 'SELECT [dkey_functie]       ,[functiegroep]       ,[functie]   FROM [dim_functie] WHERE dkey_functie in (  SELECT [dkey_functie]   FROM [dbo].[dim_professional]   where dkey_professional in (SELECT[dkey_professional_pa]   FROM [dbo].[dim_verzuim]))'
select * from util.parse_sql(@sql)
*/
CREATE function [util].[parse_sql] (@sql VARCHAR(MAX)
  ) RETURNS @List TABLE (item VARCHAR(8000), i int)
BEGIN
	declare @transfer_id as int = -1

	-- END standard BETL header code... 
	--set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID)
	
		, @i as int 
		, @pos_space as int 
		, @pos_char10 as int 
		, @pos_char13 as int 
		, @select_clause as varchar(8000)
		, @from_clause as varchar(8000)
	set @sql = util.remove_comments(@sql) 
	--print @proc_name		
	set @i = charindex('FROM', @sql, 0) 
	if isnull(@i,0) =0 
	begin
		--exec dbo.log @transfer_id, 'ERROR', 'no from found in sql query ?', @sql
		--print 'no from found in sql query ?'
		goto footer
	end
	-- split on first occurance of FROM 
	set @from_clause =substring(@sql,@i+4,len(@sql)-@i-3) 
	set @select_clause =replace(replace( substring(@sql,0, @i-1) ,'select', '')  , 'as','') 
	-- parse from clause 
	set @from_clause = ltrim(@from_clause) 
	set @pos_space  = charindex(' ', @from_clause,0)  
	if @pos_space = 0 set @pos_space = null 
	set @pos_char10 = charindex(char(10), @from_clause,0) 
	if @pos_char10 = 0 set @pos_char10 = null 
	set @pos_char13 = charindex(char(13), @from_clause,0) 
	if @pos_char13 = 0 set @pos_char13 = null 
	--insert into @List values ( 'pos_space', @pos_space ) 
	--insert into @List values ( '@pos_char10', @pos_char10 ) 
	--insert into @List values ( '@pos_char13', @pos_char13 ) 
	set @i = convert(int, util.udf_min3(@pos_space , @pos_char10 , @pos_char13 ) )
	if isnull(@i,0) =0 
			set @i= len(@from_clause) 
	set @from_clause = substring(@from_clause, 1, @i-1) 
	insert into @List values (@from_clause,0) 
	;
	with q as( 
		select ltrim(rtrim(util.filter(item,'char(10),char(13)'))) item 
		,i
		from util.split( @select_clause, ',') 
	) 
	insert into @List 
	select item
	, row_number() over (order by i) 
	from q 
	where len(item)>0
	
	--exec dbo.log @transfer_id, 'VAR', '@from_clause ?', @from_clause
--	exec dbo.log @transfer_id, 'VAR', '@select_clause ?', @select_clause
 
	footer:
 	--exec dbo.log @transfer_id, 'footer', 'DONE ?', @proc_name 
	return
END