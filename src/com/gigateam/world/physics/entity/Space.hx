package com.gigateam.world.physics.entity;
import com.gigateam.util.Debugger;
import com.gigateam.world.WorldSimulator;
import com.gigateam.world.physics.Impulse;
import com.gigateam.world.physics.InterpolationType;
import com.gigateam.world.physics.algorithm.Collision;
import com.gigateam.world.physics.algorithm.ProjectionResult;
import com.gigateam.world.physics.algorithm.SweepTestResult;
import com.gigateam.world.physics.math.AxisType;
import com.gigateam.world.physics.shape.AABB;
import com.gigateam.world.physics.shape.AABBTree;
import com.gigateam.world.physics.shape.AABBTreeNode;
import com.gigateam.world.physics.shape.MovableAABB;
import com.gigateam.world.physics.shape.OBB;
import com.gigateam.world.physics.shape.Vec;
import com.gigateam.world.physics.timeline.DisplacementKeyframe;
import com.gigateam.world.physics.timeline.TweenKeyframe;
import haxe.ds.GenericStack;

/**
 * ...
 * @author Tiger
 */
class Space 
{
	public var airThreshold:Int = 3;
	private var _movableBody:GenericStack<Body>;
	private var _staticBody:GenericStack<Body>;
	private var _movableTree:AABBTree;
	private var _staticTree:AABBTree;
	private var _offsetTime:Int;
	private var _gravity:Vec;
	private var debugStr:String = "";
	public function new(offsetTime:Int, gravity:Vec) 
	{
		_movableBody = new GenericStack<Body>();
		_movableTree = new AABBTree(10);
		_staticBody = new GenericStack<Body>();
		_staticTree = new AABBTree(1);
		_offsetTime = offsetTime;
		Debugger.getInstance().log("offsetTime:" + Std.string(_offsetTime));
		_gravity = gravity.clone();
	}
	public function reset(time:Int):Void{
		_offsetTime = time;
	}
	public function getStaticBodies():Array<Body>{
		var body:Body;
		var arr:Array<Body> = new Array<Body>();
		var i:Int = 0;
		for (body in _staticBody){
			arr.push(body);
			//arr.insert(i, body);
			i++;
		}
		return arr;
	}
	public function unSpawnBody(body:Body):Void{
		if (body.bodyType == BodyType.DYNAMIC){
			_movableBody.remove(body);
			_movableTree.remove(body.getAABB());
		}else{
			_staticBody.remove(body);
			_staticTree.remove(body.getAABB());
			_staticTree.update();
		}
	}
	public function spawnBody(body:Body, spawnAt:Int, gravity:Vec=null):Void{
		spawnAt -= _offsetTime;
		if (body.bodyType == BodyType.DYNAMIC){
			_movableBody.add(body);
			_movableTree.add(body.getAABB());
		}else{
			_staticBody.add(body);
			_staticTree.add(body.getAABB());
			_staticTree.update();
		}
		if (gravity == null){
			gravity = _gravity;
		}
		body.init(this, gravity, spawnAt);
	}
	public function getOffset():Int{
		return _offsetTime;
	}
	public static function bodySweepTest(body:Body, tree:AABBTree, broadphase:AABB, earliestCr:SweepTestResult):AABB{
		var colliding:AABB = null;
		var nodes:GenericStack<AABBTreeNode> = tree.collidingWith(broadphase);
		var aabb:MovableAABB = cast body.getAABB();
		var cr:SweepTestResult = new SweepTestResult();
		for (node in nodes){
			if (Std.is(node.data, OBB)){
				var obb:OBB = cast node.data;
				var pr:ProjectionResult = obb.collideMovableAABB(aabb, cr);
				if (!cr.isCollided){
					continue;
				}
			}else{
				if (!Collision.sweepAABB(aabb, node.data, cr)){
					continue;
				}
			}
			if (body.collideeExists(node.data)){
				cr.entryTime+= 1;
			}
			//cr.entryTime < earliestCr.entryTime
			//get the earliest colliding time to avoid multiple collision at one step
			if (cr.entryTime < earliestCr.entryTime){
				colliding = node.data;
				earliestCr.cloneFrom(cr);
			}
		}
		return colliding;
	}
	public function advance(globalTime:Int):Void{
		var time:Int = globalTime-_offsetTime;
		var broadphase:AABB = AABB.create();
		
		var nodes:GenericStack<AABBTreeNode>;
		var node:AABBTreeNode;
		var cr:SweepTestResult = new SweepTestResult();
		var earliestCr:SweepTestResult = new SweepTestResult();
		//earliestCr = new CollisionResult();
		var colliding:AABB;
		var body:Body;
		var emptyTween:TweenKeyframe = TweenKeyframe.empty();
		//0:no collision, 1:new collision, -1:old existing collision

		var collisionState:Int;
		
		_movableTree.update();
		for (b in _movableBody){
			body = b;
			if (body.interpolationType==InterpolationType.TWEENING){
				//var result:Int = body.getTweenTimeline().interpolate(time-body.rewund, emptyTween);
				continue;
			}else if (!body.moving){
				continue;
			}
			//Rewunded time of this body
			var objTime:Int = time-body.rewund;
			var lastKeyframe:DisplacementKeyframe;
			colliding = null;
			earliestCr.isCollided = false;
			earliestCr.entryTime = 1 * 2;
			earliestCr.normalX = 0;
			earliestCr.normalY = 0;
			earliestCr.normalZ = 0;
			//!Important! Call reckoning to get where body to go to at this step from last step.
			if (!body.reckoning(objTime)){
				//Debugger.getInstance().log("exiting3");
				continue;
			}else if (!body.collidable){
				body.updatePosition();
				//Debugger.getInstance().log("exiting4");
				continue;
			}
			if (body.debug){
				var origin:Vec = body.getAABB().origin;
				//Debugger.getInstance().log("pos:"+origin.toString());
			}
			var impulse:Impulse = body.popImpulse();
			var relativeCurrent:Int = objTime-body.getOffsetTime();
			var interpolation:Int = 0;
			var keyframe:DisplacementKeyframe = null;
			var aabb:MovableAABB = cast body.getAABB();
			var normalX:Int = 0;
			var normalY:Int = 0;
			var normalZ:Int = 0;
			var moving:Vec = new Vec(aabb.vx, aabb.vy, aabb.vz);
			var movingDistance:Float = moving.length();
			Collision.getSweptBroadphaseBox(aabb, broadphase);
			
			colliding = bodySweepTest(body, _staticTree, broadphase, earliestCr);
			if (body.sweepTester != null){
				colliding = body.sweepTester.sweepTest(body, this, broadphase, colliding, earliestCr, time, time);
			}
			lastKeyframe = cast body.getDisplacementTimeline().lastFrame(objTime);
			if (earliestCr.isCollided){
				if (earliestCr.entryTime >= 1){
					earliestCr.entryTime-= 1;
					collisionState = CollisionState.EXISTING_COLLISION;
				}else{
					collisionState = CollisionState.NEW_COLLISION;
					
					if (earliestCr.entryTime == 0){
						interpolation = relativeCurrent;
						keyframe = body.getDisplacementTimeline().asKeyframe(body.getCursor());
						keyframe.time = interpolation;
					}else{
						interpolation = Std.int(body.getCursor() + (relativeCurrent - body.getCursor()) * earliestCr.entryTime / 1);
						keyframe = body.getDisplacementTimeline().asKeyframe(interpolation);
					}
					
					aabb.vx *= earliestCr.entryTime;
					aabb.vy *= earliestCr.entryTime;
					aabb.vz *= earliestCr.entryTime;
					
					keyframe.origin.x = aabb.origin.x + aabb.vx;
					keyframe.origin.y = aabb.origin.y + aabb.vy;
					keyframe.origin.z = aabb.origin.z + aabb.vz;
					
					Collision.getSweptBroadphaseBox(aabb, broadphase);
				}
			}else{
				collisionState = CollisionState.NO_COLLISION;
			}
			lastKeyframe = cast body.getDisplacementTimeline().lastFrame(objTime);
			var collisionEnd:Bool;
			var fromAir:Bool = body.isAir();
			collisionEnd = body.removeNonIntersects(broadphase, earliestCr, objTime) > 0;
			
			
			//When not new collision BUT some collidee leave OR body itself does something changes(eg:new impulse), pin it
			lastKeyframe = cast body.getDisplacementTimeline().lastFrame(objTime);
			if ((collisionEnd || body.boostUpdated()) && keyframe == null){
				keyframe = body.pinKeyframe(time);
			}
			
			lastKeyframe = cast body.getDisplacementTimeline().lastFrame(objTime);
			
			if (collisionState==CollisionState.NEW_COLLISION){
				//body.applyAcceleration(keyframe);
				body.addResult(earliestCr.clone(), objTime);
				body.resetReckoning(interpolation + body.getOffsetTime());
				if (!body.getDisplacementTimeline().insertKeyframe(keyframe)){
					throw "a";
				}
			}
			var toAir:Bool = body.isAir();
			if (toAir != fromAir){
				if (fromAir){
					body.land(objTime);
				}else{
					body.fall(objTime);
				}
			}
			//lastKeyframe = cast body.getDisplacementTimeline().lastFrame(objTime);
			var hasImpulse:Bool = false;
			if (impulse != null){
				//If this impulse direction is up, then set air to true
				if (keyframe.applyImpulse(impulse) < 0){
				}
				hasImpulse = true;
			}else if (Std.is(earliestCr.target, OBB)){
				hasImpulse = true;
			}
			
			if (impulse != null || collisionState==CollisionState.NEW_COLLISION){
				body.applyAcceleration(keyframe, hasImpulse);
			}
			
			body.updatePosition();
		}
	}
}