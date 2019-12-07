package com.gigateam.world.network;
import com.gigateam.util.Debugger;
import com.gigateam.world.entity.Director;
import com.gigateam.world.entity.Entity;
import com.gigateam.world.entity.EntityManager.EntityCreator;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.network.Payload.NetworkEntity;
import com.gigateam.world.network.Payload.Packable;
import com.gigateam.physics.entity.Space;
import com.gigateam.physics.shape.AABB;
import haxe.ds.GenericStack;
import haxe.io.Bytes;

/**
 * ...
 * @author Tiger
 */

class NetworkEntityPool implements Packable
{
	public static inline var ENTITY_ID_MAX:Int = 0xffff;
	public static inline var ENTITY_ID_MIN:Int = 1;
	public var lastAckTime:Int = 0;
	
	private var _groupCount:UInt = 0;
	private var _lastEventTimestamp:Int = 0;
	private var _events:Array<NetworkEvent> = [];
	private var _localId:Int;
	private var _creator:EntityCreator;
	private var _space:Space;
	private var _director:Director;
	private var pool:Map<Int, NetworkEntity>;
	private var groups:Map<Int, NetworkGroup>;
	public function new(localId:Int, creator:EntityCreator, space:Space, director:Director) 
	{
		groups = new Map<Int, NetworkGroup>();
		pool = new Map<Int, NetworkEntity>();
		_localId = localId;
		_creator = creator;
		_space = space;
	}
	
	public function createRemoteEntity(networkId:Int, entity:NetworkEntity):Int{
		if (isExists(networkId)){
			return -1;
		}
		pool.set(networkId, entity);
		return 0;
	}
	public function createGroupEntity(groupId:Int, entity:NetworkEntity):Int{
		var entityId:Int = next(groupId);
		return create(groupId, entityId, entity);
	}
	public function createLocalEntity(entity:NetworkEntity):Int{
		var entityId:Int = next(_localId);
		create(_localId, next(_localId), entity);
		return entityId;
	}
	public function create(groupId:Int, entityId:Int, entity:NetworkEntity):Int{
		var fKey:Int = toFKey(groupId, entityId);
		pool.set(fKey, entity);
		entity.networkId = fKey;
		return fKey;
	}
	public function remove(networkId:Int):Void{
		pool.remove(networkId);
	}
	public function getEntity(networkEntityId:Int):NetworkEntity{
		return pool.get(networkEntityId);
	}
	public function get(groupId:Int, entityId:Int):NetworkEntity{
		return getEntity(toFKey(groupId, entityId));
	}
	public function getEntityByAABB(aabb:AABB):NetworkEntity{
		var key:Int;
		for (key in pool.keys()) {
			var entity:Entity = cast pool.get(key);
			if (entity.getAABB() == aabb){
				return entity;
			}
		}
		return null;
	}
	public function isExists(networkId:Int):Bool{
		return pool.exists(networkId);
	}
	public function entityExists(groupId:Int, entityId:Int):Bool{
		return isExists(toFKey(groupId, entityId));
	}
	public function removeGroup(groupId:UInt):Int{
		var key:Int;
		for (key in pool.keys()) {
			if(groupOfKey(key)==groupId)
				pool.remove(key);
		}
		groups.remove(groupId);
		_groupCount -= 1;
		return 0;
	}
	public function otherEntity(updatedEntityIds:Array<Int>):Array<NetworkEntity>{
		var others:Array<NetworkEntity> = [];
		var key:Int;
		for (key in pool.keys()) {
			if(updatedEntityIds.indexOf(pool.get(key).networkId)<0){
				others.push(pool.get(key));
			}
		}
		return others;
	}
	public function pack(bytes:BytesStream, worldTime:Int=0):Int{
		var len:Int = 4;
		//bytes.setUInt16(offset, len);
		return len+2;
	}
	public function unpack(bytes:BytesStream, remoteWorldTime:Int=0, localWorldTime:Int=0):Int{
		return 0;
	}
	public static function toFKey(groupId:Int, entityId:Int):Int{
		return (groupId << 16) + entityId;
	}
	public static function groupOfKey(fKey:Int):UInt{
		return (fKey >>> 16) & 0xffff;
	}
	public static function entityIdOfKey(fKey:Int):UInt{
		return fKey & 0xffff;
	}
	public function getPool():Map<Int, NetworkEntity>{
		return pool;
	}
	public function groupLength():UInt{
		return _groupCount;
	}
	public function addGroup(groupId:Int):Int{
		_groupCount += 1;
		groups.set(groupId, new NetworkGroup(ENTITY_ID_MIN));
		return 0;
	}
	public function next(groupId:Int):Int{
		var group:NetworkGroup = groups.get(groupId);
		var increment:Int = group.increment;
		while (true){
			if (!isExists(toFKey(groupId, increment))){
				break;
			}
			increment++;
			if (increment >= ENTITY_ID_MAX){
				increment = ENTITY_ID_MIN;
			}
		}
		group.increment = increment;
		return increment;
	}
	public function getGroups():Iterator<Int>{
		return groups.keys();
	}
	//network io
	public function packSnapshot(bytes:Bytes, worldTime:Int, offset:Int=0, lastAckedTime:Int=0):Int{
		var entities:Map<Int, NetworkEntity> = getPool();
		var networkId:Int;
		var originOffset:Int = offset;
		
		var bStream:BytesStream = new BytesStream(bytes, offset);
		var flags:Int = 0;
		bStream.writeInt24(worldTime);
		if (_events.length > 0){
			//Debugger.getInstance().log("Dipsatching events:" + Std.string(_events.length));
			flags |= 0x40;
			bStream.write(flags);
			if (lastAckedTime > 0){
				var i:Int = _events.length;
				while (i-- > 0) {
					if (_events[i].time < lastAckedTime) {
						//Debugger.getInstance().log("Eliminated. lastAckedTime:" + Std.string(lastAckedTime)+",i:"+Std.string(i)+",eventTime:"+Std.string(_events[i].time));
						_events.splice(i, 1);
					}else{
						//Debugger.getInstance().log("lastAckedTime:" + Std.string(lastAckedTime)+",i:"+Std.string(i)+",eventTime:"+Std.string(_events[i].time));
					}
				}
			}
			for (evt in _events){
				bStream.write(2);
				evt.pack(bStream, worldTime);
			}
			bStream.write(1);
		}else{
			bStream.write(flags);
		}
		for (networkId in entities.keys()){
			var entity:NetworkEntity = entities.get(networkId);
			var libId:Int = entity.libId;
			bStream.write(libId);
			bStream.writeInt32(networkId);
			entity.pack(bStream, worldTime);
		}
		//if (flags != 0){
			//Debugger.getInstance().log(Debugger.getInstance().bytesToHex(bStream));
		//}
		return bStream.offset() - originOffset;
	}
	public function dispatchEvent(evt:NetworkEvent):Void{
		_events.push(evt);
	}
	public function shiftEvent():NetworkEvent{
		if (_events.length == 0){
			return null;
		}
		return _events.shift();
	}
	public function parseSnapshot(snapshot:Bytes, offset:Int, length:Int, localWorldTime:Int, handler:Director=null):Int{
		var bStream:BytesStream = new BytesStream(snapshot, offset);
		var numEntity:UInt = 0;
		var lastAckTime:UInt = bStream.readInt24();
		var remoteWorldTime:Int = bStream.readInt24();
		var flags:Int = bStream.read();
		var received:Array<Int> = [];
		if ((flags & 0x40) > 0){
			var lastEvent:Int = 0;
			while (true){
				var exists:Int = bStream.read();
				if (exists == 1){
					break;
				}else if (exists != 2){
					throw "Invalid format; position:"+Std.string(bStream.offset())+", data:"+Debugger.getInstance().bytesToHex(bStream);
				}
				var event:NetworkEvent = new NetworkEvent();
				event.unpack(bStream, remoteWorldTime, localWorldTime);
				if (event.time > _lastEventTimestamp){
					if (event.time > lastEvent){
						lastEvent = event.time;
					}
					if (handler != null){
						handler.handle(event, localWorldTime);
					}
				}
			}
			if (lastEvent > _lastEventTimestamp){
				_lastEventTimestamp = lastEvent;
			}
		}
		while (bStream.offset()<length){
			var libId:Int = bStream.read();
			var networkId:Int = bStream.readInt32();
			//var entity:NetworkEntity;
			var len:Int = 0;
			var en:Entity;
			if (isExists(networkId)){
				//entity = ;
				en = cast getEntity(networkId);
				len = _creator.updateEntity(en, bStream, remoteWorldTime, localWorldTime);
				en.insertPendingKeyframe();
			}else{
				en = _creator.createEntity(libId);
				en.stopCollision();
				
				//entity = cast en;
				len = _creator.updateEntity(en, bStream, remoteWorldTime, localWorldTime);
				_space.spawnBody(en.getBody(), en.lastUpdateTime()+_space.getOffset());
				en.insertPendingKeyframe();
				
				if (_creator.validate(en)){
					if (createRemoteEntity(networkId, cast en) < 0){
						return -2;
					}
					var groupId:Int = groupOfKey(networkId);
					en.networkId = networkId;
					_creator.networkedEntity(en, groupId, networkId-(groupId<<16), remoteWorldTime);
				}else{
					return -1;
				}
			}
			received.push(networkId);
			offset += len;
			numEntity++;
		}
		var noUpdateEntities:Array<NetworkEntity> = otherEntity(received);
		for ( networkEn in noUpdateEntities){
			var entity:Entity = cast networkEn;
			var groupId:Int = NetworkEntityPool.groupOfKey(entity.networkId);
			var entityId:Int = entity.networkId - (groupId << 16);
			if (groupId == 0 && entityId == 0){
				continue;
			}
			_creator.removeEntity(entity, groupOfKey(groupId), entityId, remoteWorldTime, localWorldTime);
			remove(entity.networkId);
		}
		
		return remoteWorldTime;
	}
}