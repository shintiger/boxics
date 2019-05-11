package com.gigateam.world.physics.shape;

/**
 * ...
 * @author Tiger
 */
class Vertex
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public function new(_x:Float=0, _y:Float=0, _z:Float=0) 
	{
		x = _x;
		y = _y;
		z = _z;
	}
	public function dot(b:Vertex):Float{
		var scalar:Float = 0;
		scalar += x * b.x;
		scalar += y * b.y;
		scalar += z * b.z;
		return scalar;
	}
	public function cross(b:Vertex, out:Vertex=null):Vertex{
		if(out==null){
			out = new Vertex();
		}
		out.x = y * b.z - z * b.y;
		out.y = z * b.x - x * b.z;
		out.z = x * b.y - y * b.x;
		
		return out;
	}
	public function mul(magnitude:Float):Vertex{
		x *= magnitude;
		y *= magnitude;
		z *= magnitude;
		return this;
	}
	public function equalZero():Bool{
		return (x == 0 && y == 0 && z == 0);
	}
	public function length():Float{
		return Math.sqrt(x * x + y * y + z * z);
	}
	public function clone(out:Vertex=null):Vertex{
		if (out == null){
			out = new Vertex();
		}
		out.cloneFrom(this);
		return out;
	}
	public function cloneFrom(src:Vertex):Void{
		x = src.x;
		y = src.y;
		z = src.z;
	}
	public function plus(v:Vertex):Vertex{
		x += v.x;
		y += v.y;
		z += v.z;
		return this;
	}
	public function minus(v:Vertex):Vertex{
		x -= v.x;
		y -= v.y;
		z -= v.z;
		return this;
	}
	public function normalize():Void{
		var magnitude:Float = getMagnitude();
		if (magnitude != 0){
			x = x / magnitude;
			y = y / magnitude;
			z = z / magnitude;
		}
	}
	public function getMagnitude():Float{
		return Math.sqrt(x * x + y * y + z * z);
	}
	public function toString():String{
		return "[vertex " + Std.string(x) + "," + Std.string(y) + "," + Std.string(z) + "]";
	}
}