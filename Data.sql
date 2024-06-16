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
-- Data for Name: Region; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Region" ("ID_Region", "Name", "CodeRegion") FROM stdin;
22	Алтайский Край	385
79	Еврейская автономная область	426
77	Москва	495
42	Кемеровская область - Кузбасс	384
36	Воронежская область	473
\.


--
-- Data for Name: City; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."City" ("ID_City", "Region_ID", "Name") FROM stdin;
1	77	Москва
2	42	Кемерово
3	42	Юрга
4	42	Прокопьевск
5	42	Новокузнецк
6	22	Горный Алтай
7	22	Барнаул
8	22	Белокуриха
9	36	Воронеж
10	36	Семилуки
\.


--
-- Data for Name: Status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Status" ("ID_Status", "NameStatus") FROM stdin;
1	Работает
2	Ремонт
3	Установка
\.


--
-- Data for Name: TypePay; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TypePay" ("ID_Pay", "TypeBenefit", "Total") FROM stdin;
1	Без льгот	$850.00
2	Участники ВОВ	$350.00
3	Инвалидность	$637.50
\.


--
-- Data for Name: Abonent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Abonent" ("ID_Phone", "LastName", "FirstName", "MiddleName", "Status_ID", "City_ID", "Street", "Home", "Building", "Apartment", "LastWrite-off", "Balance", "Pay_ID") FROM stdin;
7896325	Васильев	Петр	Родионович	3	1	Банный проезд	5	6	53	\N	$890.00	1
5691452	Смирнова	Ольга	Дмитриевна	1	1	ул. Смольная	54	3	54	2023-09-23	$112.00	2
5698745	Романовская	Наталья	Васильевна	1	1	ул. Лавочкина	25	2	36	2023-10-03	$650.00	1
6666666	Андреяшкин	Дмитрий	Александрович	1	1	ул. Академика Янгеля	6	\N	168	2021-12-25	$0.00	3
2365475	Андреев	Павел	Федорович	1	1	ул. Фестивальная	25	1	157	2023-10-12	$324.00	1
3695475	Дорохов	Александр	\N	1	1	ул. Авимоторная	7	\N	1	2022-02-26	$331.00	3
1115475	Ибрагимов	Петр	\N	3	1	ул. Яковлева	32	\N	\N	2024-05-25	$150.00	1
4563259	Петрова	Ольга	Борисовна	1	1	Кронштадский бульвар	14	\N	54	2022-12-04	$54.00	1
7856325	Сидоткина	Анна	Валерьевна	1	1	ул. Фестивальная	25	1	156	2024-06-01	$848.00	1
\.


--
-- Data for Name: Cost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Cost" ("Region_Out_ID", "Region_In_ID", "PayMinute") FROM stdin;
\.


--
-- Data for Name: CostRegion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CostRegion" ("ID_CostRegion", "Region_Out_ID", "Region_In_ID", "PayMinute") FROM stdin;
1	77	22	$7.00
2	77	36	$4.00
3	77	42	$10.00
4	77	79	$5.00
\.


--
-- Data for Name: Intercity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Intercity" ("ID_Intercity", "Phone_ID", "Region_ID", "DateTimeStart", "DateTimeEnd", "Duration", "Sum") FROM stdin;
1	7856325	22	2023-08-08 19:23:45	2023-08-08 19:28:50	6	$42.00
3	7856325	36	2023-08-10 23:56:43	2023-08-11 00:01:21	5	$20.00
4	7856325	42	2023-09-13 00:00:00	2023-09-13 00:06:12	7	$70.00
5	5691452	42	2023-09-26 07:03:56	2023-09-26 07:11:43	8	$80.00
6	7856325	42	2023-09-27 12:23:41	2023-09-27 12:28:37	5	$50.00
7	5691452	36	2023-09-27 14:41:22	2023-09-27 14:42:23	2	$8.00
8	7856325	79	2023-09-28 12:54:12	2023-09-28 12:56:10	2	$10.00
9	5691452	42	2023-10-03 14:42:14	2023-10-03 14:44:45	3	$30.00
10	2365475	22	2023-10-10 13:23:42	2023-10-10 13:30:22	7	$49.00
11	2365475	22	2023-10-10 12:51:31	2023-10-10 12:51:32	1	$100.00
2	2365475	42	2023-08-09 18:43:56	2023-08-09 19:00:32	17	$170.00
\.


--
-- Data for Name: TypeJob; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TypeJob" ("ID_TypeJob", "NameJob") FROM stdin;
1	Ремонт
2	Установка
\.


--
-- Data for Name: Worker; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Worker" ("ID_Worker", "LastName", "FirstName", "MiddleName", "City_ID") FROM stdin;
365	Егоров	Егор	Емельянович	1
598	Сидоров	Игорь	Федорович	1
436	Петров	Иван	Григорьевич	1
555	Иванов	Иван	\N	1
\.


--
-- Data for Name: Job; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Job" ("ID_Job", "Worker_ID", "Phone_ID", "TypeJob_ID", "DateRegistration", "DatePerformance") FROM stdin;
2	598	2365475	2	2023-09-05	2023-09-12
4	598	5691452	2	2023-09-20	2023-09-23
6	598	5698745	2	2023-08-01	2023-09-03
7	598	7856325	2	2023-09-13	2023-09-15
1	598	7896325	2	2023-10-16	\N
11	436	7856325	1	2023-03-14	2023-03-16
10	436	5698745	1	2022-12-15	2023-01-11
8	598	4563259	2	2022-12-01	2022-12-04
5	598	6666666	2	2021-11-20	2021-11-25
3	598	3695475	2	2022-01-01	2022-01-06
9	436	4563259	1	2023-10-16	2024-06-01
\.


--
-- Data for Name: Register; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Register" ("ID_Receipt", "Phone_ID", "DatePay", "Sum") FROM stdin;
1	2365475	2023-10-10	$1,500.00
2	3695475	2022-02-05	$762.00
3	5691452	2023-09-20	$580.00
5	7896325	2023-10-16	$850.00
6	5698745	2023-08-01	$650.00
7	7856325	2023-10-16	$890.00
8	4563259	2022-12-01	$904.00
9	2365475	2023-09-05	$850.00
10	3695475	2022-01-01	$637.50
11	7856325	2023-09-13	$1,700.00
4	6666666	2021-11-20	$637.50
12	7856325	2024-06-01	$1,000.00
\.


--
-- PostgreSQL database dump complete
--

