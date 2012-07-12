package {

	import away3d.bounds.BoundingVolumeBase;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.SphereGeometry;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class PickingNestedObjectsTest extends PickingTestBase
	{
		public function PickingNestedObjectsTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = true;
			_view.camera.lens.far = 1000000;

			// Choose global picking method
//			_view.mousePicker = PickingType.RAYCAST_BEST_HIT;
			_view.mousePicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
//			_view.mousePicker = PickingType.SHADER;

			test2d();
			test3d();
		}

		// -----------------------
		// 2D.
		// -----------------------

		private function test2d():void {

			// Main container.
			var container:Sprite = new Sprite();
			container.name = "container";
			container.mouseEnabled = true;
			container.mouseChildren = true;
			container.x = 250;
			container.y = 250;
			addChild( container );

			// Child A.
			var childA:Sprite = new Sprite();
			childA.name = "childA";
			childA.graphics.beginFill( 0xFF0000 );
			childA.graphics.drawCircle( 0, 0, 50 );
			childA.graphics.endFill();
			childA.mouseEnabled = true;
			enableSpriteMouseListeners( childA );
			container.addChild( childA );
		}

		// -----------------------
		// 3D.
		// -----------------------

		private function test3d():void {

			// Main container.
			var container:ObjectContainer3D = new ObjectContainer3D();
			container.name = "container";
//			container.mouseEnabled = true; // is false by default
//			container.mouseChildren = false; // is true by default
			_view.scene.addChild( container );

			// Sub-container.
			var subContainer:ObjectContainer3D = new ObjectContainer3D();
			subContainer.name = "subContainer";
			container.addChild( subContainer );

			// Child materials.
			var colorMaterial:ColorMaterial = new ColorMaterial( 0xFF0000 );
			colorMaterial.lightPicker = _lightPicker;

			// Child A.
			var childA:Mesh = new Mesh( new SphereGeometry( 250 ), colorMaterial );
			childA.name = "childA";
			childA.mouseEnabled = true;
			childA.mouseChildren = false; // doesn't matter in this case
			childA.showBounds = true;
			childA.pickingCollider = PickingColliderType.BOUNDS_ONLY;
//			childA.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			enableMeshMouseListeners( childA );
			subContainer.addChild( childA );
//			_view.scene.addChild( childA );

			traceObjectBounds( container );
			traceObjectBounds( subContainer );
			traceObjectBounds( childA );
		}

		private function traceObjectBounds( entity:ObjectContainer3D ):void {
			trace( "Bounds info for " + entity.name + " ----------" );
			trace( "width: " + entity.minX + ", " + entity.maxX );
			trace( "height: " + entity.minY + ", " + entity.maxY );
			trace( "depth: " + entity.minZ + ", " + entity.maxZ );
		}

		// ---------------------------------------------------------------------
		// MouseEvent handlers.
		// ---------------------------------------------------------------------

		protected function enableSpriteMouseListeners( sprite:Sprite ):void {
			sprite.addEventListener( MouseEvent.MOUSE_OVER, onSpriteMouseOver );
			sprite.addEventListener( MouseEvent.MOUSE_OUT, onSpriteMouseOut );
			sprite.addEventListener( MouseEvent.MOUSE_MOVE, onSpriteMouseMove );
			sprite.addEventListener( MouseEvent.MOUSE_DOWN, onSpriteMouseDown );
			sprite.addEventListener( MouseEvent.MOUSE_UP, onSpriteMouseUp );
			sprite.addEventListener( MouseEvent.CLICK, onSpriteMouseClick );
			sprite.addEventListener( MouseEvent.DOUBLE_CLICK, onSpriteMouseDoubleClick );
			sprite.addEventListener( MouseEvent.MOUSE_WHEEL, onSpriteMouseWheel );
		}

		protected function onSpriteMouseMove( event:MouseEvent ):void {
//			trace( "sprite mouse move: " + event.target.name );
		}

		protected function onSpriteMouseOver( event:MouseEvent ):void {
			trace( "sprite mouse over: " + event.target.name );
		}

		protected function onSpriteMouseOut( event:MouseEvent ):void {
			trace( "sprite mouse out: " + event.target.name );
		}

		protected function onSpriteMouseDown( event:MouseEvent ):void {
			trace( "sprite mouse down: " + event.target.name );
		}

		protected function onSpriteMouseUp( event:MouseEvent ):void {
			trace( "sprite mouse up: " + event.target.name );
		}

		protected function onSpriteMouseWheel( event:MouseEvent ):void {
			trace( "sprite wheeled on: " + event.target.name );
		}

		protected function onSpriteMouseDoubleClick( event:MouseEvent ):void {
			trace( "sprite double clicked: " + event.target.name );
		}

		protected function onSpriteMouseClick( event:MouseEvent ):void {
			trace( "sprite clicked: " + event.target.name );
		}
	}
}
