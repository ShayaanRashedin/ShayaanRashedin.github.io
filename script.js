document.addEventListener('DOMContentLoaded', () => {
  console.log('📜 script.js loaded');

  // — THEME PERSISTENCE & TOGGLE —
  const toggleBtn = document.getElementById('theme-toggle');
  const body = document.body;

  // apply saved theme on load
  if (localStorage.getItem('theme') === 'dark') {
    body.classList.add('dark');
    console.log('♟ Applied saved theme: dark');
  }

  if (toggleBtn) {
    toggleBtn.addEventListener('click', () => {
      const isDark = body.classList.toggle('dark');
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
      console.log('🌓 toggled theme:', isDark ? 'dark' : 'light');
    });
  }

  // — ACCORDION TOGGLE —  
  const headers = document.querySelectorAll('.accordion-header');
  if (headers.length) {
    headers.forEach(header => {
      header.addEventListener('click', () => {
        const item = header.closest('.accordion-item');
        const isOpen = item.classList.toggle('open');
        console.log(`🔽 toggled "${header.textContent.trim()}":`, isOpen);
      });
    });
  }
});

// Lightbox functionality
const lightbox = document.getElementById('lightbox');
const lbImg    = document.getElementById('lightbox-img');

document.querySelectorAll('.lab-img').forEach(img => {
  img.addEventListener('click', () => {
    lbImg.src = img.src;
    lightbox.style.display = 'flex';
  });
});

function closeLightbox() {
  lightbox.style.display = 'none';
  lbImg.src = '';
}
