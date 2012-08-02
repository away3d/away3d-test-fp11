package
{

	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.SphereGeometry;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class PickingOverlayTest extends PickingTestBase
	{
		public function PickingOverlayTest() {
			super();
		}

		override protected function postInit():void {

			// Setup view.
			_view.backgroundColor = 0xCCCCCC;
			_view.antiAlias = 4;
			_view.forceMouseMove = false;

			// Choose global picking method
			_view.mousePicker = PickingType.RAYCAST_FIRST_ENCOUNTERED;
//			_view.mousePicker = PickingType.RAYCAST_BEST_HIT;
//			_view.mousePicker = PickingType.SHADER;

			// 3D object.
			var material:ColorMaterial = new ColorMaterial( 0xFF0000 );
			material.lightPicker = _lightPicker;
			var mesh:Mesh = new Mesh( new SphereGeometry(), material );
			mesh.mouseEnabled = true;
			mesh.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			enableMeshMouseListeners( mesh );
			_view.scene.addChild( mesh );

			// 2D object.
			var spr:Sprite = new Sprite();
			spr.graphics.beginFill( 0x00FF00 );
			spr.graphics.drawCircle( 0, 0, 50 );
			spr.graphics.endFill();
			spr.x = stage.stageWidth / 2 + 50;
			spr.y = stage.stageHeight / 2;
			spr.useHandCursor = spr.mouseEnabled = spr.buttonMode = true;
			spr.addEventListener( MouseEvent.MOUSE_OVER, onSpriteMouseOver );
			spr.addEventListener( MouseEvent.MOUSE_OUT, onSpriteMouseOut );
			spr.addEventListener( MouseEvent.MOUSE_MOVE, onSpriteMouseMove );
			spr.addEventListener( MouseEvent.MOUSE_DOWN, onSpriteMouseDown );
			addChild( spr );
		}

		private function onSpriteMouseDown( event:MouseEvent ):void {
			trace( "sprite mouse down" );
		}

		private function onSpriteMouseMove( event:MouseEvent ):void {
			trace( "sprite mouse move" );
		}

		private function onSpriteMouseOut( event:MouseEvent ):void {
			trace( "sprite mouse out" );
		}

		private function onSpriteMouseOver( event:MouseEvent ):void {
			trace( "sprite mouse over" );
		}
	}
}
