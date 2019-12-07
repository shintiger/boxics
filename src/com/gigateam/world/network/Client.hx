package com.gigateam.world.network;
import com.gigateam.world.entity.Entity;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.logic.KeyState;
import com.gigateam.world.logic.status.Character;
import com.gigateam.world.network.ClientInputStream.IInputStream;
import com.gigateam.world.network.Payload.NetworkEntity;
import com.gigateam.world.network.Payload.Packable;
import com.gigateam.physics.Impulse;
import com.gigateam.physics.shape.Vec;

/**
 * ...
 * @author Tiger
 */
class Client implements IInputStream implements ISubscriber implements Packable
{
	public var nickname:String = "";
	private var _inputStream:ClientInputStream;
	private var groupId:Int;
	private var worldTime:Int;
	private var keyState:KeyState;
	private var entity:Character;
	public var ackedSnapshotTime:UInt;
	
	public function new(gid:Int, time:Int) 
	{
		worldTime = time;
		groupId = gid;
		keyState = new KeyState(0);
		_inputStream = new ClientInputStream(time);
	}
	public function createInput(time:Int, transformX:Float, transformY:Float, keyBytes:Int):ClientInput{
		#if cpp
		return null;
		#else
		var input:ClientInput = new ClientInput(time-worldTime, transformX, transformY, keyBytes);
		_inputStream.append(input);
		return input;
		#end
	}
	public function pack(bytes:BytesStream, worldTime:Int = 0):Int{
		bytes.writeUTF(nickname);
		return 0;
	}
	public function unpack(bytes:BytesStream, remoteWorldTime:Int = 0, localWorldTime:Int = 0):Int{
		nickname = bytes.readUTF();
		return 0;
	}
	public function lastAckedInput():Int{
		return _inputStream.ackedTime();
	}
	public function getStream():ClientInputStream{
		return _inputStream;
	}
	public function dispose():Void{	
		_inputStream.dispose();
		_inputStream = null;
	}
	public function getEntity():Character{
		return entity;
	}
	public function setEntity(en:Character):Void{
		entity = en;
	}
	public function reset(time:Int):Void{
		worldTime = time;
		_inputStream.reset(time);
	}
	public function processBytes(bStream:BytesStream, offset:Int, time:Int):Int{
		ackedSnapshotTime = bStream.readInt24();
		_inputStream.unpack(bStream, 0, time);
		var arr:Array<ClientInput> = _inputStream.getRaw();
		var ackedTime:Int = _inputStream.ackedTime();
		
		if (ackedTime>time){
			return -1;
		}
		for ( input in arr){
			//input
			if ((time-input.time) > 1000){
				continue;
			}
			keyState.update(input.keyBytes);
			
			var state:Int = entity.processInput(keyState, input.transformX, input.transformY, input.time, time);
		}
		_inputStream.ack(time);
		return _inputStream.ackedTime();
	}
}