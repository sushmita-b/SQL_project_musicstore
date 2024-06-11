--Q Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

--Q Which countries have the most invoices?

SELECT COUNT(*) AS c, billing_country
FROM invoice
GROUP BY billing_country 
ORDER BY c DESC

--Q What are top 3 values of total invoices?

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

--Q Which city has the best customer?
--We would like to thorw a promotional Music Festival in thr city we made the most money.Write a query that returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals. 

SELECT SUM(total) AS invoice_total,billing_city	
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC

--Q Who is the best customer? The customer who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money.

SELECT customer.customer_id, customer.first_name,customer.last_name, SUM(invoice.total) AS total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1

--Q Write query to return the email, first name ,last name & Genre of all Rock music listeners.
--Return your list ordered alphabetically by email staring with A
SELECT DISTINCT email, first_name,last_name
FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN (
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email

--Q Let's invite the artists who have written the most rockmusic in our dataset.
--Write a query that retruns the Artist name and total track count of the tpo 10 rock brands
SELECT artist.artist_id,artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
where genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

--Q Return all the track names that have a song lrngth longer than the average song length.
--Retrun the name and milliseconds for each track.
--Order by the song length with the longest songs listed frist.

SELECT name,milliseconds
FROM track
WHERE milliseconds >(
	SELECT AVG(milliseconds) AS avg_length
	FROM track
)
ORDER BY milliseconds DESC;

--Q Find how much amount spent by each customer on artists
--Write a query to return customer nsme, artist name and total spent

WITH best_selling_artists AS(
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id= i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artists bsa ON bsa.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Q We want to find out the most popular music genre for each country
--we determine the most popular genre as the genre with the highest amount of purchases.
--write a query that returns each country along with the top genre. for countries where hter maximum number of purchases is shared return all genres.

WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY count(invoice_line.quantity)DESC) AS RowNo
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC 
	)
SELECT * FROM popular_genre WHERE RowNo<=1

--Q Write a query that determines the suctomer that has spent the most on music for each country.
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent his amount.

WITH RECURSIVE
  customer_with_country AS (
  SELECT customer.customer_id,first_name,last_name,billing_country, SUM(total) AS total_spending
  FROM INVOICE
  JOIN customer ON customer.customer_id = invoice.customer_id
  GROUP BY 1,2,3,4
  ORDER BY 1,5 DESC),

  country_max_spending AS (
	SELECT billing_country ,MAX(total_spending) AS max_spending
	FROM customer_with_country
	GROUP BY billing_country)
SELECT cc.billing_country,cc.total_spending,cc.first_name,cc.last_name
FROM customer_with_country cc
JOIN country_max_spending ms ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;	
	
	
  
  









