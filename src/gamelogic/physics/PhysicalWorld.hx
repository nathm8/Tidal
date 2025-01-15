package gamelogic.physics;

import utilities.Vector2D;
import h2d.Object;
import graphics.HeapsDebugDraw;
import utilities.MessageManager;
import box2d.common.Vec2;
import box2d.dynamics.World;
import gamelogic.GravityBody;

class PhysicalWorld {
    public static var world(get, null): World;
    static var init = false;
    static var debugDraw: HeapsDebugDraw;
    public static var gravityBodies = new Array<GravityBody>();

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
        world.setParticleRadius(2.5);
    }

    public static function get_world() : World {
        if (!init) init = true;
        initialise();
        return world;
    }

    public static function update(dt: Float) {
        // apply gravity to each particle
        var buff = PhysicalWorld.world.getParticleVelocityBuffer();
        for (b in gravityBodies) {
            for (i in 0...PhysicalWorld.world.getParticleCount()) {
                var dirc : Vector2D = PhysicalWorld.world.getParticlePositionBuffer()[i].sub(b.getPosition());
                var dist = dirc.magnitude;
                var force : Vector2D = -b.mass/(dist)*dirc.normalize();
                // var force : Vector2D = -b.mass/(dist*dist)*dirc.normalize();
                buff[i] = buff[i].add(force*dt);
            }
        }

        world.step(dt, 1, 1);
        world.clearForces();
        // debugDraw.clear();
        // world.drawDebugData();
        MessageManager.sendMessage(new PhysicsStepDoneMessage());
    }
}