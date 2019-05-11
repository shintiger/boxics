package com.gigateam.world.logic;

/**
 * ...
 * @author Tiger
 * 
 * For example, Peter have a ability A call Dragon Blast, it has 2 bullets and take 4 seconds to cool down for 1.
 * Then duration is 4x2 = 8000 ms, division is 2(bullet), update startTime to t -  when Peter use 
 */
class CoolDown 
{
	private var _offset:Int;
	private var _duration:Map<Int, Int>;
	private var _startTime:Map<Int, Int>;
	private var _bullet:Map<Int, Int>;
	public function new(offsetTime:Int) 
	{
		offset = offsetTime;
	}
	public function add(id:Int, duration:Int, bullet:Int = 1, startTime:Int=0):Void{
		_duration.set(id, duration);
		_startTime.set(id, startTime);
		_bullet.set(id, division);
	}
	public function getBullet(id:Int, time:Int):Int{
		time -= _offset;
		var d:Int = time - _startTime.get(id));
		var perBullet:Int = Std.int(_duration.get(id) / _bullet.get(id));
		var bullet:Int = Std.int(d / perBullet);
	}
	public function use(id:Int, time:Int):Void{
		time -= _offset;
	}
}