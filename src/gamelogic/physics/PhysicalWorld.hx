package gamelogic.physics;

import hxd.Timer;
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

final hertz = 1/60.0;

class WorldListener implements MessageListener {

    public function new() {
        MessageManager.addListener(this);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, MouseReleaseMessage)) {
            var params = cast(msg, MouseReleaseMessage);
            var shape = new CircleShape();
            shape.setRadius(50);
            var xform = new Transform();
            xform.p.x = params.worldPosition.x;
            xform.p.y = params.worldPosition.y;
            cast (PhysicalWorld.world.getParticleDestructionListener(), SolidParticleDestructionListener).lastEpicenter = params.worldPosition;
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
    static var bankedTime = 0.0;
    
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
        world.setParticleRadius(8);
        world.setParticleDestructionListener(new SolidParticleDestructionListener());
        listener = new WorldListener();
    }

    public static function get_world() : World {
        if (!init) init = true;
        initialise();
        return world;
    }

    public static function update(dt: Float) {
        bankedTime += dt;
        var steps = 0;
        while (bankedTime >= hertz) {
            bankedTime -= hertz;
            var buff = world.getParticleVelocityBuffer();
            for (i in 0...world.getParticleCount()) {
                // apply gravity to each particle
                for (b in gravityBodies) {
                    // walls don't move, skip gravity
                    if (world.getParticleFlagsBuffer()[i] & ParticleType.b2_wallParticle != 0)
                        continue;
                    var data = cast(world.getParticleUserDataBuffer()[i], UserData);
                    var gravity_scale = data.gravityScale;
                    if (gravity_scale == 0)
                        continue;
                    var dirc: Vector2D = world.getParticlePositionBuffer()[i].sub(b.getPosition());
                    var dist = dirc.magnitude;
                    var force = -gravity_scale*b.mass/dist*dirc.normalize();
                    // var force = -gravity_scale*b.mass/(dist*dist)*dirc.normalize();
                    buff[i] = buff[i].add(force*hertz);
                }
                // reduce lifetimes, check for phase-change
            }
            world.step(hertz, 4, 4);
            world.clearForces();
            while (toAdd.length > 0) {
                var pd = toAdd.pop();
                var i = PhysicalWorld.world.createParticle(pd);
            }
            steps++;
        }
        trace(steps);
        // debugDraw.clear();
        // world.drawDebugData();
        MessageManager.sendMessage(new PhysicsStepDoneMessage());
    }
}