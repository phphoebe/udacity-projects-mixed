
-- I used Excel Pivot Tables for creating the visualizations based on the query results.

-- Question 1 -What are the numbers of times Family movies have been rented out?
WITH t1
     AS (SELECT f.title AS film_title,
                c.name AS category_name
        FROM category c
             JOIN film_category fc
                ON c.category_id = fc.category_id
             JOIN film f
                ON fc.film_id = f.film_id
        WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy',
                         'Family', 'Music')),
      t2
      AS (SELECT f.title AS film_title,
                 COUNT(rental_id) AS rental_count
          FROM film f
              JOIN inventory i
                ON f.film_id = i.film_id
              JOIN rental r
                ON i.inventory_id = r.inventory_id
          GROUP BY 1)
SELECT t1.film_title,
       t1.category_name,
       t2.rental_count
FROM t1
     JOIN t2
        ON t1.film_title = t2.film_title
ORDER BY category_name,
         film_title



-- Question 2 - What is the quartile distribution for family movies based on rental duration?
WITH t1
     AS (SELECT c.name AS category_name,
                NTILE(4) OVER (ORDER BY f.rental_duration) AS quartile
         FROM category c
              JOIN film_category fc
                  ON c.category_id = fc.category_id
              JOIN film f
                  ON fc.film_id = f.film_id
         WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy',
                          'Family', 'Music'))
SELECT category_name AS Category,
       quartile AS Rental_Length_Category,
       COUNT (*) AS count
FROM t1
GROUP BY 1,2
ORDER BY 1,2


-- I used Excel Concatenate and Left function for creating the Year-Month Column for visualizaitons.

-- Question 3 - What is the monthly rental orders fulfilled by each store?
SELECT DATE_PART ('month', rental_date) AS Rental_month,
       DATE_PART ('year', rental_date) AS Rental_year,
       s.store_id AS Store_ID,
       COUNT (*) AS Count_rentals
FROM rental r
      JOIN staff f
          ON r.staff_id = f.staff_id
      JOIN store s
          ON f.store_id = s.store_id
GROUP BY 1,2,3
ORDER BY 4 DESC


-- Question 4 -What are the Top 10 customers’ monthly expenditure?
WITH t1
     AS (SELECT c.first_name ||' '||c.last_name AS full_name,
                c.customer_id AS customer_id,
                SUM (p.amount) AS pay_amount
         FROM payment p
              JOIN customer c
                  ON p.customer_id = c.customer_id
         GROUP BY 1,2
         ORDER BY 3 DESC
         LIMIT 10)
SELECT DATE_TRUNC ('month',p.payment_date) AS pay_mon,
       t1.full_name AS fullname,
       COUNT(p.payment_id) AS pay_countpermon,
       SUM (p.amount) AS pay_amount
FROM t1
     JOIN payment p
        ON t1.customer_id = p.customer_id
GROUP BY 1,2
ORDER BY 2,1
