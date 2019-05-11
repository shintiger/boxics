package com.gigateam.world.logic.status;

/**
 * ...
 * @author Tiger
 */
class IdleState extends EntityState
{
	public function new(observator:INotifee) 
	{
		super(EntityState.IDLE, observator, 0);
	}
	
}