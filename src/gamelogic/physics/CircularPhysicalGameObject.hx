package gamelogic.physics;

import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2BodyType;
import utilities.Vector2D;

class CircularPhysicalGameObject {

    public var body: B2Body;

    public function new(position: Vector2D, radius: Float, userdata: Dynamic, density=0.1, linear_damping=0.5) {
        var body_definition = new B2BodyDef();
        body_definition.fixedRotation = true;
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        body_definition.position = position;
        body_definition.linearDamping = linear_damping;
        var circle = new B2CircleShape();
        circle.setRadius(radius);
        var fixture_definition = new B2FixtureDef();
        fixture_definition.shape = circle;
        fixture_definition.friction = 0.5;
        fixture_definition.restitution = 0.5;
        fixture_definition.density = density;

        body = PhysicalWorld.gameWorld.createBody(body_definition);
        var fix = body.createFixture(fixture_definition);
        fix.setUserData(userdata);
        body.setActive(true);
    }

    public function removePhysics() {
        // idk why I need to check this but I do
        if (body.getWorld() != null)
            body.getWorld().destroyBody(body);
    }
}

class BoxPhysicalGameObject {

    var body: B2Body;

    public function new(position: Vector2D, rot: Float, width: Float, height: Float, userdata: Dynamic, density=1.0) {
        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        body_definition.position = position;
        body_definition.linearDamping = 1.0;
        if (Std.isOfType(userdata, Brick)) body_definition.linearDamping = 0.5;
        body_definition.angularDamping = 1.0;
        var poly = new B2PolygonShape();
        poly.setAsBox(width, height);
        var fixture_definition = new B2FixtureDef();
        fixture_definition.shape = poly;
        fixture_definition.friction = 0.5;
        fixture_definition.restitution = 0.5;
        fixture_definition.density = density;

        body = PhysicalWorld.gameWorld.createBody(body_definition);
        var fix = body.createFixture(fixture_definition);
        fix.setUserData(userdata);
        body.setAngle(rot);
        body.setActive(true);
    }

    public function removePhysics() {
        body.getWorld().destroyBody(body);
    }
}