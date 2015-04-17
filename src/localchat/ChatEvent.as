/**
 * Created by Leo on 15.04.2015.
 */
package localchat {
import flash.events.Event;

public class ChatEvent extends Event{
    public static const CHAT_CONNECTED:String = "chatConnected";
    public static const CHAT_READY:String = "chatReady";
    public static const ON_DATA:String = "onData";

    private var _data:Object;
    public function ChatEvent(type:String, data:Object = null) {
        super(type, false, false);
        _data = data;
    }

    public function get data():Object {
        return _data;
    }
}
}
