package {
    import flash.display.Sprite;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.text.TextField;
    
    public class TestHTTP extends Sprite {
        private var tf:TextField;
        
        public function TestHTTP() {
            tf = new TextField();
            tf.width = 400;
            tf.height = 300;
            tf.wordWrap = true;
            addChild(tf);
            tf.text = "Testing HTTP...\n";
            
            var req:URLRequest = new URLRequest("http://127.0.0.1:3000/api/health");
            req.method = URLRequestMethod.GET;
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, function(e:Event):void {
                tf.appendText("SUCCESS: " + loader.data + "\n");
            });
            loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
                tf.appendText("IO ERROR: " + e.text + "\n");
            });
            loader.load(req);
            tf.appendText("Request sent...\n");
        }
    }
}
