console.log('Matter.js loaded:', Matter);

document.addEventListener('DOMContentLoaded', () => {
    // Create a Matter.js engine
    const { Engine, Render, Runner, Bodies, Composite, World, Events } = Matter;

    const engine = Engine.create();
    const world = engine.world;

    // Create a renderer
    const render = Render.create({
        element: document.body,
        engine: engine,
        options: {
            width: window.innerWidth,
            height: window.innerHeight,
            wireframes: false,
            background: 'black',
        }
    });

    Render.run(render);

    // Create a runner
    const runner = Runner.create();
    Runner.run(runner, engine);

    // Add invisible ground
    let ground = Bodies.rectangle(window.innerWidth / 2, window.innerHeight + 10, window.innerWidth, 20, {
        isStatic: true,
        render: {
            visible: false // Make the ground invisible
        }
    });
    World.add(world, ground);

    // Add left and right walls
    const leftWall = Bodies.rectangle(0, window.innerHeight / 2, 20, window.innerHeight, {
        isStatic: true,
        render: {
            visible: false // Make the wall invisible
        }
    });
    const rightWall = Bodies.rectangle(window.innerWidth, window.innerHeight / 2, 20, window.innerHeight, {
        isStatic: true,
        render: {
            visible: false // Make the wall invisible
        }
    });
    World.add(world, [leftWall, rightWall]);

    window.addEventListener('scroll', function() {
        let scrollPosition = window.pageYOffset;
        if (scrollPosition % 100 === 0) { // Adjust this value to control the frequency of falling elements
            createFallingElement(scrollPosition);
        }

        // Update ground position to be at the bottom of the viewport
        Matter.Body.setPosition(ground, { x: window.innerWidth / 2, y: scrollPosition + window.innerHeight + 10 });
    });

    function createFallingElement(scrollPosition) {
        let x = Math.random() * window.innerWidth;
        let y = scrollPosition - 20; // Start above the viewport based on scroll position

        console.log('Creating element at:', x, y);

        // Create a Matter.js body for the falling element
        let element = Bodies.circle(x, y, 10, {
            render: {
                fillStyle: 'red' // Use a simple color for demonstration
            }
        });

        World.add(world, element);
        console.log('Element added:', element);
    }

    // Handle window resize
    window.addEventListener('resize', function() {
        Render.lookAt(render, {
            min: { x: 0, y: 0 },
            max: { x: window.innerWidth, y: window.innerHeight }
        });

        Matter.Body.setPosition(ground, { x: window.innerWidth / 2, y: window.innerHeight + 10 });
        Matter.Body.setPosition(leftWall, { x: 0, y: window.innerHeight / 2 });
        Matter.Body.setPosition(rightWall, { x: window.innerWidth, y: window.innerHeight / 2 });

        ground.bounds.max.x = window.innerWidth;
        rightWall.bounds.max.y = window.innerHeight;
    });
});
