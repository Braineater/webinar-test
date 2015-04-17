/**
 * Created by Leo on 15.04.2015.
 */
package localchat {
import flash.events.IEventDispatcher;

public interface IChat extends IEventDispatcher{
    function connect():void;
    function disconnect():void;
    function sendMessage(text:String):String;
    function set userName(value:String):void;
    function get userName():String;
    function get connected():Boolean;
    function get usersList():UsersList;
}
}
