```sql
-- Задание 1: Магазин >300 покупателей
SELECT CONCAT(s.last_name, ' ', s.first_name) AS staff_name,
       c.city,
       COUNT(cu.customer_id) AS customer_count
FROM store st
JOIN staff s ON st.manager_staff_id = s.staff_id
JOIN address a ON st.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN customer cu ON st.store_id = cu.store_id
GROUP BY st.store_id, s.last_name, s.first_name, c.city
HAVING COUNT(cu.customer_id) > 300;

-- Задание 2: Фильмы длиннее среднего
SELECT COUNT(*) AS films_longer_than_average
FROM film f
WHERE f.length > (
    SELECT AVG(length) 
    FROM film
);

-- Задание 3: Месяц с max платежами
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS payment_month,
       SUM(amount) AS total_payments,
       COUNT(r.rental_id) AS rental_count
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY total_payments DESC
LIMIT 1;

-- Задание 4: Продажи с премией
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    COUNT(p.payment_id) AS sales_count,
    CASE 
        WHEN COUNT(p.payment_id) > 8000 THEN 'Да'
        ELSE 'Нет'
    END AS bonus
FROM staff s
LEFT JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name;

-- Задание 5: Фильмы без аренд
SELECT 
    f.title,
    f.film_id
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL
GROUP BY f.film_id, f.title;
```