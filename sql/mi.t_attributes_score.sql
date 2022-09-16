DROP TABLE IF EXISTS mi.t_attributes_score;

CREATE TABLE mi.t_attributes_score (
     area TEXT
    ,value_name TEXT 
    ,value_score INT 
    ,mod_date TIMESTAMP DEFAULT NOW()
); 