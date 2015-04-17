package localchat {
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.GroupSpecifier;
import flash.net.NetConnection;
import flash.net.NetGroup;
import flash.utils.setTimeout;

import localchat.commands.ChatCommands;

public class Chat extends EventDispatcher implements IChat{
    public const TYPE_HIDDEN:int = -1;
    public const TYPE_HANDSHAKE:int = 0;
    public const TYPE_MESSAGE:int = 1;
    public const TYPE_ECHO:int = 2;
    public const TYPE_RENAME:int = 3;

    private var nc:NetConnection;
    private var group:NetGroup;

    private var _handshakeAlreadySent:Boolean = false;
    private var _reconnectTimeoutID:int = -1;

    private var _usersList:UsersList;
    private var _commands:ChatCommands;

    private var _userName:String = "Leo";
    private var _connected:Boolean = false;

    public function Chat() {
        super ();
    }

    public function connect():void{
        _usersList = new UsersList();
        _commands = new ChatCommands();

        nc = new NetConnection();
        nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
        nc.connect("rtmfp:");

        userName = "user"+Math.round(Math.random()*1000);
    }
    
    public function reconnect():void {
        if (_reconnectTimeoutID != -1)
            return;        
        
        _connected = false;
        dispatchEvent(new ChatEvent(ChatEvent.ON_DATA, {text:"No connection. Reconnect in 5 s."}));
        _reconnectTimeoutID = setTimeout(connect, 5000);
    }

    public function disconnect():void {
        // Эта реализация чата не позволяет дисконнектиться добровольно! Муахахаха!
    }

    private function netStatus(event:NetStatusEvent):void{
        trace(event.info.code);
        switch(event.info.code){
            case "NetConnection.Connect.Success":
                dispatchEvent(new ChatEvent(ChatEvent.CHAT_CONNECTED));
                setupGroup();
                break;

            case "NetGroup.Connect.Success":
                _connected = true;
                dispatchEvent(new ChatEvent(ChatEvent.CHAT_READY));
                break;

            case "NetConnection.Connect.Rejected":
            case "NetConnection.Connect.Failed":
            case "NetConnection.Connect.Closed":
            case "NetGroup.Connect.Rejected":
            case "NetGroup.Connect.Failed":
                reconnect();
                break;

            case "NetGroup.Neighbor.Connect":
                // При подключении первого соседа шлем рукопожатие и ждем в ответ список пар имя-ид
                sendHandshake();
                break;

            case "NetGroup.Neighbor.Disconnect":
                var userID:String = group.convertPeerIDToGroupAddress(event.info.peerID);
                var disconnectedName:String = _usersList.getUserName(userID);
                disconnectedName ||= "Безымянный пользователь";
                if (disconnectedName) {
                    dispatchEvent(new ChatEvent(ChatEvent.ON_DATA, {userName: disconnectedName, text:"покинул чат."}));
                }
                _usersList.deleteUser(userID);
                break;

            case "NetGroup.Posting.Notify":
                describeMessage(event.info);
                if (event.info.message.type == TYPE_HIDDEN) return;
                dispatchEvent(new ChatEvent(ChatEvent.ON_DATA, event.info.message));
                break;
        }
    }

    private function setupGroup():void{
        var groupspec:GroupSpecifier = new GroupSpecifier("myGroup/groupOne");
        groupspec.postingEnabled = true;
        groupspec.ipMulticastMemberUpdatesEnabled = true;
        groupspec.addIPMulticastAddress("225.225.0.1:30303");

        group = new NetGroup(nc,groupspec.groupspecWithAuthorizations());
        group.addEventListener(NetStatusEvent.NET_STATUS,netStatus);
    }

    public function sendMessage(text:String):String{
        var commandExecuteResult:Object = _commands.execute(text, this);
        
        if (commandExecuteResult.doNotSend === true) {
            return commandExecuteResult.text;
        }
        
        var message:Object = {};
        message.type = TYPE_MESSAGE;
        message.text = commandExecuteResult.text;
        message.sender = group.convertPeerIDToGroupAddress(nc.nearID);
        message.userName = _userName;

        group.post(message);
        return commandExecuteResult.text;
    }

    public function sendHandshake():void {
        if (_handshakeAlreadySent) return;

        _handshakeAlreadySent = true;
        var message:Object = {};
        message.type = TYPE_HANDSHAKE;
        message.sender = group.convertPeerIDToGroupAddress(nc.nearID);
        message.userName = _userName;

        group.post(message);
    }

    public function sendEcho():void {
        var message:Object = {};
        message.type = TYPE_ECHO;
        message.data = usersList.getUsersForEcho();
        message.data[group.convertPeerIDToGroupAddress(nc.nearID)] = _userName;
        group.post(message);
    }

    public function sendRename(oldName:String, newName:String):void {
        var message:Object = {};
        message.type = TYPE_RENAME;
        message.sender = group.convertPeerIDToGroupAddress(nc.nearID);
        message.newName = newName;
        message.userName = oldName;

        group.post(message);
    }

    private function describeMessage(info:Object):void {
        info.message ||= {};
        var message:Object = info.message;

        if (message.type == undefined) {
            message.type = -1;
            return;
        }

        switch (message.type) {
            case TYPE_HANDSHAKE:
                message.type = TYPE_HIDDEN;
                var newHandshakeUsers:Object = {};
                newHandshakeUsers[message.sender] = message.userName;
                checkAndAddUsers(newHandshakeUsers);
                sendEcho();
                break;

            case TYPE_ECHO:
                // На наше рукопожатие ответили, просто запомним нового друга
                message.type = TYPE_HIDDEN;
                checkAndAddUsers(message.data);
                break;

            case TYPE_RENAME:
                var newRenameUsers:Object = {};
                newRenameUsers[message.sender] = message.newName;
                if (!checkAndAddUsers(newRenameUsers)) {
                    message.text = "теперь известен как " + message.newName;
                }

                break;
            
            case TYPE_MESSAGE:
                // don`t do anything
                break;

            default:
                // something wrong
                message.type = TYPE_HIDDEN;
        }
    }

    /** return true if has new users */
    private function checkAndAddUsers(users:Object):Boolean {
        var newUsers:Array = _usersList.setUsersFromEcho(users, group.convertPeerIDToGroupAddress(nc.nearID));

        if (newUsers.length) {
            var message:String = newUsers.length > 1 ? "вошли в чат." : "вошел в чат.";
            var names:String = newUsers.join(", ");
            dispatchEvent(new ChatEvent(ChatEvent.ON_DATA, { userName: names, text: message}));
        }
        return newUsers.length;
    }

    public function get userName():String {
        return _userName;
    }

    public function set userName(value:String):void {
        if (value == _userName) return;
        if (_connected) sendRename(_userName, value);
        _userName = value;
    }

    public function get connected():Boolean {
        return _connected;
    }

    public function get usersList():UsersList {
        return _usersList;
    }
}
}
