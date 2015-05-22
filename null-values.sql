/*
  From the paper: http://www09.sigmod.org/sigmod/record/issues/0809/p23.grant.pdf
  Flaw in SQL pointed out by CJ Date.
*/
drop database if exists null_values;
create database null_values;
use null_values;

create table suppliers(sno varchar(30), city varchar(20));
create table parts(pno varchar(30), city varchar(20));

insert into suppliers (sno, city) values ('S1', 'London');
insert into parts (pno) values ('P1');

select sno, pno from suppliers, parts where suppliers.city <> parts.city or parts.city <> 'Paris';
