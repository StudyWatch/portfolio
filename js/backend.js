(()=>{
'use strict';

const CACHE_KEY='chana_tours_supabase_v2';
const cfg=window.CHANA_SUPABASE_CONFIG||{};
const configured=Boolean(
  cfg.url && cfg.publishableKey &&
  !String(cfg.url).startsWith('__') &&
  !String(cfg.publishableKey).startsWith('__')
);
const client=configured&&window.supabase?.createClient
  ? window.supabase.createClient(cfg.url,cfg.publishableKey,{
      auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}
    })
  : null;

const clone=o=>JSON.parse(JSON.stringify(o));
const emptyCRM=()=>({
  travelers:[],participants:[],payments:[],bookingGroups:[],rooms:[],roomOccupants:[],
  followUps:[],tasks:[],documents:[],contactLog:[],loaded:false
});
const state={
  configured:!!client,isAdmin:false,user:null,loading:true,lastError:null,saving:false,
  crm:emptyCRM()
};
let saveTimer=null,saveResolvers=[];
let memoryData=null;

function seed(){return clone(window.CHANA_SEED||{});}
function safeCacheShape(d){
  const x=clone(d||{});
  // Personal data must not be persisted into localStorage on a shared/admin browser.
  x.leads=[];
  delete x.crm;
  return x;
}
function readDiskCache(){
  try{
    const raw=localStorage.getItem(CACHE_KEY);
    if(raw){
      const v=JSON.parse(raw);
      return {...seed(),...v,settings:{...(seed().settings||{}),...(v.settings||{})}};
    }
  }catch(e){}
  return seed();
}
function readCache(){
  if(memoryData)return clone(memoryData);
  memoryData=readDiskCache();
  return clone(memoryData);
}
function writeCache(d){
  memoryData=clone(d||seed());
  try{localStorage.setItem(CACHE_KEY,JSON.stringify(safeCacheShape(memoryData)));}
  catch(e){console.warn('Cache write failed',e);}
}
function clearPersonalMemory(){
  if(memoryData)memoryData.leads=[];
  state.crm=emptyCRM();
}

function mapAdminPayload(payload){
  const d={...seed(),...(payload||{}),settings:{...(seed().settings||{}),...((payload||{}).settings||{})}};
  const baseIds=new Set((window.CHANA_PROMPTS||[]).map(p=>p.id));
  d.promptOverrides={}; d.customPrompts=[];
  (payload?.prompts||[]).forEach(p=>{
    if(p.custom||!baseIds.has(p.id))d.customPrompts.push({...p,custom:true});
    else d.promptOverrides[p.id]={title:p.title,category:p.category,description:p.description,text:p.text};
  });
  d.assets=payload?.assets||d.assets||[];
  d.leads=payload?.leads||[];
  return d;
}
function publicMerge(payload){
  const d={...seed(),...(payload||{}),settings:{...(seed().settings||{}),...((payload||{}).settings||{})}};
  d.promptOverrides={}; d.customPrompts=[]; d.leads=[];
  return d;
}
function promptPayload(d){
  const base=(window.CHANA_PROMPTS||[]).map(p=>({...p,...((d.promptOverrides||{})[p.id]||{}),custom:false}));
  const custom=(d.customPrompts||[]).map(p=>({...p,custom:true}));
  return base.concat(custom).map(p=>({
    id:p.id,title:p.title||'',category:p.category||'',description:p.description||'',text:p.text||'',custom:!!p.custom
  }));
}
function serialize(d){
  return {
    settings:{...(d.settings||{})},
    destinations:d.destinations||[],
    tours:(d.tours||[]).map(t=>({...t,capacity:t.capacity===''?null:t.capacity})),
    reviews:d.reviews||[],prompts:promptPayload(d),
    assets:(d.assets||[]).map(a=>({
      id:a.id,name:a.name,category:a.category,src:a.src||a.dataUrl||'',storagePath:a.storagePath||null,
      uploaded:!!a.uploaded,premium:!!a.premium
    }))
  };
}

async function hydratePublic(){
  if(!client){state.loading=false;window.dispatchEvent(new CustomEvent('chana-data-ready'));return readCache();}
  try{
    const {data,error}=await client.rpc('public_site_payload');
    if(error)throw error;
    const d=publicMerge(data); writeCache(d); state.lastError=null; return d;
  }catch(e){
    state.lastError=e; console.error('Supabase public load failed',e); return readCache();
  }finally{
    state.loading=false; window.dispatchEvent(new CustomEvent('chana-data-ready'));
  }
}
async function checkAdmin(){
  if(!client)return false;
  const {data:{session}}=await client.auth.getSession();
  state.user=session?.user||null;
  if(!session){state.isAdmin=false;return false;}
  const {data,error}=await client.rpc('is_admin');
  if(error||data!==true){state.isAdmin=false;return false;}
  state.isAdmin=true; return true;
}
async function hydrateAdmin(){
  if(!client)throw new Error('Supabase is not configured');
  if(!await checkAdmin())throw new Error('NOT_ADMIN');
  const {data,error}=await client.rpc('admin_site_payload');
  if(error)throw error;
  const d=mapAdminPayload(data); writeCache(d);
  await loadCRM();
  window.dispatchEvent(new CustomEvent('chana-admin-ready'));
  return d;
}
async function signIn(email,password){
  if(!client)throw new Error('Supabase is not configured');
  const {data,error}=await client.auth.signInWithPassword({email:String(email||'').trim(),password:String(password||'')});
  if(error)throw error;
  state.user=data.user||null;
  if(!await checkAdmin()){await client.auth.signOut();throw new Error('NOT_ADMIN');}
  await hydrateAdmin(); return true;
}
async function sendMagicLink(email){
  if(!client)throw new Error('Supabase is not configured');
  const redirectTo=location.origin+location.pathname+'#admin';
  const {error}=await client.auth.signInWithOtp({
    email:String(email||'').trim(),options:{emailRedirectTo:redirectTo,shouldCreateUser:false}
  });
  if(error)throw error; return true;
}
async function signOut(){
  if(client)await client.auth.signOut();
  state.user=null; state.isAdmin=false; clearPersonalMemory();
  try{localStorage.removeItem(CACHE_KEY);}catch(e){}
  await hydratePublic();
}
async function saveNow(d){
  if(!client||!state.isAdmin)return false;
  state.saving=true;
  try{
    const {error}=await client.rpc('replace_site_content',{payload:serialize(d)});
    if(error)throw error; state.lastError=null; return true;
  }finally{state.saving=false;}
}
function queueSave(d){
  writeCache(d);
  if(!client||!state.isAdmin)return Promise.resolve(false);
  return new Promise((resolve,reject)=>{
    saveResolvers.push({resolve,reject}); clearTimeout(saveTimer);
    saveTimer=setTimeout(async()=>{
      const pending=saveResolvers.splice(0);
      try{
        const ok=await saveNow(readCache()); pending.forEach(x=>x.resolve(ok));
      }catch(e){
        state.lastError=e; console.error('Supabase save failed',e); pending.forEach(x=>x.reject(e));
        window.dispatchEvent(new CustomEvent('chana-save-error',{detail:e}));
      }
    },350);
  });
}

async function submitInquiry(fd){
  if(!client)throw new Error('Supabase is not configured');
  const p={
    p_name:String(fd.name||'').trim(),p_phone:String(fd.phone||'').trim(),p_destination:String(fd.destination||'').trim(),
    p_message:String(fd.message||'').trim(),p_source:String(fd.source||'website'),p_website:String(fd.website||''),
    p_consent:fd.consent===true||fd.consent==='1'||fd.consent==='on',p_inquiry_type:String(fd.inquiryType||'general'),
    p_tour_id:fd.tourId?String(fd.tourId):null,p_tour_title:String(fd.tourTitle||''),p_tour_start:fd.tourStart||null,
    p_tour_end:fd.tourEnd||null,p_privacy_version:String(fd.privacyVersion||'2026-08-28'),
    p_marketing_consent:fd.marketingConsent===true||fd.marketingConsent==='1'||fd.marketingConsent==='on'
  };
  const {data,error}=await client.rpc('submit_inquiry',p); if(error)throw error; return data;
}
async function updateInquiryStatus(id,status){
  requireAdmin(); const {error}=await client.from('inquiries').update({status}).eq('id',id); if(error)throw error; return hydrateAdmin();
}
async function deleteInquiry(id){
  requireAdmin(); const {error}=await client.from('inquiries').delete().eq('id',id); if(error)throw error; return hydrateAdmin();
}
async function deleteExpiredInquiries(){
  requireAdmin(); const {data,error}=await client.rpc('delete_expired_inquiries'); if(error)throw error; await hydrateAdmin(); return Number(data||0);
}

function requireAdmin(){if(!client||!state.isAdmin)throw new Error('NOT_ADMIN');}
function snakeTraveler(x){return {full_name:String(x.fullName||'').trim(),phone:String(x.phone||'').trim(),email:String(x.email||'').trim(),city:String(x.city||'').trim(),notes:String(x.notes||'').trim(),tags:Array.isArray(x.tags)?x.tags:[],marketing_consent:!!x.marketingConsent,marketing_consent_at:x.marketingConsent?(x.marketingConsentAt||new Date().toISOString()):null,archived:!!x.archived};}
function camelTraveler(x){return {id:x.id,fullName:x.full_name,phone:x.phone,phoneNormalized:x.phone_normalized,email:x.email,city:x.city,notes:x.notes,tags:x.tags||[],marketingConsent:x.marketing_consent,marketingConsentAt:x.marketing_consent_at,archived:x.archived,createdAt:x.created_at,updatedAt:x.updated_at};}
function camelParticipant(x){return {id:x.id,tourId:x.tour_id,travelerId:x.traveler_id,sourceInquiryId:x.source_inquiry_id,bookingGroupId:x.booking_group_id,status:x.status,agreedPrice:x.agreed_price,currency:x.currency,pickupPoint:x.pickup_point,roomRequest:x.room_request,operationalNotes:x.operational_notes,registeredAt:x.registered_at,cancelledAt:x.cancelled_at,createdAt:x.created_at,updatedAt:x.updated_at};}
function camelPayment(x){return {id:x.id,participantId:x.participant_id,amount:Number(x.amount||0),currency:x.currency,paidOn:x.paid_on,method:x.method,reference:x.reference,note:x.note,createdAt:x.created_at};}
function camelGroup(x){return {id:x.id,tourId:x.tour_id,name:x.name,groupType:x.group_type,notes:x.notes};}
function camelRoom(x){return {id:x.id,tourId:x.tour_id,roomLabel:x.room_label,roomType:x.room_type,notes:x.notes};}
function camelOccupant(x){return {roomId:x.room_id,participantId:x.participant_id};}
function camelFollowUp(x){return {id:x.id,travelerId:x.traveler_id,participantId:x.participant_id,dueAt:x.due_at,kind:x.kind,note:x.note,status:x.status,completedAt:x.completed_at};}
function camelTask(x){return {id:x.id,tourId:x.tour_id,title:x.title,dueDate:x.due_date,priority:x.priority,status:x.status,notes:x.notes,completedAt:x.completed_at};}
function camelDocument(x){return {id:x.id,tourId:x.tour_id,title:x.title,category:x.category,storagePath:x.storage_path,fileName:x.file_name,mimeType:x.mime_type,fileSize:Number(x.file_size||0),createdAt:x.created_at};}
function camelContact(x){return {id:x.id,travelerId:x.traveler_id,participantId:x.participant_id,channel:x.channel,direction:x.direction,summary:x.summary,occurredAt:x.occurred_at,createdAt:x.created_at};}

async function loadCRM(){
  requireAdmin();
  // Prefer one guarded RPC for speed; keep a table fallback for migration/diagnostic compatibility.
  try{
    const {data,error}=await client.rpc('admin_crm_payload');
    if(error)throw error;
    state.crm={
      travelers:(data?.travelers||[]).map(camelTraveler),participants:(data?.participants||[]).map(camelParticipant),payments:(data?.payments||[]).map(camelPayment),
      bookingGroups:(data?.bookingGroups||[]).map(camelGroup),rooms:(data?.rooms||[]).map(camelRoom),roomOccupants:(data?.roomOccupants||[]).map(camelOccupant),
      followUps:(data?.followUps||[]).map(camelFollowUp),tasks:(data?.tasks||[]).map(camelTask),documents:(data?.documents||[]).map(camelDocument),
      contactLog:(data?.contactLog||[]).map(camelContact),loaded:true
    };
  }catch(rpcError){
    const names=['travelers','trip_participants','participant_payments','booking_groups','trip_rooms','room_occupants','follow_ups','trip_tasks','trip_documents','contact_log'];
    const results=await Promise.all(names.map(name=>client.from(name).select('*')));
    const err=results.find(x=>x.error)?.error; if(err)throw rpcError?.message?rpcError:err;
    const [travelers,participants,payments,groups,rooms,occupants,followUps,tasks,documents,contactLog]=results.map(x=>x.data||[]);
    state.crm={
      travelers:travelers.map(camelTraveler),participants:participants.map(camelParticipant),payments:payments.map(camelPayment),
      bookingGroups:groups.map(camelGroup),rooms:rooms.map(camelRoom),roomOccupants:occupants.map(camelOccupant),
      followUps:followUps.map(camelFollowUp),tasks:tasks.map(camelTask),documents:documents.map(camelDocument),contactLog:contactLog.map(camelContact),loaded:true
    };
  }
  window.dispatchEvent(new CustomEvent('chana-crm-ready'));
  return clone(state.crm);
}
async function saveTraveler(x){
  requireAdmin(); const row=snakeTraveler(x); let q;
  if(x.id)q=client.from('travelers').update(row).eq('id',x.id).select().single();
  else q=client.from('travelers').insert(row).select().single();
  const {data,error}=await q; if(error)throw error; await loadCRM(); return camelTraveler(data);
}
async function archiveTraveler(id,archived=true){
  requireAdmin(); const {error}=await client.from('travelers').update({archived}).eq('id',id); if(error)throw error; return loadCRM();
}
async function eraseTraveler(id){requireAdmin();const {data,error}=await client.rpc('erase_traveler_if_safe',{p_traveler_id:id});if(error)throw error;await loadCRM();return data===true;}
async function saveParticipant(x){
  requireAdmin();
  const row={tour_id:x.tourId,traveler_id:x.travelerId,source_inquiry_id:x.sourceInquiryId||null,booking_group_id:x.bookingGroupId||null,status:x.status||'interested',agreed_price:x.agreedPrice===''||x.agreedPrice==null?null:Number(x.agreedPrice),currency:x.currency||'ILS',pickup_point:String(x.pickupPoint||''),room_request:String(x.roomRequest||''),operational_notes:String(x.operationalNotes||''),registered_at:['registered','deposit','paid'].includes(x.status)&&!x.registeredAt?new Date().toISOString():(x.registeredAt||null),cancelled_at:x.status==='cancelled'?(x.cancelledAt||new Date().toISOString()):null};
  let q=x.id?client.from('trip_participants').update(row).eq('id',x.id).select().single():client.from('trip_participants').upsert(row,{onConflict:'tour_id,traveler_id'}).select().single();
  const {data,error}=await q; if(error)throw error; await loadCRM(); return camelParticipant(data);
}
async function addPayment(x){
  requireAdmin(); const row={participant_id:x.participantId,amount:Number(x.amount),currency:x.currency||'ILS',paid_on:x.paidOn||new Date().toISOString().slice(0,10),method:x.method||'other',reference:String(x.reference||''),note:String(x.note||'')};
  const {data,error}=await client.from('participant_payments').insert(row).select().single(); if(error)throw error; await loadCRM(); return camelPayment(data);
}
async function deletePayment(id){requireAdmin();const {error}=await client.from('participant_payments').delete().eq('id',id);if(error)throw error;return loadCRM();}
async function saveBookingGroup(x){
  requireAdmin(); const row={tour_id:x.tourId,name:String(x.name||''),group_type:x.groupType||'other',notes:String(x.notes||'')};
  const q=x.id?client.from('booking_groups').update(row).eq('id',x.id).select().single():client.from('booking_groups').insert(row).select().single();
  const {data,error}=await q;if(error)throw error;await loadCRM();return camelGroup(data);
}
async function deleteBookingGroup(id){requireAdmin();const {error}=await client.from('booking_groups').delete().eq('id',id);if(error)throw error;return loadCRM();}
async function saveRoom(x){
  requireAdmin(); const row={tour_id:x.tourId,room_label:String(x.roomLabel||'').trim(),room_type:x.roomType||'double',notes:String(x.notes||'')};
  const q=x.id?client.from('trip_rooms').update(row).eq('id',x.id).select().single():client.from('trip_rooms').insert(row).select().single();
  const {data,error}=await q;if(error)throw error;await loadCRM();return camelRoom(data);
}
async function deleteRoom(id){requireAdmin();const {error}=await client.from('trip_rooms').delete().eq('id',id);if(error)throw error;return loadCRM();}
async function assignRoom(participantId,roomId){
  requireAdmin();
  if(!roomId){const {error}=await client.from('room_occupants').delete().eq('participant_id',participantId);if(error)throw error;}
  else {const {error}=await client.from('room_occupants').upsert({participant_id:participantId,room_id:roomId},{onConflict:'participant_id'});if(error)throw error;}
  return loadCRM();
}
async function saveFollowUp(x){
  requireAdmin(); const row={traveler_id:x.travelerId||null,participant_id:x.participantId||null,due_at:x.dueAt,kind:x.kind||'follow_up',note:String(x.note||''),status:x.status||'pending',completed_at:x.status==='done'?(x.completedAt||new Date().toISOString()):null};
  const q=x.id?client.from('follow_ups').update(row).eq('id',x.id).select().single():client.from('follow_ups').insert(row).select().single();
  const {data,error}=await q;if(error)throw error;await loadCRM();return camelFollowUp(data);
}
async function completeFollowUp(id){requireAdmin();const {error}=await client.rpc('complete_follow_up',{p_id:id});if(error)throw error;return loadCRM();}
async function deleteFollowUp(id){requireAdmin();const {error}=await client.from('follow_ups').delete().eq('id',id);if(error)throw error;return loadCRM();}
async function saveTask(x){
  requireAdmin(); const row={tour_id:x.tourId,title:String(x.title||''),due_date:x.dueDate||null,priority:x.priority||'normal',status:x.status||'open',notes:String(x.notes||''),completed_at:x.status==='done'?(x.completedAt||new Date().toISOString()):null};
  const q=x.id?client.from('trip_tasks').update(row).eq('id',x.id).select().single():client.from('trip_tasks').insert(row).select().single();
  const {data,error}=await q;if(error)throw error;await loadCRM();return camelTask(data);
}
async function deleteTask(id){requireAdmin();const {error}=await client.from('trip_tasks').delete().eq('id',id);if(error)throw error;return loadCRM();}
async function convertInquiry(inquiryId,tourId=null){
  requireAdmin(); const {data,error}=await client.rpc('convert_inquiry_to_participant',{p_inquiry_id:inquiryId,p_tour_id:tourId||null}); if(error)throw error; await hydrateAdmin(); return data;
}

async function logContact(x){
  requireAdmin();
  const row={traveler_id:x.travelerId,participant_id:x.participantId||null,channel:x.channel||'note',direction:x.direction||'outbound',summary:String(x.summary||'').trim().slice(0,1000),occurred_at:x.occurredAt||new Date().toISOString()};
  const {data,error}=await client.from('contact_log').insert(row).select().single(); if(error)throw error;
  await loadCRM(); return camelContact(data);
}
async function deleteContact(id){requireAdmin();const {error}=await client.from('contact_log').delete().eq('id',id);if(error)throw error;return loadCRM();}
async function cleanupOldOperationalHistory(before=null){
  requireAdmin(); const args={}; if(before)args.p_before=before;
  const {data,error}=await client.rpc('cleanup_old_operational_history',args); if(error)throw error; await loadCRM(); return data||{};
}

function safeExt(file){const n=String(file?.name||'').toLowerCase();const ext=n.includes('.')?n.split('.').pop():'jpg';return ['jpg','jpeg','png','webp','avif','gif'].includes(ext)?ext:'jpg';}
async function uploadAsset(file,meta={}){
  requireAdmin(); if(!file||!file.type?.startsWith('image/'))throw new Error('INVALID_FILE'); if(file.size>10*1024*1024)throw new Error('FILE_TOO_LARGE');
  const id='asset-'+crypto.randomUUID(); const path=`uploads/${new Date().toISOString().slice(0,10)}/${crypto.randomUUID()}.${safeExt(file)}`;
  const {error:upErr}=await client.storage.from('site-media').upload(path,file,{cacheControl:'31536000',upsert:false,contentType:file.type}); if(upErr)throw upErr;
  const {data:urlData}=client.storage.from('site-media').getPublicUrl(path);
  const asset={id,name:String(meta.name||file.name),category:String(meta.category||'destination'),src:urlData.publicUrl,storagePath:path,uploaded:true,premium:false};
  const {error}=await client.from('media_assets').insert({id:asset.id,name:asset.name,category:asset.category,src:asset.src,storage_path:path,uploaded:true,premium:false,visibility:'public'});
  if(error){await client.storage.from('site-media').remove([path]);throw error;} return asset;
}
async function deleteAsset(asset){
  requireAdmin(); if(asset?.storagePath){const {error}=await client.storage.from('site-media').remove([asset.storagePath]);if(error)throw error;}
  const {error}=await client.from('media_assets').delete().eq('id',asset.id);if(error)throw error;return true;
}
function documentExt(file){const n=String(file?.name||'file').toLowerCase();const ext=n.includes('.')?n.split('.').pop():'bin';return ext.replace(/[^a-z0-9]/g,'').slice(0,8)||'bin';}
async function uploadDocument(file,meta={}){
  requireAdmin(); if(!file||!meta.tourId)throw new Error('INVALID_DOCUMENT'); if(file.size>25*1024*1024)throw new Error('FILE_TOO_LARGE');
  const path=`tours/${String(meta.tourId).replace(/[^a-zA-Z0-9_-]/g,'_')}/${new Date().toISOString().slice(0,10)}/${crypto.randomUUID()}.${documentExt(file)}`;
  const {error:upErr}=await client.storage.from('admin-documents').upload(path,file,{upsert:false,contentType:file.type||'application/octet-stream'});if(upErr)throw upErr;
  const row={tour_id:meta.tourId,title:String(meta.title||file.name),category:String(meta.category||'other'),storage_path:path,file_name:file.name,mime_type:file.type||'',file_size:file.size};
  const {data,error}=await client.from('trip_documents').insert(row).select().single();
  if(error){await client.storage.from('admin-documents').remove([path]);throw error;}await loadCRM();return camelDocument(data);
}
async function openDocument(doc){requireAdmin();const {data,error}=await client.storage.from('admin-documents').createSignedUrl(doc.storagePath,300);if(error)throw error;window.open(data.signedUrl,'_blank','noopener');}
async function deleteDocument(doc){requireAdmin();const {error:e1}=await client.storage.from('admin-documents').remove([doc.storagePath]);if(e1)throw e1;const {error}=await client.from('trip_documents').delete().eq('id',doc.id);if(error)throw error;return loadCRM();}

async function bootstrap(){
  if(!client){state.loading=false;window.dispatchEvent(new CustomEvent('chana-data-ready'));return;}
  client.auth.onAuthStateChange(async(event,session)=>{
    state.user=session?.user||null;
    if(event==='SIGNED_OUT'){state.isAdmin=false;clearPersonalMemory();return;}
    if(session){try{if(await checkAdmin())await hydrateAdmin();}catch(e){console.warn(e);}}
  });
  await hydratePublic();
  try{if(await checkAdmin())await hydrateAdmin();}catch(e){console.warn('Admin hydration skipped',e);}
}

window.ChanaBackend={
  client,state,CACHE_KEY,getCachedData:readCache,setCachedData:writeCache,hydratePublic,hydrateAdmin,checkAdmin,
  signIn,sendMagicLink,signOut,queueSave,saveNow,submitInquiry,updateInquiryStatus,deleteInquiry,deleteExpiredInquiries,
  loadCRM,saveTraveler,archiveTraveler,eraseTraveler,saveParticipant,addPayment,deletePayment,saveBookingGroup,deleteBookingGroup,saveRoom,deleteRoom,assignRoom,
  saveFollowUp,completeFollowUp,deleteFollowUp,saveTask,deleteTask,convertInquiry,logContact,deleteContact,cleanupOldOperationalHistory,
  uploadAsset,deleteAsset,uploadDocument,openDocument,deleteDocument,configured:()=>!!client
};
bootstrap();
})();
