CREATE OR REPLACE VIEW mi.v_vacancy_priority_rank AS WITH 

-- policz ile wakatów ma klient
 vac_cnt AS (
                    SELECT client_corporation_id, COUNT(*) as vac_cnt 
                    FROM mi.v_vacancy
                    WHERE vacancy_status IN ('Active')   -- policz tylko aktywne wakaty
                    GROUP BY client_corporation_id
                )

-- pobierz dodatkowe oceny dla wakatu
,vac_add_rank AS (
                    SELECT ar.vacancy_id, SUM(ar.additional_rank) as additional_rank
                    FROM mi.t_vacancy_additional_rank ar 
                    GROUP BY ar.vacancy_id
                )

-- przygotuj dane do raportu 
,vac_det AS (
                SELECT 
                 v.vacancy_id
                ,vacancy_full_name
                ,cc.corporation_name

                ,vc.vac_cnt 
                ,v.tech_area
                ,v.seniority_level

                ,COALESCE(ar.additional_rank, 0) as additional_rank
                FROM mi.v_vacancy v 
                JOIN mi.v_client_corporation cc 
                    ON v.client_corporation_id = cc.client_corporation_id
                JOIN vac_cnt vc 
                    ON v.client_corporation_id = vc.client_corporation_id
                LEFT JOIN vac_add_rank ar 
                    ON v.vacancy_id = ar.vacancy_id 
                WHERE v.vacancy_status IN ('Active')    -- ranking tylko dla aktywnych wakatów
                AND cc.corporation_name NOT LIKE '%SCALO%'     -- tylko zewnętrzni klienci
            )

-- wystaw ocene na podstawie danych 
,vac_rank AS (
                SELECT * 
                ,CASE 
                    WHEN vac_cnt <=10 THEN 5
                    WHEN vac_cnt >10 AND vac_cnt <=20 THEN 10
                    WHEN vac_cnt >20 THEN 20
                    ELSE 0
                    END AS vac_cnt_rank  
                ,CASE 
                    WHEN tech_area IN ('JVM', 'Client-side JS', 'Server-side JS') THEN 10
                    WHEN tech_area IN ('C/C++') THEN 8
                    WHEN tech_area IN ('FrontEnd') THEN 7   --nie istnieje
                    ELSE 2 
                    END tech_area_rank 
                ,CASE
                    WHEN seniority_level LIKE '%expert%' THEN 10
                    WHEN seniority_level LIKE '%senior%' THEN 7
                    WHEN seniority_level LIKE '%regular%' THEN 4
                    WHEN seniority_level LIKE '%junior%' THEN 1
                    ELSE 0
                END AS seniority_level_rank
                FROM vac_det 
            )

----

SELECT 
 vacancy_full_name
,corporation_name

,vac_cnt 
,vac_cnt_rank

,tech_area
,tech_area_rank

,seniority_level
,seniority_level_rank

,additional_rank

,(vac_cnt_rank + tech_area_rank + seniority_level_rank + additional_rank) AS sum_rank  

,vacancy_id
FROM vac_rank

