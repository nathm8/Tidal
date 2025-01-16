package gamelogic;

import gamelogic.physics.UserData;
import gamelogic.physics.PhysicalWorld;
import h2d.SpriteBatch.BatchElement;

class ParticleSprite extends BatchElement {

    var index: Int;

    public function new(i: Int) {
        index = i;
        var data = cast(PhysicalWorld.world.getParticleUserDataBuffer()[index], UserData);
        if (data.solid)
            super(hxd.Res.img.solid.toTile().center());
        else
            super(hxd.Res.img.gradient.toTile().center());
        var col = PhysicalWorld.world.getParticleColorBuffer()[index];
        r = col.r/255;
        g = col.g/255;
        b = col.b/255;
        a = col.a/255;
    }

    private override function update(et:Float):Bool {
        var p = PhysicalWorld.world.getParticlePositionBuffer()[index];
        x = p.x;
        y = p.y;
        return super.update(et);
    }
}