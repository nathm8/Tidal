package utilities;

import hxd.Rand;

class RNGManager {
    static var init = false;
    public static var rand: Rand;
    
    public static function initialise() {
        if (init) return;
        init = true;
        rand = Rand.create();
    }
}