package com.gigateam.physics.shape;

/**
 * ...
 * @author Tiger
 */
class Bounding
{
	public var boundingType:Int;
	public var origin:Vec;
	public function new(p:Vec) 
	{
		origin = new Vec(p.x, p.y, p.z);
		boundingType = 0;
	}
	public function getCentralPoint():Vec{
		return origin;
	}
}