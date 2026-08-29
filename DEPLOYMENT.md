# Production deployment — Chana Tours

## יעד מומלץ

Frontend ב-Vercel + פרויקט Supabase ייעודי בארגון **Chana tours**. אין קשר תפעולי ל-BaliHofesh.

## Environment ציבורי בלבד

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

אין להעלות ל-Git/Frontend DB password, Secret Key או `service_role`.

## סדר העלאה

1. אמת שהיעד הוא `Chana Tours` / `rxapuzqnatmcapgacpfb` ב-Europe Central / Frankfurt.
2. בפרויקט החי הזה 8 המיגרציות כבר הוחלו. **אין להריץ אותן שוב.** בפרויקט חדש וריק בלבד יש להחיל את 8 המיגרציות לפי הסדר או את `supabase/ALL_MIGRATIONS.sql`.
3. הרץ `supabase/POST_DEPLOY_VERIFY.sql` כבדיקת read-only.
4. Auth user של חנה כבר קיים ב-LIVE ומקושר ל-`admin_profiles.active=true`. `ADMIN_SETUP.sql` נשאר ככלי שחזור/idempotent בלבד.
5. הזרק Project URL + Publishable Key באמצעות `scripts/configure-supabase.mjs`.
6. הרץ `npm run check`.
7. פרטי הקשר כבר הוגדרו. לאחר הפריסה יש רק לאמת שהם מוצגים נכון בעמוד יצירת הקשר.
8. אשר לפרסום רק מועדים שחנה באמת מדריכה.
9. בצע smoke test מלא: ליד → CRM → משתתף → תשלום ידני → חדר → מעקב → Excel.
10. בדוק תמונות ציבוריות ומסמכים פרטיים ב-Storage.
11. הרץ Security Advisor ו-Performance Advisor.
12. בדוק Home, Tours, 7 יעדים, Contact, Privacy, Accessibility ו-Admin במחשב ובנייד.
13. לאחר חיבור הדומיין הסופי הוסף canonical URLs ו-Sitemap URL ל-`robots.txt`.

## SEO / PWA basics

החבילה כוללת favicon, Apple Touch Icon, manifest ו-`robots.txt`. `robots.txt` אינו מכיל Sitemap עד שקיים דומיין סופי, כדי לא להמציא URL.

## Headers

`vercel.json` מגדיר CSP, HSTS, nosniff, frame deny, Referrer Policy, Permissions Policy ו-COOP.
