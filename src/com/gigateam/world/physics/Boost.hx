package com.gigateam.world.physics;
import com.gigateam.world.physics.shape.Vec;

/**
 * ...
 * @author Tiger
 */
class Boost 
{
	public var direction:Vec;
	public var acceleration:Float;
	public var targetVelocity:Float;
	public function new(dir:Vec, acc:Float, velocity:Float, skipDirectionClone:Bool=false) 
	{
		direction = skipDirectionClone ? dir.clone() : dir;
		direction.normalize();
		acceleration = Math.abs(acc);
		targetVelocity = Math.abs(velocity);
	}
	public static function fromXYZ(dirX:Float, dirY:Float, dirZ:Float, acc:Float, velocity:Float):Boost{
		var b:Boost = new Boost(new Vec(dirX, dirY, dirZ), acc, velocity);
		return b;
	}
	public function getVelocityVector(out:Vec=null):Vec{
		if (out == null){
			out = new Vec();
		}
		
		out.cloneFrom(direction);
		out.normalize();
		out.mul(targetVelocity);
		return out;
	}
	public function getAccelerationVector(out:Vec=null):Vec{
		if (out == null){
			out = new Vec();
		}
		
		out.cloneFrom(direction);
		out.normalize();
		out.mul(acceleration);
		return out;
	}
}