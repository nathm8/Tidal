package graphics.ui;

import h2d.Text;
import hxd.Event;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import h2d.col.Point;
import h2d.col.Polygon;
import h2d.col.Polygons;
import h2d.col.PolygonCollider;

class ButtonWithText extends Bitmap {

    public var text(get, set): String;
    public var textObject: Text;

	public function new(t:Tile, s:String, p:Object, f:() -> Void=null, polys:Polygons=null) {
        t.setCenterRatio();
        super(t, p);

		textObject = new h2d.Text(hxd.res.DefaultFont.get(), this);
		textObject.y = -10;
		textObject.text = s;
		textObject.textAlign = Center;
        if (f != null && polys != null)
		    new h2d.Interactive(0, 0, this, new PolygonCollider(polys, true)).onClick = function(event:Event) { f(); };
    }

	function get_text():String {
		return textObject.text;
	}

	function set_text(value:String):String {
		textObject.text = value;
        return value;
	}
}

class BackgroundButtonWithText extends ButtonWithText {

    static var initialised = false;
    static var polys: Polygons;
    static var bgTile: Tile;

    function init() {
        initialised = true;
        polys = new Polygons();
        polys.push(new Polygon([
            new Point(-60, -22.5),
            new Point(60, -22.5),
            new Point(60, 22.5),
            new Point(-60, 22.5)
        ]));
		bgTile = hxd.Res.img.ButtonBG.toTile();
    }

	public function new(s:String, p:Object, f:() -> Void) {
        if (!initialised) init();
		super(bgTile, s, p, f, polys);
	}
}