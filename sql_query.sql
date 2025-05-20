---    Set-1 Easy SQL Question
---01: Who is the senior most employee based on job title?
       select first_name ,levels
       from employee 
       order by levels desc
       limit 1

---02: which countries have the most invoices?
       select count(*) as c, billing_country
       from invoice
       group by billing_country
       order by c desc

---03: what are top 3 values of total invoic?
       select * from invoice
       order by total desc
       limit 3

---04: which country has the best customers? we would like to throw a promotional Music festival
---    in the city we made the most money. write a query which returns one city that has the 
---    heightest sum of invoice totals. Return both the city name and sum of all invoice tptal?
       select sum(total)as invoice_total, billing_city
       from invoice
	   group by billing_city
	   order by invoice_total desc


--- 05: Who is the best costomer? The customer who has spend the most money will be declared 
---     the bsest customer. Write the query that returns the person who has spent the most money?	   
        select customer.customer_id, customer.first_name, customer.last_name , sum(invoice.total)as total
		from customer
		join invoice on customer.customer_id = invoice.customer_id
		group by customer.customer_id
		order by total desc
		limit 1


---     Set-2Moderate level SQL question
--- 01: Write query	to return the email, first name, last name and genre or all rock music listeners
---     Return your list ordered alphabetically by email starting with A ?
        select distinct email, first_name, last_name
		from customer 
		join invoice on customer. customer_id = invoice.customer_Id
		join invoice_line on invoice.invoice_id = invoice_line.invoice_id
		where track_id in(
                          select track_id from track
						  join genre on track.genre_id = genre.genre_id
						  where genre.name like 'Rock'
						  )
	   order by email;


---	 02: Let's invite the artists  who have written the most rock music in our dataset. Write a wuery
---      that returns the artist name and tatal track count of the top 10 rock bands.
         select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
		 from track
		 join album on album.album_id = track.album_id
		 join artist on artist.artist_id = album.artist_id
		 join genre on genre.genre_id = track.genre_id
		 where genre.name like 'Rock'
		 group by artist.artist_id
		 order by number_of_songs desc
		 limit 10;

		 
--- 03:  Return all track names that have a song length longer than the average song length. Return the 
---      name and milliseconds for each track. Order by the song length with the longest songs listed 
---      first?
         select name, milliseconds
		 from track
		 where milliseconds > (
               select avg(milliseconds) as avg_track_length
			   from track)
	      order by milliseconds desc;


		 select name, milliseconds
		 from track
		 where milliseconds > 393599
	     order by milliseconds desc;



---     Set-3 Advance level SQL questions
--- 01: Find how much amount spent by each customer on artists? write a query to return customer name, 
---     artist name and total spent
        with best_selling_artist as (
             select artist.artist_id as artist_id, artist.name as artist_name,
			 sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
			 from invoice_line
			 join track on track.track_id = invoice_line.track_id
			 join album on album.album_id = track.album_id
             join artist on artist.artist_id = album.artist_id
			 group by 1
			 order by 3 desc
			 limit 1	 
		)
		select c. customer_id, c.first_name, c.last_name, bsa.artist_name,
		sum(il.unit_price*il.quantity) as amount_spent
		from invoice i
		join customer c on c.customer_id = i.customer_id
		join invoice_line il on il.invoice_id = i.invoice_id
		join track t on t.track_id =il.track_id
		join album alb on alb.album_id = t.album_id
		join best_selling_artist bsa on bsa.artist_id = alb.artist_id
        group by 1,2,3,4
		order by 5 desc;
		



--- 02: We want to find out the most popular music genre for each country. We determine the most popular 
---     genre with the highest amount of purchases. Write a query that returns each country along with 
---     the top genre. For countries where the maximum number of purchases is shared return all genres.

 /* Method 1: Using CTE */

       WITH popular_genre AS 
       (
        SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
        FROM invoice_line 
	    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	    JOIN customer ON customer.customer_id = invoice.customer_id
	    JOIN track ON track.track_id = invoice_line.track_id
	    JOIN genre ON genre.genre_id = track.genre_id
	    GROUP BY 2,3,4
	    ORDER BY 2 ASC, 1 DESC
        )
        SELECT * FROM popular_genre WHERE RowNo <= 1

/* Method 2: : Using Recursive */

      WITH RECURSIVE
	    sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	  ),
	    max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

        SELECT sales_per_country.* 
        FROM sales_per_country
        JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
        WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;



---03: Write a query that determines the customer that has spent the most on music for each country. 
---    Write a query that returns the country along with the top customer and how much they spent. 
---    For countries where the top amount spent is shared, provide all customers who spent this amount.
        /* Method 1: using CTE */

       WITH Customter_with_country AS 
	   (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC
		)
        SELECT * FROM Customter_with_country WHERE RowNo <= 1


/* Method 2: Using Recursive */

       WITH RECURSIVE 
	   customter_with_country AS 
	   (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC
		),

	    country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country
		)

        SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
        FROM customter_with_country cc
        JOIN country_max_spending ms
        ON cc.billing_country = ms.billing_country
        WHERE cc.total_spending = ms.max_spending
        ORDER BY 1;

--- End of project
 