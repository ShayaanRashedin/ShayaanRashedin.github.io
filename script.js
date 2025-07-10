document.addEventListener('DOMContentLoaded', () => {
  // theme toggle (unchanged)
  const toggleBtn = document.getElementById('theme-toggle');
  toggleBtn.addEventListener('click', () => document.body.classList.toggle('dark'));

  // accordion toggle
  document.querySelectorAll('.accordion-header').forEach(header => {
    header.addEventListener('click', () => {
      header.parentElement.classList.toggle('open');
    });
  });
});

