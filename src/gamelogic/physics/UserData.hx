package gamelogic.physics;

import graphics.ParticleSprite;

enum GameParticleType {
    Indestructible;
    Rock;
    Sand;
    Liquid;
    Gas;
}

// catch-all info for box2d user data
class UserData {
    public var type: GameParticleType = Liquid;
    public var sprite: ParticleSprite;
    public var gravityScale(get, null): Float;

    public function new(o:UserData = null) {
        if (o != null) {
            type = o.type;
        }
    }

    function get_gravityScale():Float {
        switch type {
            case Indestructible: // should always be wall, so immovable
                return 0.0;
            case Rock: // should always be wall, so immovable
                return 0.0;
            case Sand:
                return 2.0;
            case Liquid:
                return 1.0;
            case Gas:
                return 0.1;
        }

    }
}