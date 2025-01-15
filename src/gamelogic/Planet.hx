package gamelogic;

import box2d.particle.ParticleType;
import h2d.SpriteBatch;
import box2d.collision.shapes.ChainShape;
import box2d.dynamics.Body;
import box2d.particle.ParticleDef;
import box2d.common.Vec2;
import box2d.dynamics.BodyDef;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.BodyType;

import utilities.Vector2D;
import utilities.Noisemap;
import gamelogic.physics.PhysicalWorld;
import gamelogic.physics.WaterParticle;
import h2d.Graphics;
import h2d.Object;

using Lambda;

class Moon implements Updateable implements GravityBody {
    
    var graphics: Graphics;
    var timeElapsed = 0.0;
    var radius = 1000;
    public var mass = 100000.0;

    public function new(parent: Object) {

        graphics = new Graphics(parent);
        // no outline
        graphics.beginFill();
        for (p in 0...32)
            graphics.addVertex(100*Math.sin(2*Math.PI*p/32), 100*Math.cos(2*Math.PI*p/32), 0.7, 0.7, 0.7, 1.0);
        // close the circle
        graphics.addVertex(100*Math.sin(0), 100*Math.cos(0), 0.7, 0.7, 0.7, 1.0);
        graphics.endFill();

        PhysicalWorld.gravityBodies.push(this);
    }

    public function update(dt:Float) {
        timeElapsed += dt/10;
        graphics.x = radius*Math.sin(-timeElapsed);
        graphics.y = radius*Math.cos(-timeElapsed);
    }

    public function getPosition() {
        return new Vector2D(graphics.x, graphics.y);
    }

}

class Planet implements Updateable implements GravityBody {

    // constant for how many points to use in rendering curves
    static final PLANET_VERTICES = 64;
    static final MASS_MULTIPLIER = 5;
    // static final MASS_MULTIPLIER = 150;

    var graphics: Graphics;
    var heightmap: Array<Float>;
    var radius: Float;
    var centroid = new Vector2D();
    var points = new Array<Vector2D>();
    public var mass = 0.0;
    var time = 0.0;

    var body: Body;
    var hasWater: Bool;

    var spriteBatch: SpriteBatch;

    // r  - base radius
    // nr - noise radius multiplier
    // public function new(parent: Object, r = 50.0, nr = 100.0) {
    public function new(parent: Object, has_water: Bool, r = 150.0, nr = 150.0) {
        radius = r;
        hasWater = has_water;
        generateHeightmap(nr);
        initGraphics(parent);
    }

    function generateHeightmap(nr: Float) {
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
            // r = 150;
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
        centroid /= heightmap.length;

        // physics
        var body_definition = new BodyDef();
        body_definition.type = BodyType.KINEMATIC;
        body_definition.position = centroid;
        body_definition.angularVelocity = 0.05;
        body = PhysicalWorld.world.createBody(body_definition);
        var edge = new ChainShape();
        var loop = new haxe.ds.Vector<Vec2>(points.length);
        var loop2 = new haxe.ds.Vector<Vec2>(points.length);
        var atmo_dist = heightmap.fold(Math.max, heightmap[0])*1.5;
        for (i in 0...points.length) {
            loop[i] = points[i];
            loop2[i] = points[i];
            loop2[i].x = atmo_dist*Math.cos(2*Math.PI*i/points.length);
            loop2[i].y = atmo_dist*Math.sin(2*Math.PI*i/points.length);
        }
        edge.createLoop(loop, points.length);
        var fixture_definition = new FixtureDef();
        fixture_definition.shape = edge;
        body.createFixture(fixture_definition);
        // "atmosphere" barrier
        body_definition.type = BodyType.STATIC;
        var atmo_body = PhysicalWorld.world.createBody(body_definition);
        edge.createLoop(loop2, points.length);
        fixture_definition.shape = edge;
        atmo_body.createFixture(fixture_definition);

        PhysicalWorld.gravityBodies.push(this);
        
        // water
        if (hasWater) {
            var particle_def = new ParticleDef();
            // particle_def.flags = ParticleType.b2_waterParticle | ParticleType.b2_viscousParticle;
            var num_particles = 4000;
            var spawn_dist = heightmap.fold(Math.max, heightmap[0]) + 20;
            var third = Math.floor(num_particles/3);
            for (j in 0...3) {
                for (i in 0...third) {
                    particle_def.position = new Vector2D(spawn_dist+j*10,0).rotateAroundAngle(2*Math.PI*i/third);
                    PhysicalWorld.world.createParticle(particle_def);
                }
            }
        }
    }

    public function initGraphics(parent: Object) {
        graphics = new Graphics(parent);
        spriteBatch = new SpriteBatch(hxd.Res.img.water.toTile().center(), parent);
        spriteBatch.hasUpdate = true;
        for (i in 0...PhysicalWorld.world.getParticleCount())
            spriteBatch.add(new WaterParticle(i));
        // no outline
        graphics.beginFill();
        for (p in points)
            graphics.addVertex(p.x, p.y, 0.0, 0.7, 0.0, 1.0);
        // close the circle
        graphics.addVertex(points[0].x, points[0].y, 0.0, 0.7, 0.0, 1.0);
        graphics.endFill();
    }

    public function getPosition(): Vector2D {
        return new Vector2D();
    }
    
    public function getPositionAtFutureTime(dt:Float): Vector2D {
        return new Vector2D();
    }

    public function update(dt: Float) {
        time += dt;

        graphics.rotation = body.getAngle();
        graphics.x = body.getPosition().x;
        graphics.y = body.getPosition().y;
    }

}