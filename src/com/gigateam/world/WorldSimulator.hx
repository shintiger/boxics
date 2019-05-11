package com.gigateam.world;

import com.gigateam.util.BytesUtil;
import com.gigateam.util.Debugger;
import com.gigateam.util.Scheduler;
import com.gigateam.world.entity.Director;
import com.gigateam.world.entity.Entity;

import com.gigateam.world.entity.EntityManager.EntityCreator;
import com.gigateam.world.logic.BulletSweepTester;
import com.gigateam.world.logic.BytesStream;

import com.gigateam.world.logic.status.Character;
import com.gigateam.world.network.Client;
import com.gigateam.world.network.NetworkEntityPool;
import com.gigateam.world.network.NetworkEvent;
import com.gigateam.world.network.Payload;

import com.gigateam.world.physics.InterpolationType;

import com.gigateam.world.physics.entity.Body;
import com.gigateam.world.physics.entity.BodyType;
import com.gigateam.world.physics.entity.Space;
import com.gigateam.world.physics.shape.AABB;

import com.gigateam.world.physics.shape.Vertex;
import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesData;

typedef Point = {
	var x:Float;
	var y:Float;
	var z:Float;
};

typedef Meta = {
	var rx:Float;
	var ry:Float;
	var rz:Float;
};

typedef BodyData = {
	var x:Float;
	var y:Float;
	var z:Float;
	var xLength:Float;
	var yLength:Float;
	var zLength:Float;
	var rx:Float;
	var ry:Float;
	var rz:Float;
	var meta:Meta;
};

typedef StateData = {
	var name:String;
	var duration:Int;
	var loop:Bool;
	var next:String;
};

typedef EntityData = {
	var libId:Int;
	var bodyType:Int;
	var bodies:Array<BodyData>;
	var stateFps:Int;
	var states:Array<StateData>;
	var gravity:Point;
};

typedef WorldDetail = {
  var name:String;
  var gravity:Point;
  var entities:Array<EntityData>;
};

/**
 * ...
 * @author Tiger
 */
class WorldSimulator extends Director
{
	private var _bulletSweepTester:BulletSweepTester;
	private var _scheduler:Scheduler;
	private var _ePool:NetworkEntityPool;
	//private var _parser:NetworkParser;
	//private var _packer:NetworkPacker;
	private var _json:WorldDetail;
	private var _space:Space;
	private var _creator:EntityCreator;
	private var _clients:Map<Int, Client>;
	private var _me:Client;
	public var initialized:Bool = false;
	public var fps:Int = 60;
	public function new(){
		_clients = new Map<Int, Client>();
		super();
	}
	public function init(worldJson:String, time:Int, ownerId:Int, authorized:Bool, creator:EntityCreator, scheduler:Scheduler):Int{
		_json = Json.parse(worldJson);
		
		_creator = creator;
		_creator.init(_json.entities, authorized, authorized);
		var p:Point = _json.gravity;
		_space = new Space(time, new Vertex(p.x, p.y, p.z));
		_ePool = new NetworkEntityPool(ownerId, _creator, _space, this);
		//_packer = new NetworkPacker(_ePool);
		//_parser = new NetworkParser(_ePool, _creator, _space);
		_scheduler = scheduler;
		
		if (ownerId >= 0){
			if (_clients.exists(ownerId)){
				_me = _clients.get(ownerId);
			}else{
				_me = new Client(ownerId, time);
				_clients.set(ownerId, _me);
			}
		}
		var entityData:EntityData;
		for (entityData in _json.entities){
			var bodyData:BodyData;
			if (entityData.bodyType != BodyType.STATIC)
				continue;
			for (bodyData in entityData.bodies){
				var body:Body = new Body(BodyType.STATIC, bodyData.x, bodyData.xLength, bodyData.y, bodyData.yLength, bodyData.z, bodyData.zLength, bodyData.rx, bodyData.ry, bodyData.rz);
				_space.spawnBody(body, time);
			}
		}
		initialized = true;
		reset(time);
		return 0;
	}
	public function checksum():Int{
		return 25384051;
	}
	public function reset(time:Int):Int{
		if(_me!=null){
			_me.reset(time);
		}
		_space.reset(time);
		_scheduler.offset = _space.getOffset() * 0.001;
		return 0;
	}
	override public function dispatchEvent(evt:NetworkEvent):Void{
		_ePool.dispatchEvent(evt);
	}
	public function getScheduler():Scheduler{
		return _scheduler;
	}
	public function advance(time:Int):Void{
		if (_bulletSweepTester != null){
			_bulletSweepTester.update(time);
		}
		_scheduler.advanceStartupTime(time * 0.001);
		
		lerp(time);
		_space.advance(time);
	}
	public function lerp(time:Int):Void{
		var pool:Map<Int, NetworkEntity> = _ePool.getPool();
		var key:Int;
		time-= _space.getOffset();
		for (key in pool.keys()){
			var entity:Entity = cast pool.get(key);
			#if cpp
			entity.step(time);
			#else
			if (entity.getBody().interpolationType != InterpolationType.TWEENING){
				continue;
			}
			entity.interpolate(time);
			#end
		}
	}
	public function getSpace():Space{
		return _space;
	}
	override public function unSpawnEntity(time:Int, entity:Entity):Void{
		var group:Int = NetworkEntityPool.groupOfKey(entity.networkId);
		//_creator.removeEntity(entity, group, NetworkEntityPool.entityIdOfKey(entity.networkId),
		_space.unSpawnBody(entity.getBody());
		_ePool.remove(entity.networkId);
		entity.dispose();
	}
	override public function spawnEntity(time:Int, groupId:Int, libId:Int, x:Float=0, y:Float=0, z:Float=0, center:Bool=false):Entity{
		var entity:Entity = _creator.createEntity(libId);
		entity.director = this;
		switch(libId){
			case 11:
				entity.getBody().sweepTester = _bulletSweepTester;
		}
		_ePool.createGroupEntity(groupId, cast entity);
		var o:Vertex = entity.getBody().getAABB().origin;
		if (center){
			var aabb:AABB = entity.getBody().getAABB();
			o.x = x - aabb.w * 0.5;
			o.y = y - aabb.h * 0.5;
			o.z = z - aabb.d * 0.5;
		}else{
			o.x = x;
			o.y = y;
			o.z = z;
		}
		_space.spawnBody(entity.getBody(), time);
		return entity;
	}
	#if cpp
	/*public function ackedInputTime(groupId:Int):Int{
		var client:Client = _clients.get(groupId);
		return client.lastAckedInput();
	}*/
	public function getSnapshot(raw:cpp.Pointer<cpp.UInt8>, length:Int, time:Int):Int{
		var array:Array<cpp.UInt8> = raw.toUnmanagedArray(length);
		var bytes:Bytes = Bytes.ofData(array);
		var snapshotTimeLen:Int = BytesUtil.writeUnsignedInt24(bytes, 0, time-_space.getOffset());
		//return _packer.packSnapshot(by, time-getOffset(), snapshotTimeLen)+snapshotTimeLen;
		return _ePool.packSnapshot(bytes, time-getOffset(), snapshotTimeLen, minSnapshotTime())+snapshotTimeLen;
	}
	public function getStaticBodiesLength():Int{
		return _space.getStaticBodies().length;
	}
	public function getStaticBodies(src:cpp.Pointer<Body>):Int{
		var arr:Array<Body> = _space.getStaticBodies();
		cpp.NativeArray.setData(arr, src, arr.length);
		return arr.length;
	}
	public function serverInit(raw:cpp.Pointer<cpp.UInt8>, rawLength:Int, time:UInt):Int{
		var array:Array<cpp.UInt8> = raw.toUnmanagedArray(rawLength);
		var by:Bytes = Bytes.ofData(array);
		var scheduler:Scheduler = new Scheduler();
		var creator:EntityManager = new EntityManager(scheduler);
		_bulletSweepTester = new BulletSweepTester(this);
		
		var bytes:Bytes = Bytes.alloc(20);
		var by2:BytesStream = new BytesStream(bytes, 0);
		by2.writeUTF("halo~!!");
		by2.setOffset(0);
		var timeInt:Int = Std.parseInt(Std.string(time));
		Debugger.getInstance().log("C++ uint time:" + time);
		Debugger.getInstance().log("C++ int time:" + timeInt);
		Debugger.getInstance().log("Test:" + by2.readUTF());
		if (timeInt < 0){
			throw "System time should never be negative";
		}
		return init(by.getString(0, rawLength), timeInt, -1, true, creator, scheduler);
	}
	public function processInput(raw:cpp.Pointer<cpp.UInt8>, offset:Int, length:Int, clientId:Int, time:Int):Int{
		var array:Array<cpp.UInt8> = raw.toUnmanagedArray(length);
		return _processInput(Bytes.ofData(array), offset, clientId, time);
	}
	/*
	 * To get time of speicified Client acknownledged snapshot (from Client)
	 */
	public function getClientAckedSnapshotTime(clientId:Int):UInt{
		var client:Client = _clients.get(clientId);
		return client.ackedSnapshotTime;
	}
	/*
	 * Get minimum time of acknowledged snapshot from all Client, any snapshot before this time are useless.
	 */
	public function minSnapshotTime():UInt{
		var min:UInt = 1000000000;
		for (clientId in _clients.keys()){
			var client:Client = _clients.get(clientId);
			if (client.ackedSnapshotTime < min){
				min = client.ackedSnapshotTime;
			}
		}
		return min;
	}
	public function entityExists(groupId:Int, entityId:Int):Bool{
		return _clients.get(groupId) != null;
	}
	public function getEntityX(groupId:Int, entityId:Int):Float{
		return getEntityCenterPoint(groupId, entityId).x;
	}
	public function getEntityY(groupId:Int, entityId:Int):Float{
		return getEntityCenterPoint(groupId, entityId).y;
	}
	public function getEntityZ(groupId:Int, entityId:Int):Float{
		return getEntityCenterPoint(groupId, entityId).z;
	}
	private function getEntityCenterPoint(groupId:Int, entityId:Int):Vertex{
		return (cast getEntity(groupId, entityId)).getBody().getAABB().origin;
	}
	private function getEntity(groupId:Int, entityId:Int):NetworkEntity{
		var entity:NetworkEntity = _ePool.getEntity(NetworkEntityPool.toFKey(groupId, entityId));
		return entity;
	}
	/*
	 * Public function use by native C++, to print log from Haxe internal.
	 */
	public function log(raw:cpp.Pointer<cpp.UInt8>, length:Int):Int{
		var array:Array<cpp.UInt8> = raw.toUnmanagedArray(length);
		var by:Bytes = Bytes.ofData(array);
		
		var output:String = Debugger.getInstance().get();
		var outputBy:Bytes = Bytes.ofString(output);
		var i:Int = 0;
		while (i < outputBy.length){
			by.set(i, outputBy.get(i));
			i++;
		}
		by.set(i, 0);
		return output.length;
	}
	/*
	 * When new Audient join.
	 */
	public function addGroup(groupId:Int, time:Int, nickname:cpp.Pointer<cpp.UInt8>, nicknameLength:Int):Int{
		if (_bulletSweepTester == null){
			throw "_bulletSweepTester is null";
		}
		/*var pool:Map<Int, NetworkEntity> = _ePool.getPool();
		var key:Int;
		//time-= _space.getOffset();
		for (key in pool.keys()){
			var entity:Entity = cast pool.get(key);
			var vel:Int = Std.int(100);
			//entity.getBody().applyBoostX(vel, vel * 5);
			vel = Std.int(150);
			//entity.getBody().applyBoostY(vel, vel * 5);
		}*/
		if (_ePool.groupLength() == 0){
			reset(time);
		}
		var worldTime:Int = time - _space.getOffset();
		var client:Client = new Client(groupId, time);
		var array:Array<cpp.UInt8> = nickname.toUnmanagedArray(nicknameLength);
		var bytes:Bytes = Bytes.ofData(array);
		var stream:BytesStream = new BytesStream(bytes, 0);
		client.nickname = stream.readUTF();
		_clients.set(groupId, client);
		_ePool.addGroup(groupId);
		var entity:Character = cast spawnEntity(time, groupId, 10, 0, 0, 1000);
		_bulletSweepTester.add(cast entity.getAABB());
		entity.name = client.nickname;
		client.setEntity(entity);
		
		var evt:NetworkEvent = new NetworkEvent(NetworkEvent.BINARY);
		evt.data = new BytesStream(Bytes.alloc(1024), 0);
		evt.dataLength = _writeInfo(evt.data, time);
		evt.time = worldTime;
		dispatchEvent(evt);
		return 0;
	}
	
	/*
	 * Remove an Audient.
	 */
	public function removeGroup(groupId:Int, time:Int):Int{
		if (_bulletSweepTester == null){
			throw "_bulletSweepTester is null";
		}
		var client:Client = _clients.get(groupId);
		_bulletSweepTester.remove(cast client.getEntity().getAABB());
		//unSpawnEntity(time, 
		client.dispose();
		_clients.remove(groupId);
		return _ePool.removeGroup(groupId);
	}
	public function writeInfo(raw:cpp.Pointer<cpp.UInt8>, length:Int, time:Int):Int{
		var array:Array<cpp.UInt8> = raw.toUnmanagedArray(length);
		var bytes:Bytes = Bytes.ofData(array);
		var bStream:BytesStream = new BytesStream(bytes, 0);
		return _writeInfo(bStream, time);
	}
	#else
	public function readInfo(bytes:BytesData, offset:Int, length:Int, localWorldTime:Int):UInt{
		var by:Bytes = Bytes.ofData(bytes);
		var bStream:BytesStream = new BytesStream(by, offset);
		return _readInfo(bStream, localWorldTime, length);
	}
	/*
	 * (Client side) Get my Client instance.
	 */
	public function me():Client{
		return _me;
	}
	/*
	 * Pack prepared input stream data into given buffer.
	 */
	public function packInput(bytes:BytesData, offset:Int, lastSnapshotTime:Int):Int{
		var by:Bytes = Bytes.ofData(bytes);
		offset += BytesUtil.writeUnsignedInt24(by, offset, lastSnapshotTime);
		var bStream:BytesStream = new BytesStream(by, offset);
		var inputCount:Int = _me.getStream().getRaw().length;
		_me.getStream().pack(bStream);
		return inputCount;
	}
	/*
	 * Write snapshot into given buffer.
	 */
	public function getSnapshot(by:Bytes):Int{
		//return _packer.packSnapshot(by, getOffset());
		var result:Int = _ePool.packSnapshot(by, getOffset());
		return result;
	}
	public function getStaticBodies():Array<Body>{
		return _space.getStaticBodies();
	}
	#end
	private function _readInfo(bStream:BytesStream, localWorldTime:Int, length:Int):UInt{
		var remoteWorldTime:UInt = bStream.readInt24();
		while (bStream.offset() < length){
			var clientId:Int = bStream.readInt16();
			var client:Client = getClient(clientId);
			if (client == null){
				client = new Client(clientId, remoteWorldTime);
				_clients.set(clientId, client);
			}
			client.unpack(bStream, remoteWorldTime, localWorldTime);
			Debugger.getInstance().log("Client id:" + Std.string(clientId)+", ["+client.nickname+"]" );
		}
		return 0;
	}
	private function _writeInfo(bStream:BytesStream, time:Int):Int{
		var offset:Int = bStream.offset();
		bStream.writeInt24(time-getOffset());
		for (clientId in _clients.keys()){
			var client:Client = _clients.get(clientId);
			bStream.writeInt16(clientId);
			client.pack(bStream, time);
		}
		return bStream.offset() - offset;
	}
	public function getClient(clientId:UInt):Client{
		if (!_clients.exists(clientId)){
			return null;
		}
		return _clients.get(clientId);
	}
	override public function scored(bulletBounding:AABB, victimBounding:AABB, worldTime:Int):Void{
		super.scored(bulletBounding, victimBounding, worldTime);
		var bullet:Entity = cast _ePool.getEntityByAABB(bulletBounding);
		var victim:Character = cast _ePool.getEntityByAABB(victimBounding);
		if (bullet == null || victim == null){
			throw "bullet or victim was null";
		}
		var evt:NetworkEvent = new NetworkEvent(NetworkEvent.SCORED);
		var center:Vertex =  victim.getBody().centerPoint();
		evt.x = center.x;
		evt.y = center.y;
		evt.z = center.z;
		evt.time = worldTime;
		evt.type = 125;
		victim.hp.shapeAdd( -25, worldTime);
		dispatchEvent(evt);
	}
	public function getFKey(groupId:Int, entityId:Int):Int{
		return NetworkEntityPool.toFKey(groupId, entityId);
	}
	private function _processInput(bytes:Bytes, offset:Int, clientId:Int, time:Int):Int{
		var client:Client = _clients.get(clientId);
		var bStream:BytesStream = new BytesStream(bytes, offset);
		time-= _space.getOffset();
		
		return client.processBytes(bStream, 0, time);
	}
	/*
	 * Get offset of world. Relative to timestamp from startup.
	 */
	public function getOffset():Int{
		return _space.getOffset();
	}
	/*
	 * To process snapshot from remote
	 */
	public function processSnapshot(bytes:BytesData, offset:Int, length:Int, time:Int):UInt{
		var by:Bytes = Bytes.ofData(bytes);
		//return _parser.parseSnapshot(by, offset, length, time-getOffset());
		var len:UInt = _ePool.parseSnapshot(by, offset, length, time-getOffset(), this);
		return len;
		
		/*while (true){
			var evt:NetworkEvent = _ePool.shiftEvent();
			if (evt == null){
				break;
			}
			_creator.handleEvent(evt);
			if (evt.type == NetworkEvent.BINARY){
				var len:Int = evt.data.offset();
				evt.data.setOffset(0);
				_readInfo(evt.data, time, len);
			}
			
		}
		return len;*/
	}
	override public function handle(evt:NetworkEvent, worldTime:Int):Void{
		_creator.handleEvent(evt);
		if (evt.type == NetworkEvent.BINARY){
			Debugger.getInstance().log("Step4" );
			var len:Int = evt.data.offset();
			evt.data.setOffset(0);
			_readInfo(evt.data, worldTime, len);
		}
	}
}