/**
 * Created by Leo on 17.04.2015.
 */
package localchat.commands {
import localchat.IChat;

public interface ICommand {
    function execute(message:String, chat:IChat):Object;
}
}
