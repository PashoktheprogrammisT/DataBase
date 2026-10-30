
-- Часть 1

-- Задание 1.2
INSERT INTO subscriptions (name, price, duration_days, is_active) 
VALUES ('Семейный', 1499.00, 90, true);

INSERT INTO payments (user_id, subscription_id, amount, paid_at, status) 
VALUES 
    (1, 4, 1499.00, '2025-04-01 10:00:00', 'SUCCESS'),
    (2, 4, 1499.00, '2025-04-02 12:00:00', 'SUCCESS');

UPDATE payments 
SET status = 'SUCCESS' 
WHERE user_id = 2 AND status = 'PENDING';

UPDATE payments 
SET amount = amount * 0.9 
WHERE subscription_id = 1 AND paid_at < '2025-02-01';

DELETE FROM users WHERE user_id = 11;

BEGIN;
DELETE FROM users WHERE user_id IN (9, 10);
SELECT COUNT(*) FROM users;
ROLLBACK;
SELECT COUNT(*) FROM users;


-- Часть 2

-- Задание 2.1
SELECT 	
    u.full_name AS "Пользователь",
    m.title AS "Фильм",
    g.name AS "Жанр",
    mv.watched_at AS "Когда смотрел",
    mv.progress AS "Прогресс, %"
FROM users u
JOIN movie_views mv ON u.user_id = mv.user_id
JOIN movies m ON mv.movie_id = m.movie_id
JOIN movie_genres mg ON m.movie_id = mg.movie_id
JOIN genres g ON mg.genre_id = g.genre_id
ORDER BY mv.watched_at DESC;

SELECT 
    m.title AS "Фильм",
    m.release_year AS "Год",
    m.rating AS "Рейтинг"
FROM movies m
LEFT JOIN movie_views mv ON m.movie_id = mv.movie_id
WHERE mv.view_id IS NULL;

SELECT 
    u.full_name AS "Пользователь"
FROM users u
JOIN movie_views mv ON u.user_id = mv.user_id
JOIN movies m ON mv.movie_id = m.movie_id
JOIN movie_genres mg ON m.movie_id = mg.movie_id
JOIN genres g ON mg.genre_id = g.genre_id
WHERE g.name IN ('Драма', 'Фантастика')
GROUP BY u.user_id, u.full_name
HAVING COUNT(DISTINCT g.name) = 2;


-- Задание 2.2
SELECT 
    u.full_name AS "Пользователь",
    COUNT(mv.view_id) AS "Всего просмотров",
    COUNT(DISTINCT mv.movie_id) AS "Уникальных фильмов"
FROM users u
LEFT JOIN movie_views mv ON u.user_id = mv.user_id
GROUP BY u.user_id, u.full_name
ORDER BY "Всего просмотров" DESC;

SELECT 
    s.name AS "Тариф",
    COUNT(p.payment_id) AS "Кол-во покупок",
    SUM(p.amount) AS "Общая выручка",
    ROUND(AVG(p.amount), 2) AS "Средний чек"
FROM subscriptions s
JOIN payments p ON s.subscription_id = p.subscription_id
WHERE p.status = 'SUCCESS'
GROUP BY s.subscription_id, s.name
HAVING SUM(p.amount) > 1000;

SELECT 
    TO_CHAR(paid_at, 'YYYY-MM') AS "Месяц",
    COUNT(payment_id) AS "Кол-во платежей",
    SUM(amount) AS "Общая выручка",
    ROUND(AVG(amount), 2) AS "Средний чек",
    MIN(amount) AS "Мин. чек",
    MAX(amount) AS "Макс. чек"
FROM payments
WHERE status = 'SUCCESS'
GROUP BY TO_CHAR(paid_at, 'YYYY-MM')
ORDER BY "Месяц";


-- Часть 3

-- Задание 3.1
SELECT 
    title AS "Фильм", 
    rating AS "Рейтинг"
FROM movies
WHERE rating > (
    SELECT AVG(rating) 
    FROM movies 
    WHERE rating IS NOT NULL
)
ORDER BY rating DESC;

-- Задание 3.2
SELECT 
    u.full_name AS "Пользователь"
FROM users u
WHERE EXISTS (
    SELECT 1 
    FROM payments p 
    WHERE p.user_id = u.user_id AND p.status = 'SUCCESS'
);

-- Задание 3.3
SELECT 
    u.full_name AS "Пользователь"
FROM users u
WHERE NOT EXISTS (
    SELECT 1 
    FROM payments p 
    WHERE p.user_id = u.user_id
);

-- Задание 3.4
SELECT 
    u.full_name AS "Пользователь",
    p.amount AS "Сумма самого дорогого платежа"
FROM users u
JOIN payments p ON u.user_id = p.user_id
WHERE p.amount = (
    SELECT MAX(p2.amount) 
    FROM payments p2 
    WHERE p2.user_id = u.user_id
);


-- Часть 4

-- Содержательный вопрос: "Какой у нас ТОП-3 самых популярных жанра и сколько уникальных зрителей их смотрят?"

-- Исходные данные
WITH genre_views AS (
    SELECT 
        g.name AS genre_name,
        mv.user_id,
        mv.view_id
    FROM genres g
    JOIN movie_genres mg ON g.genre_id = mg.genre_id
    JOIN movie_views mv ON mg.movie_id = mv.movie_id
),
-- Промежуточные данные и Агрегация
genre_stats AS (
    SELECT 
        genre_name,
        COUNT(view_id) AS total_views,
        COUNT(DISTINCT user_id) AS unique_users
    FROM genre_views
    GROUP BY genre_name
)
-- Итоговый отчет
SELECT 
    genre_name AS "Жанр",
    total_views AS "Всего просмотров",
    unique_users AS "Уникальных зрителей"
FROM genre_stats
ORDER BY total_views DESC
LIMIT 3;
