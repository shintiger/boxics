package com.gigateam.world.physics.timeline;

/**
 * ...
 * @author Tiger
 */
class VolumeKeyframe extends Keyframe
{
	public var max:Int;
	public var value:Int;
	public var duration:Array<Float> = [];
	public var dps:Array<Int> = [];
	public function new(_time:Int) 
	{
		super(_time);
	}
	public function clone():VolumeKeyframe{
		var keyframe:VolumeKeyframe = new VolumeKeyframe(time);
		keyframe.value = value;
		keyframe.duration = duration.slice(0);
		keyframe.dps = dps.slice(0);
		keyframe.max = max;
		
		return keyframe;
	}
}