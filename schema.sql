-- Supabase SQL Editor me poora run karein
create table profiles(id uuid primary key references auth.users on delete cascade, full_name text, phone text, shop_name text,
 role text not null default 'customer' check (role in ('admin','owner','customer')), created_at timestamptz default now());
create table products(id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade,
 name text not null, price numeric not null, stock int not null default 0, unit text default 'pcs', image_url text,
 active boolean default true, created_at timestamptz default now());
create table orders(id bigint generated always as identity primary key, customer_id uuid references profiles(id), owner_id uuid references profiles(id),
 customer_name text, phone text, address text, total numeric default 0, status text default 'new', created_at timestamptz default now());
create table order_items(id bigint generated always as identity primary key, order_id bigint references orders(id) on delete cascade,
 product_id uuid, name text, price numeric, qty int);

create function is_admin() returns boolean language sql security definer stable as
$$ select exists(select 1 from profiles where id=auth.uid() and role='admin') $$;
create function is_owner() returns boolean language sql security definer stable as
$$ select exists(select 1 from profiles where id=auth.uid() and role='owner') $$;

-- naya user hamesha 'customer' banta hai; owner sirf admin bana sakta hai
create function handle_new_user() returns trigger language plpgsql security definer as
$$ begin insert into profiles(id,full_name,phone) values(new.id,new.raw_user_meta_data->>'full_name',new.raw_user_meta_data->>'phone'); return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();

alter table profiles enable row level security;
alter table products enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

create policy p_sel on profiles for select using (id=auth.uid() or role='owner' or is_admin());
create policy p_upd on profiles for update using (is_admin());
create policy p_del on profiles for delete using (is_admin());

create policy pr_sel on products for select using (active or owner_id=auth.uid() or is_admin());
create policy pr_ins on products for insert with check (owner_id=auth.uid() and is_owner());
create policy pr_upd on products for update using (owner_id=auth.uid() or is_admin());
create policy pr_del on products for delete using (owner_id=auth.uid() or is_admin());

create policy o_sel on orders for select using (customer_id=auth.uid() or owner_id=auth.uid() or is_admin());
create policy o_upd on orders for update using (owner_id=auth.uid() or is_admin());
create policy oi_sel on order_items for select using (exists(select 1 from orders o where o.id=order_id and (o.customer_id=auth.uid() or o.owner_id=auth.uid() or is_admin())));

-- Order place karna: stock check + kam karna + har owner ke liye alag bill
create function place_order(p_name text,p_phone text,p_address text,p_items jsonb) returns void language plpgsql security definer as $$
declare r record; it record; oid bigint; tot numeric;
begin
 if auth.uid() is null then raise exception 'Pehle login karein'; end if;
 for r in select distinct p.owner_id from products p join jsonb_to_recordset(p_items) as x(id uuid, qty int) on x.id=p.id loop
  insert into orders(customer_id,owner_id,customer_name,phone,address) values(auth.uid(),r.owner_id,p_name,p_phone,p_address) returning id into oid;
  tot:=0;
  for it in select p.id,p.name,p.price,p.stock,x.qty from products p join jsonb_to_recordset(p_items) as x(id uuid, qty int) on x.id=p.id where p.owner_id=r.owner_id loop
   if it.qty<1 or it.qty>it.stock then raise exception 'Stock kam hai: %', it.name; end if;
   update products set stock=stock-it.qty where id=it.id;
   insert into order_items(order_id,product_id,name,price,qty) values(oid,it.id,it.name,it.price,it.qty);
   tot:=tot+it.price*it.qty;
  end loop;
  update orders set total=tot where id=oid;
 end loop;
end $$;

-- Photo storage
insert into storage.buckets(id,name,public) values('products','products',true) on conflict do nothing;
create policy img_read on storage.objects for select using (bucket_id='products');
create policy img_write on storage.objects for insert to authenticated with check (bucket_id='products');

-- PEHLE website/dashboard par apna account signup karein, phir apna email daal kar ye run karein:
-- update profiles set role='admin' where id=(select id from auth.users where email='aapka@email.com');