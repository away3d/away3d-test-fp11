package
{

	import agt.controllers.camera.FreeFlyCameraController;
	import agt.input.IInputContext;
	import agt.input.contexts.DefaultMouseKeyboardInputContext;

	import away3d.containers.ObjectContainer3D;

	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.events.MouseEvent3D;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.LineSegment;
	import away3d.primitives.SphereGeometry;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	public class PickingTestBase extends Sprite
	{
		protected var _view:View3D;
		protected var _cameraController:FreeFlyCameraController;
		protected var _cameraPointLight:PointLight;
		protected var _lightPicker:StaticLightPicker;
		protected var _locationTracer:Mesh;
		protected var _locationHint:ObjectContainer3D;
		protected var _normalTracer:SegmentSet;

		public function PickingTestBase() {
			addEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
		}

		private function stageInitHandler( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
			init();
		}

		protected function init():void {

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			//stage.frameRate = 30;

			_view = new View3D();
			addChild( _view );

			var stats:Sprite = new AwayStats( _view );
			addChild( stats );

			var tri:Trident = new Trident();
			_view.scene.addChild( tri );

			_cameraPointLight = new PointLight();
			_view.scene.addChild( _cameraPointLight );

			_lightPicker = new StaticLightPicker( [ _cameraPointLight ] );

			var cameraInput:IInputContext = new DefaultMouseKeyboardInputContext( this, stage );
			_cameraController = new FreeFlyCameraController( _view.camera );
			_cameraController.inputContext = cameraInput;

			// To trace picking positions.
			_locationTracer = new Mesh( new SphereGeometry( 3 ), new ColorMaterial( 0x00FF00 ) );
			_locationTracer.mouseEnabled = _locationTracer.mouseChildren = false;
			_locationTracer.visible = false;
			_locationTracer.name = "location tracer";
			_view.scene.addChild( _locationTracer );

			_locationHint = new ObjectContainer3D();
			var locationHintMesh:Mesh = new Mesh( new ConeGeometry( 15, 100 ), new ColorMaterial( 0xFFFF00 ) );
			locationHintMesh.mouseEnabled = locationHintMesh.mouseChildren = false;
			locationHintMesh.name = "location hint";
			locationHintMesh.rotationX += 90;
			_locationHint.visible = false;
			_locationHint.addChild( locationHintMesh );
			_view.scene.addChild( _locationHint );

			// To trace picking normals.
			_normalTracer = new SegmentSet();
			_normalTracer.mouseEnabled = _normalTracer.mouseChildren = false;
			var lineSegment:LineSegment = new LineSegment( new Vector3D(), new Vector3D(), 0xFFFFFF, 0xFFFFFF, 3 );
			_normalTracer.addSegment( lineSegment );
			_normalTracer.visible = false;
			_normalTracer.name = "normal tracer";
			_view.scene.addChild( _normalTracer );

			addEventListener( Event.ENTER_FRAME, enterframeHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, stageMouseUpHandler );

			postInit();
		}

		protected function postInit():void {
			// Override.
		}

		// ---------------------------------------------------------------------
		// Enterframe.
		// ---------------------------------------------------------------------

		protected function postUpdate():void {
			// Override.
		}

		protected function preUpdate():void {
			// Override.
		}

		private function enterframeHandler( event:Event ):void {
			preUpdate();
			_cameraController.update();
			_cameraPointLight.transform = _view.camera.transform.clone();
			_view.render();
			postUpdate();
		}

		// ---------------------------------------------------------------------
		// MouseEvent handlers.
		// ---------------------------------------------------------------------

		protected function enableMeshMouseListeners( container:ObjectContainer3D ):void {
			container.addEventListener( MouseEvent3D.MOUSE_OVER, onMeshMouseOver );
			container.addEventListener( MouseEvent3D.MOUSE_OUT, onMeshMouseOut );
			container.addEventListener( MouseEvent3D.MOUSE_MOVE, onMeshMouseMove );
			container.addEventListener( MouseEvent3D.MOUSE_DOWN, onMeshMouseDown );
			container.addEventListener( MouseEvent3D.MOUSE_UP, onMeshMouseUp );
			container.addEventListener( MouseEvent3D.CLICK, onMeshMouseClick );
			container.addEventListener( MouseEvent3D.DOUBLE_CLICK, onMeshMouseDoubleClick );
			container.addEventListener( MouseEvent3D.MOUSE_WHEEL, onMeshMouseWheel );
		}

		protected function onMeshMouseMove( event:MouseEvent3D ):void {

//			trace( "mesh mouse move: " + event.object.name );

			// Update picking position.
			_locationTracer.position = event.scenePosition;

			// Update picking normal.
			_normalTracer.position = _locationTracer.position;
//			trace( "scene normal: " + event.sceneNormal );
			var normal:Vector3D = event.sceneNormal.clone();
			normal.scaleBy( 25 );
			var lineSegment:LineSegment = _normalTracer.getSegment( 0 ) as LineSegment;
			lineSegment.end = normal.clone();

			normal.scaleBy( 5 );
			_locationHint.position = _locationTracer.position.add( new Vector3D( 0, 100, 0 ) );
			_locationHint.lookAt( _locationTracer.position );
		}

		protected function onMeshMouseOver( event:MouseEvent3D ):void {
			trace( "mesh mouse over: " + event.object.name );
			_locationTracer.visible = _normalTracer.visible = _locationHint.visible = true;
			var mesh:Mesh = event.object as Mesh;
//			mesh.showBounds = true;
		}

		protected function onMeshMouseOut( event:MouseEvent3D ):void {
			trace( "mesh mouse out: " + event.object.name );
			_locationTracer.visible = _normalTracer.visible = _locationHint.visible = false;
			var mesh:Mesh = event.object as Mesh;
//			mesh.showBounds = false;
		}

		protected function onMeshMouseDown( event:MouseEvent3D ):void {
			trace( "mesh mouse down: " + event.object.name );
		}

		protected function onMeshMouseUp( event:MouseEvent3D ):void {
			trace( "mesh mouse up: " + event.object.name );
		}

		protected function onMeshMouseWheel( event:MouseEvent3D ):void {
			trace( "mesh wheeled on: " + event.object.name );
		}

		protected function onMeshMouseDoubleClick( event:MouseEvent3D ):void {
			trace( "mesh double clicked: " + event.object.name );
		}

		protected function onMeshMouseClick( event:MouseEvent3D ):void {
			trace( "mesh clicked: " + event.object.name + ", renderable: " + event.renderable );
		}

		protected function stageMouseUpHandler( event:MouseEvent ):void {

		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		protected function rand(min:Number, max:Number):Number {
		    return (max - min)*Math.random() + min;
		}
	}
}
