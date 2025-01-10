package gamelogic;

import box2d.collision.shapes.ChainShape;
import box2d.collision.shapes.EdgeShape;
import box2d.dynamics.Body;
import box2d.particle.ParticleType;
import box2d.particle.ParticleDef;
import box2d.common.Vec2;
import box2d.collision.shapes.PolygonShape;
import box2d.dynamics.BodyDef;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.BodyType;

import utilities.Vector2D;
import utilities.RNGManager;
import utilities.Noisemap;
import gamelogic.physics.PhysicalWorld;
import h2d.Graphics;
import h2d.Object;

using Lambda;

class Planet implements Updateable {

    // minimum distance ships can orbit without colliding with the planet
    public var minPeriapsis(get, null): Float;
    // constant for how many points to use in rendering curves
    static final PLANET_VERTICES = 100;
    static final MASS_MULTIPLIER = 4;

    var graphics: Graphics;
    var heightmap: Array<Float>;
    var radius: Float;
    var centroid = new Vector2D();
    var points = new Array<Vector2D>();
    public var mass = 0.0;
    var time = 0.0;
    var rotationalPeriod: Float;

    var worldBody: Body;

    // r  - base radius
    // nr - noise radius multiplier
    // public function new(parent: Object, r = 50.0, nr = 100.0) {
    public function new(parent: Object, r = 50.0, nr = 100.0) {
        radius = r;

        generateHeightmap(nr);
        spawnWater();
        initGraphics(parent);
    }

    function spawnWater() {

    }

    function generateHeightmap(nr: Float) {
        rotationalPeriod = 25 + RNGManager.rand.random(25);
        var noise = new Noisemap();
        var min = 10*radius;
        var max = 0.0;
        heightmap = new Array<Float>();
        for (i in 0...PLANET_VERTICES){
            var theta_rads = 2*Math.PI*i/PLANET_VERTICES;
            var n = noise.getNoiseAtTheta(theta_rads);
            heightmap.push(n);
            min = n < min ? n : min;
            max = n > max ? n : max;
        } 
        // normalise
        max -= min;
        for (i in 0...PLANET_VERTICES)
            heightmap[i] = radius + nr*(heightmap[i]-min)/max;
        // generate polygon
        var i = 0;
        max = 0.0;
        for (r in heightmap) {
            var x = r*Math.cos(2*Math.PI*i/heightmap.length);
            var y = r*Math.sin(2*Math.PI*i/heightmap.length);
            var v = new Vector2D(x, y);
            centroid += v;
            mass += v.magnitude;
            points.push(v);
            i += 1;
            max = v.magnitude > max ? v.magnitude : max;
        }
        mass *= MASS_MULTIPLIER;
        minPeriapsis = max*1.5;
        centroid /= heightmap.length;

        // physics
        var body_definition = new BodyDef();
        body_definition.type = BodyType.KINEMATIC;
        body_definition.position = -centroid;
        body_definition.angularVelocity = 0.05;
        worldBody = PhysicalWorld.world.createBody(body_definition);
        var edge = new ChainShape();
        var loop = new haxe.ds.Vector<Vec2>(points.length);
        for (i in 0...points.length)
            loop[i] = points[i];
        edge.createLoop(loop, points.length);
        var fixture_definition = new FixtureDef();
        fixture_definition.shape = edge;
        worldBody.createFixture(fixture_definition);
        
        var particle_def = new ParticleDef();
        particle_def.flags = ParticleType.b2_waterParticle;
        var num_particles = 2000;
        var spawn_dist = heightmap.fold(Math.max, heightmap[0]) - centroid.magnitude + 10;
        var third = Math.floor(num_particles/3);
        for (j in 0...3) {
            for (i in 0...third) {
                particle_def.position = new Vector2D(spawn_dist+j*5,0).rotateAroundAngle(2*Math.PI*i/third);
                PhysicalWorld.world.createParticle(particle_def);
            }
        }
    }

    public function initGraphics(parent: Object) {
        graphics = new Graphics(parent);
        // no outline
        // graphics.beginFill();
        // for (p in points)
        //     graphics.addVertex(p.x - centroid.x, p.y - centroid.y, 0.0, 7.0, 0.0, 1.0);
        // // close the circle
        // graphics.addVertex(points[0].x - centroid.x, points[0].y - centroid.y, 0.0, 7.0, 0.0, 1.0);
        // graphics.endFill();
    }

    public function getPosition(): Vector2D {
        return new Vector2D();
    }
    
    public function getPositionAtFutureTime(dt:Float): Vector2D {
        return new Vector2D();
    }

    public function update(dt: Float) {
        time += dt;

        // apply gravity to each particle
        var buff = PhysicalWorld.world.getParticleVelocityBuffer();
        for (i in 0...PhysicalWorld.world.getParticleCount()) {
            var dirc : Vector2D = PhysicalWorld.world.getParticlePositionBuffer()[i].sub(worldBody.getPosition());
            var dist = dirc.magnitude;
            // var force : Vector2D = -100*dirc.normalize();
            var force : Vector2D = -2500000/(dist*dist)*dirc.normalize();
            // trace(force.magnitude);

            // var force : Vector2D = 1000/(dist*dist)*pos.normalize();
            buff[i] = buff[i].add(force*dt);
        }
        PhysicalWorld.world.setParticleVelocityBuffer(buff, buff.length);
        // worldBody.applyTorque(1000000);


        // while (time > rotationalPeriod) time -= rotationalPeriod;
        // graphics.rotation = 2*Math.PI*time/rotationalPeriod;
    }

    function get_minPeriapsis():Float {
        return minPeriapsis;
    }
}