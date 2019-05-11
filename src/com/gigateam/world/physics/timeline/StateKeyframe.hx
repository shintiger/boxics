package com.gigateam.world.physics.timeline;

/**
 * ...
 * @author Tiger
 */
class StateKeyframe extends Keyframe
{
	public var stateId:Int;
	public function new(_time:Int, _stateId:Int) 
	{
		super(_time);
		stateId = _stateId;
	}
	public static function empty():StateKeyframe{
		return new StateKeyframe(0, -1);
	}
}