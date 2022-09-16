CREATE OR REPLACE FUNCTION mi.fn_get_attribute_score(varA TEXT, varVN TEXT)
RETURNS INT

LANGUAGE plpgsql AS $$

DECLARE 
 result INT;
 default_val INT DEFAULT 0;

BEGIN 
    IF varA = 'vacancies_cnt' THEN 
        default_val = 30;
    END IF;


    BEGIN
        SELECT value_score
        INTO result
        FROM mi.t_attributes_score
        WHERE area = varA 
        AND value_name = varVN;

        RETURN COALESCE(result, default_val);
    END; 
END;
$$;

