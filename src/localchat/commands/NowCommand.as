/**
 * Created by Leo on 17.04.2015.
 */
package localchat.commands {
import localchat.IChat;

public class NowCommand implements ICommand {
    private var _cmd:String = "$now";
    public function execute(message:String, chat:IChat):Object {
        var date:String = new Date().toString();
        while (message.indexOf(_cmd) != -1) {
            message = message.replace(_cmd, date);
        }
        return { text: message };
    }
}
}
