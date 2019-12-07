package com.gigateam.physics.timeline;

/**
 * ...
 * @author Tiger
 */
class StateTimeline extends Timeline
{
	
	public function new(_offset:Int, alive:Int) 
	{
		super(_offset, alive);
	}
	public function interpolate(time:Int, frame:StateKeyframe):Int{
		time-= offset;
		
		var last:StateKeyframe = cast lastFrame(time);
		var next:StateKeyframe = cast nextFrame(time);
		
		if (last == null){
			return -1;
		}else if (last.time > time || (next!=null && next.time < time)){
			return -2;
		}
		//var percentage:Float;
		frame.time = last.time;
		frame.stateId = last.stateId;

		return 0;
	}
}