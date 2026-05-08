document.addEventListener('DOMContentLoaded', () => {
  // ───────── THEME + NAV ACTIVE ─────────
  const current = (location.pathname.split('/').pop() || 'index.html').toLowerCase();
  document.querySelectorAll('.site-header nav a').forEach(a => {
    const href = (a.getAttribute('href') || '').toLowerCase();
    if (href && current && href === current) {
      a.classList.add('active');
      a.setAttribute('aria-current', 'page');
    }
  });

  const toggleBtn = document.getElementById('theme-toggle');
  const body = document.body;
  if (localStorage.getItem('theme') === 'dark') body.classList.add('dark');
  if (toggleBtn) {
    toggleBtn.addEventListener('click', () => {
      const isDark = body.classList.toggle('dark');
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
      // re-measure open accordions after theme reflow
      setTimeout(refreshOpenHeights, 220);
    });
  }

  // ───────── LIGHTBOX ─────────
  const lightbox = document.getElementById('lightbox');
  const lbImg = document.getElementById('lightbox-img');
  document.querySelectorAll('.lab-img').forEach(img => {
    img.addEventListener('click', () => {
      if (!lightbox || !lbImg) return;
      lbImg.src = img.src;
      lightbox.style.display = 'flex';
    });
  });
  window.closeLightbox = function () {
    if (!lightbox || !lbImg) return;
    lightbox.style.display = 'none';
    lbImg.src = '';
  };

  // ───────── Smooth in-page anchor scroll ─────────
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      const id = a.getAttribute('href').slice(1);
      const el = document.getElementById(id);
      if (el) {
        e.preventDefault();
        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        history.replaceState(null, '', '#' + id);
      }
    });
  });

  // ───────── Copy-link “#” buttons ─────────
  document.querySelectorAll('.copy-link').forEach(link => {
    link.addEventListener('click', e => {
      const url = location.origin + location.pathname + link.getAttribute('href');
      navigator.clipboard.writeText(url).then(() => {
        link.textContent = '✔';
        setTimeout(() => (link.textContent = '#'), 800);
      });
    });
  });

  // ───────── Robust Accordion (single source of truth) ─────────
  const headers = document.querySelectorAll('.accordion-header');

  function getRegion(header) {
    const id = header.getAttribute('aria-controls');
    if (id) return document.getElementById(id);
    const sib = header.nextElementSibling;
    return sib && sib.classList.contains('accordion-content') ? sib : null;
  }

  function openPanel(header, region) {
    region.style.display = 'block';
    region.style.overflow = 'hidden';
    // start closed → open to measured height
    region.style.maxHeight = region.scrollHeight + 'px';
    region.style.padding = '16px';
    header.setAttribute('aria-expanded', 'true');
    header.closest('.accordion-item')?.classList.add('open');

    // after transition, allow natural height so content changes don’t clip
    const done = () => {
      region.style.maxHeight = 'none';
      region.style.overflow = 'visible';
      region.removeEventListener('transitionend', done);
    };
    region.addEventListener('transitionend', done);
  }

  function closePanel(header, region) {
    region.style.overflow = 'hidden';
    // if auto-sized, freeze current height then animate to 0
    if (region.style.maxHeight === 'none' || region.style.maxHeight === '') {
      region.style.maxHeight = region.scrollHeight + 'px';
      // force reflow
      void region.offsetHeight;
    }
    region.style.maxHeight = '0px';
    region.style.padding = '0 16px';
    header.setAttribute('aria-expanded', 'false');
    header.closest('.accordion-item')?.classList.remove('open');

    const done = () => {
      region.style.display = '';
      region.removeEventListener('transitionend', done);
    };
    region.addEventListener('transitionend', done);
  }

  function toggle(header) {
    const region = getRegion(header);
    if (!region) return;
    const expanded = header.getAttribute('aria-expanded') === 'true';
    expanded ? closePanel(header, region) : openPanel(header, region);
  }

  // init
  headers.forEach(h => {
    const region = getRegion(h);
    h.setAttribute('tabindex', '0');
    if (!h.hasAttribute('aria-expanded')) h.setAttribute('aria-expanded', 'false');
    if (region) {
      region.style.maxHeight = '0px';
      region.style.padding = '0 16px';
    }
    h.addEventListener('click', () => toggle(h));
    h.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); toggle(h); }
    });
  });

  function refreshOpenHeights() {
    document.querySelectorAll('.accordion-header[aria-expanded="true"]').forEach(h => {
      const region = getRegion(h);
      if (!region) return;
      region.style.maxHeight = 'none';
      const hgt = region.scrollHeight;
      region.style.maxHeight = hgt + 'px';
      const done = () => { region.style.maxHeight = 'none'; region.removeEventListener('transitionend', done); };
      region.addEventListener('transitionend', done);
    });
  }

  window.addEventListener('resize', refreshOpenHeights);
});
