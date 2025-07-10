document.addEventListener('DOMContentLoaded', () => {
  console.log('📜 script.js loaded')

  // — Theme toggle —
  const toggleBtn = document.getElementById('theme-toggle');
  const body = document.body;
  if (toggleBtn) {
    toggleBtn.addEventListener('click', () => {
      body.classList.toggle('dark');
      console.log('🌓 toggled dark mode:', body.classList.contains('dark'));
    });
  } else {
    console.error('❌ #theme-toggle button not found');
  }

  // — Accordion toggle —
  const headers = document.querySelectorAll('.accordion-header');
  if (headers.length > 0) {
    headers.forEach(header => {
      header.addEventListener('click', () => {
        const item = header.closest('.accordion-item');
        if (item) {
          item.classList.toggle('open');
          console.log(`🔽 toggled accordion "${header.textContent.trim()}":`, item.classList.contains('open'));
        }
      });
    });
  } else {
    console.error('❌ No elements with .accordion-header found');
  }
});
