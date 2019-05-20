package test.util;
import com.gigateam.world.physics.entity.Body;
import com.gigateam.world.physics.shape.Vec;
import h3d.scene.Mesh;

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
		v.cloneFrom(data.getAABB().origin);
		v.plus(offsetPos);
		//trace(v.x, v.y, v.z);
		display.setPosition(v.x, v.y, v.z);
	}
}