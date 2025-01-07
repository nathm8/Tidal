package gamelogic.physics;

import utilities.MessageManager;
import box2d.common.Vec2;
import box2d.dynamics.World;

class PhysicalWorld {
    public static var world = new World(new Vec2(0, 0));

    public static function reset() {
        world = new World(new Vec2(0, 0));
    }

    public static function update(dt: Float) {
        world.step(dt, 3, 3);
        world.clearForces();
        MessageManager.sendMessage(new PhysicsStepDoneMessage());
    }
}