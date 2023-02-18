					-- Lego Project--
/* In this project, we will work with a data from Lego company.
We have 8 datasets in total: themes, part_categories, parts,
sets, colors, inventory_parts, inventory_sets, inventories.
Objective: to create tables, import data into them and
make a descriptive analysis of production activities of the
company for the given period.*/

				--Creating and importing tables--

CREATE TABLE IF NOT EXISTS public.colors
(
    id integer NOT NULL,
    name character varying(255),
    rgb character varying(255),
    is_trans character varying(255),
    CONSTRAINT colors_pkey PRIMARY KEY (id)
);

COPY colors(id, name, rgb, is_trans)
FROM 'C:\Users\Public\Portfolio\1 SQL\Data_Lego\colors.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE IF NOT EXISTS public.themes
(
    id integer NOT NULL,
    name character varying(255),
    parent_id integer,
    CONSTRAINT themes_pkey PRIMARY KEY (id)
);

COPY themes(id, name, parent_id)
FROM 'C:\Users\Public\Portfolio\1 SQL\Data_Lego\themes.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE IF NOT EXISTS public.sets
(
    set_num character varying(255) NOT NULL,
    name character varying(255),
    year integer,
	theme_id integer,
	num_parts integer,
    CONSTRAINT sets_pkey PRIMARY KEY (set_num)
);

COPY sets(set_num, name,year,theme_id, num_parts)
FROM 'C:\Users\Public\Portfolio\1 SQL\Data_Lego\sets.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE IF NOT EXISTS public.inventories
(
    id integer,
    version integer,
    set_num character varying(255),
	CONSTRAINT inventories_pkey PRIMARY KEY (id),
	CONSTRAINT inventories_sets_fkey FOREIGN KEY (set_num)
	REFERENCES public.sets (set_num)
);

COPY inventories(id, version, set_num)
FROM 'C:\Users\Public\Portfolio\1 SQL\Data_Lego\inventories.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE IF NOT EXISTS public.inventory_sets
(
    inventory_id integer NOT NULL,
    set_num character varying(255),
    quantity integer,
	CONSTRAINT inventory_sets_sets_set_num_fkey FOREIGN KEY (set_num)
	REFERENCES public.sets (set_num),
	CONSTRAINT inventory_sets_inventories_fkey FOREIGN KEY (inventory_id)
	REFERENCES public.inventories (id)
);

COPY inventory_sets(inventory_id, set_num, quantity)
FROM 'C:\Users\Public\Portfolio\1 SQL\Data_Lego\inventory_sets.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE IF NOT EXISTS public.inventory_parts
(
    inventory_id integer,
    part_num character varying(255),
    color_id integer,
    quantity integer,
    is_spare character varying(255),
    CONSTRAINT inventory_parts_color_id_fkey FOREIGN KEY (color_id)
	REFERENCES public.colors (id),
	CONSTRAINT inventory_parts_inventories_fkey FOREIGN KEY (inventory_id)
	REFERENCES public.inventories (id)
);

COPY inventory_parts(inventory_id, part_num, color_id, quantity,is_spare)
FROM 'C:\Users\Public\Portfolio\1 SQL\Data_Lego\inventory_parts.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE IF NOT EXISTS public.part_categories
(
    id integer,
    name character varying(255),
	CONSTRAINT part_categories_pkey PRIMARY KEY (id)
);

COPY part_categories(id, name)
FROM 'C:\Users\Public\Portfolio\1 SQL\Data_Lego\part_categories.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE IF NOT EXISTS public.parts
(
    part_num character varying(255),
    name character varying(255),
    part_cat_id integer,
	CONSTRAINT parts_pkey PRIMARY KEY (part_num),
    CONSTRAINT parts_parts_part_categories_fkey FOREIGN KEY (part_cat_id)
	REFERENCES public.part_categories (id)
);

COPY parts(part_num, name, part_cat_id)
FROM 'C:\Users\Public\Portfolio\1 SQL\Data_Lego\parts.csv'
DELIMITER ','
CSV HEADER;


					--Analysis and work with data-- 

--How many colors are in the base?
select count(distinct name)
from colors
--There are 135 colors


--For what period we have information about sets?
select min(year) as min_y, max(year) as max_y
from sets
--We have information from 1950 to 2017 y.

--For how many sets do we have information?
select count(*)
from sets
--11673 psc. sets

--For how many parts do we have information?
select count (*)
from parts
--25993 psc. parts

--What year was produced the most sets?
select year, count (*) as count
from sets
group by year
order by count desc
--In 2014 was produced the most sets


--What year there were the most parts in the sets in average?
select year, avg(num_parts) as quantity_by_year
from sets
group by year
order by quantity_by_year desc
--In 2017 there were the most parts in the sets in average


--Which year had the most unique themes in the sets?
select year, count(distinct themes.name) as num_themes
from sets
join themes on sets.theme_id  = themes.id
group by year
order by num_themes desc
--In 2015 there were the most unique themes in the sets

--Which category has the most parts?
select part_categories.name as part_name, count (*) as total_coun
from parts
join part_categories
on parts.part_cat_id = part_categories.id
group by part_name
order by total_coun desc
--Minifigs category (8556 psc.)

--How many sets does the store have in stock?
select sum(quantity)
from inventory_sets 
--3916 psc.

--How many parts does the store have in stock?
select sum(quantity)
from inventory_parts
--1929178 psc.

--What is the most popular color among the items?
select colors.name as color_name, sum(quantity) as quan
from inventory_parts
join colors on inventory_parts.color_id = colors.id
group by color_name
order by quan desc
--Black

--How many sets are there in the most popular theme?
select themes.name, count(*) as amoun
from sets
join themes 
on sets.theme_id = themes.id
group by themes.name
order by amoun desc
--There are 496 psc. sets in the most popular theme (Supplemental)

--Which theme has the most parts?
select themes.name, sum(num_parts) as amoun
from sets
join themes 
on sets.theme_id = themes.id
group by themes.name
order by amoun desc
--Basic Set theme has the most parts - 100399 psc.

--Which topic group has the set with the most parts?
select themes.name as namm, max(num_parts) as max_elem
from sets
join themes 
on sets.theme_id = themes.id
group by namm
order by max_elem desc
--Set Sculptures has the most parts - 5922 pcs.

--What category does the item with the most stock into?
select part_categories.name, sum(quantity) as total_quan
from inventory_parts
join parts on inventory_parts.part_num  = parts.part_num
join part_categories on parts.part_cat_id = part_categories.id
group by part_categories.name
order by total_quan desc
--Bricks (321105 psc.)

--Which theme is the set whose stocks are the largest
select themes.name as tn, sum(quantity)
from inventory_sets
join sets on inventory_sets.set_num = sets.set_num
join themes on sets.theme_id = themes.id 
group by tn
order by sum(quantity) desc
--City (217 sets)


/*Count the number of sets by year as a cumulative total.
What cumulative number of sets there was in 2000.*/
with total as (select year as year, count(*) as amount
from sets
group by year)

select total.year, total.amount,
sum(total.amount) over (order by year asc)
from total
order by year asc
--In 2000 the number of sets was 3991 psc.


