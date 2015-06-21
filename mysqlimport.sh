#!/bin/bash
mysql -uroot -e 'create database if not exists studyjoin'
mysql -uroot -e 'use studyjoin; drop table if exists emp; create table emp(id int, emp_id int, mgr_id int);'
mysqlimport -uroot -p --ignore-lines=1 --fields-terminated-by=, --columns='id,emp_id,mgr_id' --local studyjoin emp.csv
