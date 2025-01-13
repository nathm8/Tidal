package gamelogic.physics;

import box2d.dynamics.Body;
import h2d.Object;
import graphics.HeapsDebugDraw;
import utilities.MessageManager;
import box2d.common.Vec2;
import box2d.dynamics.World;

class PhysicalWorld {
    public static var world(get, null): World;
    static var init = false;
    static var debugDraw: HeapsDebugDraw;
    public static var gravityBodies = new Array<Body>();

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
        world.step(dt, 1, 1);
        world.clearForces();
        // debugDraw.clear();
        // world.drawDebugData();
        MessageManager.sendMessage(new PhysicsStepDoneMessage());
    }
}