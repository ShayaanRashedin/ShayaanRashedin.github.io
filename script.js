document.addEventListener('DOMContentLoaded', () => {
  // ─── Theme toggle ──────────────────────────────────
  const toggleBtn = document.getElementById('theme-toggle');
  const body = document.body;
  toggleBtn.addEventListener('click', () => {
    body.classList.toggle('dark');
  });

  // ─── Accordion toggle ───────────────────────────────
  const headers = document.querySelectorAll('.accordion-header');
  headers.forEach(header => {
    header.addEventListener('click', () => {
      const item = header.parentElement;      // .accordion-item
      item.classList.toggle('open');
    });
  });
});

