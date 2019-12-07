package com.gigateam.world.entity;
import com.gigateam.util.Debugger;
import com.gigateam.util.Scheduler;
import com.gigateam.world.WorldSimulator.EntityData;
import com.gigateam.world.WorldSimulator.StateData;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.logic.status.EntityState;
import com.gigateam.world.logic.status.INotifee;
import com.gigateam.world.logic.status.Notifier;
import com.gigateam.physics.shape.Vec;
import com.gigateam.physics.timeline.StateKeyframe;
import com.gigateam.physics.timeline.StateTimeline;

/**
 * ...
 * @author Tiger
 */
class StatefulEntity implements INotifee extends Entity
{
	private static var tmpState:StateKeyframe = StateKeyframe.empty();
	private var _lastStateTime:Int;
	private var _scheduler:Scheduler;
	private var stateTimeline:StateTimeline;
	private var _state:Notifier;
	public var states:Array<EntityState>;
	public var stateFps:UInt;
	
	public function new(scheduler:Scheduler, offset:Int, data:EntityData, x:Float, y:Float, z:Float) 
	{
		super(offset, data, x, y, z);
		_scheduler = scheduler;
		var statesData:Array<StateData> = data.states;
		states = [];
		_state = new Notifier(0, this);
		var i:UInt = 0;
		stateFps = data.stateFps;
		for (state in statesData){
			states.push(new EntityState(state, states.length, data.stateFps));
		}
		
		stateTimeline = new StateTimeline(0, 100);
	}
	public function timesup(notifier:Notifier, time:Float):Bool{
		return false;
	}
	public function getStateByIndex(i:UInt):EntityState{
		return states[i];
	}
	public function getStateByName(name:String):EntityState{
		var s:EntityState;
		for (state in states){
			s = cast state;
			if (s.name == name){
				return s;
			}
		}
		return null;
	}
	override public function pack(bytes:BytesStream, worldTime:Int = 0):Int{
		var sum:Int = super.pack(bytes, worldTime);
		var originOffset:Int = bytes.offset();
		
		bytes.write(_state.id());
		bytes.writeInt24(_lastStateTime);
		bytes.writeInt32(2384602);
		
		return sum + (bytes.offset() - originOffset);
	}
	override public function unpack(bytes:BytesStream, remoteWorldTime:Int = 0, localWorldTime:Int = 0):Int{
		var sum:Int = super.unpack(bytes, remoteWorldTime, localWorldTime);
		var originOffset:Int = bytes.offset();
		
		//_upState.restart(bytes.read(), 100);
		var stateId:Int = bytes.read();
		var stateTime:Int = bytes.readInt24();
		checksum = bytes.readInt32();
		var keyframe:StateKeyframe = new StateKeyframe(stateTime, stateId);
		stateTimeline.insertKeyframe(keyframe);
		
		return sum + (bytes.offset() - originOffset);
	}
	override public function interpolate(time:Int, tmp:Bool = false):Vec{
		var v:Vec = super.interpolate(time, tmp);
		time-= rewundTime;
		
		//Debugger.getInstance().log("time:" + Std.string(time));
		
		if (stateTimeline.interpolate(time, tmpState) == 0){
			//Debugger.getInstance().log("stateId:" + Std.string(tmpState.stateId));
			//Debugger.getInstance().log("stateLength:" + Std.string(states.length));
			//Debugger.getInstance().log("stateTime:" + Std.string(tmpState.time) + ", lastStateTime:" + Std.string(_lastStateTime) + "~");
			if (tmpState.time != _lastStateTime){
				changeMainState(tmpState.stateId, time, time-tmpState.time);
				_lastStateTime = tmpState.time;
			}
		}
		
		return v;
	}
	public function changeMainState(targetState:Int, worldTime:Int, offset:Int):Bool{
		return changeState(targetState, _state, worldTime, offset);
	}
	private function changeState(targetState:Int, notifier:Notifier, worldTime:Int, offset:Int):Bool{
		var state:EntityState = getStateByIndex(targetState);
		var floatOffset:Float = offset * 0.001;
		if (!state.loop){
			var restartTime:Float = worldTime * 0.001 + (state.duration - floatOffset);
			//Debugger.getInstance().log("hihi~:" + Std.string(restartTime)+",track.length:"+Std.string(_scheduler.track.length));
			_scheduler.add(notifier, restartTime);
			notifier.restart(targetState, restartTime);
		}else if (state.index == notifier.id()){
			return false;
		}else{
			notifier.restart(targetState, 0);
		}
		var intTime:Int = worldTime - offset;
		creator.stateChanged(this, targetState, offset);
		_lastStateTime = intTime;
		return true;
	}
	public function stateId():Int{
		return _state.id();
	}
}