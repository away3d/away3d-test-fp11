package
{

	import away3d.bounds.BoundingSphere;
	import away3d.core.base.Geometry;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	[SWF(backgroundColor="#000000", frameRate="60", width="1024", height="768")]
	public class PickingManyObjectsTest extends PickingTestBase
	{
		// COLORS:
		private var _blackMaterial:ColorMaterial; // elements that are ignored by the picking system ( mouseEnabled = false )
		private var _grayMaterial:ColorMaterial; // elements that don't react to picking, but occlude picking on objects behind ( mouseEnabled = true but no listeners attached )
		private var _blueMaterial:ColorMaterial; // elements that react to picking with bounds only ( mouseEnabled = true and listeners attached, with bounds precision )
		private var _redMaterial:ColorMaterial; // elements that react to picking with geometry ( mouseEnabled = true and listeners attached, with triangle precision )

		private var _entities:Vector.<Entity>;
		private var _rotateEntities:Boolean;

		public function PickingManyObjectsTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = false;

			// Choose global picking method
//			_view.mousePicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
//			_view.mousePicker = PickingType.RAYCAST_BEST_HIT;
			_view.mousePicker = PickingType.SHADER;

			// Init materials.
			_blackMaterial = new ColorMaterial( 0x333333 );
			_blackMaterial.lightPicker = _lightPicker;
			_grayMaterial = new ColorMaterial( 0xCCCCCC );
			_grayMaterial.lightPicker = _lightPicker;
			_blueMaterial = new ColorMaterial( 0x0000FF );
			_blueMaterial.lightPicker = _lightPicker;
			_redMaterial = new ColorMaterial( 0xFF0000 );
			_redMaterial.lightPicker = _lightPicker;

			var useBothSides:Boolean = true; // when both sides = true, you should be able to pick on the backsides of planes
			_blackMaterial.bothSides = useBothSides;
			_grayMaterial.bothSides = useBothSides;
			_blueMaterial.bothSides = useBothSides;
			_redMaterial.bothSides = useBothSides;

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


			// Geometry.
			var geometry:Geometry;
			var randGeometry:Number = Math.random();
			if( randGeometry > 0.75 ) {
				geometry = new CubeGeometry();
			}
			else if( randGeometry > 0.5 ) {
				geometry = new SphereGeometry();
			}
			else if( randGeometry > 0.25 ) {
				geometry = new PlaneGeometry();
			}
			else {
				geometry = new CylinderGeometry();
			}

			var entity:Mesh = new Mesh(geometry);
			entity.showBounds = true;
			
			// For shader based picking.
			entity.shaderPickingDetails = true;

			// Randomly decide if the entity has a triangle collider.
			var usesTriangleCollider:Boolean = /*false;//*/Math.random() > 0.5;
			if( usesTriangleCollider ) {
				// Choose a triangle ray picking method.
//				entity.pickingCollider = CpuPickingMethod.BOUNDS_ONLY;
//				entity.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
//				entity.pickingCollider = PickingColliderType.AS3_BEST_HIT;
				entity.pickingCollider = PickingColliderType.PB_BEST_HIT;
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
