package
{

	import away3d.bounds.BoundingSphere;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.ConeGeometry;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class PickingIntersectingMeshTest extends PickingTestBase
	{
		public function PickingIntersectingMeshTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = true;
			_view.camera.lens.far = 1000000;

			// Choose global picking method
//			_view.mousePicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
			_view.mousePicker = PickingType.RAYCAST_BEST_HIT;
//			_view.mousePicker = PickingType.SHADER;

			// Init Objects.
			createIntersectingObjects();
		}

		private function createIntersectingObjects():void {

			var objectA:Mesh = createEntity();
			objectA.material = new ColorMaterial( 0xFF0000 );
			objectA.rotationX = -90;
			objectA.x = 30;

			var objectB:Mesh = createEntity();
			objectB.material = new ColorMaterial( 0x0000FF );
			objectB.rotationZ = -90;
			objectB.x = -30;

		}

		private function createEntity():Mesh {

			var entity:Mesh = new Mesh(new ConeGeometry( 150, 400 ));
			entity.showBounds = true;

			// For shader based picking.
			entity.shaderPickingDetails = true;

			// Randomly decide if the entity has a triangle collider.
			var usesTriangleCollider:Boolean = true;//Math.random() > 0.5;
			if( usesTriangleCollider ) {
				// Choose a triangle ray picking method.
				// entity.pickingCollider = PickingColliderType.BOUNDS_ONLY;
//				entity.pickingCollider = PickingColliderType.AS3_BEST_HIT;
//				entity.pickingCollider = PickingColliderType.PB_BEST_HIT;
				entity.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			}

			// Randomize bounds type.
			var usesSphereBounds:Boolean = false;//Math.random() > 0.5;
			if( usesSphereBounds ) {
				entity.bounds = new BoundingSphere();
			}

			// Enable mouse interactivity?
			var isMouseEnabled:Boolean = true;//Math.random() > 0.5;
			entity.mouseEnabled = entity.mouseChildren = isMouseEnabled;

			// Enable mouse listeners?
			var listensToMouseEvents:Boolean = true;//Math.random() > 0.5;
			if( isMouseEnabled && listensToMouseEvents ) {
				enableMeshMouseListeners( entity );
			}

			// Add to scene and store.
			_view.scene.addChild( entity );

			return entity;
		}
	}
}
