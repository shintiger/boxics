package test.util;
import com.gigateam.world.physics.entity.Body;
import com.gigateam.world.physics.shape.Vec;
import h3d.scene.Mesh;

typedef Meta = {
	var rx:Float;
	var ry:Float;
	var rz:Float;
};

typedef BodyData = {
	var x:Float;
	var y:Float;
	var z:Float;
	var xLength:Float;
	var yLength:Float;
	var zLength:Float;
	var rx:Float;
	var ry:Float;
	var rz:Float;
	var meta:Meta;
};

/**
 * ...
 * @author 
 */
class EntityModel 
{
	private var offsetPos:Vec = new Vec();
	public var data:Body;
	public var display:Mesh;
	public function new(body:Body, mesh:Mesh) 
	{
		data = body;
		display = mesh;
	}
	
	public function updateDisplay(v:Vec=null):Void{
		if (v == null){
			v = new Vec();
		}
		v.cloneFrom(body.getAABB().origin);
		v.plus(offsetPos);
		
		display.setPosition(v.x, v.y, v.z);
	}
}