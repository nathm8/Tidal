package gamelogic.physics;

import box2d.particle.ParticleType;
import box2d.particle.ParticleDef;
import box2d.common.Transform;
import box2d.collision.shapes.CircleShape;
import utilities.Vector2D;
import h2d.Object;
import graphics.HeapsDebugDraw;
import utilities.MessageManager;
import box2d.common.Vec2;
import box2d.dynamics.World;
import gamelogic.GravityBody;

class WorldListener implements MessageListener {

    public function new() {
        MessageManager.addListener(this);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, MouseReleaseMessage)) {
            var params = cast(msg, MouseReleaseMessage);
            var shape = new CircleShape();
            shape.setRadius(1000);
            var xform = new Transform();
            xform.p.x = params.worldPosition.x;
            xform.p.y = params.worldPosition.y;
            PhysicalWorld.world.destroyParticlesInShape2(shape, xform, true);
        }
        return false;
    }
}

class PhysicalWorld {
    public static var world(get, null): World;
    static var init = false;
    static var debugDraw: HeapsDebugDraw;
    public static var gravityBodies = new Array<GravityBody>();
    static var listener: WorldListener;
    public static var toAdd = new Array<ParticleDef>();
    
    public static function reset() {
        init = false;
        initialise();
    }
    
    public static function setScene(scene: Object) {
        debugDraw = new HeapsDebugDraw(scene);
        world.setDebugDraw(debugDraw);
    }

    static function initialise() {
        if (init) return;
        init = true;
        world = new World(new Vec2(0, 0));
        world.setDebugDraw(debugDraw);
        world.setParticleRadius(4);
        world.setParticleDestructionListener(new SolidParticleDestructionListener());
        listener = new WorldListener();
    }

    public static function get_world() : World {
        if (!init) init = true;
        initialise();
        return world;
    }

    public static function update(dt: Float) {
        // apply gravity to each particle
        var buff = world.getParticleVelocityBuffer();
        for (b in gravityBodies) {
            for (i in 0...world.getParticleCount()) {
                // walls don't move, skip gravity
                if (world.getParticleFlagsBuffer()[i] & ParticleType.b2_wallParticle != 0)
                    continue;
                var data = world.getParticleUserDataBuffer()[i];
                var mass = data.mass;
                var dirc: Vector2D = world.getParticlePositionBuffer()[i].sub(b.getPosition());
                var dist = dirc.magnitude;
                var force = -mass*b.mass/(dist)*dirc.normalize();
                // var force : Vector2D = -b.mass/(dist*dist)*dirc.normalize();
                buff[i] = buff[i].add(force*dt);
            }
        }

        world.step(dt, 3, 3);
        world.clearForces();
        while (toAdd.length > 0) {
            var pd = toAdd.pop();
            var i = PhysicalWorld.world.createParticle(pd);
            // MessageManager.sendMessa ge(new AddParticleSpriteMessage(i));    
        }
        // debugDraw.clear();
        // world.drawDebugData();
        MessageManager.sendMessage(new PhysicsStepDoneMessage());
    }
}