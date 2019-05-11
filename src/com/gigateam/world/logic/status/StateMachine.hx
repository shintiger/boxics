package com.gigateam.world.logic.status;

/**
 * ...
 * @author Tiger
 */
class StateMachine 
{
	private var mCurrentStateKey:Int = -1;
	private var mCurrent:IState;
	private var states:Map<Int, IState>;
	public function new() 
	{
		states = new Map<Int, IState>();
	}
	public function add(key:String, state:IState):Void{
		states.set(key, state);
	}
	public function change(key:Int):Void{
		var state:IState = states.get(key);
		if (mCurrent != null){
			mCurrent.exit();
		}
		mCurrent = state;
		mCurrentStateKey = key;
		mCurrent.enter();
	}
	public function stateKey():Int{
		return mCurrentStateKey;
	}
}