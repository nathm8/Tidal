package gamelogic.physics;

import utilities.MessageManager;
import box2d.common.Vec2;
import box2d.dynamics.World;

class PhysicalWorld {
    static final physicsScale = 1.0;
    public static var gameWorld = new World(new Vec2(0, 0));

    public static function reset() {
        gameWorld = new World(new Vec2(0, 0));
    }

    public static function update(dt: Float) {
        gameWorld.step(dt, 3, 3);
        gameWorld.clearForces();
        MessageManager.sendMessage(new PhysicsStepDoneMessage());
    }
}