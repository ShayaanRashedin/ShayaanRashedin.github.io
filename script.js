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

// --- Keep accordion heights correct on resize/content changes ---
(function () {
  const headers = document.querySelectorAll('.accordion-header');

  function refreshOpenHeights() {
    headers.forEach(h => {
      const expanded = h.getAttribute('aria-expanded') === 'true';
      if (!expanded) return;
      const regionId = h.getAttribute('aria-controls');
      const region = regionId ? document.getElementById(regionId) : (h.nextElementSibling?.classList.contains('accordion-content') ? h.nextElementSibling : null);
      if (!region) return;
      // Force recalc of maxHeight to fit full content
      region.style.maxHeight = region.scrollHeight + 'px';
    });
  }

  // Re-measure when window resizes (fonts wrap differently)
  window.addEventListener('resize', refreshOpenHeights);

  // Optional: when fonts finish loading or theme toggles
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(refreshOpenHeights);
  }
  const themeBtn = document.getElementById('theme-toggle');
  if (themeBtn) themeBtn.addEventListener('click', () => setTimeout(refreshOpenHeights, 200));
})();

