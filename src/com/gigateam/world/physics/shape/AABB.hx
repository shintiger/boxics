package com.gigateam.world.physics.shape;

/**
 * ...
 * @author Tiger
 */
class AABB extends Bounding
{
	public var vertexes:Array<Vertex> = [];
	public var node:AABBTreeNode;
	public var w:Float;
	public var h:Float;
	public var d:Float;
	public var rotatedAxises:UInt = 0;
	public function new(p:Vertex, _width:Float, _height:Float, _depth:Float=1) 
	{
		super(p);
		boundingType = 1;
		w = _width;
		h = _height;
		d = _depth;
	}
	public function createVertexes(forceReset:Bool=false):Void{
		if (vertexes.length == 0 || forceReset){
			vertexes = [];
			vertexes.push(createGlobalVertex(false , false, false));
			vertexes.push(createGlobalVertex(true , false, false));
			vertexes.push(createGlobalVertex(false , true, false));
			vertexes.push(createGlobalVertex(false , false, true));
			vertexes.push(createGlobalVertex(true , true, false));
			vertexes.push(createGlobalVertex(false , true, true));
			vertexes.push(createGlobalVertex(true , false, true));
			vertexes.push(createGlobalVertex(true , true, true));
		}
	}
	public function clone():AABB{
		var aabb:AABB = new AABB(origin, w, h, d);
		return aabb;
	}
	public function union(aabb:AABB):AABB{
		var maxpoint1:Float;
		var maxpoint2:Float;
		var n:AABB = clone();
		maxpoint1 = n.w + n.origin.x;
		maxpoint2 = aabb.w + aabb.origin.x;
		n.origin.x = Math.min(aabb.origin.x, n.origin.x);
		n.w = Math.max(maxpoint1, maxpoint2) - n.origin.x;
		
		maxpoint1 = n.h + n.origin.y;
		maxpoint2 = aabb.h + aabb.origin.y;
		n.origin.y = Math.min(aabb.origin.y, n.origin.y);
		n.h = Math.max(maxpoint1, maxpoint2) - n.origin.y;
		
		maxpoint1 = n.d + n.origin.z;
		maxpoint2 = aabb.d + aabb.origin.z;
		n.origin.z = Math.min(aabb.origin.z, n.origin.z);
		n.d = Math.max(maxpoint1, maxpoint2) - n.origin.z;
		return n;
	}
	private function createGlobalVertex(minX:Bool, minY:Bool, minZ:Bool, out:Vertex = null):Vertex{
		out = createVertex(minX, minY, minZ, out);
		//out.x += origin.x;
		//out.y += origin.y;
		//out.z += origin.z;
		
		return out;
	}
	private function createVertex(minX:Bool, minY:Bool, minZ:Bool, out:Vertex=null):Vertex{
		if (out == null){
			out = new Vertex(0, 0);
		}
		var halfWidth:Float = w * 0.5;
		var halfHeight:Float = h * 0.5;
		var halfDepth:Float = d * 0.5;
		out.x = minX ? -halfWidth : halfWidth;
		out.y = minY ? -halfHeight : halfHeight;
		out.z = minZ ? -halfDepth : halfDepth;
		
		return out;
	}
	public function axisX():Vertex{
		var cp:Vertex = centerPoint();
		var v:Vertex = new Vertex(w * 0.5 + cp.x, 0, 0);
		v.normalize();
		return v;
	}
	public function axisY():Vertex{
		var cp:Vertex = centerPoint();
		var v:Vertex = new Vertex(0, h * 0.5 + cp.y, 0);
		v.normalize();
		return v;
	}
	public function axisZ():Vertex{
		var cp:Vertex = centerPoint();
		var v:Vertex = new Vertex(0, 0, d * 0.5 + cp.z);
		v.normalize();
		return v;
	}
	public function volume():Float{
		return w * h * d;
	}
	public function contains(aabb:AABB):Bool{
		var maxX:Float = origin.x + w;
		var maxY:Float = origin.y + h;
		var maxZ:Float = origin.z + d;
		var maxX2:Float = aabb.origin.x + aabb.w;
		var maxY2:Float = aabb.origin.y + aabb.h;
		var maxZ2:Float = aabb.origin.z + aabb.d;
		return origin.x<=aabb.origin.x && maxX>=maxX2 && 
				origin.y<=aabb.origin.y && maxY>=maxY2 &&
				origin.z<=aabb.origin.z && maxZ>=maxZ2 ;
	}
	public static function create():AABB{
		var aabb:AABB = new AABB(new Vertex(0, 0), 1, 1);
		return aabb;
	}
	public function centerPoint(v:Vertex = null):Vertex{
		if(v==null){
			v = new Vertex(0, 0);
		}
		v.x = origin.x + w * 0.5;
		v.y = origin.y + h * 0.5;
		v.z = origin.z + d * 0.5;
		return v;
	}
	public function zMaxPoint(v:Vertex = null):Vertex{
		if(v==null){
			v = new Vertex(0, 0);
		}
		v.x = origin.x + w * 0.5;
		v.y = origin.y + h * 0.5;
		v.z = origin.z + d;
		return v;
	}
	public function zMinPoint(v:Vertex = null):Vertex{
		if(v==null){
			v = new Vertex(0, 0);
		}
		v.x = origin.x + w * 0.5;
		v.y = origin.y + h * 0.5;
		v.z = origin.z;
		return v;
	}
}