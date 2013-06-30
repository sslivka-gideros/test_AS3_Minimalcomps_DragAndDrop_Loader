package 
{
	import com.bit101.components.HBox;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import flash.net.FileFilter;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import flash.events.NativeDragEvent;
	import flash.desktop.NativeDragManager;
	import flash.desktop.ClipboardFormats;
	import flash.filesystem.File;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	/**
	 * ...
	 * @author sslivka
	 */
	
	public class Main extends Sprite 
	{
		
		protected var pnlDrop:Panel;
		protected var hbxDrop:HBox;
		protected var lblDrop:Label;
		protected var btnDrop:PushButton;
		
		protected var pnlMenu:Panel;
		protected var pnlOutput:Panel;
		
		protected var fileToOpen:File = new File();
		protected var pngFilter:FileFilter = new FileFilter("PNG", "*.png");
		
		protected var imageLoader:Loader = new Loader();
		
		public function Main():void 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToSatge);
		}
		
		protected function onAddedToSatge(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToSatge)
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			
			pnlDrop = new Panel(this, 0, 0);
			pnlDrop.setSize(stage.stageWidth, stage.stageHeight - 250);
			pnlDrop.y = 50;
			pnlDrop.shadow = false;
			
			hbxDrop = new HBox(pnlDrop, 0, 0);
			hbxDrop.alignment = HBox.MIDDLE;
			lblDrop = new Label(hbxDrop, 0, 0, "Drop image here or");
			btnDrop = new PushButton(hbxDrop, 0, 0, "Select image", onClick);
			hbxDrop.x = (pnlDrop.width / 2) - (hbxDrop.width / 2);
			hbxDrop.y = (pnlDrop.height / 2) - (hbxDrop.height / 2);
			pnlDrop.color = 0xDDDDDD;
			pnlDrop.buttonMode = true;
			pnlDrop.useHandCursor = true;
			
			pnlMenu = new Panel(this, 0, 0);
			pnlMenu.setSize(stage.stageWidth, 50);
			pnlMenu.shadow = false;
			
			pnlOutput = new Panel(this, 0, 0);
			pnlOutput.setSize(stage.stageWidth, 200);
			pnlOutput.y = stage.stageHeight - pnlOutput.height;
			pnlOutput.shadow = false;
			
			pnlDrop.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onNativeDragEnter);
			pnlDrop.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onNativeDragDrop);
		}
		
		protected function onResize(e:Event):void
		{
			pnlDrop.setSize(stage.stageWidth, stage.stageHeight - 250);
			pnlDrop.y = 50;
			hbxDrop.x = (pnlDrop.width / 2) - (hbxDrop.width / 2);
			hbxDrop.y = (pnlDrop.height / 2) - (hbxDrop.height / 2);
			pnlMenu.setSize(stage.stageWidth, 50);
			pnlOutput.setSize(stage.stageWidth, 200);
			pnlOutput.y = stage.stageHeight - pnlOutput.height;
		}
		
		protected function onClick(e:Event):void
		{
			try {
				fileToOpen.browseForOpen("Open", [pngFilter]);
				fileToOpen.addEventListener(Event.SELECT, onSelect);
			}
			catch (error:Error) {
				trace("Failed:", error.message);
			}
		}
		
		protected function onSelect(e:Event):void
		{
			//trace(e.target.nativePath);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			imageLoader.load(new URLRequest(e.target.nativePath));
		}
		
		protected function onNativeDragEnter(e:NativeDragEvent):void
		{
			if (e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				NativeDragManager.acceptDragDrop(pnlDrop);
			}
		}
		
		protected function onNativeDragDrop(e:NativeDragEvent):void
		{
			var files:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			for each (var file:File in files) {
				//trace(file.nativePath);
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
				imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				imageLoader.load(new URLRequest(file.nativePath));
			}
		}
		
		protected function onComplete(e:Event):void
		{
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			imageLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			imageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			//bitmapData = Bitmap(LoaderInfo(event.target).content).bitmapData;
			pnlDrop.addChild(LoaderInfo(e.target).content);
		}
		
		protected function onProgress(e:ProgressEvent):void
		{
			trace("Loading: " + String(Math.floor(e.bytesLoaded / 1024)) + " KB of " + String(Math.floor(e.bytesTotal / 1024)) + " KB.");
		}
		
		protected function onError(e:IOErrorEvent):void
		{
			trace("onError");
		}
		
	}
	
}