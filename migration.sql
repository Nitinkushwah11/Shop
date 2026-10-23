-- Run once in Supabase SQL Editor (single store, all owners share items and orders)
create or replace function is_staff() returns boolean language sql security definer stable set search_path=public as
$$ select exists(select 1 from profiles where id=auth.uid() and role in ('admin','owner')) $$;

drop policy if exists pr_sel on products; drop policy if exists pr_ins on products;
drop policy if exists pr_upd on products; drop policy if exists pr_del on products;
drop policy if exists o_sel on orders; drop policy if exists o_upd on orders; drop policy if exists oi_sel on order_items;

create policy pr_sel on products for select using (active or is_staff());
create policy pr_ins on products for insert with check (owner_id=auth.uid() and is_staff());
create policy pr_upd on products for update using (is_staff());
create policy pr_del on products for delete using (is_staff());
create policy o_sel on orders for select using (customer_id=auth.uid() or is_staff());
create policy o_upd on orders for update using (is_staff());
create policy oi_sel on order_items for select using (exists(select 1 from orders o where o.id=order_id and (o.customer_id=auth.uid() or is_staff())));

create or replace function place_order(p_name text,p_phone text,p_address text,p_items jsonb) returns void
language plpgsql security definer set search_path=public as $$
declare it record; oid bigint; tot numeric:=0;
begin
 if auth.uid() is null then raise exception 'Please login first'; end if;
 insert into orders(customer_id,customer_name,phone,address) values(auth.uid(),p_name,p_phone,p_address) returning id into oid;
 for it in select p.id,p.name,p.price,p.stock,x.qty from products p join jsonb_to_recordset(p_items) as x(id uuid, qty int) on x.id=p.id loop
  if it.qty<1 or it.qty>it.stock then raise exception 'Not enough stock: %', it.name; end if;
  update products set stock=stock-it.qty where id=it.id;
  insert into order_items(order_id,product_id,name,price,qty) values(oid,it.id,it.name,it.price,it.qty);
  tot:=tot+it.price*it.qty;
 end loop;
 if tot=0 then raise exception 'Cart is empty'; end if;
 update orders set total=tot where id=oid;
end $$;