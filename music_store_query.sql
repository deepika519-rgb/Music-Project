--Q1 who is the senior most employee based on job title?

Select top 1
      last_name, first_name, levels
From employee
Order by levels Desc;

--Q2 which countries have the most invoices?

Select billing_country, count(*) as total_invoices
from invoice
Group by billing_country
Order by billing_country Desc;

--Q3 what are the top 3 values of total invoice

Select top 3 
      Total
From invoice
Order by total Desc;

/* 
Q4 which city has the best customers? We would like to throw a promotional music festival in the city we made
the most money. Write a query that return one city that has the highest sum of invoice totals. Return both the 
city name and sum of all invoice total.
*/

Select top 1
           billing_city, sum(Total) as InvoiceTotal
From invoice
Group by billing_city
Order by sum(Total) Desc;

/* 
Q5 who is the best Customer? The customer who has spend the most money will be declared the best customer. 
write a query that returns the person who has spent the most money?
*/

Select top 1
c.first_name, c.last_name, sum(i.total) as Totalfee
From Customer c
Join Invoice i
     on c.customer_id = i.customer_id
Group by c.first_name, c.last_name
order by Totalfee Desc;

/*
Q6 Write query to return the email, Firstname, lastname, & Genre of all Rock music listeners. Return your list 
ordered alphabetically by email starting with A?
*/

Select Distinct c.first_name, c.last_name, c.email 
From customer c
Join invoice i
     on c.customer_id = i.customer_id
Join invoice_line il
     on i.invoice_id = il.invoice_id
where track_id In (  
                    select track_id
	                from track t
	                Join genre g
	                    on t.genre_id = g.genre_id
	                where g.name like 'Rock')
Order by c.email;
	
/* Q7 Let's invite the artists who have written the most rock music in our dataset. write a query that returns 
the artist name and total track count of the top 10 rock bands.
*/

Select Top 10
      ar.name, g.name, count(ar.artist_id) as no_of_song
From track t
Join album al 
    on t.album_id = al.album_id
Join artist ar
    on al.artist_id = ar.artist_id
Join genre g
     on t.genre_id = g.genre_id
where g.name like 'Rock'
Group By ar.name, g.name
order by no_of_song Desc;

/*
Q8 Return all the track names that have a song length. Longer than the average song length. Return the name and 
millisecons for each track. Order by the song length with the longest songs liste first?
*/

Select name, milliseconds
from track
where milliseconds > (Select avg(milliseconds)
                      from track)
order by milliseconds Desc;

/*
Q9 Fin how much amount spent by each customer on artist? Write a query to return customer name, artist name and 
total spent.
*/

with beat_selling_artist as (
      select top 1
	        ar.artist_id as artist_id,
			ar.name as Artist_name,
			sum(il.unit_price * il.quantity) as Total_sales
	  from invoice_line il
	  join track t
	       on il.track_id =t.track_id
	  join album al
	       on t.album_id = al.album_id
	  join artist ar
	       on al.artist_id = ar.artist_id
	  group by ar.artist_id, ar.name 
	  order by total_sales Desc)

select c.customer_id, c.first_name, c.last_name, bst.artist_name,
      (sum(il.unit_price * il.quantity)) as amount_spent
from invoice i
join customer c 
     on c.customer_id = i.customer_id
join invoice_line il 
     on il.invoice_id = i.invoice_id
join track t 
     on t.track_id = il.track_id
join album alb
     on alb.album_id = t.album_id
join beat_selling_artist bst
     on bst.artist_id = alb.artist_id
group by c.customer_id, c.first_name, c.last_name, bst.Artist_name
order by amount_spent;

/*
Q10 we want to find out the most popular music genre for each country. we determine the most popular genre as 
the genre for highest amount of purchages.
write a query that returns each country along with the top genre. for countries where the maximum number of 
purchases is shared return all genres.
*/

with Popular_Genre As (
     select 
	       count(invoice_line.quantity) as purchases, 
		   customer.country, genre.name, genre.genre_id, 
		   Row_number() over (Partition by customer.country order by count(invoice_line.quantity) Desc) 
		   As Row_no
	 from invoice_line
	 join invoice 
	      on invoice.invoice_id = invoice_line.invoice_id
	 join customer 
	      on customer.customer_id = invoice.customer_id
	 join track 
	      on track.track_id = invoice_line.track_id
	 join Genre 
	      on genre.genre_id = track.genre_id
	 Group by  customer.country, genre.name, genre.genre_id
)

select * 
from Popular_Genre 
where Row_no = 1;

/* Q11 write a query that determine the customer that has spent the most on music for each country. write a 
query that returns the country along with the top customer and how much they spent. for countries where the top
amount spent is shared,provide all customer who spent this amunt.
*/
with customer_with_country As (
     Select 
	       c.customer_id, c.first_name, 
		   c.last_name, i.billing_country, 
		   sum(i.total) as Total_spending,
	       Row_number() over (Partition by i.billing_country order by sum(i.total) Desc) as Rowno
	 from invoice i
	 Join customer c 
	      on c.customer_id = i.customer_id
	 group by c.customer_id, c.first_name, c.last_name, i.billing_country
)

select * from customer_with_country where Rowno = 1;
