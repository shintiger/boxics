package com.gigateam.world.logic.status;
import com.gigateam.world.WorldSimulator.StateData;

/**
 * ...
 * @author Tiger
 */
class EntityState
{
	public static inline var IDLE:Int = 0;
	public static inline var WALKING:Int = 1;
	public static inline var READY_JUMP:Int = 2;
	public static inline var JUMPPING:Int = 3;
	public static inline var FALLING:Int = 4;
	public static inline var GROUNDING:Int = 5;
	public static inline var STUNNING:Int = 6;
	
	public static inline var DOWN_IDLE:Int = 100;
	public static inline var DOWN_WALKING:Int = 101;
	public static inline var DOWN_NONE:Int = 102;
	
	public var index:Int;
	public var name:String;
	public var duration:Float;
	public var next:String;
	public var loop:Bool;
	
	public function new(data:StateData, i:Int, fps:UInt){
		index = i;
		name = data.name;
		duration = data.duration / fps;
		next = data.next;
		loop = data.loop;
	}
	public static function getPriority(_id:Int):Int{
		switch(_id){
			case IDLE:return 0;
			case WALKING:return 0;
			case READY_JUMP:return 0;
			case FALLING:return 0;
			case GROUNDING:return 0;
			case JUMPPING:return 0;
			
			case STUNNING:return 1;
		}
		return -1;
	}
}