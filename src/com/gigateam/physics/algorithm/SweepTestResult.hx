package com.gigateam.physics.algorithm;
import com.gigateam.physics.shape.AABB;
import com.gigateam.physics.shape.Vec;

/**
 * ...
 * @author Tiger
 */
class SweepTestResult 
{
	public var entryTime:Float;
	public var normalX:Int;
	public var normalY:Int;
	public var normalZ:Int;
	public var affectingAxis:Vec = new Vec();
	public var ratio:Int = 10000;
	public var isCollided:Bool;
	public var target:AABB;
	public var movingApart:Bool = false;
	public function new() 
	{
		entryTime = ratio;
	}
	public function cloneFrom(cr:SweepTestResult):Void{
		entryTime = cr.entryTime;
		normalX = cr.normalX;
		normalY = cr.normalY;
		normalZ = cr.normalZ;
		ratio = cr.ratio;
		isCollided = cr.isCollided;
		target = cr.target;
		affectingAxis = cr.affectingAxis.clone();
		movingApart = cr.movingApart;
	}
	public function clone():SweepTestResult{
		var str:SweepTestResult = new SweepTestResult();
		str.cloneFrom(this);
		return str;
	}
}