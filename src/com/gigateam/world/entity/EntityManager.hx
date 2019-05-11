package com.gigateam.world.entity;
import com.gigateam.util.Debugger;
import com.gigateam.util.Scheduler;
import com.gigateam.world.WorldSimulator.EntityData;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.logic.status.Character;
import com.gigateam.world.network.NetworkEvent;
import com.gigateam.world.network.Payload.NetworkEntity;
import com.gigateam.world.physics.shape.AABB;
import com.gigateam.world.physics.shape.Vertex;
import haxe.io.Bytes;

/**
 * ...
 * @author Tiger
 */
interface EntityCreator{
	public function createEntity(libId:Int):Entity;
	public function updateEntity(entity:Entity, bytes:BytesStream, remoteWorldTime:Int=0, localWorldTime:Int=0):Int;
	public function networkedEntity(entity:Entity, group:Int, entityId:Int, remoteWorldTime:Int = 0, localWorldTime:Int = 0):Int;
	public function removeEntity(entity:Entity, group:Int, entityId:Int, remoteWorldTime:Int = 0, localWorldTime:Int = 0):Int;
	public function getEntityData(libId:Int):EntityData;
	public function isAuthorized():Bool;
	public function validate(entity:Entity):Bool;
	public function init(data:Array<EntityData>, authorized:Bool, defaultCollidable:Bool):Void;
	public function collisionStart(entity:Entity, axis:Vertex, colliding:AABB, worldTime:Int):Void;
	public function collisionEnd(entity:Entity, axis:Vertex, colliding:AABB, worldTime:Int):Void;
	public function fall(entity:Entity, worldTime:Int):Void;
	public function land(entity:Entity, worldTime:Int):Void;
	public function stateChanged(entity:StatefulEntity, state:Int, offsetTime:Int):Void;
	public function handleEvent(event:NetworkEvent):Void;
}
class EntityManager implements EntityCreator
{
	public var scheduler:Scheduler;
	private var _defaultCollidable:Bool;
	private var _authorized:Bool;
	private var _data:Array<EntityData>;
	
	public function new(_scheduler:Scheduler) 
	{
		scheduler = _scheduler;
	}
	public function collisionStart(entity:Entity, axis:Vertex, colliding:AABB, worldTime:Int):Void{
		switch(entity.libId){
			//bullet
			case 11:
				entity.director.unSpawnEntity(worldTime, entity);
		}
	}
	public function handleEvent(event:NetworkEvent):Void{
		
	}
	public function collisionEnd(entity:Entity, axis:Vertex, colliding:AABB, worldTime:Int):Void{
		
	}
	public function fall(entity:Entity, worldTime:Int):Void{
		
	}
	public function land(entity:Entity, worldTime:Int):Void{
		
	}
	public function stateChanged(entity:StatefulEntity, state:Int, offsetTime:Int):Void{
		//Debugger.getInstance().log("Change state:" + Std.string(state));
	}
	public function init(data:Array<EntityData>, authorized:Bool, defaultCollidable:Bool):Void
	{
		_authorized = authorized;
		_data = data;
		_defaultCollidable = defaultCollidable;
	}
	public function createEntity(libId:Int):Entity{
		var created:Entity = null;
		var data:EntityData = getEntityData(libId);
		created = createEntityById(libId, data);
		created.libId = libId;
		if(_defaultCollidable){
			created.startCollision();
		}else{
			created.stopCollision();
		}
		return created;
	}
	private function createEntityById(libId:Int, data:EntityData):Entity{
		var created:Entity = null;
		switch(libId){
			case 10:
				created = new Character(scheduler, [], 0, data, -100, -100, -100);
			case 11:
				created = new Entity(0, data, -100, -100, -100);
			case 12:
				created = new StatefulEntity(scheduler, 0, data, 0, 0, 0);
		}
		created.libId = libId;
		created.creator = this;
		return created;
	}
	public function getEntityData(libId:Int):EntityData{
		var data:EntityData = null;
		for (data in _data){
			if (data.libId == libId){
				return data;
			}
		}
		return null;
	}
	public function isAuthorized():Bool{
		return _authorized;
	}
	public function validate(entity:Entity):Bool{
		return true;
	}
	public function updateEntity(entity:Entity, bytes:BytesStream, remoteWorldTime:Int=0, localWorldTime:Int=0):Int{
		return entity.unpack(bytes, remoteWorldTime);
	}
	//public function removeEntity(entity:Entity):Int{
		//return 0;
	//}
	public function networkedEntity(entity:Entity, group:Int, entityId:Int, remoteWorldTime:Int = 0, localWorldTime:Int = 0):Int{
		entity.createByRemote();
		return 0;
	}
	public function removeEntity(entity:Entity, group:Int, entityId:Int, remoteWorldTime:Int=0, localWorldTime:Int=0):Int{
		return 0;
	}
}