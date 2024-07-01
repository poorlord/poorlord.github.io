/* scripts.js */
window.addEventListener('scroll', function() {
    let scrollPosition = window.pageYOffset;
    console.log('Scroll position:', scrollPosition);
    if (scrollPosition % 100 === 0) {
        createFallingElement();
    }
});

function createFallingElement() {
    let element = document.createElement('div');
    element.className = 'falling-element';
    element.style.left = `${Math.random() * window.innerWidth}px`;
    element.style.top = '0px';
    console.log('Created element at:', element.style.left, element.style.top);

    document.body.appendChild(element);

    let fallInterval = setInterval(function() {
        let top = parseInt(window.getComputedStyle(element).top);
        console.log('Element top:', top);
        if (top < window.innerHeight - 20) {
            element.style.top = `${top + 5}px`;
        } else {
            clearInterval(fallInterval);
            element.style.top = `${window.innerHeight - 20}px`;
            console.log('Element settled at:', element.style.left, element.style.top);
        }
    }, 20);
}
