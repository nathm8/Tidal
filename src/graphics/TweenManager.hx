package graphics;

import h2d.Camera;
import h2d.Object;
import h2d.Drawable;
import utilities.Vector2D;

class Tween {
    public var timeTotal:Float;
	public var timeElapsed:Float;
	public var kill:Bool = true; // flag to let tweens live forever
	var after: Tween;

    public function new(te:Float, tt:Float, a: Tween= null) {
		// negative te acts a delay
		timeElapsed = te;
		timeTotal = tt;
		after = a;
	}

	public function update(dt:Float) {
        timeElapsed += dt;
        if (timeElapsed > timeTotal) {
			timeElapsed = timeTotal;
			if (after != null)
				TweenManager.add(after);
		}
    }
}

class MoveBounceTween extends Tween {
	var drawable:Drawable;
	var x = [0, 1.1, 0.7, 1];
	var y = [0, -0.4, 1.5, 1];
	
	var original:{x:Float, y:Float};
	var target:{x:Float, y:Float};

	public function new(d:Drawable, orig:{x:Float, y:Float},  targ: {x:Float, y:Float}, te:Float, tt:Float, retreat=false) {
		super(te, tt);
		drawable = d;
		original = orig;
		target = targ;
		if (retreat){
			x[0] = 1; x[3] = 0;
			y[0] = 1; y[3] = 0;
		}
	}

	override function update(dt:Float) {
		super.update(dt);
		// negative te acts as a delay
		if (timeElapsed < 0)
			return;
		var t = Math.pow(timeElapsed / timeTotal, 5);
		// if (t > 0.5) {
		// 	var tt = timeElapsed / (timeTotal * timeElapsed);
		// 	t = tt > 1 ? 1 : tt;
		// }
		var bx = Math.pow(1 - t, 3) * x[0]
			+ 3 * Math.pow(1 - t, 2) * t * x[1]
			+ 3 * (1 - t) * Math.pow(t, 2) * x[2]
			+ Math.pow(t, 3) * x[3];
		var by = Math.pow(1 - bx, 3) * y[0]
			+ 3 * Math.pow(1 - bx, 2) * bx * y[1]
			+ 3 * (1 - bx) * Math.pow(bx, 2) * y[2]
			+ Math.pow(bx, 3) * y[3];
		drawable.x = (1 - by) * original.x + by*target.x;
		drawable.y = (1 - by) * original.y + by*target.y;
	}
}

class FadeTween extends Tween {
	var obj:Object;

	public function new(o:Object, te:Float, tt:Float) {
		super(te, tt);
		obj = o;
	}

	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		obj.alpha = 1-t;
	}
}

class DelayedCallTween extends Tween {
    var func: ()->Void;

	public function new(func:() -> Void, te:Float, tt:Float) {
        super(te, tt);
        this.func = func;
    }

	override function update(dt:Float) {
        super.update(dt);
        if (timeElapsed >= timeTotal)
            func();
    }

}

class LinearCameraMoveTween extends Tween {
	var originalPosition: Vector2D;
	var targetPosition: Vector2D;
	var camera: Camera;

	public function new(te: Float, tt: Float, c: Camera, o: Vector2D, t:Vector2D){
		super(te, tt);
		originalPosition = o;
		targetPosition = t;
		camera = c;
	}

	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		var p = originalPosition*(1-t) + targetPosition*t;
		camera.x = p.x;
		camera.y = p.y;
	}
}

class LinearCameraAnchorMoveTween extends Tween{
	var originalPosition: Vector2D;
	var targetPosition: Vector2D;
	var camera: Camera;

	public function new(te: Float, tt: Float, c: Camera, o: Vector2D, t:Vector2D){
		super(te, tt);
		originalPosition = o;
		targetPosition = t;
		camera = c;
	}
	override function update(dt:Float) {
		super.update(dt);
		var t = timeElapsed / timeTotal;
		var p = originalPosition*(1-t) + targetPosition*t;
		camera.anchorX = p.x;
		camera.anchorY = p.y;
	}
}

class TweenManager {
    static var tweens = new Array<Tween>();
    
    static public function update(dt: Float) {
        var to_remove = [];
        for (t in tweens) {
            t.update(dt);
            if (t.timeElapsed >= t.timeTotal)
                to_remove.push(t);
        }
        for (t in to_remove)
			if (t.kill)
            	tweens.remove(t);
    }

    static public function add(t: Tween) {
        tweens.push(t);
    }

    static public function remove(t: Tween) {
        tweens.remove(t);
    }

	static public function reset() {
		tweens = [];
	}
}