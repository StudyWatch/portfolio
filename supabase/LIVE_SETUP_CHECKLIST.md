# חיבור חי ל-Supabase - Chana Tours

## היעד המחובר
- Organization: `Chana tours`
- Project: `Chana Tours`
- Ref: `rxapuzqnatmcapgacpfb`
- Region: `eu-central-1`
- Frontend config: `js/supabase-config.js`

## מצב LIVE
כל 8 המיגרציות נמצאות כבר ב-migration history של פרויקט היעד:
1. `202608280001_initial_schema`
2. `202608280002_seed_content`
3. `202608280003_leads_privacy_accessibility`
4. `202608280004_crm_operations`
5. `202608280005_crm_hardening`
6. `202608280006_post_deploy_advisor_hardening`
7. `202608280007_fix_crm_audit_trigger`
8. `202608280008_minimize_rpc_surface`

**אין להריץ שוב `ALL_MIGRATIONS.sql` על הפרויקט החי.** הוא מיועד לפרויקט חדש וריק בלבד.

## מה נשאר להשלמה ידנית
1. צור/י או הזמן/י משתמש Supabase Auth אמיתי לחנה.
2. האימייל של חנה כבר מוזן ב-`ADMIN_SETUP.sql`. לאחר יצירת/Invite של אותו Auth user, הרץ/י את הקובץ.
3. היכנס/י ל-`admin.html` וודא/י שה-session מזוהה כמנהל.
4. פרטי הטלפון, WhatsApp והאימייל כבר הוגדרו ב-LIVE וב-migration 009; רק אמת/י שהם מוצגים נכון.
5. אשר/י לפרסום רק מועדים שחנה באמת מדריכה. 17 מועדי supplier research נשארים `source_only`.
6. בצע/י בדיקת admin E2E: ליד -> המרה -> תשלום -> חדר -> follow-up -> Excel -> ניקוי נתוני בדיקה.
7. בצע/י בדיקה ויזואלית במחשב ובנייד.

## בדיקות בטוחות
```powershell
npm run check
```

`POST_DEPLOY_VERIFY.sql` הוא read-only ומותר להריץ שוב.

## Secrets
בדפדפן מותר רק Project URL + Publishable Key. אין להשתמש ב-Service Role, Secret Key או database password.
