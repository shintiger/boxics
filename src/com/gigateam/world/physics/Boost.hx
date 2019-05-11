package com.gigateam.world.physics;
import com.gigateam.world.physics.shape.Vertex;

/**
 * ...
 * @author Tiger
 */
class Boost 
{
	public var direction:Vertex;
	public var acceleration:Float;
	public var targetVelocity:Float;
	public function new(dir:Vertex, acc:Float, velocity:Float, skipDirectionClone:Bool=false) 
	{
		direction = skipDirectionClone ? dir.clone() : dir;
		direction.normalize();
		acceleration = Math.abs(acc);
		targetVelocity = Math.abs(velocity);
	}
	public static function fromXYZ(dirX:Float, dirY:Float, dirZ:Float, acc:Float, velocity:Float):Boost{
		var b:Boost = new Boost(new Vertex(dirX, dirY, dirZ), acc, velocity);
		return b;
	}
	public function getVelocityVector(out:Vertex=null):Vertex{
		if (out == null){
			out = new Vertex();
		}
		
		out.cloneFrom(direction);
		out.normalize();
		out.mul(targetVelocity);
		return out;
	}
	public function getAccelerationVector(out:Vertex=null):Vertex{
		if (out == null){
			out = new Vertex();
		}
		
		out.cloneFrom(direction);
		out.normalize();
		out.mul(acceleration);
		return out;
	}
}