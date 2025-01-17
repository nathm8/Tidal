package utilities;

import hxd.Rand;

class RNGManager {
    static var init = false;
    public static var seed(get, null): Int;
    public static var rand(get, null): Rand;
    
    public static function initialise() {
        if (init) return;
        init = true;
        seed = Std.random(0x7FFFFFFF);
        rand = new Rand(seed);
    }

    public static function reset() {
        init = false;
        initialise();
    }

    public static function get_seed(): Int {
        if (!init) initialise();
        return seed;
    }

    public static function get_rand(): Rand {
        if (!init) initialise();
        return rand;
    }
}