document.addEventListener('DOMContentLoaded', () => {
  // THEME
  const toggleBtn = document.getElementById('theme-toggle');
  const body = document.body;
  if (localStorage.getItem('theme') === 'dark') {
    body.classList.add('dark');
  }
  if (toggleBtn) {
    toggleBtn.addEventListener('click', () => {
      const isDark = body.classList.toggle('dark');
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
    });
  }

  // ACCESSIBLE ACCORDION
  const accordionButtons = document.querySelectorAll('.accordion-header');
  accordionButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const expanded = btn.getAttribute('aria-expanded') === 'true';
      // Close any open items for a cleaner experience
      document.querySelectorAll('.accordion-header[aria-expanded="true"]').forEach(openBtn => {
        if (openBtn !== btn) {
          openBtn.setAttribute('aria-expanded', 'false');
          const regionId = openBtn.getAttribute('aria-controls');
          const region = document.getElementById(regionId);
          if (region) region.style.maxHeight = null;
          openBtn.closest('.accordion-item')?.classList.remove('open');
        }
      });
      btn.setAttribute('aria-expanded', String(!expanded));
      const region = document.getElementById(btn.getAttribute('aria-controls'));
      const item = btn.closest('.accordion-item');
      if (item) item.classList.toggle('open', !expanded);
      if (region) {
        if (!expanded) {
          region.style.maxHeight = region.scrollHeight + 'px';
        } else {
          region.style.maxHeight = null;
        }
      }
    });
  });

  // Smooth anchor scrolling
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

  // Copy-link buttons (#)
  document.querySelectorAll('.copy-link').forEach(link => {
    link.addEventListener('click', e => {
      const url = location.origin + location.pathname + link.getAttribute('href');
      navigator.clipboard.writeText(url).then(() => {
        link.textContent = '✔';
        setTimeout(() => (link.textContent = '#'), 800);
      });
    });
  });

  // Lightbox
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
