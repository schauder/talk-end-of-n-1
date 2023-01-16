drop table if exists flight_leg;

create table flight_leg (
	flight_number varchar(6),
	seq 	int,
    start   char(3),
    ending  	char(3),
	passengers int
);


insert into flight_leg(flight_number, seq, start, ending, passengers) values ('LH4711', 1, 'MUC', 'FRA', 100);
insert into flight_leg(flight_number, seq, start, ending, passengers) values ('LH4711', 2, 'FRA', 'LAX', 250);
insert into flight_leg(flight_number, seq, start, ending, passengers) values ('LH4711', 3, 'LAX', 'SFO', 50);

insert into flight_leg(flight_number, seq, start, ending, passengers) values ('BA4712', 1, 'MUC', 'FRA', 110);
insert into flight_leg(flight_number, seq, start, ending, passengers) values ('BA4712', 2, 'FRA', 'LAX', 300);
insert into flight_leg(flight_number, seq, start, ending, passengers) values ('BA4712', 3, 'LAX', 'SFO', 40);

insert into flight_leg(flight_number, seq, start, ending, passengers) values ('MN0815', 1, 'MUC', 'FRA', 110);
insert into flight_leg(flight_number, seq, start, ending, passengers) values ('MN0815', 2, 'FRA', 'MUC', null);

-- all data
select * from flight_leg;

-- how many passengers are max on a flight route?

select flight_number, max(passengers) 
from flight_leg
group by flight_number;

-- but I want also the full route data!

select 
	max(passengers) over (partition by flight_number) max_passengers,
	*
from flight_leg;

-- classical: all legs with the maximum number of passengers

select * from(
	select 
		max(passengers) over (partition by flight_number) max_passengers,
		*
	from flight_leg
) x where max_passengers = passengers;

-- running total of passengers pro flug

select *,
	sum(passengers) over (partition by flight_number order by seq) sum_passengers
from flight_leg;

-- number the legs flying from each airport

select *,
    row_number() over (partition by start order by flight_number)
from flight_leg
order by flight_number, seq;