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
            pileUpElement(element);
        }
    }, 20);
}

function pileUpElement(element) {
    let left = parseInt(window.getComputedStyle(element).left);
    if (left < window.innerWidth / 2) {
        element.style.left = '0px';
        element.style.top = `${Math.random() * (window.innerHeight - 20)}px`;
    } else {
        element.style.left = `${window.innerWidth - 20}px`;
        element.style.top = `${Math.random() * (window.innerHeight - 20)}px`;
    }
}
