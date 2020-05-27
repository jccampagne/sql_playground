drop table property_value cascade;
drop table property cascade;
drop table product cascade;

create table if not exists product(
    id      serial  primary key,
    name    text    not null unique
);


create table property(
    id      serial  primary key,
    name    text    unique not null
);

create table property_value(
    product_id_fk      serial   references product(id),
    property_id_fk     serial   references property(id),
    value              text     not null,
    unique (product_id_fk, property_id_fk)
)
;


insert into product(name) values
('apple'),
('banana'),
('citrus')
;


insert into property(name) values
('color'),
('weight'),
('shape')
;


create or replace view pv
as select
    p.id        as product_id,
    p.name      as product_name,
    pn.name     as property_name,
    pv.value    as property_value
from product p
join property_value pv on pv.product_id_fk  = p.id
join property_name  pn on pv.property_id_fk = pn.id
;


--drop function  function_insert_pv();
create or replace function function_insert_pv()
returns trigger as
$_$
declare
    my_property_id integer;
    my_product_id  integer;
    my_pv_id       integer;
begin
    raise notice 'it is to_op=%, new=%', tg_op, new;

    select id into my_property_id from property where name = new.property_name;
    raise notice 'my_property_id = %', my_property_id;

    if my_property_id is null then
        raise exception 'not such property "%"', new.property_name;
    end if;

    raise notice 'looking into product for %', new.product_name;
    select id into my_product_id from product p where p.name = new.product_name;
    raise notice 'found product "%" with id "%"', new.product_name, my_product_id;

    insert into property_value(product_id_fk, property_id_fk, value)
    values (my_product_id, my_property_id, new.property_value);

    GET DIAGNOSTICS my_pv_id = ROW_COUNT;
    raise notice 'inserted %', my_pv_id;

    return null;
end
$_$
language plpgsql
;


-- create trigger
--drop trigger insert_pv on pv;

create trigger insert_pv
instead of insert on pv
for each row
execute function function_insert_pv();


-- this will insert
insert into pv(product_name, property_name, property_value) values('apple', 'color', 'red');
-- this will error - duplicate entry
insert into pv(product_name, property_name, property_value) values('banana', 'color', 'yellow');


-- this will error - bad property name
insert into pv(product_name, property_name, property_value) values('product_3', 'colordded', 'blue');
