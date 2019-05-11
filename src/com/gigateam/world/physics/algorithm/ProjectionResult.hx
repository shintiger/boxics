package com.gigateam.world.physics.algorithm;
import com.gigateam.world.physics.shape.Vertex;

/**
 * ...
 * @author Tiger
 */
class ProjectionResult
{
	public var velocity:Vertex;
	public var extent:Float;
	public var entryTime:Float;
	public var MTV:Float = 0;
	public var axis:Vertex;
	public var scalarLeftMax:Float;
	public var scalarRightMax:Float;
	public var scalarLeftMin:Float;
	public var scalarRightMin:Float;
	
	public var direction:Vertex;
	public var MTD:Vertex;
	public var MTDLength:Float;
	public function new() 
	{
		
	}
	public function calc():Void{
		if(axis!=null){
			var squared:Float = axis.dot(axis);

			// intersection depth on that axis, but squared.
			var intersectionDepthSquared:Float = (MTV * MTV) / squared;

			// if the intersection amount on that axis is smaller than the current mtd
			// we found, or the mtd hasn't been initialised yet (mtdLengthSquared < 0 
			// is used to signal an invalid mtd), our current mtd will be 
			// a combination of the axis and the intersection amount on that axis.
			// As more axes are being tested, the final mtd will be the axis with the
			// least amount of intersection.
			MTD = axis.clone().mul(MTV / squared);
			MTDLength = intersectionDepthSquared;
			direction = axis.clone().mul( (MTV < 0)? -1 : 1);
		}
	}
}