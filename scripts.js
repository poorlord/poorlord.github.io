/* scripts.js */

// Initialize an array to keep track of the pile heights
const pileHeights = new Array(Math.ceil(window.innerWidth / 20)).fill(0);

window.addEventListener('scroll', function() {
    let scrollPosition = window.pageYOffset;
    if (scrollPosition % 100 === 0) { // Adjust this value to control the frequency of falling elements
        createFallingElement(scrollPosition);
    }
});

function createFallingElement(scrollPosition) {
    let element = document.createElement('img');
    element.className = 'falling-element';
    element.src = 'images/your-image.png'; // Update this path to your image
    element.style.left = `${Math.random() * window.innerWidth}px`;
    element.style.top = `${scrollPosition}px`; // Start at current scroll position

    document.body.appendChild(element);

    let fallInterval = setInterval(function() {
        let top = parseInt(window.getComputedStyle(element).top);
        if (top < scrollPosition + window.innerHeight - 20) {
            element.style.top = `${top + 5}px`;
        } else {
            clearInterval(fallInterval);
            pileUpElement(element);
        }
    }, 20);
}

function pileUpElement(element) {
    let left = parseInt(window.getComputedStyle(element).left);
    let column = Math.floor(left / 20); // Determine which column the element is in
    let currentPileHeight = pileHeights[column] || 0; // Get the current height of the pile in that column

    element.style.top = `${window.innerHeight - 20 - currentPileHeight}px`; // Adjust top position based on pile height
    pileHeights[column] += 20; // Increment the pile height for that column
}
