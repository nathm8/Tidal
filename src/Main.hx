package;

import utilities.SoundManager;
import gamelogic.GameScene;
import gamelogic.physics.PhysicalWorld;
import h2d.col.Point;
import utilities.MessageManager;
import utilities.RNGManager;

class Main extends hxd.App implements MessageListener {

	var gameScene: GameScene;

	static function main() {
		new Main();
	}

	override private function init() {
		// boilerplate
		RNGManager.initialise();
		hxd.Res.initEmbed();
		// background
		h3d.Engine.getCurrent().backgroundColor = 0x002B0617;
		// controls
		hxd.Window.getInstance().addEventTarget(onEvent);	
		// gamelogic
		SoundManager.initialise();
		newGame();
	}
	
	override function update(dt:Float) {
		if (gameScene != null)
			gameScene.update(dt);
	}
	
	function newGame() {
		RNGManager.reset();
		MessageManager.reset();
		PhysicalWorld.reset();
		SoundManager.reset();
		gameScene = new GameScene();
		setScene2D(gameScene);
		PhysicalWorld.setScene(gameScene);
		MessageManager.addListener(this);
	}

	function onEvent(event:hxd.Event) {
		switch (event.kind) {
			case EPush:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.sendMessage(new MouseClickMessage(event, p));
			case ERelease:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.sendMessage(new MouseReleaseMessage(event, p));
			case EMove:
				var p = new Point(event.relX, event.relY);
				s2d.camera.sceneToCamera(p);
				MessageManager.sendMessage(new MouseMoveMessage(event, p));
			case EKeyDown:
				switch (event.keyCode) {
					case hxd.Key.R:
						MessageManager.sendMessage(new RestartMessage());
					// case hxd.Key.ENTER:
				}
			case EKeyUp:
				MessageManager.sendMessage(new KeyUpMessage(event.keyCode));
			case _:
		}
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, RestartMessage)) {
			newGame();
		}
		return false;
	}
}