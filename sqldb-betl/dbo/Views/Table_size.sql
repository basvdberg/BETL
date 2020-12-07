
create view dbo.Table_size as 

SELECT o.NAME,
  i.rowcnt 
FROM dbo.sysindexes AS i
  INNER JOIN dbo.sysobjects AS o ON i.id = o.id 
WHERE i.indid < 2  AND OBJECTPROPERTY(o.id, 'IsMSShipped') = 0
--ORDER BY o.NAME