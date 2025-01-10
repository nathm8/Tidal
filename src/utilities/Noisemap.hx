package utilities;

import hxd.Perlin;

class Noisemap {
	var noise = new Perlin();
	var seed = RNGManager.seed;
	
	public function new() {
		noise.normalize = true;
	}

	public function getNoiseAtTheta(theta: Float) : Float {
		var n = 0.0;
		for (s in [1, 2, 3]) {
			var x = Math.cos(theta)/s + 1;
			var y = Math.sin(theta)/s + 1;
			n += s*noise.perlin(seed, x, y, s, 5, 2.2);
		}
		return n;
    }
}