package graphics;

import h2d.Tile;
import gamelogic.physics.UserData;
import gamelogic.physics.PhysicalWorld;
import h2d.SpriteBatch.BatchElement;

class ParticleSprite extends BatchElement {

    var index: Int;
    static var tiles: Array<Array<Tile>>;
    public static var count: Int = 0;
    public static var totalCount: Int = 0;

    public function new(i: Int) {
        if (tiles == null)
            tiles = hxd.Res.img.particle.toTile().grid(16, 8, 8);
        index = i;
        var data = cast(PhysicalWorld.world.getParticleUserDataBuffer()[index], UserData);
        data.sprite = this;
        super(tiles[0][0]);
        count++;
        totalCount++;
    }

    private override function update(et:Float):Bool {
        if (index >= PhysicalWorld.world.getParticleCount()) {
            count--;
            return false;
        }
        var data = cast(PhysicalWorld.world.getParticleUserDataBuffer()[index], UserData);
        if (data.type == Rock || data.type == Indestructible)
            t = tiles[0][0];
        else
            t = tiles[1][0];

        var p = PhysicalWorld.world.getParticlePositionBuffer()[index];
        x = p.x;
        y = p.y;
        var col = PhysicalWorld.world.getParticleColorBuffer()[index];
        r = col.r/255;
        g = col.g/255;
        b = col.b/255;
        a = col.a/255;
        return super.update(et);
    }

    public override function remove() {
        count--;
        super.remove();
    }
}