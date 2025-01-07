package utilities;

import hxd.Event;

class Message {public function new(){}}

class PhysicsStepDoneMessage extends Message {}
class RestartMessage extends Message {}
class MouseClickMessage extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class KeyUpMessage extends Message {
	public var keycode: Int;
	public function new(k: Int) {super(); keycode = k;}
}
class MouseReleaseMessage extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class MouseMoveMessage extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}

interface MessageListener {
    public function receiveMessage(msg: Message): Bool;
}

class MessageManager {

    static var listeners = new Array<MessageListener>();

	public static function addListener(l:MessageListener) {
		listeners.push(l);
    }

	public static function removeListener(l:MessageListener) {
		listeners.remove(l);
    }

    public static function sendMessage(msg: Message) {
        for (l in listeners)
            if (l.receiveMessage(msg)) return;
		// trace("unconsumed message", msg);
    }

	public static function reset() {
		listeners = [];
	}

}