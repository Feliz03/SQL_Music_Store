--SQL project 
--Creating tables 
--Names of Tables: 1)Employee 2)Customer 3)Invoice 4) Playlist 5)Artist 6)Album 7)Media_type
--                 8)Genre 9)Track 10)Invoice_line 11)Playlist_track

create table employyee (
employee_id number primary key, 
last_name varchar2(20),
first_name varchar2(20),
title varchar2(30),
reports_to number,
birthdate date,
hire_date date,
address varchar2(30),
city varchar2(20),
state varchar2(20),
country varchar2(20),
postal_code varchar(20),
phone number, 
fax number,
email varchar2(30)
);

desc employyee;

------------------------------------------
create table customer(
customer_id number,
first_name varchar2(20),
last_name varchar2(20),
company varchar2(20),
address varchar2(20),
city varchar2(20),
state varchar2(20),
country varchar2(20),
postal_code varchar2(20),
phone number,
fax number,
email varchar2(20),
support_rep_id number,
  constraints emp_id_fk foreign key (support_rep_id) references employyee(employee_id));

desc customer;

alter table customer
add constraints cust_id_pk primary key(customer_id);
--------------------------
create table invoice(
invoice_id number primary key,
customer_id number,
invoice_date date,
billing_address varchar2(20),
billing_city varchar2(20),
billing_state varchar2(20),
billing_country varchar2(20),
billing_postal_code varchar2(20),
total number,
 constraint cust_id_fk foreign key (customer_id) references customer(customer_id));
 
desc invoice;

-----------------------------------
create table playlist(
playlist_id number primary key,
name varchar2(20));

----------------------------------
create table artist(
artist_id number primary key,
name varchar2(20));

--------------------------------
create table album(
album_id number primary key,
title varchar2(20),
artist_id number,
 constraints artist_id_fk foreign key (artist_id) references artist(artist_id));
 
---------------------------------
create table media_type(
media_type_id number primary key,
name varchar2(20));

---------------------------------
create table genre(
genre_id number primary key,
name varchar2(20));

-----------------------------------
create table track(
track_id number primary key,
name varchar2(20),
album_id number,
media_type_id number,
genre_id number,
composer varchar2(20),
milliseconds number,
bytes number,
unit_price number,
 constraints album_id_fk foreign key (album_id) references album(album_id),
 constraints media_type_id_fk foreign key (media_type_id) references media_type(media_type_id),
 constraints genre_id_fk foreign key (genre_id) references genre(genre_id));
 
--------------------------------------------------
create table invoice_line(
invoice_line_id number primary key,
invoice_id number,
track_id number,
unit_price number,
quantity number,
 constraints invoice_id_fk foreign key (invoice_id) references invoice(invoice_id),
 constraints track_id_fk foreign key (track_id) references track(track_id));

---------------------------------
create table playlist_track(
playlist_id number,
track_id number,
  constraints play_id_fk foreign key (playlist_id) references playlist(playlist_id),
  constraints track_play_fk foreign key (track_id) references track(track_id));
  
------------------------------------------
--Description of all tables
desc employyee;
desc customer;
desc invoice;
desc playlist;
desc artist;
desc album;
desc media_type;
desc genre;
desc track;
desc invoice_line;
desc playlist_track;


alter table track
modify composer varchar2(150);

-----------------------------------------------------------
select * from employyee;
select * from customer;
select * from invoice;
select * from playlist;
select * from artist;
select * from album;
select * from media_type;
select * from genre;
select * from track;
select * from invoice_line;
select * from playlist_track;


desc playlist_track;

------------------------------------------
--------Questions------------------

--Q1)Who is the senior most employee based on job title?
select * from 
(select * from employyee order by hire_date)
where rownum=1;

--Q2)Which country have the most invoices?
select * from
(select distinct(billing_country),count(invoice_id) invoices 
from invoice 
group by billing_country 
order by count(invoice_id) desc)
where rownum=1;

--Q3)what are top 3 values of total invoice?
select * from
(select total from invoice order by total desc)
where rownum<=3;

--Q4)which city has best customer?
select city, total_rev
from
(select billing_city as city, sum(total) as total_rev
from invoice 
group by billing_city
order by sum(total))
where rownum=1;

--Q5)who is the best customer?
select * from
(select cu.first_name,cu.last_name,sum(i.total) as total from customer cu 
left join invoice i
on cu.customer_id=i.customer_id
group by cu.first_name,cu.last_name
order by sum(i.total) desc)
where rownum=1;

-----------------------*Moderate*----------------------

--Q1)Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
--Return your list ordered alphabetically by email starting with A

select distinct cu.email,cu.first_name,cu.last_name,g.name from customer cu
left join invoice i on cu.customer_id=i.customer_id
left join invoice_line il on i.invoice_id=il.invoice_id
left join track t on il.track_id=t.track_id
left join genre g on t.genre_id=g.genre_id
where g.name='Rock'
order by cu.email asc;

--2. Let's invite the artists who have written the most rock music in our dataset.
--Write a query that returns the Artist name and total track count of the top 10 rock bands
select * from(
select a.name,count(t.track_id) as track_count from artist a 
left join album al on a.artist_id=al.artist_id
left join track t on al.album_id=t.album_id
left join genre g on t.genre_id=g.genre_id
where g.name='Rock'
group by a.name
order by track_count desc)
where rownum<=10;


--3. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select name,milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;


------------------------*Advance*-------------------------

--1. Find how much amount spent by each customer on artists? Write a query to return customer name, 
--artist name and total spent
select cu.first_name,cu.last_name,ar.name,sum(il.unit_price*il.quantity) as total_spent from customer cu
left join invoice i on cu.customer_id=i.customer_id
left join invoice_line il on i.invoice_id=il.invoice_id
left join track t on il.track_id=t.track_id
left join album al on t.album_id=al.album_id
left join artist ar on al.artist_id=ar.artist_id
group by cu.first_name,cu.last_name,ar.name
order by total_spent desc;

select * from artist;


--2. We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres

