document.addEventListener('DOMContentLoaded', () => {
  const toggleBtn = document.getElementById('theme-toggle');
  const body = document.body;

  toggleBtn.addEventListener('click', () => {
    // Toggle the “dark” class to switch themes per your CSS variable definitions
    body.classList.toggle('dark');
  });
});
