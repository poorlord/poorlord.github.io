/* scripts.js */
window.addEventListener('scroll', function() {
    let scrollPosition = window.pageYOffset;
    if (scrollPosition % 100 === 0) { // Adjust this value to control the frequency of falling elements
        createFallingElement(scrollPosition);
    }
});

function createFallingElement(scrollPosition) {
    let element = document.createElement('div');
    element.className = 'falling-element';
    element.style.left = `${Math.random() * window.innerWidth}px`;
    element.style.top = `${scrollPosition - window.innerHeight}px`; // Adjust start position based on scroll

    document.body.appendChild(element);

    let fallInterval = setInterval(function() {
        let top = parseInt(window.getComputedStyle(element).top);
        if (top < scrollPosition + window.innerHeight - 20) {
            element.style.top = `${top + 5}px`;
        } else {
            clearInterval(fallInterval);
            pileUpElement(element, scrollPosition);
        }
    }, 20);
}

function pileUpElement(element, scrollPosition) {
    let left = parseInt(window.getComputedStyle(element).left);
    element.style.top = `${scrollPosition + window.innerHeight - 20}px`; // Pile up at the bottom
    if (left < window.innerWidth / 2) {
        element.style.left = '0px';
    } else {
        element.style.left = `${window.innerWidth - 20}px`;
    }
}
