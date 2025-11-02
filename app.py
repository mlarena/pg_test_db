import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta

# Настройки подключения (измените на свои)
DB_HOST = 'localhost'
DB_NAME = 'test_db'
DB_USER = 'postgres'
DB_PASSWORD = '12345678'
BATCH_SIZE = 1000
NUM_RECORDS = 1_000_000

fake = Faker('ru_RU')  # Русскоязычные данные

# Подключение
conn = psycopg2.connect(
    host=DB_HOST,
    database=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD
)
cur = conn.cursor()

# Списки для ссылок (из справочных таблиц)
regions = ['Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Казань',
           'Нижний Новгород', 'Челябинск', 'Самара', 'Омск', 'Ростов-на-Дону']
clubs_codes = ['CLB001', 'CLB002', 'CLB003', 'CLB004', 'CLB005']
org_inns = ['7707083893', '7810000001', '5401000010', '6671000020', '1655000030']

print(f"Начинаем вставку {NUM_RECORDS} записей...")

# Подготовка INSERT-запроса
insert_query = """
INSERT INTO club_members (
    member_number, region, surname, first_name, patronymic, organization_name,
    club_code, club_name, man_hours, number_of_clubs, number_of_hours, inn,
    enrollment_date, unload_date, additional_field1, additional_field2,
    additional_field3, additional_field4
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""

records = []
for i in range(NUM_RECORDS):
    member_num = f"MB{str(i+1).zfill(7)}"
    region = random.choice(regions)
    surname = fake.last_name()
    first_name = fake.first_name()
    patronymic = fake.prefix()
    org_name = fake.company()
    club_code = random.choice(clubs_codes)
    club_name = fake.company()  # Генерируем новое для разнообразия
    man_hours = str(random.randint(10, 100))
    num_clubs = random.randint(1, 5)
    num_hours = round(random.uniform(50.0, 500.0), 2)
    inn = random.choice(org_inns)
    enroll_date = fake.date_between(start_date='-2y', end_date='today')
    unload_date = fake.date_between(start_date=enroll_date, end_date='+1y')
    add1 = fake.word()
    add2 = fake.text(max_nb_chars=200)
    add3 = random.choice([True, False])
    add4 = fake.date_time_between(start_date='-1y', end_date='now')
    
    records.append((
        member_num, region, surname, first_name, patronymic, org_name,
        club_code, club_name, man_hours, num_clubs, num_hours, inn,
        enroll_date, unload_date, add1, add2, add3, add4
    ))
    
    if len(records) == BATCH_SIZE:
        cur.executemany(insert_query, records)
        conn.commit()
        print(f"Вставлено {i+1} записей...")
        records = []

# Последний батч
if records:
    cur.executemany(insert_query, records)
    conn.commit()
    print(f"Вставлено оставшиеся {len(records)} записей.")

cur.close()
conn.close()
print("Заполнение завершено.")