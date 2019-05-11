package com.gigateam.world.logic.status;
import com.gigateam.util.Debugger;
import com.gigateam.util.ITask;

/**
 * ...
 * @author Tiger
 */
class Notifier implements ITask
{
	private var _id:Int;
	private var _timeout:Float = 0;
	private var _startTime:Float = 0;
	private var _observator:INotifee;
	public function new(id:Int, observator:INotifee) 
	{
		_observator = observator;
		_id = id;
	}
	public function disable():Void{
		_timeout = 0;
	}
	public function trigger(time:Float):Bool{
		if (_timeout == 0){
			return false;
		}
		return _observator.timesup(this, time);
	}
	public function start(startTime:Float):Void{
		_startTime = startTime;
	}
	public function getTriggerTime():Float{
		return _startTime+_timeout;
	}
	public function restart(newId:Int, timeout:Float):Void{
		//var oldId:Int = _id;
		
		_id = newId;
		//Debugger.getInstance().log("Id changed:["+Std.string(oldId)+","+Std.string(newId)+"]");
		_startTime = 0;
		_timeout = timeout;
	}
	public function id():Int{
		return _id;
	}
}