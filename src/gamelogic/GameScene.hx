package gamelogic;

import gamelogic.Updateable;
import gamelogic.physics.PhysicalWorld;
import h2d.Scene;
import h2d.Text;
import h2d.col.Point;
import hxd.Timer;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {
	var updateables = new Array<Updateable>();
	var fpsText: Text;

	public function new() {
		super();
		fpsText = new h2d.Text(hxd.res.DefaultFont.get(), this);
		fpsText.visible = false;
		defaultSmooth = true;

		MessageManager.addListener(this);
	}

	public function update(dt:Float) {
		PhysicalWorld.update(dt);
		for (u in updateables)
			u.update(dt);

		fpsText.text = Std.string(Math.round(Timer.fps()));
		var p = new Point(20, 20);
		camera.screenToCamera(p);
		fpsText.setPosition(p.x, p.y);
	}

	public function receiveMessage(msg:Message):Bool {
		return false;
	}
}
