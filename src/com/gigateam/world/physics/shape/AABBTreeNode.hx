package com.gigateam.world.physics.shape;
import haxe.ds.Vector;


/**
 * ...
 * @author Tiger
 */
class AABBTreeNode 
{
	public var children:Vector<AABBTreeNode>;
	public var childrenCrossed:Bool;
	public var parent:AABBTreeNode;
	public var data:AABB;
	public var aabb:AABB;
	public function new() 
	{
		children = new Vector<AABBTreeNode>(2);
		childrenCrossed = false;
	}
	public function isLeaf():Bool{
		return children[0] == null;
	}
	public function asLeaf(aabb:AABB):Void{
		data = aabb;
		aabb.node = this;
		children[0] = null;
		children[1] = null;
	}
	public function asBranch(n0:AABBTreeNode, n1:AABBTreeNode):Void{
		n0.parent = this;
		n1.parent = this;
		
		children[0] = n0;
		children[1] = n1;
	}
	public function getSibling():AABBTreeNode{
		return this == parent.children[0] ? parent.children[1] : parent.children[0];
	}
	public function updateAABB(margin:Int):Void{
		if (isLeaf()){
			aabb = data.clone();
			aabb.origin.x -= margin;
			aabb.origin.y -= margin;
			aabb.origin.z -= margin;
		
			aabb.w += margin * 2;
			aabb.h += margin * 2;
			aabb.d += margin * 2;
		}else{
			aabb = children[0].aabb.union(children[1].aabb);
		}
	}
}