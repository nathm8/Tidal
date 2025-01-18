package gamelogic;

import utilities.MessageManager;
import utilities.MessageManager.AddParticleSpriteMessage;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import gamelogic.physics.UserData;
import box2d.particle.ParticleColor;
import box2d.collision.shapes.PolygonShape;
import box2d.particle.ParticleGroupType;
import box2d.particle.ParticleGroupDef;
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
import gamelogic.ParticleSprite;
import h2d.Graphics;
import h2d.Object;

import haxe.ds.Vector;

using Lambda;

class Moon implements Updateable implements GravityBody {
    
    var graphics: Graphics;
    var timeElapsed = 0.0;
    var radius = 1000;
    public var mass = 45000.0;

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
        timeElapsed += dt/5;
        graphics.x = radius*Math.sin(-timeElapsed);
        graphics.y = radius*Math.cos(-timeElapsed);
    }

    public function getPosition() {
        return new Vector2D(graphics.x, graphics.y);
    }

}

class Planet implements Updateable implements GravityBody implements MessageListener {

    // constant for how many points to use in rendering curves
    static final PLANET_VERTICES = 128;

    var graphics: Graphics;
    var heightmap: Array<Float>;
    var radius: Float;
    var centroid = new Vector2D();
    var points = new Array<Vector2D>();
    public var mass = 100000.0;
    var time = 0.0;

    var body: Body;
    var hasWater: Bool;
    var moon: Moon;

    var spriteBatch: SpriteBatch;

    // r  - base radius
    // nr - noise radius multiplier
    public function new(parent: Object, has_water: Bool, r = 200.0, nr = 200.0) {
        radius = r;
        hasWater = has_water;
        initGraphics(parent);
        generateHeightmap(nr);
        moon = new Moon(graphics);
        MessageManager.addListener(this);
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
            // r = 200;
            var x = r*Math.cos(2*Math.PI*i/heightmap.length);
            var y = r*Math.sin(2*Math.PI*i/heightmap.length);
            var v = new Vector2D(x, y);
            centroid += v;
            points.push(v);
            i += 1;
            max = v.magnitude > max ? v.magnitude : max;
        }
        centroid /= heightmap.length;

        // physics
        var loop = new haxe.ds.Vector<Vec2>(points.length);
        var atmo_dist = heightmap.fold(Math.max, heightmap[0])*1.5;
        var particle_group_def = new ParticleGroupDef();
        particle_group_def.flags = ParticleType.b2_wallParticle | ParticleType.b2_destructionListener;
        particle_group_def.groupFlags = ParticleGroupType.b2_rigidParticleGroup | ParticleGroupType.b2_solidParticleGroup;
        particle_group_def.color = new ParticleColor();
        particle_group_def.color.r = 10;
        particle_group_def.color.g = 175;
        particle_group_def.color.b = 10;
        particle_group_def.color.a = 255;
        particle_group_def.userData = new UserData();
        particle_group_def.userData.type = GameParticleType.Rock;
        var planet_group = PhysicalWorld.world.createParticleGroup(particle_group_def);
        particle_group_def.angularVelocity = 0;
        var last = points[points.length-1];
        for (i in 0...points.length) {
            var shape = new PolygonShape();
            var verts: Array<Vec2> = [last, centroid, points[i]];
            shape.set(Vector.fromArrayCopy(verts), 3);
            last = points[i];
            particle_group_def.shape = shape;
            var particle_group = PhysicalWorld.world.createParticleGroup(particle_group_def);
            PhysicalWorld.world.joinParticleGroups(planet_group, particle_group);
            
            loop[i] = new Vector2D(atmo_dist*Math.cos(2*Math.PI*i/points.length), atmo_dist*Math.sin(2*Math.PI*i/points.length));
        }
        // atmosphere barrier
        var body_definition = new BodyDef();
        body_definition.position = centroid;
        body_definition.type = BodyType.STATIC;
        var atmo_body = PhysicalWorld.world.createBody(body_definition);
        var edge = new ChainShape();
        edge.createLoop(loop, points.length);
        var fixture_definition = new FixtureDef();
        fixture_definition.shape = edge;
        atmo_body.createFixture(fixture_definition);

        PhysicalWorld.gravityBodies.push(this);
        
        // water
        if (hasWater) {
            var particle_def = new ParticleDef();
            particle_def.userData = new UserData();
            particle_def.userData.type = GameParticleType.Liquid;
            particle_def.color = new ParticleColor();
            particle_def.color.r = 100;
            particle_def.color.g = 100;
            particle_def.color.b = 255;
            particle_def.color.a = 255;
            particle_def.flags = ParticleType.b2_destructionListener;
            var num_particles = 8000;
            var spawn_dist = heightmap.fold(Math.max, heightmap[0]);
            var rings = 10;
            var portions = Math.floor(num_particles/rings);
            for (j in 0...rings) {
                for (i in 0...portions) {
                    particle_def.position = new Vector2D(spawn_dist+j*10,0).rotateAroundAngle(2*Math.PI*i/portions);
                    var k = PhysicalWorld.world.createParticle(particle_def);
                    spriteBatch.add(new ParticleSprite(k));
                }
            }
        }
        // add planet particles last
        for (i in planet_group.m_firstIndex...planet_group.m_lastIndex)
            spriteBatch.add(new ParticleSprite(i));
        trace(PhysicalWorld.world.getParticleCount());
    }

    public function initGraphics(parent: Object) {
        graphics = new Graphics(parent);
        spriteBatch = new SpriteBatch(hxd.Res.img.particle.toTile(), graphics);
        spriteBatch.hasUpdate = true;
    }

    public function getPosition(): Vector2D {
        return new Vector2D();
    }
    
    public function getPositionAtFutureTime(dt:Float): Vector2D {
        return new Vector2D();
    }

    public function update(dt: Float) {
        time += dt/10;
        // trace(ParticleSprite.count, ParticleSprite.totalCount);
        // graphics.rotation = time;
        moon.update(dt);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, AddParticleSpriteMessage)) {
            var params = cast(msg, AddParticleSpriteMessage);
            spriteBatch.add(new ParticleSprite(params.i));
        }
        return false;
    }
}