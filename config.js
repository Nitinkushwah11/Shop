// Supabase > Project Settings > API se copy karein
const SUPABASE_URL = "https://bolwkgsulhlsiowbprry.supabase.co";
const SUPABASE_KEY = "sb_publishable_-YuJ2yPV__t8f0ecq2iZlQ_DTY620Nk";
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
const $ = (s) => document.querySelector(s);
const money = (n) => "₹" + Number(n).toFixed(2).replace(/\.00$/, "");
