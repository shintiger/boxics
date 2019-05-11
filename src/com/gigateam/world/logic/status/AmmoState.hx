package com.gigateam.world.logic.status;
import com.gigateam.util.ITask;
import com.gigateam.util.Scheduler;

/**
 * ...
 * @author Tiger
 */
class AmmoState implements ITask
{
	public var allowPartialConsume:Bool = true;
	public var coolDown:Float;
	public var scheduler:Scheduler;
	public var reloadType:Int = AmmoReload.ALWAYS;
	private var _volume:Int;
	private var _capacity:Int;
	public var _startTime:Float = 0;
	public function new(magazine:Int, cd:Float) 
	{
		_capacity = magazine;
		_volume = _capacity;
		coolDown = cd;
	}
	public function trigger(time:Float):Bool{
		if (reloadType != AmmoReload.ALWAYS){
			_volume = _capacity;
		}
		return false;
	}
	public function start(startTime:Float):Void{
		_startTime = startTime;
	}
	public function getTriggerTime():Float{
		return _startTime+coolDown;
	}
	public function disable():Void{
		throw "AmmoState was design for continuous.";
	}
	/*
	 * If successful
	 */
	public function consume(time:Float, count:Int):Int{
		var ammo:Int = getAmmo(time);
		var reloading:Bool = isReloading(time);
		if (ammo <= 0){
			return 0;
		}else if (!allowPartialConsume && ammo<count){
			return 0;
		}
		var used:Int = count;
		if (ammo < count){
			used = ammo;
		}
		_consume(time, used, reloading);
		return used;
	}
	public function isReloading(time:Float):Bool{
		return (_startTime+coolDown) > time;
	}
	private function _consume(time:Float, count:Int, reloading:Bool):Void{
		if (reloadType != AmmoReload.ALWAYS){
			_volume-= count;
			if (reloadType!=AmmoReload.MANUAL && _volume <= 0 && scheduler!=null){
				scheduler.add(this, time);
			}
		}else{
			if (!reloading){
				if(scheduler!=null){
					scheduler.add(this, time);
				}
				_startTime -= coolDown;
			}
			_startTime+= timePerBullet() * count;
			if(scheduler!=null){
				scheduler.sort();
			}
		}
	}
	public function timePerBullet():Float{
		return coolDown / _capacity;
	}
	public function getAmmoPercentage(time:Float):Float{
		if(reloadType != AmmoReload.ALWAYS || isReloading(time)){
			var percent:Float = (time-_startTime) / coolDown;
			if (percent > 1){
				percent = 1;
			}
			return percent;
		}
		return _volume/_capacity;
	}
	public function getAmmo(time:Float):Int{
		if (!isReloading(time) && reloadType == AmmoReload.ALWAYS){
			return _volume;
		}
		return Math.floor(getAmmoPercentage(time) * _capacity);
	}
}