#!/usr/bin/env ruby

# Creates a MySQL script that studies the joins 

nRows = 1000
nTables = 3
dbName = "studyjoins"
File.open("tmp.sql", "w") do |file| 
  file.puts("drop database if exists #{dbName};");
  file.puts("create database #{dbName};");
  file.puts("use #{dbName};");
  1.upto nTables do |ti|
    file.puts("create table t#{ti} (i#{ti} int);")
    1.upto nRows do |ri|
      file.puts("insert into t#{ti}(i#{ti}) values(#{ri});");
    end
  end
end

