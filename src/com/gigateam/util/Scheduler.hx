package com.gigateam.util;

/**
 * ...
 * @author Tiger
 */
class Scheduler 
{
	public var offset:Float = 0;
	public var advancedTime:Float = 0;
	public var track:Array<ITask>;
	private static var _instance:Scheduler;
	public function new() 
	{
		track = [];
	}
	public function add(item:ITask, givenTime:Float=-1):Void{
		addItem(item, givenTime);
		sort();
	}
	public function addRelativeTime(item:ITask, triggerAfterTime:Float =-1):Void{
		add(item, advancedTime+triggerAfterTime);
	}
	private function addItem(item:ITask, givenTime:Float):Void{
		track.push(item);
		if (givenTime < 0){
			givenTime = advancedTime;
		}
		item.start(givenTime);
	}
	public function getTaskAfter(deltaTime:Float = 0):ITask{
		var i:Int = 0;
		var startupTime:Float = advancedTime+deltaTime;
		while (i < track.length){
			if (track[i].getTriggerTime() >= startupTime){
				return track[i];
			}
			i++;
		}
		return null;
	}
	public function getTaskBefore(deltaTime:Float = 0):ITask{
		var i:Int = track.length;
		var startupTime:Float = advancedTime+deltaTime;
		while (i < track.length){
			i--;
			if (track[i].getTriggerTime() <= startupTime){
				return track[i];
			}
		}
		return null;
	}
	//Delta time
	public function advanceTime(deltaTime:Float):Void{
		advanceStartupTime(advancedTime+deltaTime);
	}
	public function expire(item:ITask):Int{
		var i:Int = 0;
		while (i < track.length){
			if (track[i] == item){
				track.splice(i, 1);
				return i;
			}
			i++;
		}
		return -1;
	}
	//So-called timestamp collapsed
	public function advanceStartupTime(startupTime:Float):Void{
		advancedTime = startupTime-offset;
		var task:ITask;
		while(track.length>0){
			if (advancedTime <= track[0].getTriggerTime()){
				break;
			}
			task = track.shift();
			if (task.trigger(advancedTime)){
				add(task);
			}
		}
	}
	public function remove(task:ITask):Int{
		var index:Int = track.indexOf(task);
		if (index < 0){
			return index;
		}
		track.remove(task);
		return index;
	}
	public static function getDefault():Scheduler{
		if (_instance == null){
			_instance = new Scheduler();
		}
		return _instance;
	}
	public function sort():Void{
		track.sort(function(a:ITask, b:ITask):Int {
			if (a.getTriggerTime() < b.getTriggerTime()) return -1;
			else if (a.getTriggerTime() > b.getTriggerTime()) return 1;
			return 0;
		});
	}
}