package com.gigateam.world.physics.shape;
import com.gigateam.world.physics.algorithm.Collision;
import haxe.ds.GenericStack;
import haxe.ds.Vector;

/**
 * ...
 * @author Tiger
 */
class AABBTree 
{
	public var margin:Int = 10;
	private var root:AABBTreeNode;
	private var nodeList:Array<AABBTreeNode>;
	private var invalidNodes:Array<AABBTreeNode>;
	private var pairs:Array<AABBTreeNode>;
	public function new(_margin:Int) 
	{
		margin = _margin;
		//nodeList = new Array<AABBTreeNode>();
		invalidNodes = new Array<AABBTreeNode>();
	}
	public function add(aabb:AABB):AABBTreeNode{
		if (root!=null){
			var node:AABBTreeNode = new AABBTreeNode();
			node.asLeaf(aabb);
			node.updateAABB(margin);
			insertNode(node, root);
			return node;
		}
		root = new AABBTreeNode();
		root.asLeaf(aabb);
		root.updateAABB(margin);
		return root;
	}
	public function remove(aabb:AABB):Void{
		var node:AABBTreeNode = aabb.node;
		node.data = null;
		node.aabb = null;
		
		removeNode(node);
		aabb.node = null;
	}
	public function removeNode(node:AABBTreeNode):Void{
		var parent:AABBTreeNode = node.parent;
		if (parent != null){
			var sibling:AABBTreeNode = node.getSibling();
			if (parent.parent != null){
				sibling.parent = parent.parent;
				replaceFromParent(parent, sibling);
			}else{
				root = sibling;
				sibling.parent = null;
			}
		}else{
			root = null;
		}
	}
	public function insertNode(node:AABBTreeNode, parent:AABBTreeNode):Void{
		if (parent.isLeaf()){
			var newParent:AABBTreeNode = new AABBTreeNode();
			newParent.parent = parent.parent;
			replaceFromParent(parent, newParent);
			newParent.asBranch(node, parent);
			parent = newParent;
		}else{
			var aabb0:AABB = parent.children[0].aabb;
			var aabb1:AABB = parent.children[1].aabb;
			var volumeDiff0:Float = aabb0.union(node.aabb).volume() - aabb0.volume();
			var volumeDiff1:Float = aabb1.union(node.aabb).volume() - aabb1.volume();
			if (volumeDiff0 < volumeDiff1){
				insertNode(node, parent.children[0]);
			}else{
				insertNode(node, parent.children[1]);
			}
		}
		parent.updateAABB(margin);
	}
	public function replaceFromParent(node:AABBTreeNode, parent:AABBTreeNode):Void{
		if (node.parent != null){
			var index:Int = node.parent.children[0] == node ? 0 : 1;
			node.parent.children[index] = parent;
		}else{
			root = parent;
		}
	}
	public function update():Void{
		if (root!=null){
			if (root.isLeaf())
				root.updateAABB(margin);
			else{
				// grab all invalid nodes
				clearInvalidNodes();
				updateNodeHelper(root, invalidNodes);
				var node:AABBTreeNode;
				// re-insert all invalid nodes
				for (node in invalidNodes)
				{
					// grab parent link
					// (pointer to the pointer that points to parent)
					//var node:AABBTreeNode = invalidNodes[i];
					var parent:AABBTreeNode = node.parent;
					var sibling:AABBTreeNode = node.getSibling();
					
					replaceFromParent(parent, sibling);
					sibling.parent = parent.parent == null ? null : parent.parent;
			 
					// re-insert node
					node.updateAABB(margin);
					insertNode(node, root);
				}
				clearInvalidNodes();
			}
		}
	}
	private function clearInvalidNodes():Void{
		if (invalidNodes.length == 0)
		return;
		invalidNodes = new Array<AABBTreeNode>();
	}
	private function clearPairs():Void{
		if (pairs.length == 0)
		return;
		pairs = new Array<AABBTreeNode>();
	}
	public function updateNodeHelper(node:AABBTreeNode, invalidNodes:Array<AABBTreeNode>):Void{{
		if (node.isLeaf())
		{
		  // check if fat AABB doesn't 
		  // contain the collider's AABB anymore
		  if(!node.aabb.contains(node.data))
			invalidNodes.push(node);
		}
		else
		{
		  updateNodeHelper(node.children[0], invalidNodes);
		  updateNodeHelper(node.children[1], invalidNodes);
		}
	  }
	}
	public var checkStatus:Int = 0;
	public function collidingWith(aabb:AABB):GenericStack<AABBTreeNode>{
		var collides:GenericStack<AABBTreeNode> = new GenericStack();
		checkStatus = 0;
		if(root!=null){
			checkAABBWithNode(aabb, root, collides);
		}
		return collides;
	}
	private function checkAABBWithNode(aabb:AABB, node:AABBTreeNode, collides:GenericStack<AABBTreeNode>):Bool{
		checkStatus++;
		if (!Collision.AABBCheck(node.aabb, aabb)){
			return false;
		}else if (node.isLeaf()){
			collides.add(node);
			return true;
		}
		var leftCollided:Bool = checkAABBWithNode(aabb, node.children[0], collides);
		var rightCollided:Bool = checkAABBWithNode(aabb, node.children[1], collides);
		return leftCollided || rightCollided;
	}
}