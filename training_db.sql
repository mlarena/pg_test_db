-- 1. Создание базы данных (если нужно выполнить отдельно)
CREATE DATABASE training_db;
-- \c training_db;

-- 2. Таблица users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    balance DECIMAL(10,2) DEFAULT 0.00,
    country VARCHAR(60),
    city VARCHAR(60),
    phone VARCHAR(20),
    last_login TIMESTAMP,
    referrer_id INT REFERENCES users(id) ON DELETE SET NULL
);

-- 3. Таблица courses
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    level VARCHAR(20) CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    duration_hours INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_published BOOLEAN DEFAULT TRUE,
    language VARCHAR(20) DEFAULT 'English',
    category VARCHAR(50),
    rating_avg DECIMAL(3,2) DEFAULT 0.00
);

-- 4. Таблица enrollments
CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress_percent INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    grade INT CHECK (grade >= 0 AND grade <= 100),
    certificate_issued BOOLEAN DEFAULT FALSE,
    last_accessed TIMESTAMP,
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('paid', 'pending', 'free'))
);

-- 5. Таблица lessons
CREATE TABLE lessons (
    id SERIAL PRIMARY KEY,
    course_id INT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    order_index INT NOT NULL,
    content_type VARCHAR(20) CHECK (content_type IN ('video', 'text', 'quiz')),
    duration_minutes INT,
    is_free BOOLEAN DEFAULT FALSE,
    UNIQUE(course_id, order_index)
);

-- 6. Таблица payments
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30),
    transaction_id VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('success', 'failed', 'refunded', 'pending')),
    course_id INT REFERENCES courses(id) ON DELETE SET NULL
);

-- 7. Таблица reviews
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    helpful_count INT DEFAULT 0
);

-- =====================================================
-- 8. Заполнение тестовыми данными (нагрузочными)
-- =====================================================

-- 8.1 Пользователи (5000)
INSERT INTO users (email, full_name, birth_date, registration_date, is_active, balance, country, city, phone, last_login, referrer_id)
SELECT
    'user' || i || '@example.com',
    'User ' || i,
    DATE '1980-01-01' + (random() * 40 * 365)::INT,
    NOW() - (random() * 1095) * INTERVAL '1 day',
    random() > 0.1,
    (random() * 5000)::DECIMAL(10,2),
    (ARRAY['USA','Canada','UK','Germany','France','Spain','Italy','Poland','Ukraine','Australia'])[floor(random()*10)+1],
    (ARRAY['New York','London','Berlin','Paris','Madrid','Rome','Warsaw','Kyiv','Sydney','Toronto'])[floor(random()*10)+1],
    '+1' || floor(random()*9000000000)::TEXT,
    NOW() - (random() * 30) * INTERVAL '1 day',
    NULL
FROM generate_series(1, 5000) i;

-- 8.2 Курсы (200)
INSERT INTO courses (title, description, price, level, duration_hours, created_at, is_published, language, category, rating_avg)
SELECT
    'Course ' || i,
    'Description for course ' || i,
    (random() * 199 + 1)::DECIMAL(10,2),
    (ARRAY['beginner','intermediate','advanced'])[floor(random()*3)+1],
    floor(random() * 100 + 10)::INT,
    NOW() - (random() * 400) * INTERVAL '1 day',
    random() > 0.05,
    (ARRAY['English','Spanish','French','German'])[floor(random()*4)+1],
    (ARRAY['IT','Marketing','Design','Business','Photography'])[floor(random()*5)+1],
    (random() * 5)::DECIMAL(3,2)
FROM generate_series(1, 200) i;

-- 8.3 Записи (15000)
INSERT INTO enrollments (user_id, course_id, enrolled_at, progress_percent, is_completed, grade, certificate_issued, last_accessed, payment_status)
SELECT
    floor(random() * 5000 + 1)::INT,
    floor(random() * 200 + 1)::INT,
    NOW() - (random() * 200) * INTERVAL '1 day',
    floor(random() * 101)::INT,
    random() > 0.7,
    CASE WHEN random() > 0.7 THEN floor(random() * 101)::INT ELSE NULL END,
    random() > 0.8,
    NOW() - (random() * 30) * INTERVAL '1 day',
    (ARRAY['paid','pending','free'])[floor(random()*3)+1]
FROM generate_series(1, 15000) i
ON CONFLICT DO NOTHING;

-- 8.4 Уроки (800)
INSERT INTO lessons (course_id, title, order_index, content_type, duration_minutes, is_free)
SELECT
    floor(random() * 200 + 1)::INT,
    'Lesson ' || i,
    floor(random() * 20 + 1)::INT,
    (ARRAY['video','text','quiz'])[floor(random()*3)+1],
    floor(random() * 60 + 5)::INT,
    random() > 0.8
FROM generate_series(1, 800) i
ON CONFLICT DO NOTHING;

-- 8.5 Платежи (12000)
INSERT INTO payments (user_id, amount, payment_date, payment_method, transaction_id, status, course_id)
SELECT
    floor(random() * 5000 + 1)::INT,
    (random() * 300 + 10)::DECIMAL(10,2),
    NOW() - (random() * 365) * INTERVAL '1 day',
    (ARRAY['card','paypal','crypto'])[floor(random()*3)+1],
    'tx_' || md5(random()::TEXT),
    (ARRAY['success','failed','refunded','pending'])[floor(random()*4)+1],
    CASE WHEN random() > 0.3 THEN floor(random() * 200 + 1)::INT ELSE NULL END
FROM generate_series(1, 12000) i;

-- 8.6 Отзывы (6000)
INSERT INTO reviews (user_id, course_id, rating, comment, created_at, helpful_count)
SELECT
    floor(random() * 5000 + 1)::INT,
    floor(random() * 200 + 1)::INT,
    floor(random() * 5 + 1)::INT,
    'This is a sample review comment for testing. ' || md5(random()::TEXT),
    NOW() - (random() * 300) * INTERVAL '1 day',
    floor(random() * 50)::INT
FROM generate_series(1, 6000) i
ON CONFLICT DO NOTHING;

-- 8.7 Обновим referrer_id для части пользователей (чтобы была самосвязь)
UPDATE users SET referrer_id = floor(random() * 5000 + 1)::INT
WHERE random() < 0.3;

-- 8.8 Обновим средний рейтинг курсов (агрегат)
UPDATE courses c
SET rating_avg = (SELECT COALESCE(AVG(rating), 0) FROM reviews WHERE course_id = c.id);

-- =====================================================
-- 9. Несколько полезных запросов для анализа производительности (необязательно)
-- =====================================================
-- EXPLAIN ANALYZE
-- SELECT u.full_name, c.title, e.progress_percent
-- FROM enrollments e
-- JOIN users u ON e.user_id = u.id
-- JOIN courses c ON e.course_id = c.id