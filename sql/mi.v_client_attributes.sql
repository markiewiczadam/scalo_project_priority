CREATE OR REPLACE VIEW mi.v_client_attributes AS 

    SELECT 
     cc.client_corporation_id
    ,cc.corporation_name
    ,COALESCE(ca.client_type, '-') as client_type	
    ,COALESCE(ca.client_probability, '-')	as client_probability
    ,COALESCE(ca.client_recruitment, '-')	as client_recruitment
    ,COALESCE(ca.client_relations, '-') as client_relations
    FROM mi.v_client_corporation cc 
    LEFT JOIN mi.t_client_attributes ca
        ON cc.client_corporation_id = ca.client_corporation_id
    WHERE client_activity_status = 'Active'



