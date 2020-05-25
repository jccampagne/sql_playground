drop table property_value;
drop table property_name;
drop table product;

create table if not exists product(
    id      serial primary key,
    name    text   not null
);


create table property_name(
    id      serial  primary key,
    name    text    unique not null
);

create table property_value(
    product_id_fk       serial  references product(id),
    property_name_id_fk serial  references property_name(id),
    value               text    not null
)
;



insert into product(id, name) values
(1, 'product_1'),
(2, 'product_2');
;

insert into property_name(name) values
('color'),
('weight')
;

insert into property_value values
(1, 1, 'red'),
(2, 1, 'blue')
;


select * from property_name;

--create view prods as

create or replace view pv as select
p.id as product_id,
p.name as product_name,
pn.name as property_name,
pv.value as property_value
from product p
join property_value pv on pv.product_id_fk = p.id
join property_name pn on pv.property_name_id_fk = pn.id
;

--drop function  function_insert_pv();

create or replace function function_insert_pv()
returns trigger
as
$_$
    begin
    raise notice 'called';
    end
$_$
language plpgsql
;


drop trigger insert_pv on pv;

create trigger insert_pv
INSTEAD OF insert on pv
for each row
execute function function_insert_pv();
