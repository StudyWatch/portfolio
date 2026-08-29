import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const ctx={window:{}}; vm.createContext(ctx);
vm.runInContext(fs.readFileSync(path.join(root,'js/data.js'),'utf8'),ctx);
vm.runInContext(fs.readFileSync(path.join(root,'js/prompts.js'),'utf8'),ctx);
const d=ctx.window.CHANA_SEED,p=ctx.window.CHANA_PROMPTS;
const cfgCtx={window:{}}; vm.createContext(cfgCtx);
vm.runInContext(fs.readFileSync(path.join(root,'js/supabase-config.js'),'utf8'),cfgCtx);
const liveCfg=cfgCtx.window.CHANA_SUPABASE_CONFIG||{};
const errors=[]; const ok=(c,m)=>{if(!c)errors.push(m)};
ok(liveCfg.url==='https://rxapuzqnatmcapgacpfb.supabase.co',`wrong live Supabase URL: ${liveCfg.url||'(missing)'}`);
ok(/^sb_publishable_[A-Za-z0-9_-]+$/.test(liveCfg.publishableKey||''),'live Publishable Key missing/invalid');
ok(!String(liveCfg.publishableKey||'').includes('YOUR_KEY'),'live Publishable Key is still a placeholder');
ok(d.destinations.length===7,`expected 7 destinations, got ${d.destinations.length}`);
ok(d.tours.length===17,`expected 17 research tours, got ${d.tours.length}`);
ok(d.tours.every(t=>t.sourceOnly===true&&t.published===false),'supplier research must be private by default');
ok(d.reviews.length===13,`expected 13 reviews, got ${d.reviews.length}`);
ok(p.length===28,`expected 28 prompts, got ${p.length}`);
const refs=new Set();
for(const x of d.destinations){[x.hero,x.card,x.chanaPhoto,...(x.gallery||[])].forEach(v=>v&&refs.add(v));}
for(const a of d.assets||[]){const v=a.src||a.dataUrl;if(v)refs.add(v)}
for(const r of refs){if(/^https?:|^data:/.test(r))continue;ok(fs.existsSync(path.join(root,r)),`missing asset: ${r}`)}
for(const f of ['js/data.js','js/prompts.js','js/backend.js','js/crm-ui.js','js/xlsx-lite.js','js/app.js','js/supabase-config.js','index.html']){
 const txt=fs.readFileSync(path.join(root,f),'utf8');
 ok(!/sb_secret_[A-Za-z0-9_-]{10,}/.test(txt),`${f} contains a secret-key candidate`);
 ok(!/SUPABASE_SERVICE_ROLE_KEY\s*=/.test(txt),`${f} contains a service-role assignment`);
 ok(!/adminPassword|חנה13/.test(txt),`${f} contains legacy frontend admin password`);
}
const app=fs.readFileSync(path.join(root,'js/app.js'),'utf8');
for(const token of ['name="consent"','name="website"','name="marketingConsent"','renderAccessibility()','renderTerms()','data-action="tour-interest"','name="tourId"','PRIVACY_VERSION','data-crm-action','case\'operations\'','case\'travelers\'']) ok(app.includes(token),`app token missing: ${token}`);
ok(app.includes("!t.archived"),'archived tours are not filtered from public views');
const index=fs.readFileSync(path.join(root,'index.html'),'utf8');
ok(index.includes('js/xlsx-lite.js')&&index.includes('js/crm-ui.js'),'CRM/XLSX scripts not loaded');
const backend=fs.readFileSync(path.join(root,'js/backend.js'),'utf8');
for(const token of ['safeCacheShape','x.leads=[]','loadCRM','convertInquiry','admin-documents','eraseTraveler']) ok(backend.includes(token),`backend token missing: ${token}`);
const crm=fs.readFileSync(path.join(root,'js/crm-ui.js'),'utf8');
for(const token of ['מאגר המטיילים','ניהול טיול','export-crm-backup','export-crm-json','cleanup-old-history','Rooming List','מעקבים','מסמכי הטיול','traveler-profile','היסטוריית קשר','crmContactForm']) ok(crm.includes(token),`CRM feature missing: ${token}`);
ok(backend.includes("from('participant_payments')")||backend.includes("'participant_payments'"),'backend payment ledger missing');
const migrations=['202608280001_initial_schema.sql','202608280002_seed_content.sql','202608280003_leads_privacy_accessibility.sql','202608280004_crm_operations.sql','202608280005_crm_hardening.sql','202608280006_post_deploy_advisor_hardening.sql','202608280007_fix_crm_audit_trigger.sql','202608280008_minimize_rpc_surface.sql','202608290009_contact_details.sql'];
const sql=fs.readFileSync(path.join(root,'supabase/migrations',migrations[0]),'utf8');
for(const table of ['admin_profiles','site_settings','destinations','tours','reviews','prompts','media_assets','inquiries','audit_log']) ok(sql.includes(`alter table public.${table} enable row level security`),`RLS missing for ${table}`);
for(const token of ['public_site_payload()','admin_site_payload()','submit_inquiry(','replace_site_content(payload jsonb)']) ok(sql.includes(token),`base SQL missing: ${token}`);
const sql3=fs.readFileSync(path.join(root,'supabase/migrations',migrations[2]),'utf8');
for(const field of ['inquiry_type','tour_id','tour_title','privacy_version','marketing_consent','retention_until']) ok(sql3.includes(field),`lead field missing from migration 003: ${field}`);
const sql4=fs.readFileSync(path.join(root,'supabase/migrations',migrations[3]),'utf8');
for(const table of ['travelers','booking_groups','trip_participants','participant_payments','trip_rooms','room_occupants','follow_ups','trip_tasks','trip_documents']){
 ok(sql4.includes(`create table if not exists public.${table}`),`CRM table missing: ${table}`);
 ok(sql4.includes(`alter table public.${table} enable row level security`),`CRM RLS missing: ${table}`);
}
for(const token of ['convert_inquiry_to_participant','validate_payment_currency','erase_traveler_if_safe','admin-documents','archived=true,published=false']) ok(sql4.includes(token),`CRM SQL control missing: ${token}`);
ok(!sql4.includes('service_role'),'CRM migration should not depend on a frontend service-role secret');
const sql5=fs.readFileSync(path.join(root,'supabase/migrations',migrations[4]),'utf8');
for(const token of ['create table if not exists public.contact_log','admin_crm_payload','validate_room_occupant_tour','validate_participant_group_tour','validate_followup_identity','cleanup_old_operational_history']) ok(sql5.includes(token),`CRM hardening missing: ${token}`);
ok(sql5.includes('alter table public.contact_log enable row level security'),'RLS missing for contact_log');
const sql6=fs.readFileSync(path.join(root,'supabase/migrations',migrations[5]),'utf8');
for(const token of ['revoke all on function public.audit_crm_change()','followups_traveler_idx','participants_booking_group_idx','drop index if exists public.inquiries_status_created_at_idx']) ok(sql6.includes(token),`advisor hardening missing: ${token}`);
const sql7=fs.readFileSync(path.join(root,'supabase/migrations',migrations[6]),'utf8');
for(const token of ["if tg_table_name='trip_participants' then","elsif tg_table_name='participant_payments' then","revoke all on function public.audit_crm_change()"] ) ok(sql7.includes(token),`CRM audit fix missing: ${token}`);
const sql8=fs.readFileSync(path.join(root,'supabase/migrations',migrations[7]),'utf8');
const sql9=fs.readFileSync(path.join(root,'supabase/migrations',migrations[8]),'utf8');
for(const token of ['revoke all on function public.set_updated_at()','revoke all on function public.validate_payment_currency()','grant execute on function public.normalize_phone(text) to authenticated']) ok(sql8.includes(token),`RPC surface hardening missing: ${token}`);
for(const token of ['050-631-6950','972506316950','Chamel71@gmail.com']) ok(sql9.includes(token),`contact migration missing: ${token}`);
ok(d.settings.phoneDisplay==='050-631-6950','fallback contact phone mismatch');
ok(d.settings.whatsapp==='972506316950','fallback WhatsApp mismatch');
ok((d.settings.email||'').toLowerCase()==='chamel71@gmail.com','fallback contact email mismatch');
for(const m of migrations) ok(fs.existsSync(path.join(root,'supabase/migrations',m)),`migration file missing: ${m}`);
const allMigrations=fs.readFileSync(path.join(root,'supabase/ALL_MIGRATIONS.sql'),'utf8');
for(const m of migrations){const stem=m.replace('.sql','');ok(allMigrations.includes(stem),`ALL_MIGRATIONS missing section: ${stem}`)}
const liveDoc=fs.readFileSync(path.join(root,'LIVE_CONNECTION.md'),'utf8');
ok(liveDoc.includes('rxapuzqnatmcapgacpfb')&&liveDoc.includes('sb_publishable_'),'LIVE_CONNECTION.md is not synchronized with live config');
for(const legal of ['privacy.html','accessibility.html','terms.html','LEGAL_PRIVACY_ACCESSIBILITY.md']) ok(fs.existsSync(path.join(root,legal)),`legal artifact missing: ${legal}`);
for(const artifact of ['favicon-32.png','apple-touch-icon.png','icon-192.png','icon-512.png','site.webmanifest','robots.txt','supabase/ALL_MIGRATIONS.sql','supabase/POST_DEPLOY_VERIFY.sql','supabase/LIVE_SETUP_CHECKLIST.md']) ok(fs.existsSync(path.join(root,artifact)),`launch artifact missing: ${artifact}`);
ok(index.includes('site.webmanifest')&&index.includes('favicon-32.png'),'favicon/manifest not linked from index');
ok(crm.includes('function exportCRMJson')&&crm.includes('Chana-Tours-CRM-Backup-'),'CRM JSON backup missing');
const styles=fs.readFileSync(path.join(root,'styles.css'),'utf8');
for(const token of ['.contact-timeline','.profile-section-head','.backup-note']) ok(styles.includes(token),`CRM polish style missing: ${token}`);
for(const token of ['data-action="admin-more"','toggle-prompt-favorite','publishResearchForm','resetConfirmForm','importConfirmForm','optimizeImageForUpload','launch-readiness','data-prompt-mode']) ok(app.includes(token),`final admin UX missing: ${token}`);
for(const asset of ['assets/generated/home-chana-premium.jpg','assets/generated/home-chana-premium.webp','assets/generated/home-chana-premium-mobile.webp']) ok(fs.existsSync(path.join(root,asset)),`final hero asset missing: ${asset}`);
ok(index.includes('home-chana-premium.jpg'),'final homepage hero not linked from index metadata/preload');
for(const token of ['.mobile-more-grid','.prompt-star','.destination-form-preview','.danger-zone','.launch-readiness']) ok(styles.includes(token),`final admin UX style missing: ${token}`);


if(errors.length){console.error('VALIDATION FAILED');for(const e of errors)console.error('-',e);process.exit(1)}
console.log('VALIDATION OK');
console.log(JSON.stringify({destinations:d.destinations.length,researchTours:d.tours.length,reviews:d.reviews.length,prompts:p.length,assets:d.assets.length,assetRefs:refs.size,crmTables:10,migrations:9},null,2));


// FINAL_VISUAL_QUALITY_CHECKS
const imageSize = (file) => {
  const buf = fs.readFileSync(file);
  // PNG
  if (buf[0]===0x89 && buf.toString('ascii',1,4)==='PNG') return {width:buf.readUInt32BE(16),height:buf.readUInt32BE(20)};
  // WebP VP8X/VP8L is intentionally not parsed here; production JPG dimensions are authoritative.
  // JPEG SOF parser
  if (buf[0]===0xff && buf[1]===0xd8){let i=2;while(i<buf.length-9){if(buf[i]!==0xff){i++;continue}const m=buf[i+1];if([0xc0,0xc1,0xc2,0xc3,0xc5,0xc6,0xc7,0xc9,0xca,0xcb,0xcd,0xce,0xcf].includes(m))return {height:buf.readUInt16BE(i+5),width:buf.readUInt16BE(i+7)};const len=buf.readUInt16BE(i+2);if(!len)break;i+=2+len}}
  return null;
};
for(const slug of ['japan','north-italy','montenegro','morocco','azerbaijan','sri-lanka','dubai']){
  const hero=path.join(root,'assets','generated',`${slug}-scenic.jpg`);const hs=imageSize(hero);if(!hs||hs.width<1600||hs.height<760)ok(false,`Visual quality: ${slug} hero too small (${hs?.width||0}x${hs?.height||0})`);
  for(let i=1;i<=5;i++){const f=path.join(root,'assets','generated',`${slug}-feature-${i}.jpg`);const sz=imageSize(f);if(!sz||sz.width<900||sz.height<600)ok(false,`Visual quality: ${slug} feature ${i} too small (${sz?.width||0}x${sz?.height||0})`)}
}
for(const f of ['home-chana-premium.jpg','about-chana-premium.jpg','about-guiding-premium.jpg']){const p=path.join(root,'assets','generated',f);const sz=imageSize(p);if(!sz||sz.width<1400)ok(false,`Visual quality: ${f} too small (${sz?.width||0}x${sz?.height||0})`)}
if(errors.length){console.error('VISUAL QUALITY FAILED');for(const e of errors)console.error('-',e);process.exit(1)}
console.log('VISUAL_QUALITY_OK');
