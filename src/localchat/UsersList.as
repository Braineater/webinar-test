/**
 * Created by Leo on 16.04.2015.
 */
package localchat {
import flash.utils.Dictionary;

public class UsersList {
    private var userList:Dictionary = new Dictionary(false);
    public function UsersList() {
        // nothing to do
    }

    public function addUser(key:String, name:String):Boolean {
        var isNew:Boolean = userList[key] == undefined;
        userList[key] = name;
        if(isNew) {
            trace("Вау, новый друг!");
        }
        return isNew;
    }

    public function deleteUser(key:String):void {
        delete userList[key];
    }

    public function getUserName(key:String):String {
        return userList[key] || "";
    }
    
    public function toString():String {
        var result:Array = [];
        for each (var nm:String in userList) {
            result.push(nm);
        }
        return result.join(", ");
    }

    public function setUsersFromEcho(users:Object, myID:String):Array {
        var result:Array = [];
        for (var id:String in users) {
            if (id == myID) continue;
            if (addUser(id, users[id]))
                result.push(users[id]);
        }

        return result;
    }

    public function getUsersForEcho():Object {
        var result:Object = {};
        for (var id:String in userList) {
            result[id] = userList[id];
        }
        return result;
    }
}
}
