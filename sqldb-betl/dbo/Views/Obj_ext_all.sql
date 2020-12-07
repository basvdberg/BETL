









-- select * from dbo.obj_ext_all
CREATE VIEW [dbo].[Obj_ext_all] AS
WITH q AS (SELECT        o.obj_id, o.obj_type_id, ot.obj_type, o.obj_name, o.parent_id, parent_o.obj_name AS parent, parent_o.parent_id AS grand_parent_id, grand_parent_o.obj_name AS grand_parent, 
                                                   grand_parent_o.parent_id AS great_grand_parent_id, great_grand_parent_o.obj_name AS great_grand_parent, o._create_dt, o._delete_dt, o._request_create_dt, o._request_delete_dt, o._record_dt, o._record_user,  
                                                   o.prefix, o.obj_name_no_prefix, ot.obj_type_level, st.server_type, o.server_type_id, o.identifier, o.src_obj_id, o.external_obj_id
												   --, dbo.get_prop_obj_id('source', o.obj_id) 
												   , pv.value _source
                         FROM            dbo.Obj AS o INNER JOIN
                                                   static.Obj_type AS ot ON o.obj_type_id = ot.obj_type_id INNER JOIN
                                                   static.Server_type AS st ON o.server_type_id = st.server_type_id LEFT OUTER JOIN
                                                   dbo.Obj AS parent_o ON o.parent_id = parent_o.obj_id LEFT OUTER JOIN
                                                   dbo.Obj AS grand_parent_o ON parent_o.parent_id = grand_parent_o.obj_id LEFT OUTER JOIN
                                                   dbo.Obj AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.obj_id
												   LEFT JOIN property_value pv on pv.property_id = 260 and pv.obj_id = o.obj_id

                         --WHERE        (o._delete_dt IS NULL)
						 ), q2 AS
    (SELECT        obj_id, obj_type, obj_name, 
                                CASE WHEN obj_type_level = 10 THEN [obj_name] WHEN obj_type_level = 20 THEN parent WHEN obj_type_level = 30 THEN grand_parent WHEN obj_type_level = 40 THEN great_grand_parent END AS srv, 
                                CASE WHEN obj_type_level = 20 THEN obj_name WHEN obj_type_level = 30 THEN parent WHEN obj_type_level = 40 THEN grand_parent ELSE NULL END AS db, 
                                CASE WHEN obj_type_level = 30 THEN obj_name WHEN obj_type_level = 40 THEN parent ELSE NULL END AS schema_name, CASE WHEN obj_type_level = 40 THEN obj_name ELSE NULL END AS schema_object
                                , _create_dt, _delete_dt, _request_create_dt, _request_delete_dt, _record_dt, _record_user, parent_id, grand_parent_id, great_grand_parent_id, prefix, obj_name_no_prefix, server_type, server_type_id, identifier,src_obj_id, external_obj_id, _source
      FROM            q AS q_1)
    SELECT        q2_1.obj_id, CASE WHEN obj_type IN ('user', 'server') THEN [obj_name] ELSE ISNULL(quotename(CASE WHEN srv <> 'LOCALHOST' THEN srv ELSE NULL END) + '.', '') + ISNULL(quotename(db), '') 
                              + ISNULL('.[' + [schema_name] + ']', '') + ISNULL('.[' + schema_object + ']', '') END AS full_obj_name, ISNULL(QUOTENAME(q2_1.schema_name) + '.', N'') + QUOTENAME(q2_1.schema_object) AS schema_obj_name
                              , q2_1.obj_type, q2_1.server_type, q2_1.obj_name, q2_1.srv AS server_name, q2_1.db AS db_name, q2_1.schema_name, q2_1.schema_object,  q2_1.parent_id, q2_1.grand_parent_id, 
                              q2_1.great_grand_parent_id, q2_1.server_type_id, q2_1._create_dt, q2_1._delete_dt, q2_1._request_create_dt, q2_1._request_delete_dt, q2_1._record_dt, q2_1._record_user, q2_1.prefix, q2_1.obj_name_no_prefix, p.default_template_id, q2_1.identifier, src_obj_id, external_obj_id, _source
     FROM            q2 AS q2_1 LEFT OUTER JOIN
                              dbo.Prefix AS p ON q2_1.prefix = p.prefix_name