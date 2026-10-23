-- Supabase > SQL Editor me ek baar run karein
alter table public.products add column if not exists category text not null default 'other';

-- (Optional) purane items ko category de do (naam se guess)
update public.products set category='staples'  where category='other' and name ~* '(atta|flour|rice|dal|sugar|chini)';
update public.products set category='oils'     where category='other' and name ~* '(oil|ghee)';
update public.products set category='spices'   where category='other' and name ~* '(salt|masala|haldi|mirch|spice)';
update public.products set category='snacks'   where category='other' and name ~* '(parle|biscuit|maggi|noodle|chips|namkeen)';
update public.products set category='drinks'   where category='other' and name ~* '(tea|coffee|cola|juice|drink)';
update public.products set category='personal' where category='other' and name ~* '(soap|shampoo|toothpaste|dove)';