package com.gigateam.world.network;
import com.gigateam.util.BytesUtil;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.logic.status.IInput;
import com.gigateam.world.network.Payload.Packable;
import haxe.Int32;
import haxe.Int64;
import haxe.io.Bytes;

/**
 * ...
 * @author Tiger
 */
class ClientInput implements Packable implements IInput
{

	public var time:Int;
	public var transformX:Float;
	public var transformY:Float;
	public var keyBytes:Int;
	public function new(_time:Int, _transformX:Float, _transformY:Float, _keyBytes:Int) 
	{
		time = _time;
		transformX = _transformX;
		transformY = _transformY;
		keyBytes = _keyBytes;
	}
	public function pack(bytes:BytesStream, worldTime:Int=0):Int{
		/*var originOffset:Int = offset;
		offset += BytesUtil.writeUnsignedInt24(bytes, offset, time);
		bytes.setInt32(offset, Std.int(transformX*1000));
		offset += 4;
		bytes.setInt32(offset, Std.int(transformY*1000));
		offset += 4;
		offset += BytesUtil.writeUnsignedInt24(bytes, offset, keyBytes);
		
		return offset-originOffset;*/
		
		var originOffset:Int = bytes.offset();
		bytes.writeInt24(time);
		bytes.writeInt32(Std.int(transformX * 1000));
		bytes.writeInt32(Std.int(transformY * 1000));
		bytes.writeInt24(keyBytes);
		
		return bytes.offset()-originOffset;
	}
	public function unpack(bytes:BytesStream, remoteWorldTime:Int=0, localWorldTime:Int=0):Int{
		/*var originOffset:Int = offset;
		time = BytesUtil.readUnsignedInt24(bytes, offset);
		offset += 3;
		transformX = bytes.getInt32(offset)*0.001;
		offset += 4;
		transformY = bytes.getInt32(offset)*0.001;
		offset += 4;
		keyBytes = BytesUtil.readUnsignedInt24(bytes, offset);
		offset += 3;
		
		return offset-originOffset;*/
		var originOffset:Int = bytes.offset();
		time = bytes.readInt24();
		transformX = bytes.readInt32()*0.001;
		transformY = bytes.readInt32()*0.001;
		keyBytes = bytes.readInt24();
		
		return bytes.offset()-originOffset;
	}
	public function getKeyBytes():Int{
		return keyBytes;
	}
	public function getTransformX():Float{
		return transformX;
	}
	public function getTransformY():Float{
		return transformY;
	}
}