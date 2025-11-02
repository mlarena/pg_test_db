-- Таблица регионов (справочные данные)
CREATE TABLE public.regions (
    id SERIAL PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL UNIQUE
);

-- Таблица клубов (справочные данные)
CREATE TABLE public.clubs (
    id SERIAL PRIMARY KEY,
    club_code VARCHAR(20) NOT NULL UNIQUE,
    club_name VARCHAR(200) NOT NULL
);

-- Таблица организаций (справочные данные)
CREATE TABLE public.organizations (
    id SERIAL PRIMARY KEY,
    org_inn VARCHAR(12) NOT NULL UNIQUE,
    org_name VARCHAR(200) NOT NULL
);

-- Главная таблица: club_members (миллион записей)
CREATE TABLE public.club_members (
    id INT4 GENERATED ALWAYS AS IDENTITY (
        INCREMENT BY 1 
        MINVALUE 1 
        MAXVALUE 2147483647 
        START 1 
        CACHE 1 
        NO CYCLE
    ) NOT NULL,
    member_number VARCHAR(50),
    region VARCHAR(100) REFERENCES public.regions(region_name),
    surname VARCHAR(100),
    first_name VARCHAR(100),
    patronymic VARCHAR(100),
    organization_name VARCHAR(200),
    club_code VARCHAR(20) REFERENCES public.clubs(club_code),
    club_name VARCHAR(200),
    man_hours VARCHAR(50),
    number_of_clubs INT4,
    number_of_hours DECIMAL(10,2),
    inn VARCHAR(12) REFERENCES public.organizations(org_inn),
    enrollment_date DATE,
    unload_date DATE,
    additional_field1 VARCHAR(100),  -- Дополнительное поле для увеличения количества
    additional_field2 TEXT,          -- Еще одно поле (TEXT для больших данных)
    additional_field3 BOOLEAN DEFAULT FALSE,  -- Булево поле
    additional_field4 TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Временная метка
    CONSTRAINT club_members_pkey PRIMARY KEY (id)
);

-- Вставка справочных данных в regions (10 записей для примера)
INSERT INTO public.regions (region_name) VALUES 
('Москва'), ('Санкт-Петербург'), ('Новосибирск'), ('Екатеринбург'), ('Казань'),
('Нижний Новгород'), ('Челябинск'), ('Самара'), ('Омск'), ('Ростов-на-Дону');

-- Вставка справочных данных в clubs (5 записей для примера)
INSERT INTO public.clubs (club_code, club_name) VALUES 
('CLB001', 'Футбольный клуб "Динамо"'),
('CLB002', 'Баскетбольный клуб "Спартак"'),
('CLB003', 'Теннисный клуб "Локо"'),
('CLB004', 'Волейбольный клуб "Зенит"'),
('CLB005', 'Хоккейный клуб "Салават"');

-- Вставка справочных данных в organizations (5 записей для примера)
INSERT INTO public.organizations (org_inn, org_name) VALUES 
('7707083893', 'ООО "СпортПро"'),
('7810000001', 'АО "ФитнесЦентр"'),
('5401000010', 'ИП Иванов И.И.'),
('6671000020', 'ООО "КлубЗдоровья"'),
('1655000030', 'Фонд "СпортДляВсех"');

-- Коммит (если в транзакции)
COMMIT;