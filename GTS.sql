--
-- PostgreSQL database dump
--

-- Dumped from database version 10.22
-- Dumped by pg_dump version 10.22

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: add_user_abonent(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_user_abonent(user_id text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Создаем пользователя
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', user_id, user_id);
    
    -- Добавляем в группу Abonent
    EXECUTE format('GRANT "Abonent" TO %I', user_id);
END;
$$;


ALTER FUNCTION public.add_user_abonent(user_id text) OWNER TO postgres;

--
-- Name: add_user_worker(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_user_worker(user_id text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Создаем пользователя
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', user_id, user_id);
    
    -- Добавляем в группу Abonent
    EXECUTE format('GRANT "Worker" TO %I', user_id);
END;
$$;


ALTER FUNCTION public.add_user_worker(user_id text) OWNER TO postgres;

--
-- Name: block_delete_update_fnc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.block_delete_update_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$    BEGIN
        RAISE EXCEPTION 'Операция удаления/изменения невозможна';
    END;
    $$;


ALTER FUNCTION public.block_delete_update_fnc() OWNER TO postgres;

--
-- Name: calcduration(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calcduration(datetimestart timestamp without time zone, datetimeend timestamp without time zone) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    Duration INT;
BEGIN
    -- Рассчитываем разницу в минутах между двумя датами и округляем в большую сторону
    Duration := CEIL(EXTRACT(EPOCH FROM DateTimeEnd - DateTimeStart) / 60.0);

    -- Возвращаем результат
    RETURN Duration;
END;
$$;


ALTER FUNCTION public.calcduration(datetimestart timestamp without time zone, datetimeend timestamp without time zone) OWNER TO postgres;

--
-- Name: calcsumpay(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calcsumpay(duration integer, phone integer, regionin integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE
    SumPay DECIMAL;
    PayMinute DECIMAL;
    RegionOut INT;
BEGIN
    SELECT "City"."Region_ID" INTO RegionOut
    FROM "Abonent"
    JOIN "City" ON "City"."ID_City" = "Abonent"."City_ID"
    WHERE "Abonent"."ID_Phone" = Phone;

    SELECT "CostRegion"."PayMinute" INTO PayMinute
    FROM "CostRegion"
    WHERE "CostRegion"."Region_In_ID" = RegionIn AND "CostRegion"."Region_Out_ID" = RegionOut;

    SumPay := Duration * PayMinute;

    RETURN SumPay;
END;
$$;


ALTER FUNCTION public.calcsumpay(duration integer, phone integer, regionin integer) OWNER TO postgres;

--
-- Name: delete_old(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_old() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    job RECORD;
    register RECORD;
BEGIN
    FOR job IN
        SELECT * 
        FROM "public"."Job"
        WHERE "DatePerformance" IS NOT NULL
          AND (("DatePerformance" <= CURRENT_DATE - INTERVAL '365 days' AND "TypeJob_ID" = 1) OR
          ("DatePerformance" <= CURRENT_DATE - INTERVAL '1095 days' AND "TypeJob_ID" = 2))
    LOOP
        DELETE FROM "public"."Job"
        WHERE "ID_Job" = job."ID_Job";
    END LOOP;

    ALTER TABLE "public"."Register" DISABLE TRIGGER "register_delete";
    FOR register IN
        SELECT * 
        FROM "public"."Register"
        WHERE "DatePay" <= CURRENT_DATE - INTERVAL '1095 days'
    LOOP
        DELETE FROM "public"."Register"
        WHERE "ID_Receipt" = register."ID_Receipt";
    END LOOP;
    ALTER TABLE "public"."Register" ENABLE TRIGGER "register_delete";
END;
$$;


ALTER FUNCTION public.delete_old() OWNER TO postgres;

--
-- Name: delete_register_fnc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_register_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        flag_exist BOOLEAN;
    BEGIN
        SELECT EXISTS(
            SELECT 1
            FROM "Abonent"
            WHERE "ID_Phone" = OLD."Phone_ID"
        ) INTO flag_exist;
        IF flag_exist = FALSE THEN
            RAISE EXCEPTION 'Такого абонента не существует';
        END IF;

        UPDATE "Abonent"
        SET "Balance" = "Balance" - OLD."Sum"
        WHERE "Abonent"."ID_Phone" = OLD."Phone_ID";
        RAISE NOTICE 'Удаление произведено.';

        RETURN OLD;
    END
    $$;


ALTER FUNCTION public.delete_register_fnc() OWNER TO postgres;

--
-- Name: disable_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.disable_trigger() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE 'ALTER TABLE "public"."Intercity" DISABLE TRIGGER "intercity_update"';
END;
$$;


ALTER FUNCTION public.disable_trigger() OWNER TO postgres;

--
-- Name: done_job(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.done_job(job_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "public"."Job"
    SET "DatePerformance" = CURRENT_DATE
    WHERE "ID_Job" = job_id;
END;
$$;


ALTER FUNCTION public.done_job(job_id integer) OWNER TO postgres;

--
-- Name: enable_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.enable_trigger() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE 'ALTER TABLE "public"."Intercity" ENABLE TRIGGER "intercity_update"';
END;
$$;


ALTER FUNCTION public.enable_trigger() OWNER TO postgres;

--
-- Name: get_abonent_info(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_abonent_info(phone_id integer) RETURNS TABLE("ID_Phone" integer, "FIO" text, "Town" text, "Addres" text, "NameStatus" text, "LastWrite-off" date, "Balance" money, "TypeBenefit" text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT T1."ID_Phone", 
           T1.FIO, 
           T1.Town, 
           T1.Addres, 
           T1."NameStatus", 
           T1."LastWrite-off", 
           T1."Balance", 
           T2."TypeBenefit"
    FROM (SELECT "public"."Abonent"."ID_Phone", 
                 CONCAT("Abonent"."FirstName", ' ', "Abonent"."LastName", ' ', "Abonent"."MiddleName") AS FIO, 
                 "City"."Name" AS Town, 
                 CONCAT("Abonent"."Street", ', д. ', "Abonent"."Home", 'к', ', кв. ', "Abonent"."Apartment") AS Addres, 
                 "Status"."NameStatus", 
                 "Abonent"."LastWrite-off", 
                 "Abonent"."Balance", 
                 "Abonent"."Pay_ID"
          FROM "public"."Status"
          JOIN "public"."Abonent" ON "public"."Abonent"."Status_ID" = "public"."Status"."ID_Status"
          JOIN "public"."City" ON "public"."Abonent"."City_ID" = "public"."City"."ID_City"
          WHERE "Abonent"."ID_Phone" = phone_id) AS T1
    JOIN
    (SELECT "TypePay"."ID_Pay", "TypePay"."TypeBenefit"
     FROM "public"."TypePay"
     JOIN "public"."Abonent" ON "public"."Abonent"."Pay_ID" = "public"."TypePay"."ID_Pay"
     WHERE "Abonent"."ID_Phone" = phone_id) AS T2
    ON T1."Pay_ID" = T2."ID_Pay";
END;
$$;


ALTER FUNCTION public.get_abonent_info(phone_id integer) OWNER TO postgres;

--
-- Name: get_details(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_details(phone_id integer, p_year integer, p_month integer) RETURNS TABLE("Входящий регион" text, "Время начала" timestamp without time zone, "Время окончания" timestamp without time zone, "Длительность" integer, "Стоимость 1 минуты" money, "Общая сумма разговора" money)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT "Region"."Name" AS "Входящий регион", "Intercity"."DateTimeStart" AS "Время начала", "Intercity"."DateTimeEnd" AS "Время окончания", "Intercity"."Duration" AS "Длительность", "CostRegion"."PayMinute" AS "Стоимость 1 минуты", "Intercity"."Sum" AS "Общая сумма разговора"
FROM "public"."CostRegion"
JOIN "public"."Region" ON "public"."CostRegion"."Region_In_ID" = "public"."Region"."ID_Region"
JOIN "public"."Intercity" ON "public"."Intercity"."Region_ID" = "public"."Region"."ID_Region"
JOIN "public"."Abonent" ON "public"."Abonent"."ID_Phone" = "public"."Intercity"."Phone_ID"
JOIN "public"."City" ON "public"."Abonent"."City_ID" = "public"."City"."ID_City"
WHERE "Abonent"."ID_Phone" = 7856325 AND "CostRegion"."Region_Out_ID" = "City"."Region_ID" AND "CostRegion"."Region_In_ID" = "Intercity"."Region_ID" AND CAST(EXTRACT(YEAR FROM "Intercity"."DateTimeStart") AS INTEGER) = p_year AND CAST(EXTRACT(MONTH FROM "Intercity"."DateTimeStart") AS INTEGER) = p_month;
END;
$$;


ALTER FUNCTION public.get_details(phone_id integer, p_year integer, p_month integer) OWNER TO postgres;

--
-- Name: get_details_register(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_details_register(phone_id integer, p_year integer) RETURNS TABLE("Номер квитанции" integer, "Дата пополнения" date, "Сумма пополнения" money)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT "Register"."ID_Receipt" AS "Номер квитанции", "Register"."DatePay" AS "Дата пополнения", "Register"."Sum" AS "Сумма пополнения"
FROM "public"."Register"
WHERE "Register"."Phone_ID" = phone_id AND CAST(EXTRACT(YEAR FROM "Register"."DatePay") AS INTEGER) = p_year;
END;
$$;


ALTER FUNCTION public.get_details_register(phone_id integer, p_year integer) OWNER TO postgres;

--
-- Name: get_fio(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_fio(phone_id integer) RETURNS TABLE(fio text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT CONCAT("FirstName", ' ', "LastName", ' ', "MiddleName") AS FIO
            FROM "public"."Abonent" 
            WHERE "Abonent"."ID_Phone" = phone_id;
END;
$$;


ALTER FUNCTION public.get_fio(phone_id integer) OWNER TO postgres;

--
-- Name: get_install_by_city(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_install_by_city(city_id integer) RETURNS TABLE("Табельный номер" integer, "Номер телефона" integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT "Job"."Worker_ID" AS "Табельный номер", "Job"."Phone_ID" AS "Номер телефона"
    FROM "public"."Job"
    JOIN "public"."Abonent" ON "public"."Job"."Phone_ID" = "public"."Abonent"."ID_Phone"
    WHERE "Abonent"."Status_ID" = 3 AND "Job"."DatePerformance" IS NULL AND "Abonent"."City_ID" = city_id;
END;
$$;


ALTER FUNCTION public.get_install_by_city(city_id integer) OWNER TO postgres;

--
-- Name: get_jobs_worker(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_jobs_worker(worker_id integer) RETURNS TABLE("ID Заявки" integer, "Дата регистрации" date, "Телефон" integer, "ФИО" text, "Город" text, "Адрес" text, "Наименование работы" text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT T1."ID_Job" AS "ID Заявки", 
           T1.Reg AS "Дата регистрации", 
           T1.Phone AS "Телефон", 
           T1.FIO AS "ФИО", 
           T1.Town AS "Город", 
           T1.Addres AS "Адрес", 
           T2."NameJob" AS "Наименование работы"
    FROM (
        SELECT "Job"."ID_Job",
               "Job"."DateRegistration" AS Reg,
               "Job"."TypeJob_ID",
               "Abonent"."ID_Phone" AS Phone, 
               CONCAT("Abonent"."FirstName", ' ', "Abonent"."LastName", ' ', "Abonent"."MiddleName") AS FIO, 
               "City"."Name" AS Town, 
               CONCAT("Abonent"."Street", ', д. ', "Abonent"."Home", ', к', ', кв. ', "Abonent"."Apartment") AS Addres
        FROM "public"."Worker"
        JOIN "public"."Job" ON "public"."Worker"."ID_Worker" = "public"."Job"."Worker_ID"
        JOIN "public"."Abonent" ON "public"."Job"."Phone_ID" = "public"."Abonent"."ID_Phone"
        JOIN "public"."City" ON "public"."Abonent"."City_ID" = "public"."City"."ID_City"
        WHERE "Job"."DatePerformance" IS NULL 
          AND "Worker"."ID_Worker" = worker_id
    ) AS T1
    JOIN (
        SELECT "TypeJob"."ID_TypeJob", "TypeJob"."NameJob"
        FROM "public"."TypeJob"
    ) AS T2
    ON T1."TypeJob_ID" = T2."ID_TypeJob";
END;
$$;


ALTER FUNCTION public.get_jobs_worker(worker_id integer) OWNER TO postgres;

--
-- Name: get_month_intercity(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_month_intercity(p_phone_number integer) RETURNS TABLE(month integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT CAST(EXTRACT(MONTH FROM "Intercity"."DateTimeStart") AS INTEGER) AS month
    FROM "public"."Intercity"
    WHERE "Intercity"."Phone_ID" = p_phone_number;
END;
$$;


ALTER FUNCTION public.get_month_intercity(p_phone_number integer) OWNER TO postgres;

--
-- Name: get_repair_by_city(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_repair_by_city(city_id integer) RETURNS TABLE("Табельный номер" integer, "Номер телефона" integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT "Job"."Worker_ID" AS "Табельный номер", "Job"."Phone_ID" AS "Номер телефона"
    FROM "public"."Job"
    JOIN "public"."Abonent" ON "public"."Job"."Phone_ID" = "public"."Abonent"."ID_Phone"
    WHERE "Abonent"."Status_ID" = 2 AND "Job"."DatePerformance" IS NULL AND "Abonent"."City_ID" = city_id;
END;
$$;


ALTER FUNCTION public.get_repair_by_city(city_id integer) OWNER TO postgres;

--
-- Name: get_typepay(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_typepay() RETURNS TABLE("ID_Pay" integer, "TypeBenefit" text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT "TypePay"."ID_Pay", "TypePay"."TypeBenefit"
    FROM "public"."TypePay";
END;
$$;


ALTER FUNCTION public.get_typepay() OWNER TO postgres;

--
-- Name: get_workers_by_city(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_workers_by_city(p_city_id integer) RETURNS TABLE("Табельный номер" integer, "ФИО" text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "Worker"."ID_Worker" AS "Табельный номер",
        CONCAT("Worker"."LastName", ' ', "Worker"."FirstName", ' ', "Worker"."MiddleName") AS ФИО
    FROM "public"."Worker"
    WHERE "Worker"."City_ID" = p_city_id;
END;
$$;


ALTER FUNCTION public.get_workers_by_city(p_city_id integer) OWNER TO postgres;

--
-- Name: get_workers_city(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_workers_city(city_id integer) RETURNS TABLE("ID_Worker" integer, "LastName" text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT "Worker"."ID_Worker", "Worker"."LastName"
    FROM "public"."Worker"
    WHERE "City_ID" = city_id;
END;
$$;


ALTER FUNCTION public.get_workers_city(city_id integer) OWNER TO postgres;

--
-- Name: get_workers_phone(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_workers_phone(p_phone_number integer) RETURNS TABLE(id_worker integer, lastname text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT "Worker"."ID_Worker", "Worker"."LastName"
    FROM "public"."Worker"
    WHERE "City_ID" = (
        SELECT "Abonent"."City_ID"
        FROM "public"."Abonent"
        WHERE "Abonent"."ID_Phone" = p_phone_number
    );
END;
$$;


ALTER FUNCTION public.get_workers_phone(p_phone_number integer) OWNER TO postgres;

--
-- Name: get_year_intercity(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_year_intercity(p_phone_number integer) RETURNS TABLE(year integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT CAST(EXTRACT(YEAR FROM "Intercity"."DateTimeStart") AS INTEGER) AS year
    FROM "public"."Intercity"
    WHERE "Intercity"."Phone_ID" = p_phone_number;
END;
$$;


ALTER FUNCTION public.get_year_intercity(p_phone_number integer) OWNER TO postgres;

--
-- Name: get_year_register(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_year_register(p_phone_number integer) RETURNS TABLE(year integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT CAST(EXTRACT(YEAR FROM "Register"."DatePay") AS INTEGER) AS year
    FROM "public"."Register"
    WHERE "Register"."Phone_ID" = p_phone_number;
END;
$$;


ALTER FUNCTION public.get_year_register(p_phone_number integer) OWNER TO postgres;

--
-- Name: insert_intercity_fnc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_intercity_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        duration INTEGER;
        pay DECIMAL;
        balance_now DECIMAL;
        flag_exist BOOLEAN;
    BEGIN
        SELECT EXISTS(
            SELECT 1
            FROM "Abonent"
            WHERE "ID_Phone" = NEW."Phone_ID"
        ) INTO flag_exist;
        IF flag_exist = FALSE THEN
            RAISE EXCEPTION 'Такого абонента не существует';
        END IF;

        SELECT calcduration(NEW."DateTimeStart", NEW."DateTimeEnd") INTO duration;
        SELECT calcsumpay(duration, NEW."Phone_ID", NEW."Region_ID") INTO pay;
        UPDATE "Intercity"
		SET "Duration" = duration
		WHERE "Intercity"."ID_Intercity" = NEW."ID_Intercity";
        UPDATE "Intercity"
		SET "Sum" = pay
		WHERE "Intercity"."ID_Intercity" = NEW."ID_Intercity";
        SELECT "Balance" INTO balance_now
        FROM "Abonent"
        WHERE NEW."Phone_ID" = "ID_Phone";
        IF balance_now - pay::numeric <= 0 THEN
            UPDATE "Abonent"
            SET "Balance" = "Balance" - pay::money
            WHERE "Abonent"."ID_Phone" = NEW."Phone_ID";
            RAISE NOTICE 'Запись внесена. Абоненту необходимо выдать извещение о минусовом балансе';
        ELSE IF balance_now - pay::numeric > 0 THEN
                UPDATE "Abonent"
                SET "Balance" = "Balance" - pay::money
                WHERE "Abonent"."ID_Phone" = NEW."Phone_ID";
                RAISE NOTICE 'Запись внесена.';
            END IF;
        END IF;

        RETURN NEW;
    END
    $$;


ALTER FUNCTION public.insert_intercity_fnc() OWNER TO postgres;

--
-- Name: insert_job_fnc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_job_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        flag_exist BOOLEAN;
    BEGIN
        SELECT EXISTS(
            SELECT 1
            FROM "Abonent"
            WHERE "ID_Phone" = NEW."Phone_ID"
        ) INTO flag_exist;
        IF flag_exist = FALSE THEN
            RAISE EXCEPTION 'Такого абонента не существует';
        END IF;
        IF NEW."TypeJob_ID" = 1 AND NEW."DatePerformance" IS NULL THEN
            UPDATE "Abonent"
            SET "Status_ID" = 2
            WHERE "Abonent"."ID_Phone" = NEW."Phone_ID";
        END IF;
        RETURN NEW;
    END
    $$;


ALTER FUNCTION public.insert_job_fnc() OWNER TO postgres;

--
-- Name: insert_new_abonent(integer, text, text, text, integer, text, integer, integer, integer, numeric, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_new_abonent(phone integer, lastn text, firstn text, middle text, city integer, street text, home integer, build integer, apart integer, balance numeric, pay integer, worker_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_id INTEGER;
    new_job INTEGER;
BEGIN
    INSERT INTO "public"."Abonent" ("ID_Phone","LastName","FirstName","MiddleName","Status_ID","City_ID","Street","Home","Building","Apartment","Balance","Pay_ID")
    VALUES (phone,lastn,firstn,middle,3,city,street,home,build,apart,0::MONEY,pay);

    SELECT COALESCE(MAX("Job"."ID_Job"), 0) + 1 INTO new_job FROM "public"."Job";

    INSERT INTO "public"."Job" ("ID_Job", "Worker_ID", "Phone_ID", "TypeJob_ID", "DateRegistration")
    VALUES (new_job, worker_id, phone, 2, CURRENT_DATE);

    SELECT COALESCE(MAX("Register"."ID_Receipt"), 0) + 1 INTO new_id FROM "public"."Register";

    INSERT INTO "public"."Register" ("ID_Receipt","Phone_ID","DatePay","Sum")
    VALUES (new_id, phone,CURRENT_DATE,balance::MONEY);

END;
$$;


ALTER FUNCTION public.insert_new_abonent(phone integer, lastn text, firstn text, middle text, city integer, street text, home integer, build integer, apart integer, balance numeric, pay integer, worker_id integer) OWNER TO postgres;

--
-- Name: insert_new_worker(integer, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_new_worker(tabel integer, last text, first text, middle text, city integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO "public"."Worker" ("ID_Worker","LastName","FirstName","MiddleName","City_ID")
    VALUES (tabel, last, first, middle, city);
END;
$$;


ALTER FUNCTION public.insert_new_worker(tabel integer, last text, first text, middle text, city integer) OWNER TO postgres;

--
-- Name: insert_register(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_register(phone_id integer, sum numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_id INTEGER;
BEGIN
    SELECT COALESCE(MAX("Register"."ID_Receipt"), 0) + 1 INTO new_id FROM "public"."Register";

    INSERT INTO "public"."Register" ("ID_Receipt","Phone_ID","DatePay","Sum")
    VALUES (new_id, phone_id,CURRENT_DATE,sum::MONEY);
END;
$$;


ALTER FUNCTION public.insert_register(phone_id integer, sum numeric) OWNER TO postgres;

--
-- Name: insert_register_fnc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_register_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        flag_exist BOOLEAN;
    BEGIN
        SELECT EXISTS(
            SELECT 1
            FROM "Abonent"
            WHERE "ID_Phone" = NEW."Phone_ID"
        ) INTO flag_exist;
        IF flag_exist = FALSE THEN
            RAISE EXCEPTION 'Такого абонента не существует';
        END IF;

        UPDATE "Abonent"
        SET "Balance" = "Balance" + NEW."Sum"
        WHERE "Abonent"."ID_Phone" = NEW."Phone_ID";
        RAISE NOTICE 'Запись внесена.';

        RETURN NEW;
    END
    $$;


ALTER FUNCTION public.insert_register_fnc() OWNER TO postgres;

--
-- Name: insert_repair_job(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_repair_job(worker_id_arg integer, phone_id_arg integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_id INTEGER;
BEGIN
    -- Получение нового значения ID_Job как максимального значения текущего ID_Job + 1
    SELECT COALESCE(MAX("Job"."ID_Job"), 0) + 1 INTO new_id FROM "public"."Job";

    -- Вставка новой записи в таблицу Job
    INSERT INTO "public"."Job" ("ID_Job", "Worker_ID", "Phone_ID", "TypeJob_ID", "DateRegistration")
    VALUES (new_id, worker_id_arg, phone_id_arg, 1, CURRENT_DATE);
END;
$$;


ALTER FUNCTION public.insert_repair_job(worker_id_arg integer, phone_id_arg integer) OWNER TO postgres;

--
-- Name: intercity_insert_fnc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.intercity_insert_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Отключение триггера
    EXECUTE 'ALTER TABLE "public"."Intercity" DISABLE TRIGGER "intercity_update"';
    
    -- Ваши действия по вставке или другие операции
    PERFORM insert_intercity_fnc();  -- Предполагается, что у вас есть эта функция

    -- Включение триггера
    EXECUTE 'ALTER TABLE "public"."Intercity" ENABLE TRIGGER "intercity_update"';
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.intercity_insert_fnc() OWNER TO postgres;

--
-- Name: new_pay(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.new_pay(phone_id integer, npay integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "public"."Abonent"
    SET "Pay_ID" = npay
    WHERE "ID_Phone" = phone_id;
END;
$$;


ALTER FUNCTION public.new_pay(phone_id integer, npay integer) OWNER TO postgres;

--
-- Name: update_balance(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_balance() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    abonent RECORD;
    total_amount MONEY;
BEGIN
    FOR abonent IN
        SELECT * 
        FROM "public"."Abonent"
        WHERE "LastWrite-off" IS NOT NULL
          AND "LastWrite-off" <= CURRENT_DATE - INTERVAL '30 days'
    LOOP
        -- Получение суммы из таблицы TypePay
        SELECT "Total" INTO total_amount
        FROM "public"."TypePay"
        WHERE "ID_Pay" = abonent."Pay_ID";
        
        -- Проверка текущего баланса
        IF abonent."Balance" >= total_amount THEN
            -- Обновление баланса
            UPDATE "public"."Abonent"
            SET "Balance" = "Balance" - total_amount,
                "LastWrite-off" = CURRENT_DATE
            WHERE "ID_Phone" = abonent."ID_Phone";
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION public.update_balance() OWNER TO postgres;

--
-- Name: update_job_fnc(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_job_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        flag_exist BOOLEAN;
    BEGIN
        SELECT EXISTS(
            SELECT 1
            FROM "Abonent"
            WHERE "ID_Phone" = NEW."Phone_ID"
        ) INTO flag_exist;
        IF flag_exist = FALSE THEN
            RAISE EXCEPTION 'Такого абонента не существует';
        END IF;
        IF NEW."DatePerformance" IS NOT NULL THEN
            UPDATE "Abonent"
            SET "Status_ID" = 1
            WHERE "Abonent"."ID_Phone" = NEW."Phone_ID";
        END IF;
        RETURN NEW;
    END
    $$;


ALTER FUNCTION public.update_job_fnc() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Abonent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Abonent" (
    "ID_Phone" integer NOT NULL,
    "LastName" text NOT NULL,
    "FirstName" text NOT NULL,
    "MiddleName" text,
    "Status_ID" integer NOT NULL,
    "City_ID" integer NOT NULL,
    "Street" text NOT NULL,
    "Home" integer NOT NULL,
    "Building" integer,
    "Apartment" integer,
    "LastWrite-off" date,
    "Balance" money NOT NULL,
    "Pay_ID" integer NOT NULL
);


ALTER TABLE public."Abonent" OWNER TO postgres;

--
-- Name: City; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."City" (
    "ID_City" integer NOT NULL,
    "Region_ID" integer NOT NULL,
    "Name" text NOT NULL
);


ALTER TABLE public."City" OWNER TO postgres;

--
-- Name: Cost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Cost" (
    "Region_Out_ID" integer NOT NULL,
    "Region_In_ID" integer NOT NULL,
    "PayMinute" money NOT NULL
);


ALTER TABLE public."Cost" OWNER TO postgres;

--
-- Name: CostRegion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CostRegion" (
    "ID_CostRegion" integer NOT NULL,
    "Region_Out_ID" integer NOT NULL,
    "Region_In_ID" integer NOT NULL,
    "PayMinute" money NOT NULL
);


ALTER TABLE public."CostRegion" OWNER TO postgres;

--
-- Name: Intercity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Intercity" (
    "ID_Intercity" integer NOT NULL,
    "Phone_ID" integer NOT NULL,
    "Region_ID" integer NOT NULL,
    "DateTimeStart" timestamp without time zone NOT NULL,
    "DateTimeEnd" timestamp without time zone NOT NULL,
    "Duration" integer,
    "Sum" money
);


ALTER TABLE public."Intercity" OWNER TO postgres;

--
-- Name: Job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Job" (
    "ID_Job" integer NOT NULL,
    "Worker_ID" integer NOT NULL,
    "Phone_ID" integer NOT NULL,
    "TypeJob_ID" integer NOT NULL,
    "DateRegistration" date NOT NULL,
    "DatePerformance" date
);


ALTER TABLE public."Job" OWNER TO postgres;

--
-- Name: Region; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Region" (
    "ID_Region" integer NOT NULL,
    "Name" text NOT NULL,
    "CodeRegion" integer
);


ALTER TABLE public."Region" OWNER TO postgres;

--
-- Name: Register; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Register" (
    "ID_Receipt" integer NOT NULL,
    "Phone_ID" integer NOT NULL,
    "DatePay" date NOT NULL,
    "Sum" money NOT NULL
);


ALTER TABLE public."Register" OWNER TO postgres;

--
-- Name: Status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Status" (
    "ID_Status" integer NOT NULL,
    "NameStatus" text NOT NULL
);


ALTER TABLE public."Status" OWNER TO postgres;

--
-- Name: TypeJob; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TypeJob" (
    "ID_TypeJob" integer NOT NULL,
    "NameJob" text NOT NULL
);


ALTER TABLE public."TypeJob" OWNER TO postgres;

--
-- Name: TypePay; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TypePay" (
    "ID_Pay" integer NOT NULL,
    "TypeBenefit" text NOT NULL,
    "Total" money NOT NULL
);


ALTER TABLE public."TypePay" OWNER TO postgres;

--
-- Name: Worker; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Worker" (
    "ID_Worker" integer NOT NULL,
    "LastName" text NOT NULL,
    "FirstName" text NOT NULL,
    "MiddleName" text,
    "City_ID" integer NOT NULL
);


ALTER TABLE public."Worker" OWNER TO postgres;

--
-- Data for Name: Abonent; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Abonent" VALUES (7896325, 'Васильев', 'Петр', 'Родионович', 3, 1, 'Банный проезд', 5, 6, 53, NULL, '$890.00', 1);
INSERT INTO public."Abonent" VALUES (5691452, 'Смирнова', 'Ольга', 'Дмитриевна', 1, 1, 'ул. Смольная', 54, 3, 54, '2023-09-23', '$112.00', 2);
INSERT INTO public."Abonent" VALUES (5698745, 'Романовская', 'Наталья', 'Васильевна', 1, 1, 'ул. Лавочкина', 25, 2, 36, '2023-10-03', '$650.00', 1);
INSERT INTO public."Abonent" VALUES (6666666, 'Андреяшкин', 'Дмитрий', 'Александрович', 1, 1, 'ул. Академика Янгеля', 6, NULL, 168, '2021-12-25', '$0.00', 3);
INSERT INTO public."Abonent" VALUES (2365475, 'Андреев', 'Павел', 'Федорович', 1, 1, 'ул. Фестивальная', 25, 1, 157, '2023-10-12', '$324.00', 1);
INSERT INTO public."Abonent" VALUES (3695475, 'Дорохов', 'Александр', NULL, 1, 1, 'ул. Авимоторная', 7, NULL, 1, '2022-02-26', '$331.00', 3);
INSERT INTO public."Abonent" VALUES (1115475, 'Ибрагимов', 'Петр', NULL, 3, 1, 'ул. Яковлева', 32, NULL, NULL, '2024-05-25', '$150.00', 1);
INSERT INTO public."Abonent" VALUES (4563259, 'Петрова', 'Ольга', 'Борисовна', 1, 1, 'Кронштадский бульвар', 14, NULL, 54, '2022-12-04', '$54.00', 1);
INSERT INTO public."Abonent" VALUES (7856325, 'Сидоткина', 'Анна', 'Валерьевна', 1, 1, 'ул. Фестивальная', 25, 1, 156, '2024-06-01', '$848.00', 1);


--
-- Data for Name: City; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."City" VALUES (1, 77, 'Москва');
INSERT INTO public."City" VALUES (2, 42, 'Кемерово');
INSERT INTO public."City" VALUES (3, 42, 'Юрга');
INSERT INTO public."City" VALUES (4, 42, 'Прокопьевск');
INSERT INTO public."City" VALUES (5, 42, 'Новокузнецк');
INSERT INTO public."City" VALUES (6, 22, 'Горный Алтай');
INSERT INTO public."City" VALUES (7, 22, 'Барнаул');
INSERT INTO public."City" VALUES (8, 22, 'Белокуриха');
INSERT INTO public."City" VALUES (9, 36, 'Воронеж');
INSERT INTO public."City" VALUES (10, 36, 'Семилуки');


--
-- Data for Name: Cost; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: CostRegion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."CostRegion" VALUES (1, 77, 22, '$7.00');
INSERT INTO public."CostRegion" VALUES (2, 77, 36, '$4.00');
INSERT INTO public."CostRegion" VALUES (3, 77, 42, '$10.00');
INSERT INTO public."CostRegion" VALUES (4, 77, 79, '$5.00');


--
-- Data for Name: Intercity; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Intercity" VALUES (1, 7856325, 22, '2023-08-08 19:23:45', '2023-08-08 19:28:50', 6, '$42.00');
INSERT INTO public."Intercity" VALUES (3, 7856325, 36, '2023-08-10 23:56:43', '2023-08-11 00:01:21', 5, '$20.00');
INSERT INTO public."Intercity" VALUES (4, 7856325, 42, '2023-09-13 00:00:00', '2023-09-13 00:06:12', 7, '$70.00');
INSERT INTO public."Intercity" VALUES (5, 5691452, 42, '2023-09-26 07:03:56', '2023-09-26 07:11:43', 8, '$80.00');
INSERT INTO public."Intercity" VALUES (6, 7856325, 42, '2023-09-27 12:23:41', '2023-09-27 12:28:37', 5, '$50.00');
INSERT INTO public."Intercity" VALUES (7, 5691452, 36, '2023-09-27 14:41:22', '2023-09-27 14:42:23', 2, '$8.00');
INSERT INTO public."Intercity" VALUES (8, 7856325, 79, '2023-09-28 12:54:12', '2023-09-28 12:56:10', 2, '$10.00');
INSERT INTO public."Intercity" VALUES (9, 5691452, 42, '2023-10-03 14:42:14', '2023-10-03 14:44:45', 3, '$30.00');
INSERT INTO public."Intercity" VALUES (10, 2365475, 22, '2023-10-10 13:23:42', '2023-10-10 13:30:22', 7, '$49.00');
INSERT INTO public."Intercity" VALUES (11, 2365475, 22, '2023-10-10 12:51:31', '2023-10-10 12:51:32', 1, '$100.00');
INSERT INTO public."Intercity" VALUES (2, 2365475, 42, '2023-08-09 18:43:56', '2023-08-09 19:00:32', 17, '$170.00');


--
-- Data for Name: Job; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Job" VALUES (2, 598, 2365475, 2, '2023-09-05', '2023-09-12');
INSERT INTO public."Job" VALUES (4, 598, 5691452, 2, '2023-09-20', '2023-09-23');
INSERT INTO public."Job" VALUES (6, 598, 5698745, 2, '2023-08-01', '2023-09-03');
INSERT INTO public."Job" VALUES (7, 598, 7856325, 2, '2023-09-13', '2023-09-15');
INSERT INTO public."Job" VALUES (1, 598, 7896325, 2, '2023-10-16', NULL);
INSERT INTO public."Job" VALUES (11, 436, 7856325, 1, '2023-03-14', '2023-03-16');
INSERT INTO public."Job" VALUES (10, 436, 5698745, 1, '2022-12-15', '2023-01-11');
INSERT INTO public."Job" VALUES (8, 598, 4563259, 2, '2022-12-01', '2022-12-04');
INSERT INTO public."Job" VALUES (5, 598, 6666666, 2, '2021-11-20', '2021-11-25');
INSERT INTO public."Job" VALUES (3, 598, 3695475, 2, '2022-01-01', '2022-01-06');
INSERT INTO public."Job" VALUES (9, 436, 4563259, 1, '2023-10-16', '2024-06-01');


--
-- Data for Name: Region; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Region" VALUES (22, 'Алтайский Край', 385);
INSERT INTO public."Region" VALUES (79, 'Еврейская автономная область', 426);
INSERT INTO public."Region" VALUES (77, 'Москва', 495);
INSERT INTO public."Region" VALUES (42, 'Кемеровская область - Кузбасс', 384);
INSERT INTO public."Region" VALUES (36, 'Воронежская область', 473);


--
-- Data for Name: Register; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Register" VALUES (1, 2365475, '2023-10-10', '$1,500.00');
INSERT INTO public."Register" VALUES (2, 3695475, '2022-02-05', '$762.00');
INSERT INTO public."Register" VALUES (3, 5691452, '2023-09-20', '$580.00');
INSERT INTO public."Register" VALUES (5, 7896325, '2023-10-16', '$850.00');
INSERT INTO public."Register" VALUES (6, 5698745, '2023-08-01', '$650.00');
INSERT INTO public."Register" VALUES (7, 7856325, '2023-10-16', '$890.00');
INSERT INTO public."Register" VALUES (8, 4563259, '2022-12-01', '$904.00');
INSERT INTO public."Register" VALUES (9, 2365475, '2023-09-05', '$850.00');
INSERT INTO public."Register" VALUES (10, 3695475, '2022-01-01', '$637.50');
INSERT INTO public."Register" VALUES (11, 7856325, '2023-09-13', '$1,700.00');
INSERT INTO public."Register" VALUES (4, 6666666, '2021-11-20', '$637.50');
INSERT INTO public."Register" VALUES (12, 7856325, '2024-06-01', '$1,000.00');


--
-- Data for Name: Status; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Status" VALUES (1, 'Работает');
INSERT INTO public."Status" VALUES (2, 'Ремонт');
INSERT INTO public."Status" VALUES (3, 'Установка');


--
-- Data for Name: TypeJob; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."TypeJob" VALUES (1, 'Ремонт');
INSERT INTO public."TypeJob" VALUES (2, 'Установка');


--
-- Data for Name: TypePay; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."TypePay" VALUES (1, 'Без льгот', '$850.00');
INSERT INTO public."TypePay" VALUES (2, 'Участники ВОВ', '$350.00');
INSERT INTO public."TypePay" VALUES (3, 'Инвалидность', '$637.50');


--
-- Data for Name: Worker; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Worker" VALUES (365, 'Егоров', 'Егор', 'Емельянович', 1);
INSERT INTO public."Worker" VALUES (598, 'Сидоров', 'Игорь', 'Федорович', 1);
INSERT INTO public."Worker" VALUES (436, 'Петров', 'Иван', 'Григорьевич', 1);
INSERT INTO public."Worker" VALUES (555, 'Иванов', 'Иван', NULL, 1);


--
-- Name: Abonent Abonent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Abonent"
    ADD CONSTRAINT "Abonent_pkey" PRIMARY KEY ("ID_Phone");


--
-- Name: City City_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."City"
    ADD CONSTRAINT "City_pkey" PRIMARY KEY ("ID_City");


--
-- Name: CostRegion CostRegion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CostRegion"
    ADD CONSTRAINT "CostRegion_pkey" PRIMARY KEY ("ID_CostRegion");


--
-- Name: Cost Cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cost"
    ADD CONSTRAINT "Cost_pkey" PRIMARY KEY ("Region_Out_ID", "Region_In_ID");


--
-- Name: Intercity Intercity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Intercity"
    ADD CONSTRAINT "Intercity_pkey" PRIMARY KEY ("ID_Intercity");


--
-- Name: Job Job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Job"
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY ("ID_Job");


--
-- Name: Region Region_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Region"
    ADD CONSTRAINT "Region_pkey" PRIMARY KEY ("ID_Region");


--
-- Name: Register Register_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Register"
    ADD CONSTRAINT "Register_pkey" PRIMARY KEY ("ID_Receipt");


--
-- Name: Status Status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Status"
    ADD CONSTRAINT "Status_pkey" PRIMARY KEY ("ID_Status");


--
-- Name: TypeJob TypeJob_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TypeJob"
    ADD CONSTRAINT "TypeJob_pkey" PRIMARY KEY ("ID_TypeJob");


--
-- Name: TypePay TypePay_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TypePay"
    ADD CONSTRAINT "TypePay_pkey" PRIMARY KEY ("ID_Pay");


--
-- Name: Worker Worker_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Worker"
    ADD CONSTRAINT "Worker_pkey" PRIMARY KEY ("ID_Worker");


--
-- Name: Job_DatePerformance; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Job_DatePerformance" ON public."Job" USING btree ("DatePerformance");


--
-- Name: Intercity intercity_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER intercity_delete BEFORE DELETE ON public."Intercity" FOR EACH ROW EXECUTE PROCEDURE public.block_delete_update_fnc();

ALTER TABLE public."Intercity" DISABLE TRIGGER intercity_delete;


--
-- Name: Intercity intercity_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER intercity_insert AFTER INSERT ON public."Intercity" FOR EACH ROW EXECUTE PROCEDURE public.insert_intercity_fnc();


--
-- Name: Job job_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER job_insert AFTER INSERT ON public."Job" FOR EACH ROW EXECUTE PROCEDURE public.insert_job_fnc();


--
-- Name: Job job_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER job_update AFTER UPDATE ON public."Job" FOR EACH ROW EXECUTE PROCEDURE public.update_job_fnc();


--
-- Name: Register register_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER register_delete AFTER DELETE ON public."Register" FOR EACH ROW EXECUTE PROCEDURE public.delete_register_fnc();


--
-- Name: Register register_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER register_insert AFTER INSERT ON public."Register" FOR EACH ROW EXECUTE PROCEDURE public.insert_register_fnc();


--
-- Name: Register register_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER register_update BEFORE UPDATE ON public."Register" FOR EACH ROW EXECUTE PROCEDURE public.block_delete_update_fnc();


--
-- Name: Abonent Abonent_City_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Abonent"
    ADD CONSTRAINT "Abonent_City_ID_fkey" FOREIGN KEY ("City_ID") REFERENCES public."City"("ID_City");


--
-- Name: Abonent Abonent_Pay_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Abonent"
    ADD CONSTRAINT "Abonent_Pay_ID_fkey" FOREIGN KEY ("Pay_ID") REFERENCES public."TypePay"("ID_Pay");


--
-- Name: Abonent Abonent_Status_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Abonent"
    ADD CONSTRAINT "Abonent_Status_ID_fkey" FOREIGN KEY ("Status_ID") REFERENCES public."Status"("ID_Status");


--
-- Name: City City_CodeRegion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."City"
    ADD CONSTRAINT "City_CodeRegion_fkey" FOREIGN KEY ("Region_ID") REFERENCES public."Region"("ID_Region");


--
-- Name: CostRegion CostRegion_Region_In_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CostRegion"
    ADD CONSTRAINT "CostRegion_Region_In_ID_fkey" FOREIGN KEY ("Region_In_ID") REFERENCES public."Region"("ID_Region");


--
-- Name: CostRegion CostRegion_Region_Out_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CostRegion"
    ADD CONSTRAINT "CostRegion_Region_Out_ID_fkey" FOREIGN KEY ("Region_Out_ID") REFERENCES public."Region"("ID_Region");


--
-- Name: Cost Cost_region_in_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cost"
    ADD CONSTRAINT "Cost_region_in_id_fkey" FOREIGN KEY ("Region_In_ID") REFERENCES public."Region"("ID_Region");


--
-- Name: Cost Cost_region_out_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cost"
    ADD CONSTRAINT "Cost_region_out_id_fkey" FOREIGN KEY ("Region_Out_ID") REFERENCES public."Region"("ID_Region");


--
-- Name: Intercity Intercity_CodeRegion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Intercity"
    ADD CONSTRAINT "Intercity_CodeRegion_fkey" FOREIGN KEY ("Region_ID") REFERENCES public."Region"("ID_Region");


--
-- Name: Intercity Intercity_Phone_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Intercity"
    ADD CONSTRAINT "Intercity_Phone_ID_fkey" FOREIGN KEY ("Phone_ID") REFERENCES public."Abonent"("ID_Phone");


--
-- Name: Job Job_Phone_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Job"
    ADD CONSTRAINT "Job_Phone_ID_fkey" FOREIGN KEY ("Phone_ID") REFERENCES public."Abonent"("ID_Phone");


--
-- Name: Job Job_TypeJob_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Job"
    ADD CONSTRAINT "Job_TypeJob_ID_fkey" FOREIGN KEY ("TypeJob_ID") REFERENCES public."TypeJob"("ID_TypeJob");


--
-- Name: Job Job_Worker_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Job"
    ADD CONSTRAINT "Job_Worker_ID_fkey" FOREIGN KEY ("Worker_ID") REFERENCES public."Worker"("ID_Worker");


--
-- Name: Register Register_Phone_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Register"
    ADD CONSTRAINT "Register_Phone_ID_fkey" FOREIGN KEY ("Phone_ID") REFERENCES public."Abonent"("ID_Phone");


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO PUBLIC;


--
-- Name: FUNCTION block_delete_update_fnc(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.block_delete_update_fnc() TO admin;
GRANT ALL ON FUNCTION public.block_delete_update_fnc() TO "SelectAllUsers";
GRANT ALL ON FUNCTION public.block_delete_update_fnc() TO "Abonent";


--
-- Name: FUNCTION delete_register_fnc(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.delete_register_fnc() TO admin;
GRANT ALL ON FUNCTION public.delete_register_fnc() TO "SelectAllUsers";
GRANT ALL ON FUNCTION public.delete_register_fnc() TO "Abonent";


--
-- Name: FUNCTION done_job(job_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.done_job(job_id integer) TO "Worker";


--
-- Name: FUNCTION get_abonent_info(phone_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_abonent_info(phone_id integer) TO "Operators";
GRANT ALL ON FUNCTION public.get_abonent_info(phone_id integer) TO "Abonent";


--
-- Name: FUNCTION get_details(phone_id integer, p_year integer, p_month integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_details(phone_id integer, p_year integer, p_month integer) TO "Operators";
GRANT ALL ON FUNCTION public.get_details(phone_id integer, p_year integer, p_month integer) TO "Abonent";


--
-- Name: FUNCTION get_details_register(phone_id integer, p_year integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_details_register(phone_id integer, p_year integer) TO "Operators";
GRANT ALL ON FUNCTION public.get_details_register(phone_id integer, p_year integer) TO "Abonent";


--
-- Name: FUNCTION get_fio(phone_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_fio(phone_id integer) TO "Operators";
GRANT ALL ON FUNCTION public.get_fio(phone_id integer) TO "Abonent";


--
-- Name: FUNCTION get_install_by_city(city_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_install_by_city(city_id integer) TO "Operators";


--
-- Name: FUNCTION get_jobs_worker(worker_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_jobs_worker(worker_id integer) TO "Worker";


--
-- Name: FUNCTION get_month_intercity(p_phone_number integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_month_intercity(p_phone_number integer) TO "Operators";
GRANT ALL ON FUNCTION public.get_month_intercity(p_phone_number integer) TO "Abonent";


--
-- Name: FUNCTION get_repair_by_city(city_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_repair_by_city(city_id integer) TO "Operators";


--
-- Name: FUNCTION get_workers_phone(p_phone_number integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_workers_phone(p_phone_number integer) TO "Operators";


--
-- Name: FUNCTION get_year_intercity(p_phone_number integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_year_intercity(p_phone_number integer) TO "Operators";
GRANT ALL ON FUNCTION public.get_year_intercity(p_phone_number integer) TO "Abonent";


--
-- Name: FUNCTION get_year_register(p_phone_number integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_year_register(p_phone_number integer) TO "Operators";
GRANT ALL ON FUNCTION public.get_year_register(p_phone_number integer) TO "Abonent";


--
-- Name: FUNCTION insert_register(phone_id integer, sum numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.insert_register(phone_id integer, sum numeric) TO "Abonent";


--
-- Name: FUNCTION insert_register_fnc(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.insert_register_fnc() TO admin;
GRANT ALL ON FUNCTION public.insert_register_fnc() TO "SelectAllUsers";
GRANT ALL ON FUNCTION public.insert_register_fnc() TO "Abonent";


--
-- Name: FUNCTION insert_repair_job(worker_id_arg integer, phone_id_arg integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.insert_repair_job(worker_id_arg integer, phone_id_arg integer) TO "Operators";


--
-- Name: TABLE "Abonent"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."Abonent" TO admin;
GRANT SELECT ON TABLE public."Abonent" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."Abonent" TO "Operators";
GRANT SELECT,UPDATE ON TABLE public."Abonent" TO "Abonent";
GRANT SELECT,UPDATE ON TABLE public."Abonent" TO "Worker";


--
-- Name: TABLE "City"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."City" TO admin;
GRANT SELECT ON TABLE public."City" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."City" TO "Operators";
GRANT SELECT ON TABLE public."City" TO "Abonent";
GRANT SELECT ON TABLE public."City" TO "Worker";


--
-- Name: TABLE "CostRegion"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public."CostRegion" TO "Operators";
GRANT SELECT ON TABLE public."CostRegion" TO "Abonent";
GRANT SELECT ON TABLE public."CostRegion" TO "Worker";


--
-- Name: TABLE "Intercity"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."Intercity" TO admin;
GRANT SELECT ON TABLE public."Intercity" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."Intercity" TO "Operators";
GRANT SELECT ON TABLE public."Intercity" TO "Abonent";
GRANT SELECT ON TABLE public."Intercity" TO "Worker";


--
-- Name: TABLE "Job"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."Job" TO admin;
GRANT SELECT ON TABLE public."Job" TO "SelectAllUsers";
GRANT SELECT,INSERT ON TABLE public."Job" TO "Operators";
GRANT SELECT ON TABLE public."Job" TO "Abonent";
GRANT SELECT,UPDATE ON TABLE public."Job" TO "Worker";


--
-- Name: TABLE "Region"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."Region" TO admin;
GRANT SELECT ON TABLE public."Region" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."Region" TO "Operators";
GRANT SELECT ON TABLE public."Region" TO "Abonent";
GRANT SELECT ON TABLE public."Region" TO "Worker";


--
-- Name: TABLE "Register"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."Register" TO admin;
GRANT SELECT ON TABLE public."Register" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."Register" TO "Operators";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."Register" TO "Abonent";
GRANT SELECT ON TABLE public."Register" TO "Worker";


--
-- Name: TABLE "Status"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."Status" TO admin;
GRANT SELECT ON TABLE public."Status" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."Status" TO "Operators";
GRANT SELECT ON TABLE public."Status" TO "Abonent";
GRANT SELECT ON TABLE public."Status" TO "Worker";


--
-- Name: TABLE "TypeJob"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."TypeJob" TO admin;
GRANT SELECT ON TABLE public."TypeJob" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."TypeJob" TO "Operators";
GRANT SELECT ON TABLE public."TypeJob" TO "Abonent";
GRANT SELECT ON TABLE public."TypeJob" TO "Worker";


--
-- Name: TABLE "TypePay"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."TypePay" TO admin;
GRANT SELECT ON TABLE public."TypePay" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."TypePay" TO "Operators";
GRANT SELECT ON TABLE public."TypePay" TO "Abonent";
GRANT SELECT ON TABLE public."TypePay" TO "Worker";


--
-- Name: TABLE "Worker"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public."Worker" TO admin;
GRANT SELECT ON TABLE public."Worker" TO "SelectAllUsers";
GRANT SELECT ON TABLE public."Worker" TO "Operators";
GRANT SELECT ON TABLE public."Worker" TO "Abonent";
GRANT SELECT ON TABLE public."Worker" TO "Worker";


--
-- PostgreSQL database dump complete
--

