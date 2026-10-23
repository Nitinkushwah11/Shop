// // Supabase > Project Settings > API se copy karein
// const SUPABASE_URL = "https://bolwkgsulhlsiowbprry.supabase.co";
// const SUPABASE_KEY = "sb_publishable_-YuJ2yPV__t8f0ecq2iZlQ_DTY620Nk";
// const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
// const $ = (s) => document.querySelector(s);
// const money = (n) => "₹" + Number(n).toFixed(2).replace(/\.00$/, "");


// Supabase > Project Settings > API se copy karein
const SUPABASE_URL = "https://bolwkgsulhlsiowbprry.supabase.co";
const SUPABASE_KEY = "sb_publishable_-YuJ2yPV__t8f0ecq2iZlQ_DTY620Nk";
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
const $ = (s) => document.querySelector(s);
const money = (n) => "₹" + Number(n).toFixed(2).replace(/\.00$/, "");

// ---- Shop contact (fill these; empty = button hidden) ----
const SHOP_PHONE = "7723877876";    // WhatsApp/call number, e.g. "919876543210" (91 + 10 digits)
const SHOP_ADDRESS = "dhakora road biaora";  // e.g. "Main Market, Ward 5, Bhopal"
const SHOP_MAP = "https://www.google.com/maps/place/Biaora,+Madhya+Pradesh+465674/@23.92172,76.8876454,14z/data=!3m1!4b1!4m6!3m5!1s0x397b6b7fd0bde47f:0xfe49a311c66d279!8m2!3d23.9185649!4d76.9113222!16zL20vMGYwaGw2?entry=ttu&g_ep=EgoyMDI2MTAxOS4wIKXMDSoASAFQAw%3D%3D";      // optional: paste Google Maps "Share" link of your shop
const digits = (p) => { let d = String(p || "").replace(/\D/g, ""); return d.length === 10 ? "91" + d : d; };
const waLink = (phone, text) => digits(phone) ? `https://wa.me/${digits(phone)}?text=${encodeURIComponent(text || "")}` : "";
const mapLink = () => SHOP_MAP || (SHOP_ADDRESS ? "https://www.google.com/maps/search/?api=1&query=" + encodeURIComponent(SHOP_ADDRESS) : "");