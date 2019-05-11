package test.util;
import com.gigateam.world.physics.entity.Body;
import h3d.scene.Mesh;

/**
 * ...
 * @author 
 */
class EntityModel 
{
	var data:Body;
	var display:Mesh;
	public function new(body:Body, mesh:Mesh) 
	{
		data = body;
		display = mesh;
	}
	
}