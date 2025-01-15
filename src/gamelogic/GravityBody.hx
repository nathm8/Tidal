package gamelogic;

import utilities.Vector2D;

interface GravityBody {
    function getPosition(): Vector2D;
    public var mass: Float;
}