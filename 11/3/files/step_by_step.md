```sql
-- Задание 1: Районы K...a без пробелов
SELECT DISTINCT district 
FROM address 
WHERE district LIKE 'K%a' AND district NOT LIKE '% %' AND district IS NOT NULL;

-- Задание 2: Платежи 15-18 июня 2005 > $10
SELECT * FROM payment
WHERE payment_date >= '2005-06-15' 
  AND payment_date <= '2005-06-18 23:59:59' 
  AND amount > 10.00;

-- Задание 3: Последние 5 аренд
SELECT * FROM rental ORDER BY rental_date DESC LIMIT 5;

-- Задание 4: Kelly/Willie активные
SELECT REPLACE(LOWER(first_name), 'll', 'pp') AS first_name,
       LOWER(last_name) AS last_name,
       active
FROM customer
WHERE active = 1 AND first_name IN ('Kelly', 'Willie');

-- Задание 5: Разделить email
SELECT email,
       SUBSTRING_INDEX(email, '@', 1) AS username,
       SUBSTRING_INDEX(email, '@', -1) AS domain
FROM customer;

-- Задание 6: Email с заглавной буквой
SELECT email,
       CONCAT(UPPER(LEFT(SUBSTRING_INDEX(email, '@', 1), 1)),
              LOWER(SUBSTRING(SUBSTRING_INDEX(email, '@', 1), 2))) AS username,
       CONCAT(UPPER(LEFT(SUBSTRING_INDEX(email, '@', -1), 1)),
              LOWER(SUBSTRING(SUBSTRING_INDEX(email, '@', -1), 2))) AS domain
FROM customer;
```