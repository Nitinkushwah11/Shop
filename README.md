# Shop

# My Store — Single-store online shop

HTML + CSS + vanilla JS, Supabase backend, Netlify hosting. Mobile-first, English/Hindi toggle.

## Files

| File | Kaam |
|---|---|
| `index.html` | Storefront: items, categories, cart, login/signup, My Orders |
| `dashboard.html` | Admin/Owner panel: Owners (admin), Items & Stock, Orders/Bills |
| `config.js` | Supabase keys + shop phone/address/map |
| `i18n.js` | `SHOP_NAME`, English/Hindi text, categories list (`CATS`) |
| `style.css` | Poora design. Colors sabse upar `:root` me |
| `schema.sql`, `migration.sql`, `category_migration.sql` | Database (Supabase SQL Editor me, isi order me) |

## Roles
- **admin**: owner accounts banata hai, items/orders dekh sakta hai. Sirf developer (tum) ke paas.
- **owner**: items add/edit/delete, stock, bills, order status, WhatsApp customer.
- **customer**: bina login browse; order ke liye signup/login.

## Pehli baar setup
1. Supabase project banao. **Authentication → Providers → Email → "Confirm email" OFF** (owner banane ke liye zaroori).
2. SQL Editor me run karo: `schema.sql` → `migration.sql` → `category_migration.sql`.
3. Storage me public bucket **`products`** banao.
4. `config.js` me `SUPABASE_URL` aur **publishable key** (`sb_publishable_...`) daalo. Secret key kabhi frontend me nahi.
5. Apna account signup karo, phir SQL Editor me:
   `update profiles set role='admin' where id='<your-user-id>';`
6. `dashboard.html` se owner ID banao.

## Dukan ki details (config)
- `i18n.js` → `SHOP_NAME`
- `config.js` → `SHOP_PHONE` (`"919876543210"`), `SHOP_ADDRESS`, `SHOP_MAP` (optional Google Maps share link). Khali = wo button chhup jata hai.
- Colors: `style.css` ki pehli line (`--pri` main green, `--acc` orange).
- Categories badalni ho: `i18n.js` me `CATS` aur dono languages me `cat_...` naam.

## Local testing
VS Code → Live Server → `http://127.0.0.1:5500/index.html`.
Phone par test: PC aur phone same Wi-Fi par, `http://<PC-IP>:5500/index.html` (`ipconfig` se IPv4).

## Deploy (Netlify + GitHub) — ek baar
1. Netlify → **Add new site → Import an existing project → GitHub** → `Shop` repo.
2. **Build command: khali. Publish directory: `.` (ya khali).** Koi build nahi hai.
3. Site name badlo (Site configuration → Change site name).
4. Supabase → Authentication → URL Configuration → Site URL = Netlify link.

### Branches
- Netlify **kisi bhi branch** ko deploy kar sakta hai.
- **Site configuration → Build & deploy → Branches** me **Production branch** chuno (client ki live site isi se banti hai, jaise `main`).
- Wahin **Branch deploys → "All" ya "Let me add individual branches"** chuno. Tab `develop` branch ka alag test link banta hai: `develop--<site-name>.netlify.app`. Client wala link nahi badalta.
- Rule: **develop me kaam + test → sahi lage to `main` me merge → live update.**

## Update kaise karein (link wahi rehta hai)
1. `develop` branch par code badlo, Live Server par test karo.
2. `git add . && git commit -m "..." && git push` → `develop--...` link par check karo.
3. Sab theek ho to `develop` ko `main` me merge/push karo (GitHub me Pull Request) → Netlify 1 minute me live kar dega.
4. Gadbad ho jaye: Netlify → **Deploys** → purana deploy → **Publish deploy** (rollback).

**Database change ho to:** pehle Supabase me SQL chalao, phir code push karo. Naya column hamesha `add column if not exists ... default ...`.
Update raat ko ya dukan band hone par karo.

## Client ko handover
- Customers ko: sirf site ka link.
- Owner ko: `link/dashboard.html` + owner ID/password (admin dashboard se banao).
- Phone: Chrome → Menu → *Add to Home screen*.
- **Kabhi mat do:** Supabase / Netlify / GitHub login, admin account.

## Trial ke baad access wapas lena
- Owner ka access band: Supabase → Authentication → Users → user delete,
  ya `update profiles set role='customer' where id='<owner-id>';`
- (Dashboard ka "Remove" sirf profile hatata hai, login nahi.)
- Poori site band: Netlify → Site configuration → Delete site (ya unpublish).
- Band karne se pehle data export karke client ko do (Supabase → Table Editor → Export CSV). Pehle hi likhit me tay kar lo: trial kitna, uske baad kya, data kiska.
- Customers ka naam/phone/address tumhare Supabase me hai, to uska galat use mat karo.

## Free plan ki limits
- Supabase free: 7 din koi activity na ho to project **pause** (Dashboard se Restore). Backup nahi, to hafte me data export karo.
- Netlify free: chhoti dukan ke liye kaafi.

## Common problems
| Dikkat | Wajah / Solution |
|---|---|
| Search box me email/password aa jata hai | Chrome autofill. Search input `readonly` trick use karta hai; login fields `<form>` ke andar hain |
| Hindi button kuch nahi karta | Inline `onclick` me `lang` button ka attribute ban jata hai. `toggleLang()` use karo |
| Naya design/code nahi dikh raha | `Ctrl+Shift+R` (hard refresh) |
| "Database error saving new user" | `handle_new_user` trigger me `set search_path = public` aur `public.profiles` hona chahiye |
| Photo upload fail | Bucket `products` public hai? Storage policies check karo |
| Order me "not enough stock" | `place_order` RPC stock check karta hai; dashboard me stock badhao |
| Mobile preview DevTools me kata dikhe | DevTools ko undock karo, zoom 100% karo, ya asli phone par check karo |
