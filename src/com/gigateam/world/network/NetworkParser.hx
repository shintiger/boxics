package com.gigateam.world.network;
import com.gigateam.util.BytesUtil;
import com.gigateam.util.Debugger;
import com.gigateam.world.entity.Entity;
import com.gigateam.world.entity.EntityManager.EntityCreator;
import com.gigateam.world.logic.BytesStream;
import com.gigateam.world.network.Payload.NetworkEntity;
import com.gigateam.world.physics.entity.Space;
import haxe.io.Bytes;
/**
 * ...
 * @author Tiger
 */
class NetworkParser extends NetworkStream
{
	private var _creator:EntityCreator;
	private var _space:Space;
	public function new(pool:NetworkEntityPool, creator:EntityCreator, space:Space) 
	{
		super(pool);
		//_packer = packer;
		_creator = creator;
		_space = space;
	}
}