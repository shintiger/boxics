package com.gigateam.world.physics.timeline;
import com.gigateam.world.physics.shape.Vec;

/**
 * ...
 * @author Tiger
 */
class TweenKeyframe extends Keyframe 
{
	public var faceRotation:Float = 0;
	public var rotationZ:Float = 0;
	public var rotationX:Float = 0;
	public var origin:Vec;
	public function new(_time:Int, x:Float=0, y:Float=0, z:Float=0, rotZ:Float=0, rotX:Float=0, rotFace:Float=0) 
	{
		super(_time);
		origin = new Vec(x, y, z);
		rotationZ = rotZ;
		rotationX = rotX;
		faceRotation = rotFace;
	}
	public static function empty():TweenKeyframe{
		return new TweenKeyframe(0);
	}
	public function dispose():Void{
		origin = null;
	}
}