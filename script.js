document.addEventListener('DOMContentLoaded', () => {
  /* THEME */
  const body = document.body;
  const toggleBtn = document.getElementById('theme-toggle');
  function applyTheme(){
    body.classList.toggle('dark', localStorage.getItem('theme') === 'dark');
  }
  applyTheme();
  if (toggleBtn) {
    toggleBtn.addEventListener('click', () => {
      const nowDark = !body.classList.contains('dark');
      localStorage.setItem('theme', nowDark ? 'dark' : 'light');
      applyTheme();
    });
  }
  window.addEventListener('storage', (e)=>{ if (e.key === 'theme') applyTheme(); });

  /* NAV HIGHLIGHT */
  const here = (location.pathname.split('/').pop() || 'index.html').toLowerCase();
  document.querySelectorAll('.site-nav a').forEach(a => {
    const file = (a.getAttribute('href') || '').split('/').pop().toLowerCase();
    if (file === here) a.setAttribute('aria-current', 'page');
  });

  /* LIGHTBOX for .lab-img */
  const lightbox = document.getElementById('lightbox');
  const lbImg = document.getElementById('lightbox-img');
  if (lightbox && lbImg){
    document.querySelectorAll('img.lab-img').forEach(img => {
      img.addEventListener('click', ()=>{
        lbImg.src = img.src;
        lightbox.style.display = 'flex';
      });
    });
    window.closeLightbox = function(){ lbImg.src = ''; lightbox.style.display = 'none'; };
    lightbox.addEventListener('click', closeLightbox);
  }

  /* ACCORDION (if present; keeps your projects.html working) */
  const headers = document.querySelectorAll('.accordion-header');
  function getRegion(h){ const sib=h?.nextElementSibling; return (sib && sib.classList.contains('accordion-content'))? sib : null; }
  function toggle(h){
    const region=getRegion(h); if(!region) return;
    const open=h.getAttribute('aria-expanded')==='true';
    document.querySelectorAll('.accordion-item').forEach(it=>{
      const hd=it.querySelector('.accordion-header'); const rg=getRegion(hd);
      if(hd!==h){ hd?.setAttribute('aria-expanded','false'); it.classList.remove('open'); if(rg){rg.style.maxHeight=null; rg.style.padding='0 16px';} }
    });
    h.setAttribute('aria-expanded', String(!open));
    h.closest('.accordion-item')?.classList.toggle('open', !open);
    if(!open){ region.style.maxHeight = region.scrollHeight+'px'; region.style.padding='16px'; }
    else{ region.style.maxHeight=null; region.style.padding='0 16px'; }
  }
  headers.forEach(h=>{ h.setAttribute('tabindex','0'); h.addEventListener('click',()=>toggle(h));
    h.addEventListener('keydown',e=>{ if(e.key==='Enter'||e.key===' '){e.preventDefault();toggle(h);} });
  });
});
