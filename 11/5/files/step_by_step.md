```sql
-- Задание 1: Процент индексов
SELECT 
    ROUND(
        (SUM(index_length) / SUM(data_length + index_length) * 100), 2
    ) AS 'Индексы к таблицам (%)'
FROM information_schema.tables 
WHERE table_schema = 'sakila';

-- Задание 2: Оптимизированный запрос
SELECT DISTINCT CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
       ROUND(SUM(p.amount), 2) AS total_amount
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN customer c ON r.customer_id = c.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE p.payment_date >= '2005-07-30 00:00:00' 
  AND p.payment_date < '2005-07-31 00:00:00'
GROUP BY c.customer_id, c.last_name, c.first_name;

-- Индекс для оптимизации:
CREATE INDEX idx_payment_date ON payment(payment_date);
CREATE INDEX idx_payment_rental_date ON payment(rental_date);
```