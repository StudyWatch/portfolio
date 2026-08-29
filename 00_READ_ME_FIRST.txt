לטייל עם חנה — LIVE FINAL HANDOFF
===================================

מצב החבילה:
- Frontend + Admin + CRM + Excel + Legal + Accessibility קיימים בקוד.
- ה-Frontend מחובר בפועל ל-Supabase של Chana Tours באמצעות Project URL + Publishable Key בלבד.
- 9 migrations הוחלו בפרויקט החי ונמצאות גם בתוך ה-ZIP.
- RLS, Storage, public leads, CRM schema, advisor hardening ותיקון audit runtime נמצאים בחבילה.
- העיצוב החדש נשמר: Home Hero הוא צילום מלא שבו חנה חלק טבעי מהתמונה; Destination Heroes הם full-bleed scenic.

פרויקט היעד היחיד:
- Organization: Chana tours
- Project: Chana Tours
- Project ID / ref: rxapuzqnatmcapgacpfb
- Region: eu-central-1
- Expected status: ACTIVE_HEALTHY

חשוב:
- אין להריץ את ALL_MIGRATIONS.sql שוב על הפרויקט החי. הוא reference/one-shot לפרויקט חדש וריק בלבד.
- אין לבצע שום שינוי ב-BaliHofesh.
- אין להכניס service_role key, secret key או database password ל-Frontend.
- אין לשמור מספר כרטיס אשראי, CVV, סיסמת בנק או מסמך רגיש שאינו נחוץ.

השלמה ידנית שנותרה:
- Auth user של חנה כבר קיים ומקושר ל-admin_profiles ב-LIVE. אין ליצור משתמש נוסף אלא אם מבצעים שחזור לפרויקט חדש.
- פרטי הטלפון/WhatsApp/אימייל המאושרים כבר מסונכרנים ב-LIVE ובחבילה.
- לפרסם רק טיולים אמיתיים של חנה; 17 מועדי supplier research נשארים source_only ומוסתרים.

בדיקה:
- npm run check
- קרא RELEASE_STATUS.md ו-QA_REPORT.md
- Supabase read-only verification: supabase/POST_DEPLOY_VERIFY.sql


FINAL UX 29.08.2026
-------------------
התחילו ב-FINAL_GO_LIVE_CHECKLIST.txt לשני צעדי הבעלים האחרונים.
האדמין כולל ניווט מובייל מלא, אישורים לפעולות מסוכנות, פרומפטים לפי משימה ואופטימיזציית תמונות.
