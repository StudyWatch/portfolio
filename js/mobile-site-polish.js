(()=>{
'use strict';
const MOBILE=820;
const $=(q,r=document)=>r.querySelector(q);
const esc=s=>String(s??'').replace(/[&<>'"]/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[m]));
let scheduled=false;
function settings(){try{return window.ChanaBackend?.getCachedData?.()?.settings||window.CHANA_SEED?.settings||{}}catch{return window.CHANA_SEED?.settings||{}}}
function polishAboutHero(){
  if(innerWidth>MOBILE||location.hash!=='#about')return;
  const picture=$('.about-hero picture.media-picture');
  if(!picture||picture.dataset.realMobile==='1')return;
  const sources=[...picture.querySelectorAll('source')];
  sources.forEach((source,i)=>{source.srcset=i===0?'assets/chana/real/about-real-fuji-portrait.webp':'assets/chana/real/about-real-fuji-portrait.jpg'});
  const img=picture.querySelector('img.hero-bg');
  if(img){img.src='assets/chana/real/about-real-fuji-portrait.jpg';img.alt='חנה בטיול ביפן מול הר פוג׳י'}
  picture.dataset.realMobile='1';
}
function polishFooter(){
  const text=String(settings().intro||'').trim();
  const target=$('.footer-brand small');
  if(target&&text)target.textContent=text;
}
function polishAdminSettings(){
  if(location.hash!=='#admin')return;
  const form=$('#settingsForm');
  if(!form)return;
  const s=settings();
  if(!form.querySelector('[name="intro"]')){
    const contactHead=[...form.querySelectorAll('.settings-subhead')].find(x=>x.textContent.includes('פרטי קשר'));
    const wrap=document.createElement('div');
    wrap.className='field full';
    wrap.innerHTML=`<label>טקסט קצר בפוטר</label><textarea name="intro" rows="2" placeholder="למשל: טיולים מאורגנים לשומרי מסורת, עם ליווי אישי והדרכה מקצועית.">${esc(s.intro||'')}</textarea><small>מופיע מתחת ללוגו בתחתית האתר.</small>`;
    if(contactHead)form.insertBefore(wrap,contactHead); else form.appendChild(wrap);
  }
  if(!form.querySelector('.settings-control-note')){
    const btn=form.querySelector('button.btn-gold.full');
    const note=document.createElement('div');
    note.className='notice full settings-control-note';
    note.innerHTML='<strong>המלצות:</strong> לכל המלצה כבר ניתן לבחור יעד מסוים או “כל היעדים / כללי” במסך ההמלצות.';
    if(btn)form.insertBefore(note,btn);
  }
  const head=$('.panel-head');
  if(head&&!head.querySelector('.settings-preview-actions')){
    const actions=document.createElement('div');
    actions.className='settings-preview-actions';
    actions.innerHTML='<a class="btn btn-outline btn-small" href="#home">תצוגת דף הבית</a><a class="btn btn-outline btn-small" href="#about">תצוגת אודות</a>';
    head.appendChild(actions);
  }
}
function polish(){polishAboutHero();polishFooter();polishAdminSettings()}
function schedule(){if(scheduled)return;scheduled=true;requestAnimationFrame(()=>{scheduled=false;polish()})}
window.addEventListener('hashchange',()=>setTimeout(schedule,0));
window.addEventListener('resize',schedule,{passive:true});
window.addEventListener('chana-data-ready',schedule);
document.addEventListener('DOMContentLoaded',schedule);
const root=document.getElementById('app');
if(root)new MutationObserver(schedule).observe(root,{childList:true,subtree:true});
setTimeout(schedule,0);
})();
