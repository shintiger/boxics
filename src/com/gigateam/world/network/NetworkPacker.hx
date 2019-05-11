package com.gigateam.world.network;
import com.gigateam.world.entity.Entity;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.network.Payload.NetworkEntity;
import haxe.io.Bytes;
/**
 * ...
 * @author Tiger
 */
class NetworkPacker extends NetworkStream
{
	public var lastAckTime:Int = 0;
	public function new(pool:NetworkEntityPool) 
	{
		super(pool);
	}
	public function packSnapshot(bytes:Bytes, worldTime:Int, offset:Int=0):Int{
		var entities:Map<Int, NetworkEntity> = _pool.getPool();
		var networkId:Int;
		var originOffset:Int = offset;
		
		var bStream:BytesStream = new BytesStream(bytes, offset);
		
		/*for (networkId in entities.keys()){
			var entity:NetworkEntity = entities.get(networkId);
			var libId:Int = entity.libId;
			bytes.set(offset, libId);
			offset += 1;
			bytes.setInt32(offset, networkId);
			offset += 4;
			offset += entity.pack(bStream, offset);
		}
		return offset - originOffset;*/
		bStream.writeInt24(worldTime);
		for (networkId in entities.keys()){
			var entity:NetworkEntity = entities.get(networkId);
			var libId:Int = entity.libId;
			bStream.write(libId);
			bStream.writeInt32(networkId);
			entity.pack(bStream, worldTime);
		}
		return bStream.offset() - originOffset;
	}
}