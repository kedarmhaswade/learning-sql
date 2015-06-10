select p.name, p.product_cd, a.account_id from product p left outer join account a
  on p.product_cd = a.product_cd;
  
select p.name, p.product_cd, a.account_id from account a right outer join product p
  on p.product_cd = a.product_cd;

select ab.account_id, ab.product_cd, i.fname, i.lname, ab.name from (select a.cust_id, a.account_id, a.product_cd, b.name from account a left outer join business b 
 on a.cust_id = b.cust_id) ab left outer join individual i on
 ab.cust_id = i.cust_id order by ab.account_id;
  

