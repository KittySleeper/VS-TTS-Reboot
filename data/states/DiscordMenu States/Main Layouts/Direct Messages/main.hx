
import funkin.editors.ui.UIState;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

import openfl.geom.Rectangle;
import flixel.input.keyboard.FlxKey;

import funkin.editors.ui.UITextBox;

import StringTools;
var _camera:FlxCamera;

var bar_color = 0xFF383a40;
var barMessage:FlxSprite;

var addFilesIcon:FlxSprite;
function create() {
    _camera = getCamera();

    barMessage = new FlxSprite().makeGraphic(_camera.width - 50, 55, bar_color);
    add_roundedShader(barMessage, 8, true);
    barMessage.x = _camera.width * 0.5 - barMessage.width * 0.5;
    barMessage.y = _camera.height - barMessage.height - 25;
    add(barMessage);

    addFilesIcon = new FlxSprite().makeGraphic(30, 30, 0xFFFF0000);
    add_roundedShader(addFilesIcon, 0.5, false);
    addFilesIcon.x = barMessage.x + 15;
    addFilesIcon.y = barMessage.y + barMessage.height * 0.5 - addFilesIcon.height * 0.5;
    add(addFilesIcon);

    initMessageTextUI();
}

var textBox:UITextBox;
var highlight_sprite:FlxSprite;

var inputData = {
    text: "",

    isHighlighting: false,
    highlight: function(pos) {
        if (pos == -1) inputData.isHighlighting = false;
        else inputData.isHighlighting = true;
    }
};

function initMessageTextUI() {
    highlight_sprite = new FlxSprite().makeGraphic(50, 1, 0xFF0b40ab);
    add(highlight_sprite);

    textBox = new UITextBox(0, 0, userData.__getMessageString(), (barMessage.width - (addFilesIcon.width + 25)), barMessage.height);
    textBox.autoAlpha = false;
    textBox.x = barMessage.x + barMessage.width - textBox.bWidth;
    textBox.y = barMessage.y + barMessage.height * 0.5 - textBox.bHeight * 0.5;
    textBox.alpha = 0;
    textBox.label.setFormat(Paths.font("Discord Fonts/Bold.TTF"), 18, 0xFFFFFFFF, "left");
    textBox.label.alpha = 0.5;

	textBox.caretSpr.scale.set(1, textBox.label.size);
    textBox.caretSpr.updateHitbox();
    textBox.caretSpr.onDraw = (sprite:FlxSprite) -> {sprite.y += 3; sprite.draw();}; // offsetting at it's finest in HScript
    add(textBox);
    textBox.onChange = function(_text:String) {
        _text = StringTools.trim(_text);
        var userText = userData.__getMessageString();
        inputData.text = (_text == userText) ? "" : _text;
        if (inputData.text.length <= 0 && !inputData.isHighlighting) {
            textBox.label.text = userText;
            textBox.changeSelection(0);
            textBox.label.alpha = 0.5;
        }
    };

    highlight_sprite.onDraw = (sprite:FlxSprite) -> {
        if (!inputData.isHighlighting) return;

        var xPos = textBox.label.x;

        sprite.setPosition(xPos, textBox.label.y);
        var width = (textBox.caretSpr.x - xPos);
        if (width < 2) width = 2;
        sprite.setGraphicSize(width, textBox.label.height);
        sprite.updateHitbox();
        sprite.draw();
    };
}

function update(elapsed) {
    updateTextBoxUI(elapsed);
}

// TODO: move this to a better place, so we can use it everywhere ig
var bannedList = [
    FlxKey.ALL, FlxKey.NONE,
    FlxKey.PAGEUP, FlxKey.PAGEDOWN,
    FlxKey.UP, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT,
    FlxKey.F1, FlxKey.F2, FlxKey.F3, FlxKey.F4, FlxKey.F5, FlxKey.F6, FlxKey.F7, FlxKey.F8, FlxKey.F9, FlxKey.F10, FlxKey.F11, FlxKey.F12,
    FlxKey.INSERT, FlxKey.DELETE,
    FlxKey.HOME, FlxKey.END,
    FlxKey.ESCAPE, FlxKey.SPACE, FlxKey.ENTER, FlxKey.TAB,
    FlxKey.SHIFT, FlxKey.CONTROL, FlxKey.ALT, FlxKey.CAPSLOCK, FlxKey.BACKSPACE,
    FlxKey.WINDOWS, FlxKey.TAB, FlxKey.MENU, FlxKey.PRINTSCREEN, FlxKey.GRAVEACCENT, FlxKey.NUMLOCK, FlxKey.SCROLL_LOCK, FlxKey.BREAK,
];
function getValidTextKey(?justPressed:Bool = true) {
    var justPressed = justPressed ?? true;
    var keyInt = (justPressed) ? FlxG.keys.firstJustPressed() : FlxG.keys.firstPressed();
    if (!bannedList.contains(keyInt)) return keyInt;
    return -1;
}

var justFocused = false;
function updateTextBoxUI(elapsed) {
    var selected = (textBox.selectable && textBox.focused);
    if (!selected) return justFocused = false;
    if (!justFocused) {
        if (inputData.text.length <= 0) {
            textBox.label.text = "";
            textBox.label.alpha = 1;
            textBox.changeSelection(0);
        }
        justFocused = true;
    }

    // for now formatting like this (ugh I HATE IT!!! :SOB:) but reformat it when we finish it :(
    if (inputData.isHighlighting) {
        if (FlxG.mouse.justPressed) return inputData.highlight(-1);

        if ((getValidTextKey(true) != -1 || FlxG.keys.justPressed.BACKSPACE) && !FlxG.keys.pressed.CONTROL) {

            // I DON'T KNOW A BETTER WAY TO DO THIS :SOB:
            textBox.label.text = StringTools.replace(textBox.label.text, textBox.label.text.substr(0, textBox.position), "");
            textBox?.onChange(textBox.label.text);
            textBox.position = textBox.position-1;
            textBox.changeSelection(0);
    
            inputData.highlight(-1);
        }
        return;
    }

    // check here if we highlight or not.

    if (FlxG.keys.pressed.CONTROL) {
        if (FlxG.keys.justPressed.A) {
            inputData.highlight(0);
            textBox.position = textBox.label.text.length;
        }
    }

}

// Data handling

/*
    Format:
    {id: 0, text: "hello!", embeds: [], components: []}
*/
/*
    How messages should be stored:
    in data/users/UserName/messages.json...
    look in the readme.md for more info
*/
var messages = [
    {}
];

var userData = {};
function _setUserData(?data:Dynamic) {
    userData = data ?? {name: "ERROR"};
    userData.__getMessageString = () -> { return "Message @"+userData.name; };
    textBox?.onChange(userData.__getMessageString());
}
_setUserData();