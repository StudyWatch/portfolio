-- Seed content from ChanaTours_PREMIUM_FINAL. Supplier dates remain private research.

insert into public.site_settings(id,brand_name,slogan,intro,whatsapp,phone_display,email,facebook,last_source_check,home_headline,home_subheadline,show_supplier_research_publicly) values (1,'לטייל עם חנה','חוויה אישית בטיול מאורגן','טיולים מאורגנים לשומרי מסורת, עם ליווי אישי והדרכה מקצועית.','','','','https://www.facebook.com/chana.malul.7','28.08.2026','מטיילים בעולם. מרגישים בבית.','טיולים מאורגנים לשומרי מסורת, עם ליווי אישי, תכנון מוקפד והדרכה שמחברת בין המקומות, הסיפורים והאנשים.',false) on conflict(id) do update set brand_name=excluded.brand_name,slogan=excluded.slogan,intro=excluded.intro,whatsapp=excluded.whatsapp,phone_display=excluded.phone_display,email=excluded.email,facebook=excluded.facebook,last_source_check=excluded.last_source_check,home_headline=excluded.home_headline,home_subheadline=excluded.home_subheadline,show_supplier_research_publicly=excluded.show_supplier_research_publicly;

insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('japan','יפן','מסע של ניגודים והרמוניה','מקדשים שקטים, ערים מסחררות, טבע עוצר נשימה ותרבות שמפתיעה בכל יום.','יפן מצליחה להיות עתיקה וחדשנית באותה נשימה. עוברים בין טוקיו התוססת, אזור הר פוג׳י, קיוטו המסורתית, מקדשים, גנים ורחובות שמספרים סיפור אחר לגמרי. בטיול עם חנה יש מקום גם להבנה של התרבות והמנהגים, לא רק לצילום הבא.','assets/generated/japan-scenic.jpg','assets/generated/japan-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["טוקיו - חדשנות, שכונות ססגוניות ומסורת","האקונה והר פוג׳י - טבע והסמל של יפן","קיוטו - מקדשים, גנים ורחובות היסטוריים","נארה - מורשת ואווירה יפנית רגועה","אוסקה והירושימה - עירוניות, קולינריה והיסטוריה"]'::jsonb,'["טוקיו והיכרות עם יפן המודרנית","האקונה ואזור הר פוג׳י","קיוטו - מקדשים, גנים ותרבות מסורתית","נארה ואוסקה","הירושימה במסלולים הכוללים אותה"]'::jsonb,'["assets/generated/japan-feature-1.jpg","assets/generated/japan-feature-2.jpg","assets/generated/japan-feature-3.jpg","assets/generated/japan-feature-4.jpg","assets/generated/japan-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/japan.html','קשרי תעופה מציגה כיום בין היתר את טוקיו-קיוטו ומה שביניהם, פניני יפן וטוקיו-האקונה-קיוטו-נארה-אוסקה-הירושימה. יש לאשר באדמין אילו מועדים חנה מדריכה בפועל.',true,'יפן שמבינים דרך הפרטים הקטנים','[["למי שסקרן לגבי תרבות אחרת","מסע שמוסיף הקשר וסיפור לכל אתר"],["למי שאוהב שילוב","ערים גדולות, מסורת, טבע ומקדשים"],["למי שנהנה מתוכן","הדרכה שעוזרת להבין מנהגים והיסטוריה"],["לשומרי מסורת","התאמות נבדקות ונקבעות לפי היציאה"]]'::jsonb,'טיול מאורגן ליפן עם חנה | לטייל עם חנה','יפן עם חנה: טוקיו, קיוטו, אזור הר פוג׳י, מקדשים, טבע ותרבות. מידע על היעד, מה רואים ומועדים מאושרים.',true,0) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('north-italy','צפון איטליה','אגמים, דולומיטים ועיירות שקשה להיפרד מהן','אגמים כחולים, פסגות מרשימות, ערים היסטוריות ואיטליה בקצב נעים.','צפון איטליה הוא שילוב מדויק בין נופים גדולים לערים מלאות אופי. הדולומיטים, אגם גארדה, ורונה, ונציה ועיירות קטנות יוצרים טיול מגוון מאוד, בלי לוותר על הזמן להסתכל, להרגיש וליהנות מהדרך.','assets/generated/north-italy-scenic.jpg','assets/generated/north-italy-feature-1.jpg','assets/chana/final/smiling-upper.webp','["הדולומיטים - פסגות, אגמים ונוף אלפיני","אגם גארדה - סרמיונה, ריבה דל גארדה ומלצ׳זינה","ורונה - ארנה, כיכרות וסמטאות","פאדובה ובסאנו דל גראפה","ונציה - סן מרקו, התעלות והגטו"]'::jsonb,'["ורונה והסביבה","עיירות נהר המינצ׳יו ובורגטו","הרי הדולומיטים","פאדובה ובסאנו דל גראפה","סרמיונה, ריבה דל גארדה ומלצ׳זינה","ונציה"]'::jsonb,'["assets/generated/north-italy-feature-1.jpg","assets/generated/north-italy-feature-2.jpg","assets/generated/north-italy-feature-3.jpg","assets/generated/north-italy-feature-4.jpg","assets/generated/north-italy-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/italy/north-italy.html','באתר קשרי תעופה קיימים מסלולים לצפון איטליה, לרבות טיולי משפחות וקרנבלים. המסלול המדויק לכל יציאה של חנה יעודכן באדמין.',true,'צפון איטליה בין אגמים, הרים וערים','[["למי שאוהב נוף","אגמים, פסגות ועיירות ציוריות"],["למי שרוצה גיוון","טבע וערים היסטוריות באותו מסע"],["למי שאוהב קצב נעים","ימים מלאים בלי לוותר על זמן ליהנות"],["לשומרי מסורת","ההתאמות נקבעות לפי המסלול והמועד"]]'::jsonb,'טיול לצפון איטליה עם חנה | לטייל עם חנה','צפון איטליה עם חנה: דולומיטים, אגם גארדה, ורונה, ונציה ועיירות ציוריות. מידע, חוויות ומועדים מאושרים.',true,1) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('montenegro','מונטנגרו','הפנינה הנסתרת של הבלקן','מפרצים כחולים, הרים דרמטיים, עיירות עתיקות ונופים שנפתחים בכל פנייה.','מונטנגרו קטנה על המפה אבל מלאה בנופים. מפרץ קוטור, עיירות חוף, הרים, אגמים ותצפיות הופכים אותה ליעד עשיר ומפתיע. זה טיול שמתאים למי שאוהב טבע ונוף, אבל רוצה גם היסטוריה, רחובות עתיקים וקצב נוח.','assets/generated/montenegro-scenic.jpg','assets/generated/montenegro-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["קוטור - עיר עתיקה ואתר מורשת עולמית","דורמיטור והאגם השחור","לובצ׳ן וצ׳טנייה","אגם סקאדר ושייט","פטרובאץ וסווטי סטפן"]'::jsonb,'["טיבאט, פורטו מונטנגרו, בודווה ופודגוריצה","אגם סלנסקו, דורמיטור, האגם השחור וגשר נהר הטרה","צ׳טנייה, לובצ׳ן וקוטור","אגם סקאדר, פטרובאץ ותצפית סווטי סטפן","חזרה דרך טיבאט"]'::jsonb,'["assets/generated/montenegro-feature-1.jpg","assets/generated/montenegro-feature-2.jpg","assets/generated/montenegro-feature-3.jpg","assets/generated/montenegro-feature-4.jpg","assets/generated/montenegro-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/montenegro.html','מבוסס על מסלול נופי מונטנגרו המפורסם באתר קשרי תעופה. במסלול המקיף מתווספים גם פיבה, ביוגרדסקה גורה, מורצ׳ה ואוסטרוג.',true,'מונטנגרו של מפרצים, הרים ועיירות עתיקות','[["למי שאוהב טבע","תצפיות, הרים, אגמים ומפרצים"],["למי שאוהב ערים קטנות","רחובות עתיקים ונמלים עם אופי"],["למי שרוצה יעד מגוון","הרבה נוף וחוויה במדינה קומפקטית"],["לשומרי מסורת","ההתאמות נבדקות בכל יציאה"]]'::jsonb,'טיול מאורגן למונטנגרו עם חנה | לטייל עם חנה','מונטנגרו עם חנה: מפרץ קוטור, דורמיטור, האגם השחור, בודווה ונופי הבלקן. מידע, מסלול ומועדים מאושרים.',true,2) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('morocco','מרוקו','צבעים, טעמים וזיכרונות','שווקים ססגוניים, ערים עתיקות, אדריכלות מרהיבה ומדבר שמכניס הכול לפרופורציה.','מרוקו היא יעד של צבע, ריח וקצב. בין מרקש, פאס, קזבלנקה, שווקים, ארמונות ומרחבי מדבר פוגשים תרבות עשירה וסיפור יהודי עמוק. חנה מחברת בין האתרים לסיפורים ולאנשים, כדי שהטיול ירגיש קרוב ולא רק אקזוטי.','assets/generated/morocco-scenic.jpg','assets/generated/morocco-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["מרקש - העיר האדומה, גנים ושווקים","פס - המדינה העתיקה ומלאכות מסורתיות","רבאט וקזבלנקה","הרי האטלס","מורשת יהודית ומדבר סהרה במסלולים המתאימים"]'::jsonb,'["מרקש","קזבלנקה","רבאט","פס","הרי האטלס והכפרים","מורשת יהודית, ובמסלולים מסוימים גם אזור הסהרה"]'::jsonb,'["assets/generated/morocco-feature-1.jpg","assets/generated/morocco-feature-2.jpg","assets/generated/morocco-feature-3.jpg","assets/generated/morocco-feature-4.jpg","assets/generated/morocco-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/morroco.html','עמוד מרוקו של קשרי תעופה מדגיש את מרקש, קזבלנקה, רבאט, פס, הרי האטלס, הסהרה והמורשת היהודית. סדר הימים משתנה לפי יציאה.',true,'מרוקו דרך צבע, תרבות וסיפור יהודי','[["למי שאוהב תרבות","שווקים, מלאכות, אדריכלות וסיפורים"],["למי שמחפש חוויה חושית","צבעים, טעמים ונופים שמשתנים בדרך"],["למי שמתחבר למורשת","מפגש עם שכבות של היסטוריה יהודית ומקומית"],["לשומרי מסורת","התאמות הכשרות והשבת נקבעות לפי היציאה"]]'::jsonb,'טיול מאורגן למרוקו עם חנה | לטייל עם חנה','מרוקו עם חנה: מרקש, פאס, קזבלנקה, שווקים, אדריכלות ומורשת יהודית. מידע על היעד ומועדים מאושרים.',true,3) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('azerbaijan','אזרבייג׳ן','מפגש מרתק בין מזרח למערב','באקו המודרנית, העיר העתיקה, נופי קווקז וסיפור מקומי שמתגלה יום אחרי יום.','אזרבייג׳ן משלבת בין באקו החדשה והנוצצת לעיר עתיקה, כפרים ונופי קווקז. זה יעד נוח ומסקרן שמאפשר להכיר תרבות אחרת בלי לוותר על קצב נעים ועל הרבה רגעים יפים בדרך.','assets/generated/azerbaijan-scenic.jpg','assets/generated/azerbaijan-feature-1.jpg','assets/chana/final/smiling-upper.webp','["באקו - טיילת, עיר עתיקה ואדריכלות מודרנית","מגדלי הלהבה","סביבת באקו ואתרי טבע","ארץ האש - מפגש של טבע, היסטוריה וזהות"]'::jsonb,'["באקו והעיר העתיקה","הטיילת והעיר המודרנית","אתרים בסביבת באקו","במסלולים ארוכים - המשך אל אזורי פנים המדינה"]'::jsonb,'["assets/generated/azerbaijan-feature-1.jpg","assets/generated/azerbaijan-feature-2.jpg","assets/generated/azerbaijan-feature-3.jpg","assets/generated/azerbaijan-feature-4.jpg","assets/generated/azerbaijan-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/baku.html','קשרי תעופה מציגה באקו והסביבה ל-4 לילות, ארץ האש הנצחית ל-7 לילות וכן טיול כשר בן 5 ימים לבאקו.',true,'אזרבייג׳ן בין באקו החדשה לעולם הישן','[["למי שאוהב ניגודים","עיר מודרנית לצד רחובות עתיקים"],["למי שמחפש יעד מסקרן","תרבות אחרת במרחק טיסה נוח יחסית"],["למי שאוהב נוף ועיר","באקו לצד אזורי טבע וקווקז"],["לשומרי מסורת","פרטי היציאה נבדקים לפני הפרסום"]]'::jsonb,'טיול לאזרבייג׳ן עם חנה | לטייל עם חנה','אזרבייג׳ן עם חנה: באקו, העיר העתיקה, מגדלי הלהבה ונופי קווקז. מידע, נקודות עניין ומועדים מאושרים.',true,4) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('sri-lanka','סרי לנקה','פנינת האוקיינוס ההודי','מטעי תה, רכבות בין הרים, פילים, מקדשים וחופים טרופיים.','סרי לנקה ירוקה, חמה ומלאת חיים. נוסעים בין מטעי תה, רכבות נוף, אתרים עתיקים, שמורות טבע וחופים, ופוגשים אנשים ותרבות שמוסיפים לטיול הרבה מעבר לנוף. זה מסע מגוון מאוד, צבעוני ומרגש.','assets/generated/sri-lanka-scenic.jpg','assets/generated/sri-lanka-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["סיגיריה - מצודת הסלע","מטעי התה וההרים הירוקים","הרכבת בהרים","פילים ושמורות טבע","מקדשים וחופי האוקיינוס"]'::jsonb,'["קולומבו והיכרות עם האי","אזורי תרבות ומקדשים","סיגיריה","אזורי ההרים ומטעי התה","נסיעת רכבת ציורית","שמורות טבע וחופים בהתאם למסלול"]'::jsonb,'["assets/generated/sri-lanka-feature-1.jpg","assets/generated/sri-lanka-feature-2.jpg","assets/generated/sri-lanka-feature-3.jpg","assets/generated/sri-lanka-feature-4.jpg","assets/generated/sri-lanka-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours.html','קשרי תעופה מפרסמת טיול מאורגן כשר לסרי לנקה בן 9 לילות. סדר הימים הסופי יעודכן לאחר אישור יציאת חנה.',true,'סרי לנקה של טבע, תרבות וקצב טרופי','[["למי שאוהב טבע","מטעי תה, הרים, חופים ושמורות"],["למי שאוהב חוויות דרך הדרך","רכבות נוף, כפרים ומפגשים מקומיים"],["למי שמחפש יעד צבעוני","תרבות, מקדשים וטבע באותו מסע"],["לשומרי מסורת","ההתאמות נקבעות ומאושרות לכל יציאה"]]'::jsonb,'טיול מאורגן לסרי לנקה עם חנה | לטייל עם חנה','סרי לנקה עם חנה: מטעי תה, רכבות נוף, סיגיריה, שמורות, פילים וחופים. מידע על היעד ומועדים מאושרים.',true,5) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('dubai','דובאי ואבו דאבי','עיר של חדשנות, יוקרה וחוויות','קו רקיע מרשים, מדבר, שווקים, אדריכלות יוצאת דופן וחוויות בקצב אחר.','דובאי מציעה שילוב של חדשנות, אדריכלות, קניות, מדבר ומקומות שלא דומים לשום עיר אחרת. בין גורדי השחקים לשווקים ולנוף המדברי מתקבל טיול קליל, מגוון ומלא רגעים מרשימים.','assets/generated/dubai-scenic.jpg','assets/generated/dubai-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["בורג׳ חליפה","דובאי מרינה","מדבר וספארי","אבו דאבי","שווקים וקניות"]'::jsonb,'["דובאי המודרנית והעיר הישנה","בורג׳ חליפה ומרכז העיר","מרינה וקניות","ספארי מדברי","אבו דאבי בהתאם למסלול"]'::jsonb,'["assets/generated/dubai-feature-1.jpg","assets/generated/dubai-feature-2.jpg","assets/generated/dubai-feature-3.jpg","assets/generated/dubai-feature-4.jpg","assets/generated/dubai-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/dubai.html','קשרי תעופה מציגה דובאי ואבו דאבי אקספרס ל-4 לילות, קסמי המדבר ל-6 לילות וכן מסלול דתי/כשר בן 5 ימים.',true,'דובאי ואבו דאבי בין חדשנות, מדבר ואדריכלות','[["למי שאוהב עיר מודרנית","אדריכלות, קניות ואטרקציות בקנה מידה אחר"],["למי שרוצה גיוון","קו רקיע, שווקים ומדבר באותו טיול"],["למי שמעדיף חוויה נגישה","הרבה מוקדי עניין במסלול עירוני"],["לשומרי מסורת","פרטי הכשרות והשבת נקבעים לפי היציאה"]]'::jsonb,'טיול לדובאי ואבו דאבי עם חנה | לטייל עם חנה','דובאי ואבו דאבי עם חנה: בורג׳ חליפה, מרינה, שווקים, מדבר ואדריכלות. מידע ומועדים מאושרים בלבד.',true,6) on conflict(slug) do nothing;

insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-japan-181126','japan','טוקיו-קיוטו ומה שביניהם','2026-11-18'::date,'2026-11-25'::date,7,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-japan-231126','japan','פניני יפן','2026-11-23'::date,'2026-12-01'::date,8,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-japan-040427','japan','מיטב יפן בפריחת הדובדבן','2027-04-04'::date,'2027-04-14'::date,10,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-northitaly-240926','north-italy','צפון איטליה למשפחות','2026-09-24'::date,'2026-09-30'::date,6,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-montenegro-100926','montenegro','נופי מונטנגרו','2026-09-10'::date,'2026-09-14'::date,4,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-montenegro-111026','montenegro','הטבע של מונטנגרו - כשר','2026-10-11'::date,'2026-10-15'::date,4,'פנסיון מלא','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-baku-251026','azerbaijan','טיול כשר 5 ימים לבאקו','2026-10-25'::date,'2026-10-29'::date,4,'חצי פנסיון כשר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-srilanka-051026','sri-lanka','טיול מאורגן כשר לסרי לנקה','2026-10-05'::date,'2026-10-15'::date,9,'חצי פנסיון כשר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-northitaly-carnival-030227','north-italy','קרנבלים בצפון איטליה','2027-02-03'::date,'2027-02-09'::date,6,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-montenegro-180926','montenegro','הטבע של מונטנגרו - כשר','2026-10-18'::date,'2026-10-22'::date,4,'פנסיון מלא','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-baku-041026','azerbaijan','באקו והסביבה','2026-10-04'::date,'2026-10-08'::date,4,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-baku-fire-071026','azerbaijan','ארץ האש הנצחית','2026-10-07'::date,'2026-10-14'::date,7,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-dubai-express-290926','dubai','דובאי ואבו דאבי אקספרס','2026-09-29'::date,'2026-10-03'::date,4,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-dubai-desert-231026','dubai','קסמי המדבר של איחוד האמירויות','2026-09-23'::date,'2026-09-29'::date,6,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-azerbaijan-20261011-14','azerbaijan','באקו והסביבה 4 לילות','2026-10-11'::date,'2026-10-15'::date,4,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-dubai-20261008-15','dubai','קסמי המדבר של איחוד האמירויות','2026-10-08'::date,'2026-10-14'::date,6,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-dubai-20270112-16','dubai','דובאי ואבו דאבי אקספרס','2027-01-12'::date,'2027-01-16'::date,4,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;

insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp1','japan','מעיין גוטשלק','תודה ענקית על טיול נפלא, מושקע ומלא בחוויות וזיכרונות. חנה, תודה על ההדרכה המקצועית, הידע הרב, הדרך הדידקטית והנעימה, הסיפורים המרתקים, האסרטיביות כשצריך והדאגה שהכול יתקתק. למדתי, צחקתי, טעמתי, טיילתי ובעיקר נהניתי מאוד.',true,true,0) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp2','japan','שלום רזפורקר ויהלי לוי','אחרי 13 ימים מטורפים ביפן אנחנו פשוט רוצים להגיד אריגטו. להחזיק ולנווט קבוצה במשך שבועיים זה ממש לא צחוק, ואת עשית את זה כמו נינג׳ה אמיתית. ראינו כמה השקעת וכמה דאגת לכל אחד ואחת. הלב הענק שלך היה הדבר הכי מרשים בטיול.',false,true,1) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp3','japan','גילה ורוני בוחניק','חנה הפגינה מקצועיות אינסופית לאורך כל הדרך. היא ידעה להסביר על כל מקום בצורה מרתקת, מובנת ובהירה, והכול תוך חן והומור שהפכו כל סיור לחוויה של ממש.',true,true,2) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp4','japan','אלכס ונעמי שץ','מקצועית, בעלת ידע רחב ואנושיות יוצאת דופן. חנה הכילה את כל הקבוצה, דאגה לכל פרט במסירות וברגישות והשרתה עלינו שקט נפשי וביטחון מלא. בזמן קצר הפכה את הקבוצה למשפחה אחת חמה.',false,true,3) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('g1',null,'מטיילת חוזרת','אני בטיול שלישי איתך ואמשיך לראות עולם דרך עינייך. את מקצועית, איכותית ומיוחדת, ונותנת לכל אחד להרגיש שהוא חשוב בעינייך.',true,true,4) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('g2',null,'משפחת מטיילים','הטיול היה מעבר לטיול מאורגן. זו הייתה חוויה עמוקה, שמחה ומלאת מחשבה. תודה על הלב הרחב, הסבלנות, החיוך וההובלה המדהימה. זכינו בך כמדריכה.',false,true,5) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp5','japan','נתן וחנה','תודה מכל הלב על טיול נפלא ליפן, על האווירה הטובה, החברות, החוויות והזיכרונות היפים. חנה, תודה מיוחדת על ההשקעה, הסבלנות, הדאגה והליווי לאורך כל הדרך.',false,true,6) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp6','japan','מטיילת מהקבוצה','חזרתי מיפן עם המון חוויות וזיכרונות נפלאים, אבל מעל הכול עם קבוצה שהפכה למשפחה. חנה, תודה ענקית על ליווי מסור, מקצועי ואכפתי, תמיד קשובה ודואגת לכל אחד ואחת. זכינו בך כמדריכה.',false,true,7) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp7','japan','מטיילת חוזרת','אני בטיול שלישי איתך ואמשיך לראות עולם דרך עינייך והידע שאת מעבירה. את מקצועית, איכותית ומיוחדת, ונתת לכל אחד להרגיש שהוא חשוב בעינייך.',false,true,8) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp8','japan','משפחת מטיילים','ההדרכה שלך הייתה מעבר לטיול מאורגן. זו הייתה חוויה עמוקה, שמחה ומלאת מחשבה. ניהלת טיול לשומרי מסורת רב-גילאי במקצועיות ובמסירות, ונתת לנו שקט נפשי וביטחון מלא.',false,true,9) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp9','japan','מטיילת ביפן','תודה על מסע מופלא ליפן, על הידע, ההדרכה וההובלה לאורך כל הדרך. עשית זאת ביד רמה ובמקצועיות. זו חוויה בלתי נשכחת, מגוונת ומעניינת.',false,true,10) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp10','japan','נוסעים בקבוצת יפן','איזה כיף של טיול. נהנינו מכל רגע. תודה חנה על העזרה, הדאגה, הסבלנות ובעיקר על הנחישות לפתור כל בעיה עד הסוף. מאחלים לך עוד שנים רבות של טיולים והדרכות מסביב לעולם.',false,true,11) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp11','japan','נוסעים שכתבו לקשרי תעופה','חנה מקצועית, בעלת ידע רחב ואנושיות יוצאת דופן. היא הכילה את הקבוצה, דאגה לכל פרט במסירות וברגישות, והפכה בזמן קצר קבוצת מטיילים למשפחה אחת חמה שחולקת חוויות של פעם בחיים.',false,true,12) on conflict(id) do nothing;

insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('pdf-rtl','חוברת / PDF עברי מושלם','PDF וחוברות','הפרומפט המלא לחוברת DOCX + PDF עם Visual RTL ובדיקת כל העמודים.','אני מצרפת בהודעה הזו חומר לימוד.

אני רוצה שתכין ממנו חוברת לימוד מקצועית, ברורה, נעימה ומוכנה להדפסה כ-PDF בעברית.

חשוב מאוד:
השתמש אך ורק בקובץ או בקבצים שאני מצרפת בהודעה הנוכחית.

אל תחפש קבצים ב-Library.
אל תשתמש בקבצים משיחות קודמות.
אל תשתמש ב-Google Drive.
אל תניח שיש גרסה קודמת.
אל תשתמש באינטרנט או במקורות חיצוניים אלא אם אבקש זאת במפורש.

החומר המצורף הוא מקור האמת.

==============================
1. טיפול בתוכן
==============================
קרא את כל החומר המצורף לפני שאתה מתחיל ליצור את החוברת.
אל תדלג על עמודים או חלקים.

אם הקובץ כבר מכיל חומר לימוד כתוב ומסודר: שמור על כל המלל הקיים.
אסור למחוק משפטים, פסקאות, כותרות, הסברים, דוגמאות, הערות, רשימות, טבלאות, מספרים, תאריכים, שמות או מקורות.
אל תקצר ואל תסכם חומר קיים על דעת עצמך.

אם החומר הוא חומר גלם שדורש ארגון: מותר לסדר אותו לפרקים, כותרות ופסקאות בצורה טובה יותר, אבל אסור להמציא מידע שלא נמצא במקור.
אם משהו לא ברור או חסר במקור: אל תנחש עובדות.

==============================
2. המטרה: חוברת לימוד אמיתית
==============================
אני רוצה חוברת שקל ללמוד ממנה ולא מסמך צפוף.
סדר את החומר בצורה טבעית וברורה עם כותרת ראשית, פרקים, כותרות משנה, פסקאות בגודל נוח, חלוקה הגיונית, רשימות רק כשצריך, הסברים רציפים, הדגשה עדינה של מושגים חשובים ורווחים נוחים.
אל תהפוך כל משפט לנקודה ברשימה. אל תיצור עשרות קופסאות או אזורים צבעוניים. המראה צריך להיות של חוברת לימוד מקצועית ונעימה.

==============================
3. RTL אמיתי וגם יישור לימין
==============================
זה התנאי החשוב ביותר.
כל הטקסט העברי חייב להיות RIGHT TO LEFT אמיתי וגם מיושר בפועל לצד ימין של העמוד.
לא מספיק להגדיר RTL בקוד ולא מספיק align:right. המבחן היחיד הוא איך ה-PDF נראה לאחר הרינדור.
פסקה בעברית צריכה להתחיל פיזית מהצד הימני של אזור הטקסט ולהמשיך שמאלה.
גוף הטקסט, כותרות משנה, תבליטים, מספור, הערות, מקורות וטבלאות צריכים להופיע נכון לקורא עברי.
Visual RTL קודם לכל הגדרת קוד. אם מאפיין בשם Right Alignment יוצר בפועל PDF שמיושר שמאלה, אל תשתמש בו. סמוך על התוצאה המרונדרת בלבד.

==============================
4. עברית יחד עם אנגלית ומספרים
==============================
שמור בצורה מושלמת גם על טקסט מעורב, למשל: ורונה (Verona), Museo Nicolis, Bonotto Hotel Palladio, Piazza San Marco, 20-27 באוגוסט 2026, 23:25, 1939-1940, 17 ק״מ, Verona → Vicenza.
אסור לבצע reverse על הטקסט. אסור להפוך אותיות או מילים ידנית.
מילים באנגלית/איטלקית ומספרים נשארים בכיוון LTR הטבעי שלהם.
בדוק במיוחד סוגריים, מקפים, טווחי שנים, תאריכים, שעות, מספרים, אחוזים, שמות מקומות, כתובות, URLs, חצים ולוכסנים.

==============================
5. עיצוב החוברת
==============================
פורמט A4, Portrait בדרך כלל. שוליים בערך 1.7-2 ס״מ. כתב גוף 11.5-12.5pt. כותרת ראשית 22-26pt, כותרת פרק 18-21pt, כותרת משנה 14-16pt.
השתמש בפונט עברי ברור ונקי. צבעים: שחור, אפור כהה ואפשר צבע Accent עדין אחד בלבד.
בלי צבעוניות מוגזמת, בלי עיצוב ראוותני, בלי הרבה קופסאות, בלי אייקונים מיותרים, בלי שטחים ריקים עצומים ובלי צפיפות.

==============================
6. עמודים ופסקאות
==============================
שמור על מעברי עמוד הגיוניים. אל תשאיר כותרת לבדה בתחתית העמוד. אל תיצור עמודים ריקים או חצי עמוד ריק ללא סיבה. אל תקטין כתב כדי לדחוס חומר. עדיף עוד עמוד מאשר חוברת צפופה.
מספרי עמודים צריכים להיות ברורים ועדינים.

==============================
7. טבלאות
==============================
טבלאות חייבות להיות RTL גם מבחינת המבנה. העמודה הראשונה לקורא העברי צריכה להופיע בצד ימין. טקסט עברי בתוך תא מיושר לימין וטקסט אנגלי ומספרים נשארים בכיוון התקין.
אם צריך אפשר להשתמש בעמוד Landscape לטבלה רחבה. נסה לא לפצל שורה אחת של טבלה בין שני עמודים.

==============================
8. תמונות
==============================
אם במסמך המקורי קיימות תמונות: אל תמחק אותן, אל תעוות אותן, שמור על יחס הגובה והרוחב, ואפשר לשנות גודל ומיקום כדי ליצור עמוד נעים. שמור כל כיתוב ששייך לתמונה.

==============================
9. חובה לבצע בדיקת רינדור
==============================
אל תמסור PDF מיד אחרי יצירתו. לאחר יצירת ה-DOCX רנדר אותו לעמודים ובדוק ויזואלית. לאחר יצירת ה-PDF רנדר גם אותו. בדוק את כל העמודים אחד-אחד, לא רק דוגמה.

==============================
10. בדיקת RTL בכל עמוד
==============================
בכל עמוד בדוק: האם הפסקאות העבריות בצד ימין? האם כל פסקה מתחילה פיזית מימין? האם הכותרות, התבליטים והמספור במקום הנכון? האם סוגריים, שמות באנגלית/איטלקית, שנים, תאריכים, שעות ומספרים תקינים? האם אין טקסט חתוך, חפיפות או עמודים ריקים?
אם רוב הטקסט נראה צמוד לצד שמאל, זו תקלה. אל תמסור את המסמך; תקן ורנדר שוב.

==============================
11. בדיקת שמירת החומר
==============================
לפני המסירה השווה בין קובץ המקור לבין הקובץ הסופי. ודא שלא נעלמו פסקאות, משפטים, מילים, רשימות, כותרות, מספרים, תאריכים, טבלאות, הערות או מקורות.
אם החומר אמור להישמר ללא שינוי, בצע השוואת טקסט מלאה בין המקור לבין ה-DOCX הסופי. מעברי שורה ועמוד יכולים להשתנות; המלל עצמו לא.

==============================
12. מבחן סופי
==============================
לפני המסירה ודא:
[ ] כל החומר המצורף נקרא.
[ ] לא נעשה שימוש ב-Library או בקבצים משיחות אחרות.
[ ] לא נעלם תוכן.
[ ] ה-PDF הוא RTL אמיתי.
[ ] הטקסט העברי מוצמד בפועל לצד ימין.
[ ] הפסקאות מתחילות מימין.
[ ] תבליטים ומספור נמצאים מימין.
[ ] אנגלית ואיטלקית לא התהפכו.
[ ] מספרים, תאריכים ושעות לא התהפכו.
[ ] סוגריים תקינים.
[ ] אין טקסט חתוך או חפיפות.
[ ] אין עמודים ריקים מיותרים.
[ ] גודל הכתב נוח לקריאה.
[ ] כל עמודי ה-DOCX נבדקו לאחר רינדור.
[ ] כל עמודי ה-PDF נבדקו לאחר רינדור.
אם סעיף אחד נכשל, אל תמסור עדיין. תקן ורנדר מחדש.

==============================
13. התוצאה שאני רוצה
==============================
בסיום תן לי:
1. PDF סופי, איכותי ומוכן להדפסה.
2. DOCX עריך שממנו יצרת את ה-PDF.
אל תשלח טיוטה ואל תבקש ממני לבדוק RTL בשבילך.
בסיום כתוב רק בקצרה: כמה עמודים יש, שכל העמודים נבדקו ויזואלית, שה-RTL נבדק לפי ה-PDF המרונדר, שהטקסט נמצא בפועל בצד ימין, והאם בדיקת שמירת התוכן עברה.

העיקרון החשוב ביותר: אני לא רוצה מסמך ש״רשום בקוד שהוא RTL״. אני רוצה לפתוח את ה-PDF ולראות חוברת עברית טבעית: העברית מתחילה בצד ימין, קוראים מימין לשמאל, אנגלית ומספרים מוצגים נכון, והכול נעים וברור לקריאה.',false,0) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('marketing-image','מודעת פרסום לטיול','שיווק ותמונות','הפרומפט המלא למודעת פרימיום עם לוגואים, תמונות מהמסלול ו-RTL.','אני רוצה שתיצור עבורי מודעת פרסום אחת מקצועית, יפה ומושכת לטיול, ברמת פרימיום, בעברית מלאה RTL, בהתבסס על הפרטים, המסלול והלוגואים שאצרף.

לפני שאתה מתחיל:
אם חסר פרט מהותי שבאמת נדרש כדי להכן את המודעה בצורה מושלמת — אל תנחש. שאל אותי קודם בצורה קצרה ומסודרת עד 5 שאלות ממוקדות בלבד.
אם יש מספיק מידע — אל תשאל שאלות, פשוט תכין את התוצר הסופי.

הנה המידע לטיול:
שם הטיול: [למלא]
יעד / מדינה: [למלא]
תאריכי הטיול: [למלא]
מספר לילות: [למלא]
מחיר: [למלא]
קהל יעד: [למלא]
סוג הטיול: [למלא, למשל טיול עומק / טיול מאורגן / משפחות / מבוגרים]
כשרות / מסורת: [למלא]
מה מיוחד בטיול: [למלא]
אתרים / מסלול / נקודות מרכזיות: [למלא או לצרף מסלול]
מה המחיר כולל: [למלא]
מה חשוב להבליט: [למלא]
פרטי יצירת קשר: [למלא]
לוגו 1: קשרי תעופה
לוגו 2: לטייל עם חנה

המשימה:
צור מודעת פרסום אחת מעוצבת ומרשימה, שמתאימה גם לפרסום דיגיטלי וגם להדפסה, ושנראית כמו מודעה של מותג תיירות איכותי, יוקרתי, אמין ומזמין.

מטרת העיצוב: ליצור מודעה שגורמת לאנשים לעצור, לקרוא ולהתעניין בטיול. היא צריכה להיות מסודרת, ברורה, מושכת וצבעונית במידה הנכונה — לא עמוסה מדי, אבל עשירה ומרשימה.

פורמט: A4 אנכי להדפסה, 300DPI, עם פריסה שמתאימה גם להמרה לפוסט/סטורי. שמור על שוליים בטוחים לטקסט וקריאות מצוינת בנייד.

שפה וכיווניות: עברית בלבד, RTL מלא, יישור לימין, עברית תקינה בלבד.

טיפוגרפיה: השתמש בפונט Rubik בלבד. כותרות Rubik Black/Bold, טקסט רגיל Rubik Medium/Regular. לא להשתמש בפונט דק מדי.

נאמנות לטקסט ואיכות עברית — חובה מוחלטת: אסור לשנות או להמציא מילים, אסור שגיאות כתיב, אותיות כפולות או משובשות, ואסור לפצל מילים מוזר. כל טקסט שחייב להופיע צריך להופיע בדיוק כפי שנמסר. בסוף בצע הגהה מלאה לכל מילה.

אם פרט לא נמסר — אל תמציא. אם חסר מחיר כתוב ״לפרטים ועלויות״. אם חסר מספר לילות אל תוסיף. אם חסר ״מה המחיר כולל״ אל תמציא סעיפים. אם הועלה מסלול, השתמש בו כדי לגוון את התמונות לפי האתרים האמיתיים.

סגנון: מותג תיירות איכותי, מודרני, פרימיום, נקי ואלגנטי. צבעוני אך לא ילדותי, עם תחושת חופשה, איכות, נוחות ואמינות. רקע בהיר יוקרתי לבן/שמנת/אוף-ווייט, נגיעות צבע מותאמות ליעד, צללים רכים וקווים נקיים.

לוגואים — חובה: השתמש בלוגו קשרי תעופה ובלוגו לטייל עם חנה כפי שהם. לא לסובב, למתוח, לעוות או לחתוך. שני הלוגואים צריכים להיות ברורים ואופקיים. שלב אותם בחלק העליון בצורה אלגנטית, למשל בקפסולות עדינות, תוך שמירה על איזון וקריאות.

מבנה המודעה:
1. אזור עליון: לוגואים, כותרת ראשית, תאריך/טווח תאריכים ושורת משנה.
2. אזור מרכזי: תמונה ראשית מרשימה, ואם מתאים 2–6 תמונות משנה, יתרונות בולטים, אתרים מרכזיים/מסלול, פרטי כשרות/לילות/מחיר אם נמסרו.
3. אזור תחתון: יצירת קשר בולטת ומסר סיכום קצר אם מתאים.

בחירת תמונות: התמונות חייבות להתאים ליעד, לעונה, למסלול ולאופי הטיול. אם צורף מסלול, גוון לפי האתרים האמיתיים. אל לבחור כמה תמונות שנראות אותו דבר. צור איזון בין טבע, ערים, תרבות ואנשים לפי המסלול.

תוכן: הצג בצורה פרסומית, מושכת, קצרה ומדויקת. היררכיה ברורה: כותרת גדולה, שורת משנה, highlights, פרטים חשובים ויצירת קשר. אם נמסרו נתונים כמו טיול כשר, שומרי מסורת, חצי פנסיון, מספר לילות, מחיר, טיסות ישירות, מלון אחד או מסלול מיוחד — הבלט אותם בכרטיסים/תגיות עדינות.

כללים: לא לחזור על אותו משפט, לא לחזור על השם חנה במרכז אם הוא כבר בלוגו אלא אם נדרש באזור הקשר. הצג רק פרטים שנמסרו בפועל.

אזור יצירת הקשר צריך להיות בולט מאוד, בפס תחתון או כפתור רחב. הצג את הפרטים בדיוק כפי שנמסרו.

גימור: הרבה אוויר, קריאות מעולה, תמונות איכותיות, צבעוניות מדויקת, תחושת יוקרה וחופש, התאמה ליעד ולמסלול, עברית תקינה, ללא כפילויות וללא שינויי טקסט לא רצויים.

לפני הצגת התוצאה בצע בדיקה סופית: שאין שגיאות כתיב, אותיות משובשות, החלפת מילים או כפילויות; שהלוגואים ברורים ולא מעוותים; שהתמונות מתאימות ליעד, לעונה ולמסלול; ושהמחיר, התאריכים, מספר הלילות, הכשרות ופרטי הקשר מוצגים נכון.

אם הכל ברור ויש מספיק פרטים — צור את המודעה הסופית בצורה מושלמת.',false,1) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('passenger-booklet','חוברת נוסעים מטיול ומסלול','PDF וחוברות','הופך מסלול וחומר תפעולי לחוברת נוסעים ברורה ומוכנה ל-PDF.','אני מצרפת מסלול וחומר תפעולי לטיול. הכן חוברת נוסעים מקצועית בעברית RTL. השתמש רק בחומר המצורף כמקור אמת ואל תמציא פרטים. סדר: שער עם שם היעד והתאריכים; דבר המדריכה; מידע חשוב לפני יציאה; טיסות ומפגשים אם נמסרו; תוכנית יום-יום; מזג אוויר ולבוש רק אם נמסר או אם אבקש חיפוש; כשרות ושבת; כסף ותקשורת; ציוד מומלץ; פרטי חירום; עמוד אחרון עם מסר חם. שמור על ניסוחים קצרים, הרבה אוויר, A4, RTL אמיתי ויישור ויזואלי לימין. צור DOCX ו-PDF ובדוק כל עמוד לאחר רינדור.',false,2) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('destination-page','תוכן לדף יעד באתר','שיווק ותוכן','יוצר טקסט קצר ומגרה לדף יעד בלי להמציא מסלול.','קבל את חומר היעד והמסלול שאצרף וכתוב תוכן מוכן לדף יעד באתר "לטייל עם חנה". הקהל הוא בעיקר שומרי מסורת. אל תמציא עובדות, מסלולים, מחירים או מועדים.

החזר בדיוק בסדר הבא:
1. כותרת Hero של עד 7 מילים.
2. שורת משנה של עד 14 מילים.
3. פסקת פתיחה של 80–120 מילים, טבעית ומעוררת רצון לטייל בלי קלישאות.
4. חמישה כרטיסי "מה רואים בטיול", לכל כרטיס כותרת קצרה ושורה אחת.
5. "למי הטיול מתאים" עם 3–4 נקודות ענייניות.
6. מועדים, רק אם נמסרו ואושרו. אם אין מועד: נוסח CTA "עדכנו אותי כשנפתח מועד".
7. שלוש שאלות נפוצות רלוונטיות.
8. מטא-טייטל ומטא-דסקריפשן ל-SEO.

הסגנון צריך להיות חם, מקצועי, מדויק ואנושי. אל תכתוב בניסוח גנרי או מלאכותי, אל תגזים בתארים ואל תחזור על אותו מסר.',false,3) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('whatsapp-tour','הודעת WhatsApp למתעניין','WhatsApp','תבנית אישית לפנייה אוטומטית מהאתר לפי יעד ותאריך.','כתוב הודעת WhatsApp אחת קצרה וטבעית של מטייל שמתעניין בטיול. השתמש בפרטים: יעד [יעד], שם הטיול [שם], תאריכים [תאריכים]. נוסח מומלץ: ״שלום חנה, ראיתי באתר את הטיול ל[יעד] בתאריכים [תאריכים] ואשמח לקבל פרטים.״ אם אין מועד: ״שלום חנה, ראיתי באתר את היעד [יעד]. כרגע לא מצאתי מועד שמתאים לי ואשמח שתעדכני אותי כשייפתח מועד חדש.״ אל תוסיף מידע שלא נמסר.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,4) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('whatsapp-before','הודעה לקבוצה לפני הטיול','WhatsApp','הודעת יציאה ברורה וחמה עם מקום מפגש ודגשים.','כתוב הודעת WhatsApp קצרה, חמה ומסודרת לקבוצת מטיילים לפני יציאה. יעד: [יעד]. תאריך: [תאריך]. שעת מפגש: [שעה]. מקום מפגש: [מקום]. דגשים: [דגשים]. עברית טבעית, בלי ניסוח מלאכותי ובלי אימוג׳ים כברירת מחדל. כלול פתיחה חמה, פרטי המפגש, 3–5 דגשים חשובים וסיום שמח לקראת הטיול.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,5) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('daily-message','הודעת בוקר יומית לקבוצה','WhatsApp','מסר קצר עם לו״ז, לבוש ודגשי היום.','כתוב הודעת בוקר לקבוצת מטיילים. יום בטיול: [יום]. היעד/המסלול היום: [מסלול]. שעת יציאה: [שעה]. מזג אוויר שסופק לי: [מזג אוויר]. לבוש/ציוד: [דגשים]. ארוחות/שבת/כשרות: [אם רלוונטי]. צור הודעה קצרה מאוד, ברורה, ידידותית, עם לו״ז בנקודות וסיום נעים. אל תמציא מזג אוויר או שעות.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,6) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('guide-sheet','דף הדרכה למדריכה','הדרכה','הופך חומר מקור לדף נוח להעברה בעל-פה בשטח.','אני מצרפת חומר על אתר/עיר. הכן לי דף הדרכה למדריכה בעברית: 1) הסבר קצר לעצמי כדי להבין את המקום, 2) 5–8 נקודות שאפשר לומר לקבוצה, 3) שני סיפורים/עובדות מעניינות רק אם קיימים במקור, 4) מה להראות פיזית בשטח, 5) משפט פתיחה ומשפט סיום, 6) אזהרות על עובדות לא ודאיות. אל תמציא מידע. שמור על מבנה שאפשר לסרוק במהירות בטלפון בזמן הדרכה.',false,7) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('packing','צ׳קליסט לפני יציאה','תפעול','רשימת בדיקה למדריכה ולנוסעים, כולל שבת וכשרות.','צור צ׳קליסט מסודר לטיול מאורגן ל[יעד] בתאריכים [תאריכים], לקהל שומר מסורת. חלק ל: מסמכים, כסף, ביגוד, תרופות, ציוד אישי, שבת/כשרות, מזג אוויר, טיסות, תקשורת ויום היציאה. אל תוסיף דרישות שלא נמסרו; אם פרט תלוי במסלול סמן ״לבדיקה״. הפרד בין ״למדריכה״ לבין ״לשליחה לנוסעים״.',false,8) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('post-trip','הודעת סיכום אחרי הטיול','WhatsApp','סיום אישי וחם לקבוצה לאחר החזרה.','כתוב הודעת סיכום חמה ואישית לקבוצת מטיילים שחזרה מ[יעד]. ציין תודה על האמון, האווירה והביחד, זיכרון כללי מהמסע, איחולי חזרה קלה והזמנה לשמור על קשר. קצר, טבעי, לא מתאמץ ולא מלא אימוג׳ים. אם אצרף רגעים מיוחדים מהטיול, שלב אותם בעדינות.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,9) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('review-request','בקשה נעימה לביקורת','שיווק ותוכן','הודעה לא לוחצת לבקשת המלצה מהמטיילים.','כתוב הודעה קצרה מאוד לקבוצה לאחר הטיול שמבקשת, למי שמתאים, לכתוב כמה מילים על החוויה עם חנה. הטון חם ולא לוחץ. אם מצורף קישור לביקורת [קישור] שלב אותו. אל תבקש ״5 כוכבים״ ואל תכתיב מה לכתוב; בקש חוות דעת אמיתית.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,10) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('social-post','פוסט לפרסום טיול','שיווק ותוכן','פוסט פייסבוק/WhatsApp קצר שמוביל להתעניינות.','כתוב פוסט פרסומי טבעי בעברית לטיול של ״לטייל עם חנה״. יעד [יעד], תאריכים [תאריכים], אורך [ימים/לילות], אופי [שומרי מסורת/אחר], 4–6 נקודות מסלול [להדביק], ומה מיוחד [להדביק]. פתיחה שמגרה לצאת לדרך, 4 נקודות קצרות, שורת אמון על חוויה אישית בטיול מאורגן, וסיום עם CTA ל-WhatsApp. אל תמציא מחיר, מלון, כשרות או טיסות שלא נמסרו. בלי אימוג׳ים כברירת מחדל.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,11) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('tour-summary-card','תקציר טיול לאתר/פלייר','שיווק ותוכן','מזקק מסלול ארוך לכרטיס קצר בלי לאבד דיוק.','אני מצרפת מסלול מלא. חלץ ממנו תקציר שיווקי מדויק בלבד: שם מוצע לטיול, משפט אחד שמסביר את החוויה, 5 highlights אמיתיים, מספר ימים/לילות אם מופיע, ערים/אתרים מרכזיים לפי סדר הגיוני, ומה חשוב לדעת לשומרי מסורת רק אם נכתב במקור. אל תמציא ואל תוסיף יעד שלא מופיע במסלול.',false,12) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('supplier-route-research','בדיקת מסלול ספק מול קשרי תעופה','מחקר ותכנון','בודק מסלול רשמי של ספק ומוציא רק מידע שאפשר להשתמש בו בבטחה.','אני מצרפת קישור או מסלול של ספק לטיול ל[יעד]. בדוק את המקור הרשמי בלבד. חלץ: שם המוצר, מספר ימים/לילות, נקודות המסלול לפי הסדר, מלונות/ארוחות/כשרות רק אם נכתבו, הערות חשובות, ומה משתנה בין יציאות אם מצוין. אל תניח שאני מדריכה מועד מסוים רק מפני שהוא מופיע באתר הספק. סמן בנפרד: מידע מאומת, מידע שדורש אישור, ומידע שלא נמצא. בסוף הכן תקציר שאפשר להעתיק לעמוד היעד באתר בלי לייחס לחנה פרטים שלא אושרו.

בסוף צור גם טבלת אימות קצרה: פריט | מה נמצא במקור | בטוח לפרסום? | מה דורש אישור מחנה. אל תייחס לחנה שום יציאה או שירות שלא אושר במפורש.',false,13) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('raw-trip-to-marketing-brief','מחומר גלם לבריף שיווקי מלא','שיווק ותוכן','מקבל מסלול לא מסודר והופך אותו לבריף מוכן למודעה, דף יעד ופוסט.','אני מצרפת חומר גלם על טיול. אל תמציא פרטים. הפוך את החומר לבריף שיווקי מסודר עם: שם הטיול, יעד, תאריכים, מספר ימים/לילות אם קיים, קהל יעד, אופי הטיול, כשרות/מסורת אם נמסרו, 5–7 highlights, רשימת אתרים מרכזיים, מה מיוחד בטיול, פרטים שחסרים וצריך להשלים, משפט Hero קצר, תיאור של 80–120 מילים, CTA מוצע, ורשימת 6–10 תמונות שכדאי לחפש/ליצור לפי המסלול. בסוף תן בלוק אחד מוכן להדבקה בתוך פרומפט מודעת הטיול.',false,14) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('marketing-image-from-trip','בניית פרומפט תמונה אוטומטי מטיול','שיווק ותמונות','מייצר פרומפט מדויק לתמונה שיווקית מתוך פרטי הטיול והמסלול.','קבל את פרטי הטיול והמסלול שאצרף ובנה עבורי פרומפט אחד מוכן להדבקה בכלי יצירת תמונות. הפרומפט צריך לדרוש מודעת פרימיום בעברית RTL, להשתמש בלוגו קשרי תעופה ובלוגו לטייל עם חנה כפי שאצרף, לבחור תמונה ראשית ו-2–6 תמונות משנה לפי האתרים האמיתיים, ולהדגיש רק פרטים שנמסרו. אל תמציא מחיר, מלון, טיסות, כשרות או מספר לילות. ציין את יחס התמונה הרצוי, היררכיית הטקסט, צבעוניות המתאימה ליעד, אזור ליצירת קשר ובדיקת איות מלאה. החזר בסוף רק פרומפט אחד מסודר ומוכן להעתקה.',false,15) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('traveler-info-sheet','דף מידע קצר לנוסעים','PDF וחוברות','דף אחד או שניים עם המידע שהנוסעים באמת צריכים לפני יום/אתר.','אני מצרפת חומר על יום בטיול או אתר. הכן דף מידע קצר ונעים לנוסעים בעברית RTL, עד שני עמודים אלא אם החומר מחייב יותר. שמור על העובדות בלבד. סדר: כותרת, למה המקום מעניין, מה נראה, 5 דברים שכדאי לדעת, לבוש/ציוד רק אם נמסר, נקודת מפגש/שעות רק אם נמסרו, והערה קצרה לשומרי מסורת אם רלוונטית ומאומתת. העיצוב צריך להיות נקי, קריא בנייד ומוכן ל-PDF, עם RTL ויזואלי אמיתי.',false,16) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('group-summary-meeting','מפגש סיכום לטיול','הדרכה','בונה פעילות סיום קצרה, חמה ולא מביכה לקבוצה.','בנה לי מפגש סיכום של 20–30 דקות לקבוצת מטיילים שחוזרת מ[יעד]. הקבוצה: [גיל/אופי אם ידוע]. צור פעילות נעימה ולא ילדותית, שאפשר לעשות במלון/אוטובוס/ארוחה. כלול פתיחה קצרה, 2–3 שאלות שמעלות זיכרונות, פעילות אחת שגורמת למשתתפים לשתף בלי לחץ, משפט תודה של המדריכה וסיום מחבר. אם אצרף אירועים מיוחדים מהטיול, שלב אותם.',false,17) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('reply-new-lead','מענה ראשון למתעניין','הודעות ללקוחות','תשובה ראשונה קצרה ואישית למי שפנה מהאתר.','כתוב תשובת WhatsApp ראשונה למטייל שפנה לגבי [יעד/טיול]. יש לי את הפרטים הבאים: [להדביק]. המטרה היא לענות בחום, לתת את המידע שכבר ידוע, ולשאול רק שאלה אחת או שתיים שבאמת נחוצות כדי להמשיך. אל תיצור לחץ לסגור ואל תשתמש בשפה מכירתית. אם חסר מחיר או מועד, אמור זאת בפשטות. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,18) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('followup-lead','מעקב עדין אחרי מתעניין','הודעות ללקוחות','הודעת המשך לא לוחצת אחרי שפנייה נשארה פתוחה.','כתוב הודעת המשך קצרה למי שהתעניין ב[יעד/טיול] לפני [מספר ימים] ולא חזר. המטרה רק לבדוק אם עדיין רלוונטי ואם יש שאלה שאפשר לעזור בה. בלי "רק מזכירה", בלי לחץ ובלי שפה של מכירה. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,19) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('after-registration','הודעה אחרי הרשמה','הודעות ללקוחות','אישור אישי ונעים לאחר סגירת ההרשמה.','כתוב הודעת WhatsApp למטייל שנרשם לטיול [שם הטיול] בתאריכים [תאריכים]. אשר שקיבלתי את הפרטים, כתוב מה השלב הבא רק לפי המידע שאמסור: [שלב הבא], וציין שאפשר לפנות אליי אם עולה שאלה. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,20) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('supplier-message','פנייה לספק / מוזיאון / מלון','ספקים ותפעול','הודעה מקצועית וקצרה לספק בארץ או בחו״ל.','כתוב פנייה מקצועית ל[סוג הספק] בנושא [נושא]. הפרטים: [להדביק]. השפה המבוקשת: [עברית/אנגלית/איטלקית]. כתוב קצר, מנומס וישיר. כלול רק את השאלות והבקשות שנמסרו. אם צריך אישור של שעה, מחיר, מספר נוסעים או נקודת מפגש, סדר אותם בצורה שקל לספק לענות עליה. בלי ניסוח מנופח ובלי פרטים שלא נמסרו.',false,21) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('schedule-change','עדכון שינוי לקבוצה','הודעות ללקוחות','שינוי שעה או מסלול בלי ליצור לחץ מיותר.','כתוב הודעה לקבוצת מטיילים על שינוי ב[שעה/מסלול/נקודת מפגש]. מה השתנה: [להדביק]. מה נשאר ללא שינוי: [להדביק]. מה כל אחד צריך לעשות עכשיו: [להדביק]. הניסוח צריך להיות רגוע וברור, בלי דרמה ובלי הסברים ארוכים. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,22) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('important-reminder','תזכורת חשובה לקבוצה','הודעות ללקוחות','תזכורת קצרה לשעה, דרכון, לבוש או ציוד.','כתוב תזכורת קצרה לקבוצה לקראת [מחר/הערב/היציאה]. הפרטים שחייבים להופיע: [להדביק]. סדר לפי חשיבות. אל תוסיף שום דבר שאינו נדרש. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,23) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('review-curation','עריכת ביקורת לפרסום','ביקורות','מקצר ביקורת אמיתית בלי לשנות את הקול של המטייל.','אני מצרפת ביקורת אמיתית של מטייל. הכן ממנה שתי גרסאות: 1. גרסה מלאה נקייה לקריאה באתר, עם תיקוני פיסוק בלבד; 2. ציטוט קצר של עד 35 מילים לכרטיס בדף הבית. אסור לשנות משמעות, להמציא מחמאות או להפוך את הטקסט ליותר שיווקי. אם קיצור דורש השמטה, שמור על המשפטים המקוריים וסמן שהגרסה היא קיצור.',false,24) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('faq-from-route','שאלות נפוצות מתוך מסלול','שיווק ותוכן','מייצר FAQ רק מהמידע הקיים במסלול.','אני מצרפת מסלול ופרטי טיול. צור 6–8 שאלות נפוצות שבאמת סביר שמטייל ישאל, ותשובות קצרות שמבוססות רק על החומר. נושאים אפשריים: קצב, כשרות, שבת, מלון, מזג אוויר, הליכה, כסף, מזוודות, שעות וטיסות, רק אם המידע קיים. כאשר פרט חסר כתוב "יש לבדוק מול חנה" במקום לנחש.',false,25) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('facebook-trip-post-natural','פוסט פייסבוק טבעי לטיול','שיווק ותוכן','פוסט שמרגיש כמו חנה ולא כמו מודעת AI.','כתוב פוסט פייסבוק על הטיול ל[יעד] בתאריכים [תאריכים]. חומר המקור: [להדביק]. כתוב כאילו חנה עצמה משתפת על הטיול: פתיחה אישית קצרה, 3–5 דברים שהופכים את המסלול למעניין, מידע פרקטי שנמסר, וסיום שמזמין לפנות בפרטי או ב-WhatsApp. בלי רשימת תארים, בלי אימוג׳ים כברירת מחדל, בלי הבטחות מוגזמות ובלי מידע שלא קיים.',false,26) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('trip-day-explainer','הסבר קצר על יום בטיול','הדרכה','הופך יום מסלול להסבר שחנה יכולה לשלוח או לומר.','אני מצרפת את תוכנית היום. הכן שתי גרסאות: א. הסבר של דקה שאפשר לומר לקבוצה באוטובוס; ב. הודעה קצרה שאפשר לשלוח ב-WhatsApp. הדגש מה רואים, למה זה מעניין ומה חשוב לדעת תפעולית. אל תוסיף היסטוריה או עובדות שלא נמסרו. ההודעה צריכה להיות אנושית, ללא אימוג׳ים אלא אם אבקש.',false,27) on conflict(id) do nothing;

insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('chana-final-traveler-3q','חנה - מטיילת 3/4 שקוף','chana','assets/chana/final/traveler-three-quarter.webp',null,false,true,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('chana-final-traveler','חנה - מטיילת גוף מלא שקוף','chana','assets/chana/final/traveler-full.webp',null,false,true,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('chana-final-upper','חנה - חצי גוף שקוף','chana','assets/chana/final/smiling-upper.webp',null,false,true,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('chana-final-smiling','חנה - פורטרט שקוף סופי','chana','assets/chana/final/smiling-portrait.webp',null,false,true,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-1','group-1.jpg','chana','assets/chana/group-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-2','group-2.jpg','chana','assets/chana/group-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-3','group-3.jpg','chana','assets/chana/group-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-4','guiding.jpg','chana','assets/chana/guiding.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-5','montenegro-group.jpg','chana','assets/chana/montenegro-group.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-6','smiling-original.jpg','chana','assets/chana/smiling-original.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-7','smiling.jpg','chana','assets/chana/smiling.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-8','srilanka-temple.jpg','chana','assets/chana/srilanka-temple.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-9','srilanka.jpg','chana','assets/chana/srilanka.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-10','traveler.jpg','chana','assets/chana/traveler.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-11','card.jpg','destination','assets/destinations/azerbaijan/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-12','hero.jpg','destination','assets/destinations/azerbaijan/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-13','card.jpg','destination','assets/destinations/dubai/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-14','gallery-1.jpg','destination','assets/destinations/dubai/gallery-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-15','gallery-2.jpg','destination','assets/destinations/dubai/gallery-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-16','hero.jpg','destination','assets/destinations/dubai/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-17','card.jpg','destination','assets/destinations/japan/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-18','gallery-1.jpg','destination','assets/destinations/japan/gallery-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-19','gallery-2.jpg','destination','assets/destinations/japan/gallery-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-20','gallery-3.jpg','destination','assets/destinations/japan/gallery-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-21','gallery-4.jpg','destination','assets/destinations/japan/gallery-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-22','hero.jpg','destination','assets/destinations/japan/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-23','card.jpg','destination','assets/destinations/montenegro/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-24','gallery-1.jpg','destination','assets/destinations/montenegro/gallery-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-25','gallery-2.jpg','destination','assets/destinations/montenegro/gallery-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-26','gallery-3.jpg','destination','assets/destinations/montenegro/gallery-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-27','hero.jpg','destination','assets/destinations/montenegro/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-28','card.jpg','destination','assets/destinations/morocco/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-29','hero.jpg','destination','assets/destinations/morocco/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-30','card.jpg','destination','assets/destinations/north-italy/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-31','hero.jpg','destination','assets/destinations/north-italy/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-32','card.jpg','destination','assets/destinations/sri-lanka/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-33','gallery-1.jpg','destination','assets/destinations/sri-lanka/gallery-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-34','gallery-2.jpg','destination','assets/destinations/sri-lanka/gallery-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-35','gallery-3.jpg','destination','assets/destinations/sri-lanka/gallery-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-36','gallery-4.jpg','destination','assets/destinations/sri-lanka/gallery-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-37','hero.jpg','destination','assets/destinations/sri-lanka/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-38','azerbaijan-feature-1.jpg','generated','assets/generated/azerbaijan-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-39','azerbaijan-feature-2.jpg','generated','assets/generated/azerbaijan-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-40','azerbaijan-feature-3.jpg','generated','assets/generated/azerbaijan-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-41','azerbaijan-feature-4.jpg','generated','assets/generated/azerbaijan-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-42','azerbaijan-feature-5.jpg','generated','assets/generated/azerbaijan-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-43','azerbaijan-scenic.jpg','generated','assets/generated/azerbaijan-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-44','dubai-feature-1.jpg','generated','assets/generated/dubai-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-45','dubai-feature-2.jpg','generated','assets/generated/dubai-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-46','dubai-feature-3.jpg','generated','assets/generated/dubai-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-47','dubai-feature-4.jpg','generated','assets/generated/dubai-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-48','dubai-feature-5.jpg','generated','assets/generated/dubai-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-49','dubai-scenic.jpg','generated','assets/generated/dubai-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-50','home-scenic.jpg','generated','assets/generated/home-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-51','japan-feature-1.jpg','generated','assets/generated/japan-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-52','japan-feature-2.jpg','generated','assets/generated/japan-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-53','japan-feature-3.jpg','generated','assets/generated/japan-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-54','japan-feature-4.jpg','generated','assets/generated/japan-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-55','japan-feature-5.jpg','generated','assets/generated/japan-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-56','japan-scenic.jpg','generated','assets/generated/japan-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-57','montenegro-feature-1.jpg','generated','assets/generated/montenegro-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-58','montenegro-feature-2.jpg','generated','assets/generated/montenegro-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-59','montenegro-feature-3.jpg','generated','assets/generated/montenegro-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-60','montenegro-feature-4.jpg','generated','assets/generated/montenegro-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-61','montenegro-feature-5.jpg','generated','assets/generated/montenegro-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-62','montenegro-scenic.jpg','generated','assets/generated/montenegro-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-63','morocco-feature-1.jpg','generated','assets/generated/morocco-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-64','morocco-feature-2.jpg','generated','assets/generated/morocco-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-65','morocco-feature-3.jpg','generated','assets/generated/morocco-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-66','morocco-feature-4.jpg','generated','assets/generated/morocco-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-67','morocco-feature-5.jpg','generated','assets/generated/morocco-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-68','morocco-scenic.jpg','generated','assets/generated/morocco-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-69','north-italy-feature-1.jpg','generated','assets/generated/north-italy-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-70','north-italy-feature-2.jpg','generated','assets/generated/north-italy-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-71','north-italy-feature-3.jpg','generated','assets/generated/north-italy-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-72','north-italy-feature-4.jpg','generated','assets/generated/north-italy-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-73','north-italy-feature-5.jpg','generated','assets/generated/north-italy-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-74','north-italy-scenic.jpg','generated','assets/generated/north-italy-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-75','sri-lanka-feature-1.jpg','generated','assets/generated/sri-lanka-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-76','sri-lanka-feature-2.jpg','generated','assets/generated/sri-lanka-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-77','sri-lanka-feature-3.jpg','generated','assets/generated/sri-lanka-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-78','sri-lanka-feature-4.jpg','generated','assets/generated/sri-lanka-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-79','sri-lanka-feature-5.jpg','generated','assets/generated/sri-lanka-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-80','sri-lanka-scenic.jpg','generated','assets/generated/sri-lanka-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-81','home-hero.jpg','destination','assets/home-hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-82','logo-optimized.jpg','brand','assets/logo-optimized.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-83','logo.jpeg','brand','assets/logo.jpeg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-84','azerbaijan-reference.png','destination','assets/reference/azerbaijan-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-85','dubai-reference.png','destination','assets/reference/dubai-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-86','home-reference-1.png','destination','assets/reference/home-reference-1.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-87','japan-reference.png','destination','assets/reference/japan-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-88','montenegro-reference.png','destination','assets/reference/montenegro-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-89','morocco-reference.png','destination','assets/reference/morocco-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-90','north-italy-reference.png','destination','assets/reference/north-italy-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-91','sri-lanka-reference.png','destination','assets/reference/sri-lanka-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-92','tours-reference.png','destination','assets/reference/tours-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-93','logo-final.png','brand','assets/logo-final.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-94','traveler-transparent.png','chana','assets/chana/traveler-transparent.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-95','smiling-transparent.png','chana','assets/chana/smiling-transparent.png',null,false,false,'public') on conflict(id) do nothing;
