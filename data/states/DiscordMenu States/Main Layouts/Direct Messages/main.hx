import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

import flixel.input.keyboard.FlxKey;

import openfl.geom.Rectangle;

import flixel.input.keyboard.FlxKey;

import StringTools;
var _camera:FlxCamera;

/*
    Format:
    {id: 0, text: "hello!", embeds: [], components: []}
*/
var messages = [
    {}
];

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

var typing_data = { position: 0, setHighlight: function(value) {
    var prev = typing_data.highlighting;
    if (!prev && value) typing_data.position = inputText.length;
    typing_data.highlighting = highlight_sprite.visible = value;

    // trace("Changed Highlighting Data | Is Highlighting: " + typing_data.highlighting + " | position: " + typing_data.position);
}, highlighting: false, startHighlight: 0};

var caretSpr:FlxSprite;
var cacheRect:Rectangle = new Rectangle();

var highlight_sprite:FlxSprite;

var text_testing:FlxText;
function initMessageTextUI() {

    // color = 0xFF0b40ab;
    highlight_sprite = new FlxSprite().makeGraphic(1, 1, 0xFF0b40ab);
    highlight_sprite.visible = false;
    add(highlight_sprite);

    text_testing = new FlxText(0, 0, 0, "Message @NO ONE FUCK YOU!!", 14);
    text_testing.x = addFilesIcon.x + addFilesIcon.width + 20;
    text_testing.y = addFilesIcon.y + addFilesIcon.height * 0.5 - text_testing.height * 0.5;
    text_testing.alpha = 0.35;
    add(text_testing);

    highlight_sprite.onDraw = function(sprite:FlxSprite) {
        if (!sprite.visible) return;

        var lerpWidth = FlxMath.lerp(1, text_testing.fieldWidth, (typing_data.position/text_testing.text.length));
        sprite.setGraphicSize(lerpWidth, text_testing.height);
        sprite.updateHitbox();
        sprite.setPosition(text_testing.x, text_testing.y);

        sprite.draw();
    };

    caretSpr = new FlxSprite();
    caretSpr.makeGraphic(1, 1, -1);
    caretSpr.scale.set(1, text_testing.size + 8);
    caretSpr.updateHitbox();
    add(caretSpr);
    caretSpr.onDraw = function(sprite:FlxSprite) {
        if (!getTyping()) return;
        sprite.draw();
        caretSpr.alpha = (FlxG.game.ticks % 666) >= 333 ? 1 : 0;

        var curPos = switch(typing_data.position) {
            case 0:
                FlxPoint.get(0, 0);
            default:
                if (typing_data.position >= text_testing.text.length) {
                    text_testing.textField.__getCharBoundaries(text_testing.text.length-1, cacheRect);
                    FlxPoint.get(cacheRect.x + cacheRect.width, cacheRect.y);
                } else {
                    text_testing.textField.__getCharBoundaries(typing_data.position, cacheRect);
                    FlxPoint.get(cacheRect.x, cacheRect.y);
                }
        };
        caretSpr.x = text_testing.x + (curPos.x);
        caretSpr.y = text_testing.y + (-3 + curPos.y);
        curPos.put();
    }
}

var inputText:String = "";
function update(elapsed) {
    updateBarSpriteMouse(elapsed);

    if (getTyping()) {
        if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.A) typing_data.setHighlight(true);
        inputText = checkTyping(text_testing, inputText);
        text_testing.alpha = inputText.length > 0 ? 1 : 0.35;

        if (typing_data.highlighting) inputText = updateHighlighting(text_testing, inputText);
    }
}

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


var __lastHovered:Bool = false;
function updateBarSpriteMouse(elapsed) {
    var hovered = mouseOver(barMessage, _camera);
    if (hovered && !__lastHovered) Mouse.cursor = "ibeam";
    if (!hovered && __lastHovered) Mouse.cursor = "arrow";

    if (FlxG.mouse.justPressed) {
        typing_data.setHighlight(false);
        setTyping(hovered);
    }
    
    __lastHovered = hovered;
}

var _keyToString = [
    {key: FlxKey.ONE, string: "1", shift: "!"},
    {key: FlxKey.TWO, string: "2", shift: "@"},
    {key: FlxKey.THREE, string: "3", shift: "#"},
    {key: FlxKey.FOUR, string: "4", shift: "$"},
    {key: FlxKey.FIVE, string: "5", shift: "%"},
    {key: FlxKey.SIX, string: "6", shift: "^"},
    {key: FlxKey.SEVEN, string: "7", shift: "&"},
    {key: FlxKey.EIGHT, string: "8", shift: "*"},
    {key: FlxKey.NINE, string: "9", shift: "("},
    {key: FlxKey.ZERO, string: "0", shift: ")"},

    {key: FlxKey.NUMPADONE, string: "1"},
    {key: FlxKey.NUMPADTWO, string: "2"},
    {key: FlxKey.NUMPADTHREE, string: "3"},
    {key: FlxKey.NUMPADFOUR, string: "4"},
    {key: FlxKey.NUMPADFIVE, string: "5"},
    {key: FlxKey.NUMPADSIX, string: "6"},
    {key: FlxKey.NUMPADSEVEN, string: "7"},
    {key: FlxKey.NUMPADEIGHT, string: "8"},
    {key: FlxKey.NUMPADNINE, string: "9"},
    {key: FlxKey.NUMPADZERO, string: "0"},
    {key: FlxKey.NUMPADPLUS, string: "+"},
    {key: FlxKey.NUMPADMINUS, string: "-"},
    {key: FlxKey.NUMPADPERIOD, string: "."},
    {key: FlxKey.NUMPADSLASH, string: "/"},
    {key: FlxKey.NUMPADMULTIPLY, string: "*"},

    {key: FlxKey.COMMA, string: ",", shift: "<"},
    {key: FlxKey.PERIOD, string: ".", shift: ">"},
    {key: FlxKey.SLASH, string: "/", shift: "?"},
    {key: FlxKey.BACKSLASH, string: "\\", shift: "|"},
    {key: FlxKey.MINUS, string: "-", shift: "_"},
    {key: FlxKey.PLUS, string: "+", shift: "="},
    {key: FlxKey.SPACE, string: " "},
    {key: FlxKey.SEMICOLON, string: ";", shift: ":"},
    {key: FlxKey.QUOTE, string: "'", shift: "\""},
    {key: FlxKey.LBRACKET, string: "[", shift: "{"},
    {key: FlxKey.RBRACKET, string: "]", shift: "}"},
    {key: FlxKey.GRAVEACCENT, string: "`", shift: "~"},
];

function updateCaret(textValue:String) {
    if ((FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.LEFT)) {
        var direction = FlxG.keys.justPressed.LEFT ? -1 : 1;
        var calc = typing_data.position + direction;
        if (calc > textValue.length) calc = textValue.length;
        if (calc < 0) calc = 0;
        typing_data.position = calc;
    }
}

var _backspaceTime:Float = 0;
function checkTyping(textToApply, textValue:String, ?defaultText:String) {
    if (FlxG.keys.pressed.CONTROL || typing_data.highlighting) return textValue;
    var defaultText = defaultText ?? "Message @NO ONE FUCK YOU!!";
    if (FlxG.keys.pressed.BACKSPACE) _backspaceTime += FlxG.elapsed;
    if (FlxG.keys.justPressed.BACKSPACE) _backspaceTime = 0;

    updateCaret(textValue);

    if (!FlxG.keys.justPressed.BACKSPACE) {
        var keyInt = getValidTextKey();
        var firstPressed = FlxG.keys.firstJustPressed();

        for (data in _keyToString) {
            if (data.key != firstPressed) continue;
            keyInt = -1;
            textValue += (FlxG.keys.pressed.SHIFT) ? (data?.shift ?? data.string) : data.string;
            typing_data.position++;
            break;
        }
        
        if (keyInt != -1) {
            var caps = FlxG.keys.pressed.SHIFT;
            var string = FlxKey.toStringMap.get(keyInt);

            if (caps) string = string.toUpperCase();
            else string = string.toLowerCase();

            textValue += string;
            typing_data.position++;
        }
    }

    if (_backspaceTime > 0.5 || FlxG.keys.justPressed.BACKSPACE) {
        _backspaceTime -= FlxG.elapsed*3;
        textValue = textValue.substr(0, textValue.length-1);
    }

    if (textValue.length > 0) {
        textToApply.text = textValue;
    } else {
        textValue = "";
        textToApply.text = defaultText;
    }
    return textValue;
}

function updateHighlighting(textToApply, textValue:String) {
    if (FlxG.keys.justPressed.BACKSPACE) {
        textToApply.text = textValue = textValue.substr(typing_data.position);
        typing_data.setHighlight(false);
        typing_data.position = 0;
        return textValue;
    }

    if (FlxG.keys.pressed.SHIFT) updateCaret(textValue);
    // if (typing_data.position == 0) typing_data.setHighlight(false);

    return textValue;
}