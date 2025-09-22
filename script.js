document.addEventListener('DOMContentLoaded', () => {
  // THEME
  // Auto-set active nav link by URL
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
    });
  }

  // ───────── Accordion (compatible with simple <div> markup) ─────────
  const headers = document.querySelectorAll('.accordion-header');

  function getRegion(header) {
    // If aria-controls exists, prefer it
    const id = header.getAttribute && header.getAttribute('aria-controls');
    if (id) {
      const el = document.getElementById(id);
      if (el) return el;
    }
    // Fallback: next sibling with .accordion-content
    const sib = header.nextElementSibling;
    if (sib && sib.classList.contains('accordion-content')) return sib;
    return null;
  }

  function closeAll(except) {
    document.querySelectorAll('.accordion-header').forEach(btn => {
      if (btn === except) return;
      const region = getRegion(btn);
      btn.setAttribute && btn.setAttribute('aria-expanded', 'false');
      btn.closest('.accordion-item')?.classList.remove('open');
      if (region) {
        region.style.maxHeight = null;
        region.style.padding = '0 16px';
      }
    });
  }

  function toggle(header) {
    const expanded = header.getAttribute && header.getAttribute('aria-expanded') === 'true';
    const region = getRegion(header);
    closeAll(header);
    header.setAttribute && header.setAttribute('aria-expanded', String(!expanded));
    header.closest('.accordion-item')?.classList.toggle('open', !expanded);
    if (region) {
      if (!expanded) {
        region.style.maxHeight = region.scrollHeight + 'px';
        region.style.padding = '16px';
      } else {
        region.style.maxHeight = null;
        region.style.padding = '0 16px';
      }
    }
  }

  headers.forEach(h => {
    // Make <div> headers keyboard accessible
    h.setAttribute && h.setAttribute('tabindex', '0');
    h.addEventListener('click', () => toggle(h));
    h.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); toggle(h); }
    });
  });

  // ───────── Smooth in-page anchor scroll (safe if not present) ─────────
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

  // ───────── Copy-link “#” buttons (safe if not present) ─────────
  document.querySelectorAll('.copy-link').forEach(link => {
    link.addEventListener('click', e => {
      const url = location.origin + location.pathname + link.getAttribute('href');
      navigator.clipboard.writeText(url).then(() => {
        link.textContent = '✔';
        setTimeout(() => (link.textContent = '#'), 800);
      });
    });
  });

  // ───────── Lightbox for Home Lab images (safe if not present) ─────────
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
});

// ───────── Robust Accordion ─────────
(function () {
  const headers = document.querySelectorAll('.accordion-header');

  function getRegion(header) {
    const id = header.getAttribute('aria-controls');
    if (id) return document.getElementById(id);
    const sib = header.nextElementSibling;
    return sib && sib.classList.contains('accordion-content') ? sib : null;
  }

  function openPanel(header, region) {
    // Start from current content height
    region.style.display = 'block';
    region.style.overflow = 'hidden';
    region.style.maxHeight = region.scrollHeight + 'px';
    region.style.padding = '16px';

    header.setAttribute('aria-expanded', 'true');
    header.closest('.accordion-item')?.classList.add('open');

    // After the expand transition, let the panel size itself (prevents clipping on 2nd open)
    const done = () => {
      region.style.maxHeight = 'none';
      region.style.overflow = 'visible';
      region.removeEventListener('transitionend', done);
    };
    region.addEventListener('transitionend', done);
  }

  function closePanel(header, region) {
    // If currently auto-sized, lock to pixel height first
    region.style.overflow = 'hidden';
    const h = region.scrollHeight;
    region.style.maxHeight = h + 'px';
    // force reflow so the browser registers the height before collapsing
    // eslint-disable-next-line no-unused-expressions
    region.offsetHeight;
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

  headers.forEach(h => {
    // initial state
    const region = getRegion(h);
    h.setAttribute('tabindex', '0');
    h.setAttribute('aria-expanded', h.getAttribute('aria-expanded') || 'false');
    if (region) {
      region.style.maxHeight = '0px';
      region.style.padding = '0 16px';
    }
    h.addEventListener('click', () => toggle(h));
    h.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); toggle(h); }
    });
  });

  // Re-measure open panels on resize/theme change so nothing clips
  function refreshOpenHeights() {
    document.querySelectorAll('.accordion-header[aria-expanded="true"]').forEach(h => {
      const region = getRegion(h);
      if (!region) return;
      // temporarily set to 'auto' to get true height, then freeze again
      region.style.maxHeight = 'none';
      const hgt = region.scrollHeight;
      region.style.maxHeight = hgt + 'px';
      // let it stay auto-sized after transition
      const done = () => { region.style.maxHeight = 'none'; region.removeEventListener('transitionend', done); };
      region.addEventListener('transitionend', done);
    });
  }
  window.addEventListener('resize', refreshOpenHeights);
  const themeBtn = document.getElementById('theme-toggle');
  if (themeBtn) themeBtn.addEventListener('click', () => setTimeout(refreshOpenHeights, 220));
})();

