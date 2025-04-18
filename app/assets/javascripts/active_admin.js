//= require arctic_admin/base

document.addEventListener('DOMContentLoaded', function () {
  const menuParents = document.querySelectorAll('.sidebar .has_nested');

  menuParents.forEach(function (menuParent) {
    const link = menuParent.querySelector('a');

    link.addEventListener('click', function (e) {
      e.preventDefault(); // Prevent the navigation

      const isOpen = menuParent.classList.contains('open');
      menuParents.forEach(mp => mp.classList.remove('open'));
      if (!isOpen) {
        menuParent.classList.add('open');
      }
    });
  });
});
