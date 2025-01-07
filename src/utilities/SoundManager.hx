package utilities;

import hxd.snd.Manager;
import hxd.res.Sound;
import utilities.MessageManager;

class SoundManager implements MessageListener{
    
    public static var soundManager : SoundManager;
    static var deathSounds: Array<Sound>;
    static var musketSounds: Array<Sound>;
    static var manager: Manager;

    static public function initialise() {
        if (soundManager == null) soundManager = new SoundManager();
        manager = Manager.get();
    }

    function new(){}
    
    static public function reset() {
        MessageManager.addListener(soundManager);
    }

    // static public function sync(c: Camera) {
    //     var cam = new h2d.Camera();
    //     manager.listener.syncCamera(c);
    // }

	public function receiveMessage(msg:Message):Bool {
        return false;
	}
}