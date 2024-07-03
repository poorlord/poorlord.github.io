console.log('Matter.js loaded:', Matter);

document.addEventListener('DOMContentLoaded', () => {
    const { Engine, Render, Runner, Bodies, World, Events } = Matter;

    const engine = Engine.create();
    const world = engine.world;

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

    const runner = Runner.create();
    Runner.run(runner, engine);

    const ground = Bodies.rectangle(window.innerWidth / 2, window.innerHeight - 10, window.innerWidth, 20, {
        isStatic: true,
        render: {
            visible: false // Make the ground invisible
        }
    });
    World.add(world, ground);

    function createFallingElement() {
        const x = Math.random() * window.innerWidth;
        const y = -20; // Start above the viewport

        console.log('Creating element at:', x, y);

        const element = Bodies.circle(x, y, 10, {
            render: {
                fillStyle: 'red' // Use a simple color for demonstration
            }
        });

        World.add(world, element);
        console.log('Element added:', element);
    }

    createFallingElement();
    setInterval(createFallingElement, 1000);

    function handleResize() {
        Render.lookAt(render, {
            min: { x: 0, y: 0 },
            max: { x: window.innerWidth, y: window.innerHeight }
        });

        Matter.Body.setPosition(ground, { x: window.innerWidth / 2, y: window.innerHeight - 10 });
        ground.bounds.max.x = window.innerWidth;
    }

    window.addEventListener('resize', handleResize);

    function handleScroll() {
        const scrollPosition = window.pageYOffset;
        Matter.Body.setPosition(ground, { x: window.innerWidth / 2, y: scrollPosition + window.innerHeight - 10 });
    }

    window.addEventListener('scroll', handleScroll);
});
