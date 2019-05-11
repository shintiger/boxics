package com.gigateam.world.entity;


import com.gigateam.util.BytesUtil;
import com.gigateam.util.Debugger;
import com.gigateam.world.WorldSimulator.BodyData;
import com.gigateam.world.WorldSimulator.EntityData;
import com.gigateam.world.entity.EntityManager.EntityCreator;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.network.Payload.NetworkEntity;
import com.gigateam.world.physics.Acceleration;
import com.gigateam.world.physics.InterpolationType;
import com.gigateam.world.physics.entity.Body;
import com.gigateam.world.physics.entity.BodyType;
import com.gigateam.world.physics.entity.ICollisionNotifier;
import com.gigateam.world.physics.shape.AABB;
import com.gigateam.world.physics.shape.MovableAABB;
import com.gigateam.world.physics.shape.Vertex;
import com.gigateam.world.physics.timeline.DisplacementKeyframe;
import com.gigateam.world.physics.timeline.TweenKeyframe;
import com.gigateam.world.physics.timeline.TweenTimeline;
import com.gigateam.world.World;
import haxe.io.Bytes;

/**
 * ...
 * @author Tiger
 */

class Entity implements NetworkEntity implements ICollisionNotifier
{
	private static var tmpTween:TweenKeyframe = TweenKeyframe.empty();
	
	public var direction:Vertex;
	public var director:Director;
	public var creator:EntityCreator;
	public var networkId:Int;
	public var libId:Int;
	public var faceRotationByTime:Float = 0;
	public var faceRotation:Float = 0;
	public var rotationZ:Float = 0;
	public var rotationX:Float = 0;
	public var arr:Array<Int> = [];
	public var offsetPos:Vertex;
	public var checksum:Int = 10279;
	private var _isPassive:Bool = false;
	private var lastUpdate:Int = 0;
	private var _offset:Int;
	private var body:Body;
	private static inline var positionMagnitude:Int = 1000;
	private static inline var rotationMagnitude:Int = 10000000;
	private static inline var durationMagnitude:Int = 1000;
	//private var remoteFrame:DisplacementKeyframe;
	private var pendingRemoteKeyframe:TweenKeyframe;
	private var tweenTimeline:TweenTimeline;
	public var rewundTime:Int = 0;
	public function new(offset:Int, data:EntityData, x:Float, y:Float, z:Float) 
	{
		_offset = offset;
		var bodyData:BodyData = data.bodies[0];
		offsetPos = new Vertex(-bodyData.x, -bodyData.y, -bodyData.z);
		body = new Body(data.bodyType, x, bodyData.xLength, y, bodyData.yLength, z, bodyData.zLength);
		body.collisionNotifier = this;
		tweenTimeline = new TweenTimeline(0, 150);
		if (data.gravity != null){
			body.gravityV = new Vertex(data.gravity.x, data.gravity.y, data.gravity.z);
		}
	}
	public function step(worldTime:Int):Void{
		
	}
	@:allow(com.gigateam.world)
	public function createByRemote():Void{
		_isPassive = true;
	}
	public function isPassive():Bool{
		return _isPassive;
	}
	public function getDisplayPos(v:Vertex):Vertex{
		if (v == null){
			v = new Vertex();
		}
		v.cloneFrom(body.getAABB().origin);
		v.plus(offsetPos);
		return v;
	}
	public function getTweenTimeline():TweenTimeline{
		return tweenTimeline;
	}
	public function interpolate(time:Int, tmp:Bool = false):Vertex{
		if (!_isPassive){
			throw "Non-passive entity not able to interpolate.";
		}
		time-= rewundTime;
		var res:Int = tweenTimeline.interpolate(time, tmpTween);
		
		if(!tmp && res>=0){
			body.movingVector.x = tmpTween.origin.x - body.getAABB().origin.x;
			body.movingVector.y = tmpTween.origin.y - body.getAABB().origin.y;
			body.movingVector.z = tmpTween.origin.z - body.getAABB().origin.z;
			
			//Debugger.getInstance().log("Result:" + res+", time:"+time);
			
			body.getAABB().origin.cloneFrom(tmpTween.origin);
			body.positionUpdated();
			
			faceRotation = tmpTween.faceRotation;
			rotationZ = tmpTween.rotationZ;
			rotationX = tmpTween.rotationX;
		}
		return tmpTween.origin;
	}
	public function collisionStart(body:Body, axis:Vertex, colliding:AABB, worldTime:Int):Void{
		creator.collisionStart(this, axis, colliding, worldTime);
	}
	public function collisionEnd(body:Body, axis:Vertex, colliding:AABB, worldTime:Int):Void{
		creator.collisionEnd(this, axis, colliding, worldTime);
	}
	public function fall(body:Body, worldTime:Int):Void{
		creator.fall(this, worldTime);
	}
	public function land(body:Body, worldTime:Int):Void{
		creator.land(this, worldTime);
	}
	public function rewund(offset:Int):Void{
		body.interpolationType = InterpolationType.TWEENING;
		body.moving = false;
		body.rewund = offset;
		rewundTime = offset;
	}
	public function pack(bytes:BytesStream, worldTime:Int=0):Int{
		var originOffset:Int = bytes.offset();
		var v:Vertex = body.getAABB().origin;
		var flags:Int = 0;
		var directional:Bool = false;
		if (direction!=null){
			flags |= 0x80;
			directional = true;
		}
		faceRotationByTime = faceRotation;
		bytes.write(flags);
		bytes.writeInt32(Std.int(v.x * positionMagnitude));
		bytes.writeInt32(Std.int(v.y * positionMagnitude));
		bytes.writeInt32(Std.int(v.z * positionMagnitude));
		if (direction!=null){
			bytes.writeInt32(Std.int(direction.x * rotationMagnitude));
			bytes.writeInt32(Std.int(direction.y * rotationMagnitude));
			bytes.writeInt32(Std.int(direction.z * rotationMagnitude));
			
			//bytes.writeInt32(Std.int(rotationZ * rotationMagnitude));
			//bytes.writeInt32(Std.int(rotationX * rotationMagnitude));
		}
		bytes.writeInt32(Std.int(faceRotation * rotationMagnitude));
		bytes.writeInt32(Std.int(faceRotationByTime * rotationMagnitude));
		
		return bytes.offset()-originOffset;
	}
	public function unpack(bytes:BytesStream, remoteWorldTime:Int=0, localWorldTime:Int=0):Int{
		var originOffset:Int = bytes.offset();
		var flags:Int = bytes.read();
		var directional:Bool = (flags & 0x80) > 0;
		var x:Float = bytes.readInt32() / positionMagnitude;
		var y:Float = bytes.readInt32() / positionMagnitude;
		var z:Float = bytes.readInt32() / positionMagnitude;
		if (directional){
			if (direction == null){
				direction = new Vertex();
			}
			direction.x = bytes.readInt32() / rotationMagnitude;
			direction.y = bytes.readInt32() / rotationMagnitude;
			direction.z = bytes.readInt32() / rotationMagnitude;
			
			//rotationZ = bytes.readInt32() / rotationMagnitude;
			//rotationX = bytes.readInt32() / rotationMagnitude;
		}
		var fr:Float = bytes.readInt32() / rotationMagnitude;
		var frt:Float = bytes.readInt32() / rotationMagnitude;
		
		pendingRemoteKeyframe = new TweenKeyframe(remoteWorldTime, x, y, z, rotationZ, rotationX, frt);
		return bytes.offset() - originOffset;
	}
	public function lastUpdateTime():Int{
		return lastUpdate;
	}
	public function insertPendingKeyframe():Void{
		if (pendingRemoteKeyframe == null)
		return;
		
		tweenTimeline.insertKeyframe(pendingRemoteKeyframe);
		pendingRemoteKeyframe = null;
	}
	public function updateRotation(z:Float, x:Float):Bool{
		var transformed:Bool = rotationZ != z || rotationX != x;
		rotationZ = z;
		rotationX = x;
		return transformed;
	}
	public function getBody():Body{
		return body;
	}
	public function getAABB():AABB{
		return body.getAABB();
	}
	public function stopCollision():Void{
		body.collidable = false;
	}
	public function startCollision():Void{
		body.collidable = true;
	}
	public function dispose():Void{
		tweenTimeline.dispose();
		if (pendingRemoteKeyframe != null){
			pendingRemoteKeyframe.dispose();
			pendingRemoteKeyframe = null;
		}
	}
}