/* scripts.js */
window.addEventListener('scroll', function() {
    let scrollPosition = window.pageYOffset;
    if (scrollPosition % 100 === 0) { // Adjust this value to control the frequency of falling elements
        createFallingElement();
    }
});

function createFallingElement() {
    let element = document.createElement('div');
    element.className = 'falling-element';
    element.style.left = `${Math.random() * window.innerWidth}px`;
    element.style.top = '0px';

    document.body.appendChild(element);

    let fallInterval = setInterval(function() {
        let top = parseInt(window.getComputedStyle(element).top);
        if (top < window.innerHeight - 20) {
            element.style.top = `${top + 5}px`;
        } else {
            clearInterval(fallInterval);
            // No need to adjust left or top anymore, element stays where it lands
        }
    }, 20);
}
