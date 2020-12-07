






	  
CREATE VIEW [dbo].[Col] AS
	SELECT     * 
	FROM  [dbo].[Col_h] AS h
	WHERE     (_eff_dt =
                      ( SELECT     MAX(_eff_dt) max_eff_dt
                        FROM       [dbo].[Col_h] h2
                        WHERE      h.column_id = h2.column_id
                       )
              )
		-- AND _delete_dt IS NULL