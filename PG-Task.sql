--------- 1.Quering Data ---------

SELECT * FROM actor;

SELECT first_name, last_name
FROM actor;

SELECT a.first_name
FROM actor a
ORDER BY first_name;

SELECT COUNT(country_id)
FROM city;

SELECT COUNT(DISTINCT country_id)
FROM city;

--------- 2.Filtering Data ---------

SELECT
	emp_name,
	salary
FROM employee
WHERE salary > 5000;

SELECT
	emp_name,
	salary
FROM employee
ORDER BY salary DESC
LIMIT 1;

SELECT
	emp_name,
	salary
FROM employee
ORDER BY salary DESC
FETCH FIRST 5 ROWS ONLY;

SELECT country_id, country
FROM country
WHERE country IN ('Canada', 'Mexico', 'Italy');

SELECT
	emp_name,
	salary
FROM employee
WHERE salary BETWEEN 5000 AND 10000
ORDER BY salary;

SELECT COUNT(first_name)
FROM actor
WHERE first_name LIKE 'A%';

SELECT COUNT(first_name)
FROM actor
WHERE first_name NOT LIKE 'A%';

SELECT COUNT(*)
FROM address
WHERE address2 IS NULL;

--------- 3.Joining Multiple Tables ---------

SELECT 
	f.title,
	a.first_name || ' ' || a.last_name as actor_name
FROM film_actor fa
JOIN film f USING (film_id)
JOIN actor a USING (actor_id)
WHERE fa.film_id = '1';

SELECT
	film.film_id,
	title,
	inventory_id
FROM film
LEFT JOIN inventory USING(film_id)
WHERE inventory_id IS NULL
ORDER BY title;

SELECT
    f1.title,
    f2.title,
    f1.length
FROM film f1
JOIN film f2 USING(film_id, length);

SELECT *
FROM T1
CROSS JOIN T2;

SELECT *
FROM products
NATURAL JOIN categories;

--------- 4.Grouping Data ---------
SELECT
	country,
	COUNT(*) AS Count
FROM customer c
JOIN address a USING(address_id)
JOIN city ci USING(city_id)
JOIN country co USING(country_id)
GROUP BY co.country
ORDER BY Count;

SELECT
	country,
	COUNT(*) AS Count
FROM customer c
JOIN address a USING(address_id)
JOIN city ci USING(city_id)
JOIN country co USING(country_id)
GROUP BY co.country
HAVING COUNT(*) > 10
ORDER BY Count;

--------- 5.Set Operations ---------

SELECT * FROM top_rated_films
UNION
SELECT * FROM most_popular_films;

SELECT * FROM top_rated_films
INTERSECT
SELECT * FROM most_popular_films;

SELECT * FROM top_rated_films
EXCEPT
SELECT * FROM most_popular_films;

--------- 6.Grouping sets, Cube, and Rollup ---------

SELECT
	GROUPING(brand) grouping_brand,
	GROUPING(segment) grouping_segment,
	brand,
	segment,
	SUM (quantity)
FROM
	sales
GROUP BY
	GROUPING SETS (
		(brand),
		(segment),
		()
	)
ORDER BY
	brand,
	segment;

SELECT
    brand,
    segment,
    SUM (quantity)
FROM sales
GROUP BY
    CUBE (brand, segment)
HAVING brand NOTNULL OR segment NOTNULL
ORDER BY brand, segment;

--------- 7.Subquery ---------

SELECT
	emp_name AS employee,
	salary
FROM employee
WHERE salary < (
	SELECT MAX(salary)
	FROM employee
)
ORDER BY salary DESC LIMIT 1;

SELECT title
FROM film
WHERE length >= ANY(
    SELECT MAX( length )
    FROM film
    INNER JOIN film_category USING(film_id)
    GROUP BY  category_id );

SELECT
    film_id,
    title,
    length
FROM
    film
WHERE
    length > ALL (
            SELECT ROUND(AVG (length),2)
            FROM film
            GROUP BY rating
    )
ORDER BY length;

SELECT 
	first_name,
	last_name
FROM customer c
WHERE EXISTS (
	SELECT 1 
	FROM payment p
	WHERE c.customer_id = p.customer_id
	AND amount > 11
);

--------- 8.Common Table Expression ---------

WITH film_length AS
(
	SELECT 
	film_id,
	title,
	(CASE 
	 	WHEN length < 30 THEN 'Short'
	 	WHEN length < 90 THEN 'Medium'
		ELSE 'Long'
	 END ) AS length
	
FROM film )

SELECT
	film_id,
	title,
	length
FROM film_length
WHERE length = 'Long'
ORDER BY film_id;

WITH RECURSIVE emp_hierarchy AS
(
	SELECT 
		employee_id,
		manager_id,
		full_name
	FROM employees
	WHERE employee_id = 2

	UNION
	
	SELECT 
		e.employee_id,
		e.manager_id,
		e.full_name
	FROM employees e
	JOIN emp_hierarchy em
	ON em.employee_id = e.manager_id
)

SELECT *
FROM emp_hierarchy;

--------- 9.Modifying Data ---------

CREATE TABLE temp (
	id SERIAL PRIMARY KEY,
	name VARCHAR (50) NOT NULL,
	occupation VARCHAR (50)
);

INSERT INTO 
	temp (name, occupation)
VALUES
	('Arjun', 'Data Engineer');
	
INSERT INTO 
	temp (name, occupation)
VALUES
	('Xname', 'Business Analyst'),
	('Yname', 'Full Stack Developer'),
	('Zname', 'Python Developer');

UPDATE temp
SET occupation = 'Data Engineer'
WHERE name = 'Zname';

UPDATE productX
SET net_price = price - price * discount
FROM product_segment
WHERE productX.segment_id = product_segment.id;

DELETE FROM productX
WHERE id = 1;

INSERT INTO customers (NAME, email)
VALUES('Microsoft','hotline@microsoft.com') 
ON CONFLICT ON CONSTRAINT customers_name_key 
DO 
	UPDATE SET email = EXCLUDED.email || ';' || customers.email;

--------- 10.Transaction ---------

BEGIN;
	
	UPDATE accounts
	SET balance = balance - 1000
	WHERE id = 1;
	
	UPDATE accounts
	SET balance = balance + 1000
	WHERE id = 2;
	
	SELECT * FROM accounts;
	
	COMMIT;

END;

--------- 11.Managing Tables ---------

CREATE TABLE temp2
(
	user_id serial PRIMARY KEY,
	username VARCHAR(50) NOT NULL,
	password VARCHAR(50),
	email VARCHAR(50) NOT NULL UNIQUE,
	created_on TIMESTAMP
);

SELECT c.*
INTO TABLE customer_japan
FROM customer c
JOIN address a USING (address_id)
JOIN city ci USING (city_id)
JOIN country co USING (country_id)
WHERE co.country = 'Japan'
ORDER BY c.customer_id;

CREATE TABLE x (
    x_id INT GENERATED ALWAYS AS IDENTITY,
    x_name VARCHAR NOT NULL
);

INSERT INTO x (x_name)
VALUES 
('Arjun'),
('XName');

ALTER TABLE x
ADD COLUMN x_occupation VARCHAR(50);

ALTER TABLE x
RENAME TO x_x;

ALTER TABLE x_x
DROP COLUMN x_occupation;

ALTER TABLE x_x
RENAME COLUMN x_name TO name;

ALTER TABLE x_x
ALTER COLUMN x_id TYPE int;

TRUNCATE TABLE x_x;

CREATE TEMP TABLE temp_cust(
    cust_id INT
);

INSERT INTO temp_cust(cust_id)
VALUES (123);

DROP TABLE temp_cust;

CREATE TABLE cj_copy AS
TABLE customer_japan;

--------- 12.Understanding PostgreSQL Constraints ---------

CREATE TABLE person
(
	p_id SERIAL PRIMARY KEY,
	name VARCHAR (50) NOT NULL,
	email VARCHAR (100) NOT NULL UNIQUE,
	birthday DATE CHECK(birthday > '1950-01-01') NOT NULL,
	created_on TIMESTAMP
);

CREATE TABLE emp_details
(
	emp_id SERIAL PRIMARY KEY,
	p_id INT,
	FOREIGN KEY(p_id)
	REFERENCES person(p_id)
);

--------- 13.PostgreSQL Data Types in Depth ---------

CREATE DOMAIN contact_name AS 
   VARCHAR NOT NULL CHECK (value !~ '\s');


CREATE TABLE contacts (
    contact_id uuid DEFAULT uuid_generate_v4 (),
    name contact_name,
    phone TEXT [],
	email hstore,
    PRIMARY KEY (contact_id)
);

INSERT INTO contacts (name, phone, email)
VALUES (
	'Arjun', 
	ARRAY['(408)-589-5846','(408)-589-5555'],
	'"personal" => "abc@gmail.com",
	 "work" => "xyz@gmail.com"'
);

SELECT 
	name,
	unnest(phone)
FROM contacts;

SELECT 
	name,
	skeys(email)
FROM contacts;

CREATE TABLE orders (
	id serial NOT NULL PRIMARY KEY,
	info json NOT NULL
);

INSERT INTO orders (info)
VALUES('{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'),
      ('{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'),
      ('{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}');

SELECT info ->> 'customer' AS customer,
	info -> 'items' ->> 'product' AS product,
	info -> 'items' ->> 'qty' AS quantity
FROM orders;


--------- 14.Conditional Expressions & Operators ---------

SELECT 
	title,
	(CASE 
	 	WHEN length < 30 THEN 'Short'
	 	WHEN length < 90 THEN 'Medium'
	 	ELSE 'Long'
	 END
	) length
FROM film;

SELECT
	product,
	(price - COALESCE(discount,0)) AS net_price
FROM items;

SELECT
	(SUM (CASE
			WHEN gender = 1 THEN 1
			ELSE 0
		END) 
	 / 
		 NULLIF(SUM (CASE
				WHEN gender = 2 THEN 1
				ELSE 0
			END) 
		, 0)
	) * 100 AS "Gender ratio"
FROM
	members;

SELECT 
	id,
	CASE
		WHEN rating~E'^\\d+$' THEN
			CAST(rating AS INTEGER)
		ELSE 
			0
	END
FROM ratings;

--------- PL\SQL ---------

--------- Anonymous Block ---------

DO $$
DECLARE
	country_count integer = 0;
	country_name varchar = 'India';
BEGIN 
	SELECT
		COUNT(*) INTO country_count
	FROM customer c
		JOIN address a USING(address_id)
		JOIN city ci USING(city_id)
		JOIN country co USING(country_id)
	WHERE co.country = country_name
	GROUP BY co.country;
	
	RAISESELECT get_length_type(5) AS length NOTICE 'Number of customers in % are %', country_name, country_count;
END $$;

--------- Row Type ---------

DO $$
DECLARE
	films top_rated_films%rowtype;
BEGIN 
	SELECT *
	FROM top_rated_films
	into films
	WHERE release_year = 1957;
	
	RAISE NOTICE '% - %', films.title, films.release_year;
END $$;

--------- Record Type ---------

DO $$
DECLARE
	rec record;
BEGIN
	SELECT film_id, title, length 
	INTO rec
	FROM film
	WHERE film_id = 100;
	
	RAISE NOTICE 'ID % - % - %', rec.film_id, rec.title, rec.length;   	
END $$;

--------- Constant Type ---------

DO $$
DECLARE
	pie CONSTANT NUMERIC = 3.14;
	r INTEGER = 7;
	result NUMERIC (10,2);
BEGIN
	SELECT pie * (POWER(r, 2)) INTO result;
	
	RAISE NOTICE 'Result - %', result;
END $$;

--------- Control Structure ---------

DO $$
DECLARE
	films top_rated_films%rowtype;
BEGIN 
	SELECT *
	FROM top_rated_films
	INTO films
	WHERE release_year = 1958;
	
	IF NOT FOUND THEN
		RAISE NOTICE 'No film found for given release year.';
	ELSE
		RAISE NOTICE '% - %', films.title, films.release_year;
	END IF;
END $$;

DO $$
DECLARE
	len VARCHAR;
BEGIN 
	SELECT
		(CASE 
			WHEN length < 30 THEN 'Short'
			WHEN length < 90 THEN 'Medium'
			ELSE 'Long'
		 END
		) INTO len
	FROM film
	WHERE film_id = 1;
	
	IF NOT FOUND THEN
		RAISE NOTICE 'No film found for given film id.';
	ELSE
		RAISE NOTICE '%', len;
	END IF;
END $$;

DO $$
DECLARE
	rec record;
	counter INT = 0;
BEGIN
	 FOR rec IN SELECT 
	 			film_id,
				title,
				(CASE 
				WHEN length < 30 THEN 'Short'
				WHEN length < 90 THEN 'Medium'
				ELSE 'Long'
		 	END) length
			FROM film
			ORDER BY film_id
	LOOP
		counter = counter + 1;
		IF counter > 10 THEN 
			EXIT;
		END IF;
		RAISE NOTICE 'ID % - % - %', rec.film_id, rec.title, rec.length;
	END LOOP;
END $$;

DO $$
DECLARE
	rec record;
BEGIN
	 FOR rec IN SELECT film_id, title, length
			FROM film
			WHERE film_id BETWEEN 11 AND 20
	LOOP
		RAISE NOTICE 'ID % - % - %', rec.film_id, rec.title, rec.length;
	END LOOP;
END $$;

do $$
declare 
   counter integer := 1;
begin
   while counter <= 5 loop
      raise notice 'Counter %', counter;
	  counter := counter + 1;
   end loop;
end$$;

DO $$
DECLARE
	rec record;
	counter INT = 0;
BEGIN
	 FOR rec IN SELECT 
	 			film_id,
				title,
				(CASE 
				WHEN length < 30 THEN 'Short'
				WHEN length < 90 THEN 'Medium'
				ELSE 'Long'
		 	END) length
			FROM film
			ORDER BY film_id
	LOOP
		IF rec.length IN ('Short', 'Medium') THEN
			CONTINUE;
		END IF;
		RAISE NOTICE 'ID % - % - %', rec.film_id, rec.title, rec.length;
	END LOOP;
END $$;

--------- User-defined functions ---------

CREATE OR REPLACE FUNCTION get_length_type(f_id INT)
RETURNS VARCHAR
LANGUAGE plpgsql
AS
$$
DECLARE
	result VARCHAR;
BEGIN
	SELECT 
		(CASE 
			WHEN length < 30 THEN 'Short'
			WHEN length < 90 THEN 'Medium'
			ELSE 'Long'
		END) INTO result
	FROM film
	WHERE film_id = f_id;
	
	RETURN result;
END $$;

SELECT get_length_type(1) AS length;

CREATE OR REPLACE FUNCTION get_film_stat(OUT avg_len INT) 
LANGUAGE plpgsql
AS $$
BEGIN
  
  SELECT 
  	AVG(length)::NUMERIC(5,1)
	INTO avg_len
  FROM film;
END $$;

SELECT get_film_stat();

CREATE OR REPLACE FUNCTION swap(INOUT x INT, INOUT y INT)
LANGUAGE plpgsql
AS $$
BEGIN
	SELECT x, y INTO y, x;
END $$;

SELECT swap(10, 20);

CREATE OR REPLACE FUNCTION swap(INOUT x INT, INOUT y INT, INOUT z INT)
LANGUAGE plpgsql
AS $$
BEGIN
	SELECT x, y, z INTO z, y, x;
END $$;

SELECT swap(10, 20, 30);

CREATE OR REPLACE FUNCTION get_film (p varchar) 
RETURNS TABLE (
	film_title varchar,
	film_release_year int
) 
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
		SELECT
			title,
			release_year::integer
		FROM
			film
		WHERE
			title ILIKE p;
END $$;

SELECT get_film('ar%');

DROP FUNCTION swap(INT, INT, INT);

--------- Exception handling ---------

DO $$
DECLARE
	rec record;
	v_film_id int = 2000;
BEGIN
	SELECT film_id, title 
	INTO STRICT rec
	FROM film
	WHERE film_id = v_film_id;
	
	EXCEPTION
	   WHEN no_data_found THEN
	      RAISE EXCEPTION 'film % not found', v_film_id;
END $$;

--------- Stored procedures ---------

CREATE OR REPLACE PROCEDURE transfer(sender INT, receiver INT, amt INT)
LANGUAGE PLPGSQL
AS $$
BEGIN
	UPDATE accounts
	SET balance = balance - amt
	WHERE id = sender;
	
	UPDATE accounts
	SET balance = balance + amt
	WHERE id = receiver;
	
	COMMIT;
END $$;

CALL transfer(2, 1, 1000);

DROP PROCEDURE transfer;

--------- Cursors ---------

CREATE OR REPLACE FUNCTION get_film_titles(p_year INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
	titles TEXT DEFAULT '';
	rec record;
	cur_films CURSOR(p_year INT)
			FOR SELECT title, release_year
				FROM film
				WHERE release_year = p_year;
BEGIN
	OPEN cur_films(p_year);
	
	LOOP
		FETCH cur_films into rec;
		
		EXIT WHEN NOT FOUND;
		
		IF rec.title ILIKE '%ful%' THEN 
			IF titles != '' THEN
				titles = titles || ', ' || rec.title || ' - ' || rec.release_year;
			ELSE
				titles = rec.title || ' - ' || rec.release_year;
			END IF;
		END IF;
	END LOOP;
	
	CLOSE cur_films;
	
	RETURN titles;
END $$;

SELECT get_film_titles(2006) AS films;

--------- Trigger ---------

CREATE TABLE transfer_audits (
	transaction_id INT GENERATED ALWAYS AS IDENTITY,
	account_id INT NOT NULL,
	account_holder VARCHAR(40) NOT NULL,
	amount INT NOT NULL,
	transaction_type VARCHAR NOT NULL,
    transaction_at TIMESTAMP(6) NOT NULL
);


CREATE TRIGGER transfer_log
	AFTER UPDATE
	ON accounts
	FOR EACH ROW
	EXECUTE PROCEDURE log_transfer();


CREATE OR REPLACE FUNCTION log_transfer() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
	t_type VARCHAR DEFAULT '';
	amt INT;
BEGIN
	IF OLD.balance > NEW.balance THEN 
		t_type = 'Debit';
		amt = OLD.balance - NEW.balance;
	ELSE
		t_type = 'Credit';
		amt = NEW.balance - OLD.balance;
	END IF;
	
	INSERT INTO transfer_audits(account_id, account_holder, amount, transaction_type, transaction_at)
	VALUES(
		OLD.id,
		OLD.name,
		amt,
		t_type,
		now()
	);
	
	RETURN NEW;
END $$;

CALL transfer(1, 2, 2000);

SELECT * FROM transfer_audits;