package com.gigateam.world.physics.timeline;
import com.gigateam.util.Debugger;
import com.gigateam.world.physics.shape.Vertex;

/**
 * ...
 * @author Tiger
 */
class TweenTimeline extends Timeline 
{

	public function new(_offset:Int, alive:Int) 
	{
		super(_offset, alive);
	}
	public function interpolate(time:Int, frame:TweenKeyframe, easing:Int = 0):Int{
		time-= offset;
		var last:TweenKeyframe = cast lastFrame(time);
		var next:TweenKeyframe = cast nextFrame(time);
		
		
		if (last == null){
			return -1;
		}else if (last.time > time || (next!=null && next.time < time)){
			return -2;
		}
		var percentage:Float;
		if (next == null){
			frame.origin.x = last.origin.x;
			frame.origin.y = last.origin.y;
			frame.origin.z = last.origin.z;
			frame.rotationZ = last.rotationZ;
			frame.rotationX = last.rotationX;
			frame.faceRotation = last.faceRotation;
			frame.time = last.time;
			return 1;
		}
		var percentage:Float = (time-last.time) / (next.time-last.time);
		frame.time = time;
		frame.origin.x = last.origin.x + (next.origin.x - last.origin.x) * percentage;
		frame.origin.y = last.origin.y + (next.origin.y - last.origin.y) * percentage;
		frame.origin.z = last.origin.z + (next.origin.z - last.origin.z) * percentage;
		frame.rotationZ = last.rotationZ + (next.rotationZ - last.rotationZ) * percentage;
		frame.rotationX = last.rotationX + (next.rotationX - last.rotationX) * percentage;
		frame.faceRotation = last.faceRotation + (next.faceRotation - last.faceRotation) * percentage;

		return 0;
	}
}