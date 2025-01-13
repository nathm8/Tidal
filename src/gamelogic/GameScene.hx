package gamelogic;

import h2d.Scene;
import h2d.Text;
import h2d.col.Point;
import hxd.Timer;
import hxd.Key;
import gamelogic.physics.PhysicalWorld;
import gamelogic.Updateable;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {
	var updateables = new Array<Updateable>();
	var fpsText: Text;
	var cameraScale: Float;

	public function new() {
		super();
		fpsText = new h2d.Text(hxd.res.DefaultFont.get(), this);
		fpsText.visible = true;
		defaultSmooth = true;
		camera.anchorX = 0.5;
		camera.anchorY = 0.5;
		cameraScale = 1.0;

		MessageManager.addListener(this);

		var p = new Planet(this, true);
        updateables.push(p);
	}

	public function update(dt:Float) {
		PhysicalWorld.update(dt);
		for (u in updateables)
			u.update(dt);
		cameraControl();
		fpsText.text = Std.string(Math.round(Timer.fps()));
		var p = new Point(980, 20);
		camera.screenToCamera(p);
		fpsText.setPosition(p.x, p.y);
	}

	public function receiveMessage(msg:Message):Bool {
		return false;
	}

	function cameraControl() {
		if (Key.isDown(Key.A))
			camera.move(-10,0);
		if (Key.isDown(Key.D))
			camera.move(10,0);
		if (Key.isDown(Key.W))
			camera.move(0,-10);
		if (Key.isDown(Key.S))
			camera.move(0,10);
		if (Key.isDown(Key.E))
			cameraScale *= 1.1;
		if (Key.isDown(Key.Q))
			cameraScale *= 0.9;
		camera.setScale(cameraScale, cameraScale);
		fpsText.setScale(1 / cameraScale);
	}
}
