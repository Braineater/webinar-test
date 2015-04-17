/**
 * Created by Leo on 17.04.2015.
 */
package localchat.commands {
import localchat.IChat;

public class MeCommand implements ICommand {
    private var _cmd:String = "$me";
    public function execute(message:String, chat:IChat):Object {
        while (message.indexOf(_cmd) != -1) {
            message = message.replace(_cmd, chat.userName);
        }
        return { text: message };
    }
}
}
