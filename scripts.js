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

    // Add visible ground for debugging
    let ground = Bodies.rectangle(window.innerWidth / 2, window.innerHeight - 10, window.innerWidth, 20, {
        isStatic: true,
        render: {
            fillStyle: 'white'
        }
    });
    World.add(world, ground);

    // Function to create a falling element
    function createFallingElement() {
        let x = Math.random() * window.innerWidth;
        let y = -20; // Start above the viewport

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

    // Create an element on initial load for testing
    createFallingElement();

    // Create a new falling element every 1 second for testing
    setInterval(createFallingElement, 1000);

    // Handle window resize
    window.addEventListener('resize', function() {
        Render.lookAt(render, {
            min: { x: 0, y: 0 },
            max: { x: window.innerWidth, y: window.innerHeight }
        });

        Matter.Body.setPosition(ground, { x: window.innerWidth / 2, y: window.innerHeight - 10 });
        ground.bounds.max.x = window.innerWidth;
    });
});
