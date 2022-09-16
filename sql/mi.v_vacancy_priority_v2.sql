-- DROP VIEW mi.v_vacancy_priority_v2

CREATE OR REPLACE VIEW mi.v_vacancy_priority_v2 AS WITH 

 vac_details AS (
                SELECT
                 v.vacancy_id 
                ,v.vacancy_full_name
                ,cc.client_corporation_id  
                ,cc.corporation_name  
                ,v.vacancy_owner_name as manager
                ,v.is_open 
                ,v.vacancy_status 
                ,v.primary_category as job_role
                ,v.tech_area as tech_stack
                ,v.number_of_openings as openings
                ,(DATE_PART('day', NOW() - v.added_on))::INT as age_days
                FROM mi.v_vacancy v 
                JOIN mi.v_client_corporation cc 
                    ON v.client_corporation_id = cc.client_corporation_id
                WHERE v.is_open = 'True'                -- show only opened vacancies 
                AND cc.client_corporation_id <> 252     -- dont show SCALO vacancies
            )


,vac_salary AS (
                SELECT
                 vacancy_id
                ,150 as vac_bill_rate                   -- do pobrania z BH
                ,130 as vac_pay_rate                    -- do pobrania z BH
                ,((150 - 130) *160) as vac_margin       -- ((vac_bill_rate - vac_pay_rate) * 160) 
                ,((150 - 130) /130) as vac_m_perc       -- ((vac_bill_rate - vac_pay_rate) / vac_pay_rate) 
                ,NULL as vac_comments                   -- do pobrania z BH
                FROM vac_details
            )


,vac_shortlist AS (
                    SELECT 
                     vd.vacancy_id
                    ,COUNT(DISTINCT shortlist_id) as shortlist_cnt                                                  -- wszystkie shortlisty czy tylko wybrane statusy
                    ,SUM(CASE shortlist_current_status WHEN 'CV Sent' THEN 1 ELSE 0 END) as cvsent_cnt              -- te które obecnie są na tym etapie, czy te które przez niego przeszły
                    ,SUM(CASE WHEN shortlist_current_status LIKE '%Interview%' THEN 1 ELSE 0 END) as interview_cnt   -- wszystkie interviews czy tylko wybrane 
                    ,SUM(CASE shortlist_current_status WHEN 'Placed' THEN 1 ELSE 0 END) as placed_cnt
                    ,NULL as recruiters         
                    FROM mi.v_shortlist s
                    JOIN vac_details vd
                        ON s.vacancy_id = vd.vacancy_id
                    GROUP BY vd.vacancy_id
                )


,vac_attributes AS (
                    SELECT 
                     vd.vacancy_id
                    ,COALESCE(vacancy_priority, 0) AS vacancy_priority
                    ,COALESCE(vacancy_exception, 'default') AS vacancy_exception
                    ,COALESCE(vacancy_exception_comment, '') AS vacancy_exception_comment
                    FROM vac_details vd
                    LEFT JOIN mi.t_vacancy_attributes ca 
                        ON vd.vacancy_id = ca.vacancy_id
                )


,cli_vacancies AS (
                    SELECT 
                     client_corporation_id 
                    ,COUNT(vacancy_id) as vac_cnt 
                    FROM mi.v_vacancy 
                    WHERE is_open = 'True'   -- count only opened vacancies 
                    GROUP BY client_corporation_id
                )


,cli_atrributes AS (
                    SELECT DISTINCT 
                     cv.client_corporation_id
                    ,COALESCE(client_type, 'default') AS cli_type
                    ,COALESCE(client_probability, 'default') AS cli_probability   
                    ,COALESCE(client_recruitment, 'default') AS cli_recruitment
                    ,COALESCE(client_relations, 'default') AS cli_relations
                    ,0 as cli_HC        -- how to calculate? 
                    ,0 as cli_IN        -- how to calculate? 
                    ,0 as cli_OUT       -- how to calculate? 
                    ,0 as cli_ATTR      -- how to calculate? 
                    FROM cli_vacancies cv 
                    LEFT JOIN mi.t_client_attributes ca 
                        ON cv.client_corporation_id = ca.client_corporation_id 
                )


,vac_priority_summary AS (
                            SELECT 
                            va.vacancy_priority 

                            ,vacancy_full_name
                            ,corporation_name
 
                            ,job_role
                            ,manager

                            ,vacancy_status

                            ,age_days
                            ,openings   -- tu chyba lepiej pasuje
                            ,shortlist_cnt
                            ,cvsent_cnt
                            ,interview_cnt  
                            ,placed_cnt

                            ,cli_attr
                            ,cli_hc
                            ,cli_in	
                            ,cli_out

                            -- scoreboard
                            ,mi.fn_get_attribute_score('client_type', cli_type) as cli_type_score
                            ,cli_type	

                            ,mi.fn_get_attribute_score('client_probability', cli_probability) as cli_probability_score
                            ,cli_probability	

                            ,mi.fn_get_attribute_score('client_recruitment', cli_recruitment) as cli_recruitment_score
                            ,cli_recruitment	

                            ,mi.fn_get_attribute_score('client_relations', cli_relations) as cli_relations_score
                            ,cli_relations	

                            ,mi.fn_get_attribute_score('vacancies_cnt', vac_cnt::TEXT) as vac_cnt_score
                            ,vac_cnt 

                            ,mi.fn_get_attribute_score('tech_stack', tech_stack) as tech_stack_score
                            ,tech_stack 

                            ,mi.fn_get_attribute_score('margin', vac_margin::TEXT) as vac_margin_score
                            ,vac_margin
                            ,vac_bill_rate
                            ,vac_pay_rate
                            ,vac_m_perc
                            ,vac_comments

                            ,mi.fn_get_attribute_score('vacancy_exception', vacancy_exception) AS exception_score
                            ,vacancy_exception
                            ,vacancy_exception_comment

                            -- ,recruiters         -- moim zdaniem zbędne
                            -- ,is_open            -- wszystkie są open

                            FROM vac_details vd 
                            JOIN cli_atrributes ca 
                                ON vd.client_corporation_id = ca.client_corporation_id
                            JOIN cli_vacancies cv 
                                ON vd.client_corporation_id = cv.client_corporation_id
                            JOIN vac_salary vs 
                                ON vd.vacancy_id = vs.vacancy_id
                            JOIN vac_attributes va 
                                ON vd.vacancy_id = va.vacancy_id

                            LEFT JOIN vac_shortlist vsh 
                                ON vd.vacancy_id = vsh.vacancy_id 
                        )

------


SELECT 
(exception_score + cli_type_score + cli_probability_score + cli_recruitment_score + cli_relations_score + vac_cnt_score + tech_stack_score + vac_margin_score) as TOTAL
,*
FROM vac_priority_summary
ORDER BY 2 ASC, 1 DESC 