/**
 * Created by Leo on 17.04.2015.
 */
package localchat.commands {
import localchat.IChat;

public class ChatCommands implements ICommand{
    private var _classes:Vector.<Class> = new <Class>[ListCommand, MeCommand, NowCommand];
    private var _commands:Vector.<ICommand>;
    
    public function ChatCommands() {
        _commands = new <ICommand>[];
        var cmd:ICommand;
        for each (var c:Class in _classes) {
            cmd = new c() as ICommand;
            if (cmd) _commands.push(cmd);
        }
    }
    
    public function execute(message:String, chat:IChat):Object{
        var res:Object;
        for each (var cmd:ICommand in _commands) {
            res = cmd.execute(message, chat);
            if (res.doNotSend === true) return res;
            
            message = res.text;
        }
        return res;
    }
}
}
