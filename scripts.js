// script.js

document.addEventListener('DOMContentLoaded', () => {
    const overlay = document.getElementById('overlay');
    const mainContent = document.getElementById('main-content');
    const eyeIcon = document.getElementById('eye-icon');

    eyeIcon.addEventListener('click', () => {
        overlay.style.display = 'none'; // Hide the overlay
        mainContent.style.display = 'block'; // Show the main content
    });
});
