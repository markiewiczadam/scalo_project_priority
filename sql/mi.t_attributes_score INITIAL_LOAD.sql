INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('client_type', 'strategic', 100)
    ,('client_type', 'prospect strategic', 75)
    ,('client_type', 'normal', 50)
    ,('client_type', 'longtail', 20)
    ,('client_type', 'prospect', 15);

INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('client_probability', 'exclusion recrutation', 100)
    ,('client_probability', 'high', 75)
    ,('client_probability', 'average', 50)
    ,('client_probability', 'low', 20);
    
INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('client_recruitment', 'very fast', 100)
    ,('client_recruitment', 'fast', 75)
    ,('client_recruitment', 'normal', 50)
    ,('client_recruitment', 'slow', 25)
    ,('client_recruitment', 'very slow', 10);

INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('client_relations', 'partnership relations', 30)
    ,('client_relations', 'good relations', 20)
    ,('client_relations', 'new client', 10);

INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('vacancy_exception', 'EX #0', 50)
    ,('vacancy_exception', 'EX #1', 20)
    ,('vacancy_exception', 'EX #2', 10)
    ,('vacancy_exception', 'EX #-1', -50);
    
INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('vacancies_cnt', '5', 25)
    ,('vacancies_cnt', '4', 20)
    ,('vacancies_cnt', '3', 15)
    ,('vacancies_cnt', '2', 10)
    ,('vacancies_cnt', '1', 5);

INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('tech_stack', '.Net', 100)
    ,('tech_stack', 'JVM', 100)
    ,('tech_stack', 'Python', 100)
    ,('tech_stack', 'Testing', 75)
    ,('tech_stack', 'C/C++', 50)
    ,('tech_stack', 'Client-side JS', 50)
    ,('tech_stack', 'Server-side JS', 35)
    ,('tech_stack', 'Cloud', 25)
    ,('tech_stack', 'PHP', 15)
    ,('tech_stack', 'Relational DB', 10)
    ,('tech_stack', 'Mobile', 5);

INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('margin', '4000', 80)
    ,('margin', '3500', 70)
    ,('margin', '3000', 60)
    ,('margin', '2500', 50)
    ,('margin', '2000', 40)
    ,('margin', '1500', 30)
    ,('margin', '1000', 20)
    ,('margin', '500', 10);

INSERT INTO mi.t_attributes_score (area, value_name, value_score) VALUES 
     ('job_role', 'todo', 999);
