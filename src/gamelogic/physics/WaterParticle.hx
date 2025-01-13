package gamelogic.physics;

import h2d.SpriteBatch.BatchElement;

class WaterParticle extends BatchElement {

    var index: Int;

    public function new(i: Int) {
        index = i;
        super(hxd.Res.img.water.toTile().center());
    }

    private override function update(et:Float):Bool {
        var p = PhysicalWorld.world.getParticlePositionBuffer()[index];
        x = p.x;
        y = p.y;
        return super.update(et);
    }
}