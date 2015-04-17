/**
 * Created by Leo on 17.04.2015.
 */
package localchat.commands {
import localchat.IChat;

public class ListCommand implements ICommand {

    public function execute(message:String, chat:IChat):Object {
        if (message == "$list") {
            return { text: chat.usersList.toString(), doNotSend: true };
        }
        return { text: message };
    }
}
}
