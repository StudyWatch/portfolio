# לטייל עם חנה — LIVE-connected Frontend + Supabase CRM

מערכת RTL מלאה עבור "לטייל עם חנה": אתר ציבורי פרימיום + אזור ניהול + CRM תפעולי לטיולים + Supabase Database/Auth/Storage/RLS.

## יכולות מרכזיות

### אתר ציבורי
- 7 יעדים: יפן, צפון איטליה, מונטנגרו, מרוקו, אזרבייג'ן, סרי לנקה ודובאי/אבו דאבי.
- דף בית, טיולים קרובים, יעדים, אודות, ביקורות, FAQ, צור קשר, פרטיות, נגישות ותנאי שימוש.
- Hero ייחודי לכל יעד, תמונות חנה שקופות ו-Assets איכותיים.
- טופס "אני מעוניין/ת" בכל טיול מפורסם. הטופס שומר שם, טלפון, יעד, מזהה הטיול והתאריכים האמיתיים.

### Admin + CRM
- Supabase Auth בלבד. אין `חנה13` ואין סיסמה מוטמעת ב-JavaScript.
- מאגר מטיילים מרכזי והיסטוריית טיולים.
- המרת ליד למטייל + משתתף בטיול.
- סטטוסי הרשמה, רשימת המתנה וביטול.
- תשלומים ידניים ויתרות ללא סליקה או פרטי כרטיס.
- זוגות/משפחות, חדרים, Rooming List, נקודות איסוף.
- Follow-ups ומשימות.
- היסטוריית קשר כדי לזכור שיחות/WhatsApp/מייל/פגישה.
- מסמכי טיול פרטיים ב-Supabase Storage.
- Excel אמיתי וגיבוי CRM מלא ל-XLSX/JSON.

## Supabase

המיגרציות נמצאות ב-`supabase/migrations/`:

1. `202608280001_initial_schema.sql`
2. `202608280002_seed_content.sql`
3. `202608280003_leads_privacy_accessibility.sql`
4. `202608280004_crm_operations.sql`
5. `202608280005_crm_hardening.sql`
6. `202608280006_post_deploy_advisor_hardening.sql`
7. `202608280007_fix_crm_audit_trigger.sql`
8. `202608280008_minimize_rpc_surface.sql`

הפרויקט החי `rxapuzqnatmcapgacpfb` כבר כולל את כל 8 המיגרציות. לפרויקט חדש וריק בלבד אפשר להשתמש גם ב-`supabase/ALL_MIGRATIONS.sql`.
לאחר מכן מריצים את `supabase/POST_DEPLOY_VERIFY.sql`.

ה-CRM כולל: `travelers`, `booking_groups`, `trip_participants`, `participant_payments`, `trip_rooms`, `room_occupants`, `follow_ups`, `trip_tasks`, `trip_documents`, `contact_log`.

## Security model

- הדפדפן מקבל רק `SUPABASE_URL` ו-Publishable Key.
- לעולם לא להכניס ל-Frontend: DB password, Service Role, Secret Key.
- כל טבלאות האפליקציה עם RLS.
- Admin דורש session תקין וגם `admin_profiles.active=true`.
- Public reads דרך `public_site_payload()`.
- Public leads דרך `submit_inquiry()` בלבד.
- `admin_crm_payload()` מחזיר CRM רק למנהל מורשה.
- `site-media` מיועד לתמונות ציבוריות; `admin-documents` פרטי ומוחזר רק בקישור זמני.

## חיבור Project URL + Publishable Key

```powershell
$env:SUPABASE_URL="https://PROJECT_REF.supabase.co"
$env:SUPABASE_PUBLISHABLE_KEY="sb_publishable_..."
node scripts/configure-supabase.mjs
npm run check
```

`js/supabase-config.js` כבר מחובר ל-Project URL ול-Publishable Key של `Chana Tours`. `.env.example` נשאר כתבנית בטוחה להגדרה מחדש. אין בחבילה Service Role, Secret Key או database password.

## Admin ראשון

צור משתמש Auth אמיתי לחנה דרך Supabase Auth. לאחר מכן החלף את `CHANA_ADMIN_EMAIL_HERE` ב-`supabase/ADMIN_SETUP.sql` והריץ את הקובץ. אין ליצור משתמש ישירות בתוך `auth.users` באמצעות SQL ידני.

## הפעלה מקומית

```powershell
py -m http.server 5500
```

- אתר: `http://localhost:5500`
- אדמין: `http://localhost:5500/admin.html`

## QA

```powershell
npm run check
```

הבדיקות מאמתות JavaScript, Assets, counts, פרטיות מועדי ספק, מיגרציות CRM, RLS ופונקציות hardening.

## לפני Launch

קרא את `supabase/LIVE_SETUP_CHECKLIST.md`, `DEPLOYMENT.md`, `LEGAL_PRIVACY_ACCESSIBILITY.md` ו-`QA_REPORT.md`.
פרטי הקשר של חנה כבר הוגדרו ב-LIVE, ומשתמש ה-Auth `chamel71@gmail.com` מקושר ל-`admin_profiles.active=true`. ה-Backend provisioned ומחובר לפרויקט היעד.

## Visual final LIVE-package update - 28.08.2026
The home hero now uses a complete integrated photograph rather than a cut-out portrait. Public destination/tours heroes use scenic full-bleed photography by default to avoid a repeated synthetic/Photoshop look.

### Local preview
From this folder run:

```powershell
py -m http.server 5500
```

Open:
- `http://localhost:5500`
- `http://localhost:5500/admin.html`

The public frontend can be visually reviewed without live Supabase. Cloud persistence/Auth/Storage require the real Supabase configuration and applied migrations.

## Final UX package update - 29.08.2026

The package now includes the final admin usability round:

- dedicated desktop/mobile homepage Hero files;
- complete mobile admin navigation through `עוד`;
- dashboard launch-readiness checks and new-lead badges;
- safe supplier-research publishing with explicit verification;
- import preview and typed confirmation;
- protected reset flow;
- simple destination editing with technical fields under an advanced section;
- automatic image preview and WebP optimization before upload;
- prompt library grouped into five practical tasks with favorites, recent use and "צריך / מקבלים" hints.

For the shortest launch handoff, read `FINAL_GO_LIVE_CHECKLIST.txt`.


## Visual quality final
The public site now uses premium high-resolution Hero photography for all seven destinations and for the homepage/About pages. Production destination feature files are 1200x800 and have WebP alternatives. The original premium masters are kept under `assets/premium-source/`. The validation command rejects destination Hero/feature assets below the required minimum dimensions.
