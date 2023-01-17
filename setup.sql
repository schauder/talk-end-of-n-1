drop table if exists hobby;
drop table if exists accessoire;
drop table if exists property;
drop table if exists toy;
drop table if exists minion;

create table minion (
    id    	int primary key,
    name  	varchar(200)
);

create table hobby (
	id 		int primary key,
	name 	varchar(200),
	minion_id int,
	foreign key(minion_id) references minion(id)
);

create table toy (
	id 		int primary key,
	name 	varchar(200),
	minion_id int,
	foreign key(minion_id) references minion(id)
);

create table accessoire (
	id 		int primary key,
	name 	varchar(200),
	toy_id int,
	foreign key(toy_id) references toy(id)
);

create table property (
	id 		int primary key,
	name 	varchar(200),
	toy_id int,
	foreign key(toy_id) references toy(id)
);
-----------------------------------------
insert into minion (id, name) values (1, 'Kevin');

insert into hobby (minion_id, id, name) values (1, 111, 'Annoy humans');
insert into hobby (minion_id, id, name) values (1, 112, 'Annoy minions');

insert into toy (minion_id, id, name) values (1, 211, 'hammer');

insert into property(toy_id, id, name) values (211, 32111, 'heavy');
insert into property(toy_id, id, name) values (211, 32112, 'metalic');
insert into property(toy_id, id, name) values (211, 32113, 'hurts');
-----------------------------------------
insert into minion (id, name) values (2, 'Bob');

insert into hobby (minion_id, id, name) values (2, 121, 'hold teddy');
insert into hobby (minion_id, id, name) values (2, 122, 'follow kevin');
insert into hobby (minion_id, id, name) values (2, 123, 'look cute');

insert into toy (minion_id, id, name) values (2, 221, 'teddy');
insert into toy (minion_id, id, name) values (2, 222, 'blue light');

insert into property(toy_id, id, name) values (221, 32211, 'button eyes');
insert into property(toy_id, id, name) values (221, 32212, 'limp');
insert into property(toy_id, id, name) values (222, 32221, 'blinking');

insert into accessoire(toy_id, id, name) values (221, 42211, 'rain coat');
insert into accessoire(toy_id, id, name) values (222, 42221, 'head strap');
insert into accessoire(toy_id, id, name) values (222, 42222, 'replacement bulb');

-----------------------------------------
insert into minion (id, name) values (3, 'Stuart');

insert into hobby (minion_id, id, name) values (3, 131, 'relax');
-- no toys
