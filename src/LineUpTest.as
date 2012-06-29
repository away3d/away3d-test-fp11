package
{

	import away3d.bounds.BoundingSphere;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.SphereGeometry;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class LineUpTest extends TestBase
	{
		private var _blackMaterial:ColorMaterial;
		private var _grayMaterial:ColorMaterial;
		private var _blueMaterial:ColorMaterial;
		private var _redMaterial:ColorMaterial;
		private var _entities:Vector.<Entity>;
		private var _rotateEntities:Boolean;

		public function LineUpTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = true;
			_view.camera.lens.far = 1000000;

			// Choose global picking method
			_view.mousePicker = PickingType.RAYCAST_BEST_HIT;
//			_view.mousePicker = PickingType.SHADER;

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

			_entities = new Vector.<Entity>();

			var i:uint, j:uint, k:uint;
			var nx:uint = 2;
			var ny:uint = 1;
			var nz:uint = 50;
			var size:Number = 50;
			var dw:Number = 2 * size;
			var dh:Number = 2 * size;
			var dd:Number = 2 * size;
			var spacing:Number = Math.sqrt( dh * dh + dw * dw ) / 2;
			var offsetX:Number = -( nx * dw + ( nx - 1 ) * spacing ) / 2;
			var offsetY:Number = -( ny * dh + ( ny - 1 ) * spacing ) / 2;
			var offsetZ:Number = -( nz * dd + ( nz - 1 ) * spacing ) / 2;
			for( i = 0; i < nx; ++i ) {
				for( j = 0; j < ny; ++j ) {
					for( k = 0; k < nz; ++k ) {
						var object:Mesh = createEntity();
						// Grid position.
						object.x = offsetX + ( dw + spacing ) * i + dw / 2;
						object.y = offsetY + ( dh + spacing ) * j + dh / 2;
						object.z = offsetZ + ( dd + spacing ) * k + dd / 2;
						// Random orientation.
//						object.rotationX = rand( -180, 180 );
//						object.rotationY = rand( -180, 180 );
//						object.rotationZ = rand( -180, 180 );
					}
				}
			}
		}

		private function createEntity():Mesh {

			var entity:Mesh = new Mesh();

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
			entity.shaderPickingDetails = true;

			// Randomly decide if the entity has a triangle collider.
			var usesTriangleCollider:Boolean = /*false;//*/Math.random() > 0.5;
			if( usesTriangleCollider ) {
				// Choose a triangle ray picking method.
//				entity.pickingCollider = EntityPickingMethod.BOUNDS_ONLY;
//				entity.pickingCollider = EntityPickingMethod.AS3_FIRST_ENCOUNTERED;
//				entity.pickingCollider = EntityPickingMethod.PB_FIRST_ENCOUNTERED;
				entity.pickingCollider = PickingColliderType.AUTO_FIRST_ENCOUNTERED;
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
