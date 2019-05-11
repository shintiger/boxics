package com.gigateam.world.physics.entity;
import com.gigateam.util.Debugger;
import com.gigateam.world.physics.Acceleration;
import com.gigateam.world.physics.Boost;
import com.gigateam.world.physics.Impulse;
import com.gigateam.world.physics.algorithm.Collision;
import com.gigateam.world.physics.algorithm.Equation;
import com.gigateam.world.physics.algorithm.SweepTestResult;
import com.gigateam.world.physics.math.AxisType;
import com.gigateam.world.physics.shape.AABB;
import com.gigateam.world.physics.shape.MovableAABB;
import com.gigateam.world.physics.shape.OBB;
import com.gigateam.world.physics.shape.Vec;
import com.gigateam.world.physics.timeline.DisplacementKeyframe;
import com.gigateam.world.physics.timeline.DisplacementTimeline;
import com.gigateam.world.physics.timeline.TweenKeyframe;
import com.gigateam.world.physics.timeline.TweenTimeline;

/**
 * ...
 * @author Tiger
 */
class Body 
{
	public var interpolationType:Int = 0;
	public var gravityV:Vec = null;
	public var movingVector:Vec = new Vec(0, 0, 0);
	public var collisionNotifier:ICollisionNotifier;
	public var collidable:Bool = true;
	public var moving:Bool = true;
	public var bodyType:Int = -1;
	//Normal XYZ are in inverted order, normalZ==-1 mean velocityZ are positive and colliding something
	public var normalX:Int = 0;
	public var normalY:Int = 0;
	public var normalZ:Int = 0;
	public var colliderX:AABB;
	public var colliderY:AABB;
	public var colliderZ:AABB;
	public var accumulateStop:Int = 0;
	public var accumulateAir:Int = 0;
	public var rewund:Int = 0;
	public var frictionAir:Float = 1;
	public var frictionLand:Float = 500;
	public var sweepTester:ISweepTester;
	public var debug:Bool = false;
	
	private var gravityAccel:Acceleration;
	private var _air:Bool = true;
	private var _updatedBoost:Bool = false;
	private var _space:Space = null;
	
	private var _gravityType:Int;
	private var _gravityBoost:Boost;
	private var _boostFullDirection:Boost;
	private var _boostHorizontal:Boost;
	private var _boostVertical:Boost;
	private var _boostFriction:Boost;
	
	private var _boost:Acceleration;
	private var _reckoned:Int;
	private var _gravity:Float = 980;
	private var _aabb:AABB;
	private var _dTimeline:DisplacementTimeline;
	private var _centerPoint:Vec;
	private var _centerPointUpdated:Bool = true;
	private var _pendingImpulse:Impulse;
	private var _tweening:TweenTimeline;
	private var _collidee:Array<SweepTestResult>;
	
	private static var _o:Vec = new Vec(0, 0, 0);
	private static var noGravity:Vec = new Vec();
	public function new(bType:Int, x:Float, xLength:Float, y:Float, yLength:Float, z:Float=0, zLength:Float=1, rx:Float=0, ry:Float=0, rz:Float=0) 
	{
		if(bType==BodyType.DYNAMIC){
			_aabb = new MovableAABB(new Vec(x, y, z), xLength, 0, yLength, 0, zLength, 0);
			_boost = new Acceleration(0, 0, 0);
			_collidee = [];
			_boostHorizontal = null;
			_boostVertical = null;
			_boostFullDirection = null;
		}else if(bType==BodyType.STATIC){
			if (rx == 0 && ry == 0 && rz == 0){
				_aabb = new AABB(new Vec(x, y, z), xLength, yLength, zLength);
			}else{
				_aabb = new OBB(new Vec(x, y, z), xLength, yLength, zLength, rx, ry, rz);
			}
		}
		bodyType = bType;
	}
	public function setGravity(gravityVector:Vec):Void{
		var t:Int = getGravityAxis(gravityVector);
		if (t ==-1){
			//return;
		}
		gravityV = gravityVector.clone();
		var gravityMagnitude:Float = gravityVector.getMagnitude();
		var g:Vec = gravityVector.clone();
		g.normalize();
		_gravityBoost = new Boost(g, gravityMagnitude, gravityMagnitude * 3);
		_gravityType = t;
	}
	public function getGravity():Boost{
		return _gravityBoost;
	}
	public function insertTween(time:Int, x:Float, y:Float, z:Float, rotZ:Float=0, rotX:Float=0, rotFace:Float=0):TweenKeyframe{
		time-= getOffsetTime();
		var keyframe:TweenKeyframe = new TweenKeyframe(time, x, y, z, rotZ, rotX, rotFace);
		_tweening.insertKeyframe(keyframe);
		
		return keyframe;
	}
	/*
	 * Use to determine have to pin keyframe or not from last updatePosition()
	 */
	public function boostUpdated():Bool{
		return _updatedBoost;
	}
	public function applyBoostX(acceleration:Float, maxVel:Float):Bool{
		return _applyBoost(acceleration, maxVel, AxisType.X);
	}
	public function applyBoostY(acceleration:Float, maxVel:Float):Bool{
		return _applyBoost(acceleration, maxVel, AxisType.Y);
	}
	public function applyBoostZ(acceleration:Float, maxVel:Float):Bool{
		return _applyBoost(acceleration, maxVel, AxisType.Z);
	}
	private function _applyBoost(acceleration:Float, maxVel:Float, axis:Int):Bool{
		moving = true;
		_updatedBoost = true;
		if (maxVel==0){
			acceleration = 0;
		}
		switch(axis){
			case AxisType.X:
				_boost.accelerationX = acceleration;
				_boost.maxVelX = maxVel;
			case AxisType.Y:
				_boost.accelerationY = acceleration;
				_boost.maxVelY = maxVel;
			case AxisType.Z:
				_boost.accelerationZ = acceleration;
				_boost.maxVelZ = maxVel;
		}
		return true;
	}
	public function getAABB():AABB{
		return _aabb;
	}
	public function stopBoost(time:Int):Void{
		_boostFullDirection = null;
		_boostHorizontal = null;
		_boostVertical = null;
		_updatedBoost = true;
	}
	public function hasBoost():Bool{
		return (_boostFullDirection != null || _boostHorizontal != null);
	}
	public function applyBooost(direction:Vec, acceleration:Float, maxVelocity:Float, time:Int):Void{
		if (_boostFullDirection == null){
			_boostFullDirection = new Boost(direction.clone(), acceleration, maxVelocity);
		}else{
			_boostFullDirection.direction.cloneFrom(direction);
			_boostFullDirection.acceleration = acceleration;
			_boostFullDirection.targetVelocity = maxVelocity;
		}
		_boostHorizontal = null;
		_boostVertical = null;
		_updatedBoost = true;
	}
	public function applyBoostHorizon(direction:Vec, acceleration:Float, maxVelocity:Float, time:Int):Void{
		if (_boostHorizontal == null){
			_boostHorizontal = new Boost(direction.clone(), acceleration, maxVelocity);
		}else{
			_boostHorizontal.direction.cloneFrom(direction);
			_boostHorizontal.acceleration = acceleration;
			_boostHorizontal.targetVelocity = maxVelocity;
		}
		_boostFullDirection = null;
		_updatedBoost = true;
	}
	public function applyBoostVertical(direction:Vec, acceleration:Float, maxVelocity:Float, time:Int):Void{
		if (_boostVertical == null){
			_boostVertical = new Boost(direction.clone(), acceleration, maxVelocity);
		}else{
			_boostVertical.direction = direction.clone();
			_boostVertical.acceleration = acceleration;
			_boostVertical.targetVelocity = maxVelocity;
		}
		_boostFullDirection = null;
		_updatedBoost = true;
	}
	
	public function init(space:Space, gravity:Vec, offsetTime:Int):Void{
		var defaultGravity:Bool = true;
		if (gravityV == null){
			defaultGravity = false;
			gravityV = gravity.clone();
		}
		_space = space;
		if (bodyType == BodyType.DYNAMIC){
			_boostFriction = new Boost(new Vec(), 1, 1);
			//Using false to force update(default should be true)
			_air = updateAir(false);
			gravityAccel = new Acceleration();
			gravityAccel.accelerationX = gravityV.x;
			gravityAccel.accelerationY = gravityV.y;
			gravityAccel.accelerationZ = gravityV.z;
			gravityAccel.maxVelX = gravityV.x;
			gravityAccel.maxVelY = gravityV.y;
			gravityAccel.maxVelZ = gravityV.z;
			
			_dTimeline = new DisplacementTimeline(offsetTime);
			_tweening = new TweenTimeline(offsetTime, 200);
			var keyframe:DisplacementKeyframe = new DisplacementKeyframe(0, new Vec(0, 0, 0), _aabb.origin, new Acceleration(0, 0, 0));
			applyAcceleration(keyframe);
			_dTimeline.insertKeyframe(keyframe);
			insertTween(0, 0, 0, 0);
		}
	}
	public function popImpulse():Impulse{
		var imp:Impulse = _pendingImpulse;
		_pendingImpulse = null;
		return imp;
	}
	public function getOffsetTime():Int{
		return _dTimeline.offset;
	}
	public function getDisplacementTimeline():DisplacementTimeline{
		return _dTimeline;
	}
	public function getTweenTimeline():TweenTimeline{
		return _tweening;
	}
	public function applyImpulse(impulse:Impulse):Void{
		moving = true;
		_updatedBoost = true;
		_pendingImpulse = impulse;
	}
	private static var boostAccel:Vec = new Vec();
	private static var boostMax:Vec = new Vec();
	private static function calcMaxVel(velocity:Float, acceleration:Float, boostMax:Float, gravity:Float):Float{
		if (acceleration == 0){
			return velocity;
		}
		var diff1:Float = boostMax - velocity;
		var diff2:Float = gravity - velocity;
		if (velocity == 0 || diff1==0){
			if (acceleration > 0){
				return Math.max(boostMax, gravity);
			}
			return Math.min(boostMax, gravity);
		}
		var accelPossitive:Bool = acceleration > 0;
		if ((diff1 > 0) == accelPossitive){
			if (accelPossitive){
				return Math.max(boostMax, gravity);
			}
			return Math.min(boostMax, gravity);
		}
		//else if ((diff2 > 0) == accelPossitive){
		return gravity;
	}
	public function isAir():Bool{
		return _air;
	}
	private function projectForce(force:Vec):Vec{
		for (result in _collidee){
			force = Equation.slideVector(force, result.affectingAxis);
		}
		return force;
	}
	public function applyAcceleration(keyframe:DisplacementKeyframe, debug:Bool = false):Void{
		var ac:Acceleration = keyframe.acceleration;
		var inertia:Vec = keyframe.inertia;
		//var frictionMagnitude:Float = frictionAir;
		//var mag:Float = frictionAir;
		//var fricV:Vertex;
		var force:Vec = projectForce(inertia);
		//Debugger.getInstance().log("------------------------------------------------");
		var accelerator:Float = _air ? 1 : 5;
		if (_boostFullDirection != null){
			//Debugger.getInstance().log("Condition 1");
			blendAcceleration(force, _gravityBoost, ac, _boostFullDirection, accelerator);
		}else if (_boostHorizontal != null || _boostVertical != null){
			//Debugger.getInstance().log("Condition 2");
			blendAccelerationMix(force, _gravityBoost, ac, _boostHorizontal, _boostVertical, accelerator);
		}else{
			//Debugger.getInstance().log("Condition 3");
			_boostFriction.direction.cloneFrom(force);
			_boostFriction.direction.normalize();
			_boostFriction.direction.mul( -1);
			//_boostFriction.targetVelocity = 0;
			//Debugger.getInstance().log("Acceleration:"+Std.string(_boostFriction.acceleration));
			blendAcceleration(force, _gravityBoost, ac, _boostFriction, _air ? frictionAir : frictionLand);
		}
		keyframe.inertia = force;
		
		//keyframe.applyFriction();
		keyframe.updateDuration();
	}
	public function applyAccelerationOld2(keyframe:DisplacementKeyframe, debug:Bool=false):Void{
		var ac:Acceleration = keyframe.acceleration;
		var inertia:Vec = keyframe.inertia;
		var frictionMagnitude:Float = frictionAir;
		var mag:Float = frictionAir;
		var fricV:Vec;
		var force:Vec;
		
		if(!_air){
			frictionMagnitude = frictionLand;
			mag = frictionLand;
		}
		force = projectForce(inertia);
		
		//fricV = force.clone();
		//fricV.normalize();
		//fricV.mul( -frictionMagnitude);
		var targetVelocity:Vec = _air ? gravityV : noGravity;
		//frictionMagnitude = fricV.getMagnitude();
		_boost.getAccel(boostAccel);
		_boost.getMaxVel(boostMax);
		boostAccel.mul(mag);
		boostAccel = projectForce(boostAccel);
		
		gravityAccel.setMaxVel(targetVelocity);
		fricV = targetVelocity.clone();
		fricV.minus(boostAccel);
		fricV.normalize();
		fricV.mul(frictionMagnitude);
		gravityAccel.setAccel(fricV);
		
		//boostMax.x = calcMaxVel(force.x, boostAccel.x, boostMax.x, _air ? gravityV.x : 0);
		//boostMax.y = calcMaxVel(force.y, boostAccel.y, boostMax.y, _air ? gravityV.y : 0);
		//boostMax.z = calcMaxVel(force.z, boostAccel.z, boostMax.z, _air ? gravityV.z : 0);
		
		boostMax = projectForce(boostMax);
		keyframe.inertia = force;
		ac.setAccel(boostAccel);
		ac.setMaxVel(boostMax);
		ac.blend(gravityAccel);
		
		//keyframe.updateDuration();
		keyframe.applyFriction(frictionMagnitude, targetVelocity);
			
		return;
	}
	private function blendAccelerationMix(inertia:Vec, gravity:Boost, out:Acceleration, horizontal:Boost, vertical:Boost, accelerationMultiplier:Float = 1):Bool{
		var target:Vec = horizontal.direction.clone();
		target.mul(horizontal.targetVelocity);
		var g:Vec = gravity.direction.clone();
		g.normalize();
		var dot:Float = target.dot(g);
		var remain:Float;
		var remainVector:Vec;
		if (false && dot >= 0 && dot < gravity.targetVelocity){
			remain = gravity.targetVelocity - dot;
			remainVector = g.clone();
			remainVector.mul(remain);
			target.plus(remainVector);
		}
		var acc:Vec = target.clone();
		
		target.plus(gravity.getVelocityVector());
		target = projectForce(target);
		acc.minus(inertia);
		acc.z = 0;
		acc.normalize();
		acc.mul(horizontal.acceleration*accelerationMultiplier);
		dot = acc.dot(g);
		if (false && dot >= 0 && dot < gravity.acceleration){
			remain = gravity.acceleration - dot;
			remainVector = g;
			remainVector.mul(remain);
			acc.plus(remainVector);
		}
		acc.plus(gravity.getAccelerationVector());
		
		acc = projectForce(acc);
		//Debugger.getInstance().log("inertia:"+inertia.toString());
		//Debugger.getInstance().log("target:"+target.toString());
		//Debugger.getInstance().log("acceleration:" + acc.toString());
		out.setMaxVel(target);
		out.setAccel(acc);
		
		return true;
	}
	private function blendAccelerationMixOld(inertia:Vec, gravity:Boost, out:Acceleration, horizontal:Boost, vertical:Boost, accelerationMultiplier:Float=1):Bool{
		if (vertical==null || vertical.direction.equalZero()){
			return blendAcceleration(inertia, gravity, out, horizontal, accelerationMultiplier);
		}else if (horizontal==null || horizontal.direction.equalZero()){
			return blendAcceleration(inertia, gravity, out, vertical, accelerationMultiplier);
		}
		
		horizontal.getVelocityVector(_o);
		_o = projectForce(_o);
		var horizontalAcc:Vec = _o.clone();
		_o.minus(inertia);
		_o.mul(horizontal.acceleration);
		
		var remain:Float;
		var remainVector:Vec;
		var verticalTarget:Vec = vertical.getVelocityVector();
		var g:Vec = gravity.direction;
		var dot:Float = verticalTarget.dot(g);
		if (dot >= 0 && dot < gravity.targetVelocity){
			remain = gravity.targetVelocity - dot;
			remainVector = g.clone();
			remainVector.mul(remain);
			verticalTarget.plus(remainVector);
		}
		
		var verticalAcc:Vec = vertical.getAccelerationVector();
		verticalAcc.mul(accelerationMultiplier);
		dot = verticalAcc.dot(g);
		if (dot >= 0 && dot < gravity.acceleration){
			remain = gravity.acceleration - dot;
			remainVector = g;
			remainVector.mul(remain);
			verticalAcc.plus(remainVector);
		}
		
		verticalTarget.plus(_o);
		verticalAcc.plus(horizontalAcc);
		
		out.setMaxVel(verticalTarget);
		out.setAccel(verticalAcc);
		
		return true;
	}
	private function blendAcceleration(inertia:Vec, gravity:Boost, out:Acceleration, boost:Boost, accelerationMultiplier:Float=1):Bool{
		var target:Vec = boost.direction.clone();
		target.mul(boost.targetVelocity);
		var g:Vec = gravity.direction.clone();
		g.normalize();
		var dot:Float = target.dot(g);
		var remain:Float;
		var remainVector:Vec;
		if (false && dot >= 0 && dot < gravity.targetVelocity){
			remain = gravity.targetVelocity - dot;
			remainVector = g.clone();
			remainVector.mul(remain);
			target.plus(remainVector);
		}
		var acc:Vec = target.clone();
		
		target.plus(gravity.getVelocityVector());
		target = projectForce(target);
		acc.minus(inertia);
		//acc.z = 0;
		acc.normalize();
		acc.mul(boost.acceleration*accelerationMultiplier);
		dot = acc.dot(g);
		if (false && dot >= 0 && dot < gravity.acceleration){
			remain = gravity.acceleration - dot;
			remainVector = g;
			remainVector.mul(remain);
			acc.plus(remainVector);
		}
		acc.plus(gravity.getAccelerationVector());
		
		acc = projectForce(acc);
		//Debugger.getInstance().log("inertia:"+inertia.toString());
		//Debugger.getInstance().log("target:"+target.toString());
		//Debugger.getInstance().log("acceleration:" + acc.toString());
		out.setMaxVel(target);
		out.setAccel(acc);
		
		return true;
	}
	private static function getGravityAxis(gravity:Vec):Int{
		var mag:Float = gravity.getMagnitude();
		if (Math.abs(gravity.x) == mag){
			return AxisType.X;
		}else if (Math.abs(gravity.y) == mag){
			return AxisType.Y;
		}else if (Math.abs(gravity.z) == mag){
			return AxisType.Z;
		}else if (gravity.equalZero()){
			return -1;
		}else{
			return -2;
		}
	}
	
	public function applyBoost(boost:Acceleration):Void{
		_boost = boost;
	}
	public function keyframeAt(time:Int):DisplacementKeyframe{
		time -= _dTimeline.offset;
		
		var keyframe:DisplacementKeyframe = _dTimeline.asKeyframe(time);
		return keyframe;
	}
	public function pinKeyframe(time:Int):DisplacementKeyframe{
		time -= _dTimeline.offset;
		
		var keyframe:DisplacementKeyframe = _dTimeline.asKeyframe(time);
		applyAcceleration(keyframe);
		_dTimeline.insertKeyframe(keyframe);
		return keyframe;
	}
	public function resetReckoning(time:Int):Void{
		time -= _dTimeline.offset;
		
		_reckoned = time;
	}
	public function reckoning(time:Int):Bool{
		var otime:Int = time;
		time -= _dTimeline.offset;
		
		_reckoned = time;
		
		var lastKeyframe:DisplacementKeyframe = cast _dTimeline.lastFrame(time);
		if (lastKeyframe == null){
			//Debugger.getInstance().log("otime:"+otime+", time:" + time+", dTimeline.offset:" + _dTimeline.offset);
			return false;
		}
		var lastAccel:Acceleration = lastKeyframe.acceleration;
		var inertia:Vec = lastKeyframe.inertia;
		var deltaTime:Float = (time-lastKeyframe.time) * 0.001;
		
		_dTimeline.getPositionOnly(time, _o);
		
		var mAABB:MovableAABB = cast _aabb;
		
		mAABB.vx = _o.x + lastKeyframe.origin.x - mAABB.origin.x;
		mAABB.vy = _o.y + lastKeyframe.origin.y - mAABB.origin.y;
		mAABB.vz = _o.z + lastKeyframe.origin.z - mAABB.origin.z;
		
		return true;
	}
	public function resetPosition(time:Int, x:Float, y:Float, z:Float = 0):Void{
		time -= _dTimeline.offset;
		
		_aabb.origin.x = x;
		_aabb.origin.y = y;
		_aabb.origin.z = z;
		
		_dTimeline.setCursor(time);
	}
	public function updatePosition(updateCursor:Bool = true):Void{
		if (updateCursor)
			_dTimeline.setCursor(_reckoned);
			
		var mAABB:MovableAABB = cast _aabb;
		
		movingVector.x = mAABB.vx;
		movingVector.y = mAABB.vy;
		movingVector.z = mAABB.vz;
		mAABB.move();
		_centerPointUpdated = true;
		_updatedBoost = false;
	}
	public function getCursor():Int{
		//Cursor means when AABB's coordinate is
		return _dTimeline.getCursor();
	}
	public function centerPoint():Vec{
		if (_centerPointUpdated)
			_centerPoint = _aabb.centerPoint();
		_centerPointUpdated = false;
		return _centerPoint;
	}
	public function positionUpdated():Void{
		_centerPointUpdated = true;
	}
	public function bottomPoint():Vec{
		return _aabb.zMinPoint();
	}
	public function x():Float{
		return centerPoint().x;
	}
	public function y():Float{
		return centerPoint().y;
	}
	public function z():Float{
		return centerPoint().z;
	}
	public function collisionStart(axis:Vec, colliding:AABB, worldTime:Int):Void{
		if (collisionNotifier != null){
			collisionNotifier.collisionStart(this, axis, colliding, worldTime);
		}
	}
	public function collisionEnd(axis:Vec, colliding:AABB, worldTime:Int):Void{
		if (collisionNotifier != null){
			collisionNotifier.collisionEnd(this, axis, colliding, worldTime);
		}
	}
	public function land(worldTime:Int):Void{
		if (collisionNotifier != null){
			collisionNotifier.land(this, worldTime);
		}
	}
	public function fall(worldTime:Int):Void{
		if (collisionNotifier != null){
			collisionNotifier.fall(this, worldTime);
		}
	}
	public function addResult(result:SweepTestResult, worldTime:Int):Int{
		var index:Int = _collidee.push(result);
		if (collisionNotifier != null){
			collisionNotifier.collisionStart(this, result.affectingAxis, result.target, worldTime);
		}
		_air = updateAir(_air);
		return index;
	}
	private function updateAir(org:Bool):Bool{
		for (result in _collidee){
			if (result.affectingAxis.dot(gravityV) < 0){
				if (org){
					_gravityBoost.acceleration = 0;
					_gravityBoost.targetVelocity = 0;
				}
				return false;
			}
		}
		if (!org){
			setGravity(gravityV);
		}
		return true;
	}
	public function collideeExists(collidee:AABB):Bool{
		for (res in _collidee){
			if (res.target == collidee){
				return true;
			}
		}
		return false;
	}
	private function removeResult(result:SweepTestResult):Bool{
		return _collidee.remove(result);
	}
	public function removeNonIntersects(broadphase:AABB, earliest:SweepTestResult, worldTime:Int):UInt{
		var i:Int;
		var result:SweepTestResult;
		var exitingCollidees:Array<SweepTestResult> = [];
		result = new SweepTestResult();
		for (i in 0..._collidee.length){
			if (Std.is(_collidee[i].target, OBB)){
				var obb:OBB = cast _collidee[i].target;
				var collided:Bool = false;
				if(Collision.AABBCheck(broadphase, obb)){
					obb.collideMovableAABB(cast this._aabb, result);
					if (result.isCollided){
						collided = true;
					}
				}
				if (!collided){
					exitingCollidees.push(_collidee[i]);
				}
			}else{
				var aabb:AABB = _collidee[i].target;
				if (!Collision.AABBCheck(broadphase, aabb) || !Collision.sweepAABB(cast this._aabb, aabb, result)){
					if (!Collision.AABBCheck(this._aabb, aabb) && earliest.target != aabb){
						exitingCollidees.push(_collidee[i]);
					}
				}
			}
		}
		var removed:UInt = 0;
		for (res in exitingCollidees){
			if (_collidee.remove(res)){
				removed += 1;
				if (collisionNotifier != null){
					collisionNotifier.collisionEnd(this, result.affectingAxis, result.target, worldTime);
				}
			}
		}
		_air = updateAir(_air);
		return removed;
	}
}