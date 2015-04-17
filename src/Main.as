package {
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import localchat.ChatEvent;
import localchat.IChat;
import localchat.Chat;

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;

public class Main extends Sprite {
    private const PADDING:int = 5;
    private const LINE_HEIGHT:int = 17;

    private const USER_COLOR:uint = 0x0099ff;
    private const OTHER_COLOR:uint = 0;
    private const SYSTEM_OK_COLOR:uint = 0x99cc00;
    private const SYSTEM_BAD_COLOR:uint = 0xff3300;

    private var chat:IChat;

    private var _userNameInput:TextField;
    private var _messageInput:TextField;
    private var _historyText:TextField;
    private var _historyTextFormat:TextFormat;
    private var _noConnectionButton:Sprite;
    private var _sendButton:Sprite;

    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event):void {
        createUI();
        chat = new Chat();
        setupHandlers();

        chat.connect();
        _userNameInput.text = chat.userName;
    }

    private function createUI():void{
        _userNameInput = new TextField();
        _userNameInput.x = _userNameInput.y = 5;
        _userNameInput.width = 100;
        _userNameInput.height = LINE_HEIGHT;
        _userNameInput.type = "input";
        _userNameInput.maxChars = 12;
        _userNameInput.border = true;
        addChild(_userNameInput);

        _sendButton = new Sprite();
        _sendButton.graphics.beginFill(0xcccccc);
        _sendButton.graphics.drawRect(0, 0, LINE_HEIGHT + 1, LINE_HEIGHT + 1);
        _sendButton.graphics.endFill();
        _sendButton.graphics.lineStyle(4, 0x99cc00);
        _sendButton.graphics.moveTo(4, 4);
        _sendButton.graphics.lineTo(14, 9);
        _sendButton.graphics.lineTo(4, 14);
        
        _sendButton.y = PADDING;
        _sendButton.x = stage.stageWidth - PADDING - _sendButton.width;
        _sendButton.visible = false;
        addChild(_sendButton);

        _noConnectionButton = new Sprite();

        _noConnectionButton.graphics.beginFill(0xcccccc);
        _noConnectionButton.graphics.drawRect(0, 0, LINE_HEIGHT + 1, LINE_HEIGHT + 1);
        _noConnectionButton.graphics.endFill();
        _noConnectionButton.graphics.lineStyle(4, 0xff3300);
        _noConnectionButton.graphics.moveTo(4, 4);
        _noConnectionButton.graphics.lineTo(14, 14);
        _noConnectionButton.graphics.moveTo(14, 4);
        _noConnectionButton.graphics.lineTo(4, 14);
            
        _noConnectionButton.x = _sendButton.x;
        _noConnectionButton.y = _sendButton.y;
        addChild(_noConnectionButton);

        _messageInput = new TextField();
        _messageInput.x = _userNameInput.width + _userNameInput.x + PADDING;
        _messageInput.y = 5;
        _messageInput.width = _sendButton.x - _messageInput.x - PADDING;
        _messageInput.height = LINE_HEIGHT;
        _messageInput.type = "input";
        _messageInput.border = true;
        addChild(_messageInput);

        _historyText = new TextField();
        _historyText.x = PADDING;
        _historyText.y = LINE_HEIGHT + PADDING * 2;
        _historyText.width = stage.stageWidth - PADDING * 2;
        _historyText.height = stage.stageHeight - _historyText.y - PADDING;
        _historyText.background = true;
        _historyText.backgroundColor = 0xcccccc;
        _historyTextFormat = _historyText.getTextFormat();
        addChild(_historyText);
    }

    private function setupHandlers():void {
        _sendButton.addEventListener(MouseEvent.CLICK, sendClickHandler);
        _userNameInput.addEventListener(FocusEvent.FOCUS_OUT, renameHandler);
        this.addEventListener(KeyboardEvent.KEY_DOWN, enterDownHandler);
        chat.addEventListener(ChatEvent.CHAT_CONNECTED, chatConnectHandler);
        chat.addEventListener(ChatEvent.CHAT_READY, chatReadyHandler);
        chat.addEventListener(ChatEvent.ON_DATA, receivedMessageHandler);
    }

    private function addMessage(name:String, text:String, color:uint = 0):void {
        if (!name && !text) {
            trace("Wrong message");
            return;
        }
        _historyTextFormat.color = color;
        _historyText.defaultTextFormat = _historyTextFormat;
        if(name) _historyText.appendText(name + ": ");
        _historyText.appendText(text + "\n");
    }
    
    private function sendMessage():void {
        if (!_messageInput.text) return;
        if (!chat.connected) {
            addMessage("System", "chat disconnected. Can`t send message.", SYSTEM_BAD_COLOR);
            return;
        }
        
        chat.userName = _userNameInput.text;

        var textToShow:String = chat.sendMessage(_messageInput.text);
        addMessage(chat.userName, textToShow, USER_COLOR);
        _messageInput.text = "";
    }

    private function updateButtons():void {
        if (!chat) return;
        _sendButton.visible = chat.connected;
        _noConnectionButton.visible = !chat.connected;
    }

    // HANDLERS //

    private function chatConnectHandler(e:ChatEvent):void {
        addMessage("System", "chat connected.", SYSTEM_OK_COLOR);
        updateButtons();
    }

    private function chatReadyHandler(e:ChatEvent):void {
        addMessage("System", "chat ready. You can send messages now.", SYSTEM_OK_COLOR);
        updateButtons();
    }

    private function receivedMessageHandler(e:ChatEvent):void {
        addMessage(e.data.userName, e.data.text, OTHER_COLOR);
        updateButtons();
    }

    private function sendClickHandler(e:MouseEvent):void {
        sendMessage();
    }

    private function enterDownHandler(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.ENTER) {
            sendMessage();
        }
    }

    private function renameHandler(e:Event):void {
        chat.userName = _userNameInput.text;
    }
}
}
