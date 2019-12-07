package com.gigateam.physics.shape;
import com.gigateam.util.Debugger;
import com.gigateam.physics.algorithm.Collision;
import com.gigateam.physics.algorithm.ProjectionResult;
import com.gigateam.physics.algorithm.SweepTestResult;
import com.gigateam.physics.math.Transform3D;
import haxe.macro.Type;

/**
 * ...
 * @author Tiger
 */
class OBB extends AABB
{
	private var originalWidth:Float;
	private var originalHeight:Float;
	private var originalDepth:Float;
	private var rx:Float;
	private var ry:Float;
	private var rz:Float;
	private var transform:Transform3D = new Transform3D();
	private var axises:Array<Vec>;
	private static inline var HUGH:Float = 1000000;
	public function new(minVertex:Vec, _width:Float, _height:Float, _depth:Float, rotationX:Float, rotationY:Float, rotationZ:Float)
	{
		super(minVertex, _width, _height, _depth);
		boundingType = 2;
		originalWidth = _width;
		originalHeight = _height;
		originalDepth = _depth;
		
		compose(rotationX, rotationY, rotationZ);
	}
	public function compose(rotationX:Float, rotationY:Float, rotationZ:Float):Void{
		w = originalWidth;
		h = originalHeight;
		d = originalDepth;
		
		rotatedAxises = 0;
		
		if (rotationX != 0){
			rotatedAxises += 1;
		}
		if (rotationY != 0){
			rotatedAxises += 1;
		}
		if (rotationZ != 0){
			rotatedAxises += 1;
		}
		
		rx = rotationX;
		ry = rotationY;
		rz = rotationZ;
		
		//Pack translation, rotation and scale into a matrix
		composeTransform();
		
		//Get local coords after trasformed
		createVertexes(true);
		
		//Update bounding box to newer
		var mx:Float = minX();
		var my:Float = minY();
		var mz:Float = minZ();
		w = maxX() - mx;
		h = maxY() - my;
		d = maxZ() - mz;
		origin.x = origin.x + originalWidth * 0.5 - w * 0.5;
		origin.y = origin.y + originalHeight * 0.5 - h * 0.5;
		origin.z = origin.z + originalDepth * 0.5 - d * 0.5;
		
		//Pre-calculate axises
		axises = [];
		axises.push(getAxis(0, 1));
		axises.push(getAxis(0, 2));
		axises.push(getAxis(0, 3));
	}
	override public function axisX():Vec{
		return axises[0];
	}
	override public function axisY():Vec{
		return axises[1];
	}
	override public function axisZ():Vec{
		return axises[2];
	}
	private function getAxis(from:UInt, to:UInt, out:Vec = null):Vec{
		if (out==null){
			out = new Vec();
		}
		out.x = (vertexes[to].x - vertexes[from].x) * 0.5;
		out.y = (vertexes[to].y - vertexes[from].y) * 0.5;
		out.z = (vertexes[to].z - vertexes[from].z) * 0.5;
		out.normalize();
		
		return out;
	}
	private function minX():Float{
		var num:Float = HUGH;
		for (v in vertexes){
			if (v.x < num){
				num = v.x;
			}
		}
		return num;
	}
	private function minY():Float{
		var num:Float = HUGH;
		for (v in vertexes){
			if (v.y < num){
				num = v.y;
			}
		}
		return num;
	}
	private function minZ():Float{
		var num:Float = HUGH;
		for (v in vertexes){
			if (v.z < num){
				num = v.z;
			}
		}
		return num;
	}
	private function maxX():Float{
		var num:Float = -HUGH;
		for (v in vertexes){
			if (v.x > num){
				num = v.x;
			}
		}
		return num;
	}
	private function maxY():Float{
		var num:Float = -HUGH;
		for (v in vertexes){
			if (v.y > num){
				num = v.y;
			}
		}
		return num;
	}
	private function maxZ():Float{
		var num:Float = -HUGH;
		for (v in vertexes){
			if (v.z > num){
				num = v.z;
			}
		}
		return num;
	}
	override private function createGlobalVertex(minX:Bool, minY:Bool, minZ:Bool, out:Vec=null):Vec{
		out = createVertex(minX, minY, minZ, out);
		return localToGlobal(out);
	}
	private function composeTransform():Transform3D{
		var x:Float = origin.x + originalWidth * 0.5;
		var y:Float = origin.y + originalHeight * 0.5;
		var z:Float = origin.z + originalDepth * 0.5;
		
		transform.compose(origin.x, origin.y, origin.z, rx, ry, rz, 1, 1, 1);
		
		return transform;
	}
	private function localToGlobal(v:Vec, out:Vec = null):Vec{
		var trm:Transform3D = transform;
		if (out == null){
			out = new Vec(0, 0);
		}
		//out.x = trm.a * v.x + trm.b * v.y + trm.c * v.z + trm.d; 
		//out.y = trm.e * v.x + trm.f * v.y + trm.g * v.z + trm.h;
		//out.z = trm.i * v.x + trm.j * v.y + trm.k * v.z + trm.l;
		out.x = trm.a * v.x + trm.b * v.y + trm.c * v.z; 
		out.y = trm.e * v.x + trm.f * v.y + trm.g * v.z;
		out.z = trm.i * v.x + trm.j * v.y + trm.k * v.z;
		
		return out;
	}
	public function collideMovableAABB(aabb:MovableAABB, sr:SweepTestResult):ProjectionResult{
		var axis:Vec;
		var translationVector:Float;
		var axises:Array<Vec> = [];
		var i:Int;
		
		createVertexes();
		aabb.createVertexes();
		
		axises.push(axisX());
		axises.push(axisY());
		axises.push(axisZ());
		
		axises.push(aabb.axisX());
		axises.push(aabb.axisY());
		axises.push(aabb.axisZ());
		
		var rotatedAxisesCount:UInt = rotatedAxises + aabb.rotatedAxises;
		
		//Test cross product axises only when A and B rotated more than 1 axis
		if(rotatedAxises>1){
			axises.push(axisX().cross( aabb.axisX() ));
			axises.push(axisX().cross( aabb.axisY() ));
			axises.push(axisX().cross( aabb.axisZ() ));
			axises.push(axisY().cross( aabb.axisX() ));
			axises.push(axisY().cross( aabb.axisY() ));
			axises.push(axisY().cross( aabb.axisZ() ));
			axises.push(axisZ().cross( aabb.axisX() ));
			axises.push(axisZ().cross( aabb.axisY() ));
			axises.push(axisZ().cross( aabb.axisZ() ));
		}
		
		var extent:Float = 0;
		var range1:Array<Float>;
		var range2:Array<Float>;
		var mtv:Float = HUGH;
		var squaredMTV:Float;
		var pr:ProjectionResult = new ProjectionResult();
		var colliding:Bool = true;
		var furtherCollision:Bool = true;
		var results:Array<Float> = [0, 0, 0, 0];
		
		var maxEntry:Float = -HUGH;
		var minExit:Float = HUGH;
		var maxEntryAxisIndex:Int =-1;
		var noAxisOverlapping:Bool = true;
		var affecting:Vec = null;
		
		var velocity:Vec = new Vec(aabb.vx, aabb.vy, aabb.vz);
		
		var entry:Float;
		var exit:Float;
		
		sr.target = this;
		for (i in 0...axises.length){
			if (axises[i].equalZero())
				continue;
			extent = axises[i].dot(velocity);
			range1 = getScalarRange(axises[i], aabb);
			range2 = getScalarRange(axises[i], this);
			translationVector = overlap(range1[0], range1[1], range2[0], range2[1]);
			//Debugger.getInstance().log("Ready for TOI ["+Std.string(i)+"], furtherCollision:"+(furtherCollision?"true":"false"));
			if (furtherCollision && Collision.timeOfImpact(range1[0], range1[1], range2[0], range2[1], extent, results)){
				entry = results[0];
				exit = results[1];
				if (entry > maxEntry){
					maxEntry = entry;
					affecting = axises[i];
					maxEntryAxisIndex = i;
				}
				if (exit < minExit){
					minExit = exit;
				}
				if(entry>=0){
					noAxisOverlapping = false;
				}
				//Debugger.getInstance().log("Entry/Exit:" + Std.string(entry) + "/" + Std.string(exit));
			}else{
				furtherCollision = false;
			}
			if (translationVector == 0){
				colliding = false;
				if (!furtherCollision){
					sr.entryTime = 2;
					sr.isCollided = false;
					sr.normalX = 0;
					sr.normalY = 0;
					sr.normalZ = 0;
					return null;
				}
				continue;
			}
			squaredMTV = Math.abs(translationVector);
			if (squaredMTV < mtv){
				var absExt:Float = Math.abs(extent);
				mtv = squaredMTV;
				//pr.velocity = velocity;
				pr.extent = extent;
				pr.MTV = translationVector;
				if (absExt == 0){
					pr.entryTime = 0;
				}else{
					pr.entryTime = (absExt - squaredMTV) / absExt;
				}
				pr.axis = axises[i].clone();
				pr.scalarLeftMin = range1[0];
				pr.scalarLeftMax = range1[1];
				pr.scalarRightMin = range2[0];
				pr.scalarRightMax = range2[1];
			}
		}
		//pr.calc();
		sr.normalX = 0;
		sr.normalY = 0;
		sr.normalZ = 0;
		//Debugger.getInstance().log("noAxisOverlapping:" + (noAxisOverlapping?"true":"false")+", furtherCollision:"+(furtherCollision?"true":"false"));
		if ( maxEntryAxisIndex < 0){
			sr.isCollided = false;
		}else if (!colliding && (maxEntry > minExit || maxEntry > 1 || !furtherCollision || noAxisOverlapping)){
			sr.isCollided = false;
		}else{
			if (colliding){
				maxEntry = 0;
			}
			sr.isCollided = true;
			if (affecting == null){
				Debugger.getInstance().log("maxEntryAxisIndex:"+Std.string(maxEntryAxisIndex)+", axises.length:"+Std.string(axises.length));
			}
			if(velocity.dot(affecting)>0){
				sr.affectingAxis = affecting.mul( -1);
			}else{
				sr.affectingAxis = affecting;
			}
			sr.entryTime = maxEntry;
			
		}
		return pr;
	}
	public function collideAABB(aabb:AABB, velocity:Vec=null):ProjectionResult{
		var axis:Vec;
		var translationVector:Float;
		var axises:Array<Vec> = [];
		var i:Int;
		
		createVertexes();
		aabb.createVertexes();
		
		axises.push(axisX());
		axises.push(axisY());
		axises.push(axisZ());
		
		axises.push(aabb.axisX());
		axises.push(aabb.axisY());
		axises.push(aabb.axisZ());
		
		var rotatedAxisesCount:UInt = rotatedAxises + aabb.rotatedAxises;
		
		//Test cross product axises only when A and B rotated more than 1 axis
		if(rotatedAxises>1){
			axises.push(axisX().cross( aabb.axisX() ));
			axises.push(axisX().cross( aabb.axisY() ));
			axises.push(axisX().cross( aabb.axisZ() ));
			axises.push(axisY().cross( aabb.axisX() ));
			axises.push(axisY().cross( aabb.axisY() ));
			axises.push(axisY().cross( aabb.axisZ() ));
			axises.push(axisZ().cross( aabb.axisX() ));
			axises.push(axisZ().cross( aabb.axisY() ));
			axises.push(axisZ().cross( aabb.axisZ() ));
		}
		
		var extent:Float = 0;
		var range1:Array<Float>;
		var range2:Array<Float>;
		var mtv:Float = HUGH;
		var squaredMTV:Float;
		var pr:ProjectionResult = new ProjectionResult();
		
		for (i in 0...axises.length){
			if (axises[i].equalZero())
				continue;
			if (velocity != null){
				extent = axises[i].dot(velocity);
			}
			range1 = getScalarRange(axises[i], aabb);
			range2 = getScalarRange(axises[i], this);
			translationVector = overlap(range1[0], range1[1], range2[0], range2[1]);
			if (translationVector == 0){
				return null;
			}
			squaredMTV = Math.abs(translationVector);
			if (squaredMTV < mtv){
				var absExt:Float = Math.abs(extent);
				mtv = squaredMTV;
				pr.velocity = velocity;
				pr.extent = extent;
				pr.MTV = translationVector;
				if (absExt == 0){
					pr.entryTime = 0;
				}else{
					pr.entryTime = (absExt - squaredMTV) / absExt;
				}
				pr.axis = axises[i];
				pr.scalarLeftMin = range1[0];
				pr.scalarLeftMax = range1[1];
				pr.scalarRightMin = range2[0];
				pr.scalarRightMax = range2[1];
			}
		}
		pr.calc();
		return pr;
	}
	private static function overlap(l1min:Float, l1max:Float, l2min:Float, l2max:Float):Float{
		if (l1max < l2min || l2max < l1min){
			return 0;
		}
		return (l1min < l2min)? (l1max - l2min) : (l1min - l2max);
	}
	private static function getScalarRange(axis:Vec, aabb:AABB, extent:Float=0):Array<Float>{
		var v:Array<Float> = [];
		var min:Float = HUGH;
		var max:Float = -HUGH;
		var i:Int;
		var center:Vec = aabb.centerPoint();
		
		for (i in 0...aabb.vertexes.length){
			var scalar:Float =  axis.dot(aabb.vertexes[i].clone().plus(center));
			if (scalar < min){
				min = scalar;
			}
			if (scalar > max){
				max = scalar;
			}
		}
		if (extent > 0){
			max += extent;
		}else if (extent < 0){
			min += extent;
		}
		v.push(min);
		v.push(max);
		
		return v;
	}
}