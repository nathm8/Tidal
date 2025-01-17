package gamelogic.physics;

// catch-all info for box2d user data
class UserData {
    public var solid = false;
    public var sprite: ParticleSprite;
    public var mass = 1.0;

    public function new(o:UserData = null) {
        if (o != null) {
            solid = o.solid;
            mass = o.mass;
        }
    }
}