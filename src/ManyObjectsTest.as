package
{

	import away3d.bounds.BoundingSphere;
	import away3d.core.pick.PickingMode;
	import away3d.core.raycast.colliders.picking.CpuPickingMethod;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.LineSegment;
	import away3d.primitives.SphereGeometry;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;


	public class ManyObjectsTest extends TestBase
	{
		private var _blackMaterial:ColorMaterial;
		private var _grayMaterial:ColorMaterial;
		private var _blueMaterial:ColorMaterial;
		private var _redMaterial:ColorMaterial;
		private var _entities:Vector.<Entity>;
		private var _rotateEntities:Boolean;

		public function ManyObjectsTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = true;

			// Choose global picking method
//			_view.pickingMethod = GlobalPickingMethod.CPU;
			_view.mousePicker = PickingMode.RAYCAST_PICKER_1;
//			_view.pickingMethod = GlobalPickingMethod.SHADER;

			// Init materials.
			_blackMaterial = new ColorMaterial( 0x333333 );
			_blackMaterial.lightPicker = _lightPicker;
			_grayMaterial = new ColorMaterial( 0xCCCCCC );
			_grayMaterial.lightPicker = _lightPicker;
			_blueMaterial = new ColorMaterial( 0x0000FF );
			_blueMaterial.lightPicker = _lightPicker;
			_redMaterial = new ColorMaterial( 0xFF0000 );
			_redMaterial.lightPicker = _lightPicker;

			// Init Objects.
			createABunchOfObjects();

			// Key listeners.
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
		}

		private function createABunchOfObjects():void {

			var objectCount:uint = 100;
			var spreadRange:Number = 700;

			_entities = new Vector.<Entity>();

			for( var i:uint; i < objectCount; i++ ) {

				// Create object.
				var object:Mesh = createEntity();

				// Random orientation.
				object.rotationX = rand( -180, 180 );
				object.rotationY = rand( -180, 180 );
				object.rotationZ = rand( -180, 180 );

				// Random position.
				object.x = rand( -spreadRange, spreadRange );
				object.y = rand( -spreadRange, spreadRange );
				object.z = rand( -spreadRange, spreadRange );
			}
		}

		private function createEntity():Mesh {

			var entity:Mesh = new Mesh();
			entity.showBounds = true;

			// Geometry.
			var randGeometry:Number = Math.random();
			if( randGeometry > 0.66 ) {
				entity.geometry = new CubeGeometry();
			}
			else if( randGeometry > 0.33 ) {
				entity.geometry = new SphereGeometry();
			}
			else {
				entity.geometry = new CylinderGeometry();
			}

			// For shader based picking.
			entity.mouseDetails = true;

			// Randomly decide if the entity has a triangle collider.
			var usesTriangleCollider:Boolean = /*false;//*/Math.random() > 0.5;
			if( usesTriangleCollider ) {
				// Choose a triangle ray picking method.
//				entity.rayPickingMethod = CpuPickingMethod.BOUNDS_ONLY;
				entity.rayPickingMethod = CpuPickingMethod.LOW_POLY_MESH;
			}

			// Randomize bounds type.
			var usesSphereBounds:Boolean = false;//Math.random() > 0.5;
			if( usesSphereBounds ) {
				entity.bounds = new BoundingSphere();
			}

			// Enable mouse interactivity?
			var isMouseEnabled:Boolean = /*true;//*/Math.random() > 0.5;
			entity.mouseEnabled = entity.mouseChildren = isMouseEnabled;

			// Enable mouse listeners?
			var listensToMouseEvents:Boolean = /*true;//*/Math.random() > 0.5;
			if( isMouseEnabled && listensToMouseEvents ) {
				enableMeshMouseListeners( entity );
			}

			// Pick material.
			if( !isMouseEnabled ) {
				entity.material = _blackMaterial;
			}
			else {
				if( !listensToMouseEvents ) {
					entity.material = _grayMaterial;
				}
				else {
					if( usesTriangleCollider ) {
						entity.material = _redMaterial;
					}
					else {
						entity.material = _blueMaterial;
					}
				}
			}

			// Add to scene and store.
			_entities.push( entity );
			_view.scene.addChild( entity );

			return entity;
		}

		override protected function preUpdate():void {
			if( _rotateEntities ) {
				for( var i:uint; i < _entities.length; i++ ) {
					var cube:Mesh = _entities[ i ] as Mesh;
					cube.rotationY += 1;
				}
			}
		}

		private function onStageKeyDown( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.SPACE :
					_rotateEntities = !_rotateEntities;
					break;
			}
		}
	}
}
