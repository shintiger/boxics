package com.gigateam.world.logic.status;
import com.gigateam.util.ITask;

/**
 * @author Tiger
 */
interface IEntityState implements ITask 
{
	function activate(expire:Float):Void;
	function deactivate():Void;
}