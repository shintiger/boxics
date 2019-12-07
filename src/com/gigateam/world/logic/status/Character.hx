package com.gigateam.world.logic.status;
import com.gigateam.util.Debugger;
import com.gigateam.util.Scheduler;
import com.gigateam.world.WorldSimulator.EntityData;
import com.gigateam.world.WorldSimulator.StateData;
import com.gigateam.world.entity.Entity;
import com.gigateam.world.entity.StatefulEntity;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.logic.KeyState;
import com.gigateam.world.network.NetworkEntityPool;
import com.gigateam.world.network.NetworkEvent;
import com.gigateam.physics.Boost;
import com.gigateam.physics.Impulse;
import com.gigateam.physics.entity.Body;
import com.gigateam.physics.entity.ICollisionNotifier;
import com.gigateam.physics.math.AxisType;
import com.gigateam.physics.shape.AABB;
import com.gigateam.physics.shape.Vec;
import com.gigateam.physics.timeline.StateKeyframe;
import com.gigateam.physics.timeline.StateTimeline;
import com.gigateam.physics.timeline.Timeline;
import com.gigateam.physics.timeline.VolumeKeyframe;
import com.gigateam.physics.timeline.VolumeTimeline;

/**
 * ...
 * @author Tiger
 */
class Character extends StatefulEntity
{
	private static inline var UPSTATE_NOTIFIER:Int = 1;
	private static inline var DOWNSTATE_NOTIFIER:Int = 2;
	private var _currentUpState:Int;
	private var _currentDownState:Int;
	private var _downState:Notifier;
	private var _timeoutMap:Map<Int, Int>;
	
	public var ammoStates:Array<AmmoState>;
	
	public var dead:Bool = false;

	//Infomation
	public var hp:VolumeTimeline;
	public var latestHp:Int = 0;
	
	public var name:String = "";
	
	public function new(scheduler:Scheduler, aStates:Array<AmmoState>, offset:Int, data:EntityData, x:Float, y:Float, z:Float) 
	{
		super(scheduler, offset, data, x, y, z);
		
		ammoStates = aStates;
		hp = new VolumeTimeline(0, 400, 1000);
		
		_downState = new Notifier(EntityState.DOWN_NONE, this);
		_timeoutMap = new Map<Int, Int>();
		_timeoutMap.set(EntityState.READY_JUMP, EntityState.JUMPPING);
	}
	override public function interpolate(time:Int, tmp:Bool = false):Vec{
		var result:Vec = super.interpolate(time, tmp);
		latestHp = hp.valueAt(time);
		return result;
	}
	override public function pack(bytes:BytesStream, worldTime:Int = 0):Int{
		var sum:Int = super.pack(bytes, worldTime);
		var originOffset:Int = bytes.offset();
		
		bytes.writeInt24(hp.valueAt(worldTime));
		
		return sum + (bytes.offset() - originOffset);
	}
	override public function unpack(bytes:BytesStream, remoteWorldTime:Int = 0, localWorldTime:Int = 0):Int{
		var sum:Int = super.unpack(bytes, remoteWorldTime, localWorldTime);
		var originOffset:Int = bytes.offset();
		
		var keyframe:VolumeKeyframe = hp.asKeyframe(remoteWorldTime);
		keyframe.value = bytes.readInt24();
		hp.insertKeyframe(keyframe);
		
		return sum + (bytes.offset() - originOffset);
	}
	public function changeDownState(targetState:Int, worldTime:Int, offset:Int):Bool{
		return changeState(targetState, _downState, worldTime, offset);
	}
	override public function collisionStart(body:Body, axis:Vec, colliding:AABB, worldTime:Int):Void{
		super.collisionStart(body, axis, colliding, worldTime);
	}
	override public function collisionEnd(body:Body, axis:Vec, colliding:AABB, worldTime:Int):Void{
		super.collisionEnd(body, axis, colliding, worldTime);
	}
	override public function fall(body:Body, worldTime:Int):Void{
		super.fall(body, worldTime);
		var flyState:EntityState = getStateByName("fly");
		var jumpState:EntityState = getStateByName("jump");
		if (stateId() != jumpState.index){
			changeMainState(getStateByName("fly").index, worldTime, 0);
		}
	}
	override public function land(body:Body, worldTime:Int):Void{
		super.land(body, worldTime);
		if (body.hasBoost()){
			changeMainState(getStateByName("walk").index, worldTime, 0);
		}else{
			changeMainState(getStateByName("idle").index, worldTime, 0);
		}
	}
	override public function timesup(notifier:Notifier, time:Float):Bool{
		var state:EntityState = getStateByIndex(notifier.id());
		
		if (state.next != ""){
			var next:EntityState = getStateByName(state.next);
			changeMainState(next.index, Std.int(time * 1000), 0);
		}
		return false;
	}
	override public function step(worldTime:Int):Void{
		super.step(worldTime);
		if (hp.valueAt(worldTime) <= 0){
			dead = true;
			body.stopBoost(worldTime);
			changeMainState(getStateByName("died").index, worldTime, 0);
		}
	}
	public function processInput(keyState:KeyState, transformX:Float, transformY:Float, inputTime:Int, worldTime:Int):Int{
		var transformed:Bool = updateRotation(transformX, transformY);
		var changed:Bool = transformed || keyState.isUpdated();
		if (!changed || dead){
			return 0;
		}
		var dir:Vec;
		var offset:Float = 0;
		var targetState:String = "";
		var jumpIndex:Int = getStateByName("jump").index;
		var ashootIndex:Int = getStateByName("ashoot").index;
		var fshootIndex:Int = getStateByName("fshoot").index;
		var hard:Bool = false;
		var upState:Int = stateId();
		var justHard:Bool = false;
		if (upState == fshootIndex || upState == ashootIndex){
			hard = true;
		}
		if (!hard && keyState.isPressed(15) && keyState.isChanged(15)){
			var org:Vec = getBody().getAABB().centerPoint();
			var bullet:Entity = director.spawnEntity(worldTime, NetworkEntityPool.groupOfKey(networkId), 11, org.x, org.y, org.z+30, true);
			dir = new Vec();
			var hypo:Float = -Math.cos(transformY + Math.PI * 0.5);
			var height:Float = Math.sin(transformY + Math.PI * 0.5);
			var percentage:Float = Math.abs(hypo / height);
			dir.x = -Math.sin(transformX)*percentage;
			dir.y = Math.cos(transformX)*percentage;
			dir.z = height;
			dir.normalize();
			//Debugger.getInstance().log("xyz:" + dir.toString());
			bullet.direction = dir.clone();
			bullet.getBody().debug = true;
			bullet.getBody().applyBooost(dir, 100000, 2000, worldTime);
			
			faceRotation = transformX;
			body.stopBoost(inputTime);
			targetState = body.isAir() ? "ashoot" : "fshoot";
			hard = true;
			justHard = true;
		}
		if(!hard){
			if (keyState.isPressed(0) || keyState.isPressed(1) || keyState.isPressed(2) || keyState.isPressed(3)){
				if (keyState.isPressed(0)){
					if (keyState.isPressed(2)){
						offset += Math.PI / 4;
					}else if (keyState.isPressed(3)){
						offset -= Math.PI / 4;
					}
				}else if (keyState.isPressed(1)){
					offset = Math.PI;
					if (keyState.isPressed(2)){
						offset -= Math.PI / 4;
					}else if (keyState.isPressed(3)){
						offset += Math.PI / 4;
					}
				}else if (keyState.isPressed(2)){
					offset += Math.PI * 0.5;
				}else if (keyState.isPressed(3)){
					offset -= Math.PI * 0.5;
				}
				
				transformX+= offset;
				faceRotation = transformX;
				
				dir = new Vec(-Math.sin(transformX), Math.cos(transformX), 0);
				dir.normalize();
				body.applyBoostHorizon(dir, 700, 100, inputTime);
				if(stateId()==getStateByName("idle").index){
					//changeUpState(getStateByName("walk").index, worldTime, worldTime-inputTime);
					targetState = "walk";
				}
			}else{
				body.stopBoost(inputTime);
				if(stateId()==getStateByName("walk").index){
					targetState = "idle";
				}
				//changeUpState(getStateByName("idle").index, worldTime, worldTime-inputTime);
			}
		}else if(!justHard){
			return 0;
		}
		if (!hard && keyState.isChanged(4) && keyState.isPressed(4) && !body.isAir()){
			var impulse:Impulse = Impulse.fromVertices(new Vec(0, 0, 0), new Vec(0, 0, 10), 200);
			body.applyImpulse(impulse);
			changeMainState(jumpIndex, worldTime, worldTime-inputTime);
		}else if (targetState != ""){
			if(targetState!="jump" || stateId() != jumpIndex){
				changeMainState(getStateByName(targetState).index, worldTime, worldTime-inputTime);
			}
		}
		return 0;
	}
}