package com.gigateam.world.physics.shape;

/**
 * ...
 * @author Tiger
 */
class Bounding
{
	public var boundingType:Int;
	public var origin:Vertex;
	public function new(p:Vertex) 
	{
		origin = new Vertex(p.x, p.y, p.z);
		boundingType = 0;
	}
	public function getCentralPoint():Vertex{
		return origin;
	}
}