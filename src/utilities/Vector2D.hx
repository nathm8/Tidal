/**
	Modified from Mark Knol's code at https://github.com/markknol/hx-vector2d/blob/master/src/geom/Vector2d.hx
**/
package utilities;

import box2d.common.Vec2;

@:dox(show) private typedef Vector2DImpl = {x:Float, y:Float}

/**
	Represents a two dimensional vector.

	@author Mark Knol
**/
@:forward abstract Vector2D(Vector2DImpl) from Vector2DImpl to Vector2DImpl {
	public static function empty() return new Vector2D(0.0, 0.0);
	/** Construct a new vector instance. **/
	public inline function new(x=0.0, y=0.0) {
		this = {x: x, y: y};
	}

	private var self(get, never):Vector2D;

	private inline function get_self():Vector2D {
		return (this : Vector2D);
	}

	/** Sets component values of `this` values. If `y` is ommited, both components will be set to `x`. **/
	public inline function set(x:Float, y:Float):Vector2D {
		this.x = x;
		this.y = y;
		return this;
	}

	/** Clone `this` vector into new Vector2D instance. **/
	public inline function clone():Vector2D {
		return new Vector2D(this.x, this.y);
	}

	/** Copy component values from `target` vector to `this` vector. **/
	public inline function copy(target:Vector2D):Vector2D {
		this.x = target.x;
		this.y = target.y;
		return this;
	}

	/** Round component values of `this` vector. **/
	public inline function round():Vector2D {
		this.x = Math.fround(this.x);
		this.y = Math.fround(this.y);
		return this;
	}

	/** floor (round down) component values of `this` vector. **/
	public inline function floor():Vector2D {
		this.x = Math.ffloor(this.x);
		this.y = Math.ffloor(this.y);
		return this;
	}

	/** Ceil (round up) component values of `this` vector. **/
	public inline function ceil():Vector2D {
		this.x = Math.fceil(this.x);
		this.y = Math.fceil(this.y);
		return this;
	}

	/** Convert `this` component values to absolute values. **/
	public inline function abs():Vector2D {
		this.x = Math.abs(this.x);
		this.y = Math.abs(this.y);
		return this;
	}

	/** @return Length of this vector  `x*x + y*y`. **/
	public var length(get, set):Float;

	private inline function get_length():Float {
		return this.x * this.x + this.y * this.y;
	}

	private inline function set_length(value:Float):Float {
		var length = get_length();
		if (length == 0) return 0;
		var l = value / length;
		this.x *= l;
		this.y *= l;
		return value;
	}

	/** @return true if given vector is in range `(this-vector).length < range*range` **/
	public function inRange(vector:Vector2D, range:Float):Bool {
		return (self - vector).length < range * range;
	}

	/** @return Distance to given vector. Same as `(this-vector).magnitude` **/
	public function distanceTo(vector:Vector2D):Float {
		return (self - vector).magnitude;
	}

	public function manhattanDistanceTo(vector:Vector2D):Float {
		return Math.abs(self.x - vector.x) + Math.abs(self.y - vector.y);
	}

	/** @return Distance of given vectors. Same as `a.distanceTo(b)` **/
	public inline static function distanceOf(a:Vector2D, b:Vector2D):Float {
		return a.distanceTo(b);
	}

	/** @return scalar number of dot product `x * vector.x + y * vector.y`. **/
	public inline function dot(vector:Vector2D):Float {
		var component:Vector2D = self * vector;
		return component.x + component.y;
	}

	/** @return scalar number of vector product `x * vector.y - y * vector.x`. **/
	public inline function vector(vector:Vector2D):Float {
		return this.x * vector.y - this.y * vector.x;
	}

	/** @return new vector unit of this vector `this/magnitude`. **/
	public inline function normalize():Vector2D {
		return self / magnitude;
	}

	/** Obtains the projection of current vector on a given axis. **/
	public inline function projection(to:Vector2D):Float {
		return dot(to.normalize());
	}

	/** Obtain angle of `this` vector. **/
	public function angle():Float {
		return Math.atan2(this.y, this.x);
	}

	public function rotateAroundAngle(angle:Float):Vector2D {
		var x = this.x;
		var y = this.y;
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		this.x = x * c - y * s;
		this.y = x * s + y * c;
		return this;
	}

	/** Obtains the smaller angle (radians) sandwiched from current to given vector. **/
	public inline function moveTo(angle:Float, distance:Float):Vector2D {
		this.x += Math.cos(angle) * distance;
		this.y += Math.sin(angle) * distance;
		return this;
	}

	/** @return New vector instance that is made from the smallest components of two vectors. **/
	public static function minOf(a:Vector2D, b:Vector2D):Vector2D {
		return a.clone().min(b);
	}

	/** @return New vector instance that is made from the largest components of two vectors. **/
	public static function maxOf(a:Vector2D, b:Vector2D):Vector2D {
		return a.clone().max(b);
	}

	/** @return Sets this vector instance components to the smallest components of given vectors. **/
	public function min(v:Vector2D):Vector2D {
		this.x = Math.min(this.x, v.x);
		this.y = Math.min(this.y, v.y);
		return this;
	}

	/** @return Sets this vector instance components to the largest components of given vectors. **/
	public function max(v:Vector2D):Vector2D {
		this.x = Math.max(this.x, v.x);
		this.y = Math.max(this.y, v.y);
		return this;
	}

	/** Obtains the projection of `this` vector on a given axis. **/
	public inline function polar(magnitude:Float, angle:Float) {
		this.x = magnitude * Math.cos(angle);
		this.y = magnitude * Math.sin(angle);
	}

	/** @return Magnitude of vector (squared length). **/
	public var magnitude(get, set):Float;

	private inline function get_magnitude():Float {
		if (length == 0) return 0;
		return Math.sqrt(length);
	}

	private inline function set_magnitude(magnitude:Float):Float {
		polar(magnitude, angle());
		return magnitude;
	}

	/** Invert x component of `this` vector `x *= -1`. **/
	public inline function invertX():Void this.x *= -1;

	/** Invert y component of `this` vector `y *= -1`. **/
	public inline function invertY():Void this.y *= -1;

	/** Invert both component values of `this` vector `this *= -1`. **/
	public inline function invertAssign():Vector2D {
		this.x *= -1;
		this.y *= -1;
		return this;
	}

	/** (new instance) Invert both component values of `this` vector. **/
	@:op(-A) public inline function invert():Vector2D {
		return clone().invertAssign();
	}

	/** Sum given vector to `this` component values. Modifies this instance. Can also be used with `a+=b` operator. **/
	@:commutative @:op(A += B) public inline function addAssign(by:Vector2D):Vector2D {
		this.x += by.x;
		this.y += by.y;
		return this;
	}

	/** Substract given vector from `this` component values. Modifies this instance. Can also be used with `a-=b` operator. **/
	@:commutative @:op(A -= B) public inline function substractAssign(by:Vector2D):Vector2D {
		this.x -= by.x;
		this.y -= by.y;
		return this;
	}

	/** Multiply `this` component values by given vector. Modifies this instance. Can also be used with `a*=b` operator. **/
	@:commutative @:op(A *= B) public inline function multiplyAssign(by:Vector2D):Vector2D {
		this.x *= by.x;
		this.y *= by.y;
		return this;
	}

	/** Divide `this` component values by given vector. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A /= B) public inline function divideAssign(by:Vector2D):Vector2D {
		this.x /= by.x;
		this.y /= by.y;
		return this;
	}

	/** Sets the remainder on `this` component values from given vector. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A %= B) public inline function moduloAssign(by:Vector2D):Vector2D {
		this.x %= by.x;
		this.y %= by.y;
		return this;
	}

	/** Clone `this` and sum given vector. Returns new vector instance. Can also be used with `a+b` operator. **/
	@:commutative @:op(A + B) public inline function add(vector:Vector2D):Vector2D {
		return clone().addAssign(vector);
	}

	/** Clone `this` and substract the given vector. Returns new instance. Can also be used with `a-b` operator. **/
	@:commutative @:op(A - B) public inline function substract(vector:Vector2D):Vector2D {
		return clone().substractAssign(vector);
	}

	/** Clone `this` and multiply with given vector. Returns new instance. Can also be used with `a*b` operator. **/
	@:op(A * B) public inline function multiply(vector:Vector2D):Vector2D {
		return clone().multiplyAssign(vector);
	}

	/** Clone `this` and divide by given vector. Returns new instance. Can also be used with `a/b` operator. **/
	@:commutative @:op(A / B) public inline function divide(vector:Vector2D):Vector2D {
		return clone().divideAssign(vector);
	}

	/** Clone `this` and sets remainder from given vector. Returns new instance. Can also be used with `a%b` operator. **/
	@:commutative @:op(A % B) public inline function modulo(vector:Vector2D):Vector2D {
		return clone().moduloAssign(vector);
	}

	/** Sum given value to both of `this` component values. Modifies this instance. Can also be used with `a+=b` operator. **/
	@:op(A += B) public inline function addFloatAssign(v:Float):Vector2D {
		this.x += v;
		this.y += v;
		return this;
	}

	/** Substract given value to both of `this` component values. Modifies this instance. Can also be used with `a-=b` operator. **/
	@:commutative @:op(A -= B) public inline function substractFloatAssign(v:Float):Vector2D {
		this.x -= v;
		this.y -= v;
		return this;
	}

	/** Multiply `this` component values with given value. Modifies this instance. Can also be used with `a*=b` operator. **/
	@:commutative @:op(A *= B) public inline function multiplyFloatAssign(v:Float):Vector2D {
		this.x *= v;
		this.y *= v;
		return this;
	}

	/** Divide `this` component values with given value. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A /= B) public inline function divideFloatAssign(v:Float):Vector2D {
		this.x /= v;
		this.y /= v;
		return this;
	}

	/** Sets remainder of `this` component values from given value. Modifies this instance. Can also be used with `a%=b` operator. **/
	@:op(A %= B) public inline function moduloFloatAssign(v:Float):Vector2D {
		this.x %= v;
		this.y %= v;
		return this;
	}

	/** Clone `this` and sum given value. Returns new vector instance. Can also be used with `a+b` operator. **/
	@:commutative @:op(A + B) public inline function addFloat(value:Float):Vector2D {
		return clone().addFloatAssign(value);
	}

	/** Clone `this` and substract given value. Returns new vector instance. Can also be used with `a-b` operator. **/
	@:commutative @:op(A - B) public inline function substractFloat(value:Float):Vector2D {
		return clone().substractFloatAssign(value);
	}

	/** Clone `this` and multiply given value. Returns new vector instance. Can also be used with `a*b` operator. **/
	@:commutative @:op(A * B) public inline function multiplyFloat(value:Float):Vector2D {
		return clone().multiplyFloatAssign(value);
	}

	/** Clone `this` and divide given value. Returns new vector instance. Can also be used with `a/b` operator. **/
	@:commutative @:op(A / B) public inline function divideFloat(value:Float):Vector2D {
		return clone().divideFloatAssign(value);
	}

	/** Clone `this` set remainder from given value. Returns new vector instance. Can also be used with `a%b` operator. **/
	@:commutative @:op(A % B) public inline function moduloFloat(value:Float):Vector2D {
		return clone().moduloFloatAssign(value);
	}

	/** @return `true` if both component values of `this` are same of given vector. **/
	@:commutative @:op(A == B) public inline function equals(v:Vector2D):Bool {
		return this.x == v.x && this.y == v.y;
	}

	/** @return `true` if a component values of `this` is not the same at given vector. **/
	@:commutative @:op(A != B) public inline function notEquals(v:Vector2D):Bool {
		return !(this == v);
	}

	/** Converts `this` vector to array `[x,y]`. **/
	@:to public inline function toArray():Array<Float> {
		return [this.x, this.y];
	}

	/** @return `true` if `this` is `null`. **/
	@:op(!a) public inline function isNil() return this == null;

	/** @return typed Vector2D `null` value **/
	static public inline function nil<A, B>():Vector2D return null;

	@:from public static inline function fromArray(vec:Array<Float>):Vector2D return new Vector2D(vec[0], vec[1]);
	
	#if heaps
	/** Cast Heaps Point to Vector2D. They unify because both have same component values. **/
	@:from public static inline function fromHeapsPoint(point:h2d.col.Point):Vector2D return cast point;

	/** Cast this Vector2D to Heaps Point class. They unify because both have same component values. **/
	@:to public inline function toHeapsPoint():h2d.col.Point return cast this;
	#end

	#if box2d
	@:from public static inline function fromBox2DPoint(v: Vec2):Vector2D return cast v;

	/** Cast this Vector2D to Heaps Point class. They unify because both have same component values. **/
	@:to public inline function toBox2DVec():Vec2 return cast this;
	#end

	#if liquidfun
	@:from public static inline function fromBox2DPoint(v: Vec2):Vector2D return cast v;

	/** Cast this Vector2D to Heaps Point class. They unify because both have same component values. **/
	@:to public inline function toBox2DVec():Vec2 return cast this;
	#end

	public inline function toString(prefix:String = null):String {
		return (if (prefix != null) '${prefix}=' else '') + '{x:${this.x}, y:${this.y}}';
	}

}