// This is a UIState
import funkin.editors.ui.UIState;

import funkin.backend.utils.DiscordUtil;
import flixel.group.FlxTypedSpriteGroup;
import openfl.display.BitmapData;
import openfl.display.Bitmap;

import funkin.menus.ModSwitchMenu;
import funkin.editors.EditorPicker;

import funkin.backend.scripting.Script;
import flixel.util.FlxDestroyUtil;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

var serverData = [
    {name: "Direct Messages"},
    {name: "Codename Engine", image: "cneServer", visible: true},
    {name: "erm what the sigma\nerm what the sigma\nerm what the sigma\nerm what the sigma\nerm what the sigma", image: "placeholder", visible: true},
];

var randomShit = CoolUtil.coolTextFile(Paths.txt("random bios"));
var userBio = randomShit[FlxG.random.int(0, randomShit.length - 1)];

var channel_color_bg = 0xFF313338;
var category_color_bg = 0xFF2b2d31;
var servers_color_bg = 0xFF1e1f22;

var userdata_color_bg = 0xFF232428;

var titlebar_color_bg = 0xFF1e1f22;

var serverTab_camera:FlxCamera;
var serverTabGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

var categoryTab_camera:FlxCamera;
var categoryTabGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

var channelArea_camera:FlxCamera;
var channelAreaGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

var userTab_camera:FlxCamera;
var userTabGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

// stuff not requiring a separate camera, but a container to be layered on the cameras
var serverIconGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
var selectedServerTab:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

var isTyping:Bool = false;

function create() {
    FlxG.mouse.visible = true;

    serverTabUI();

    categoryTabUI();
    
    mainAreaUI();

    userTabUI();

    FlxG.cameras.remove(FlxG.camera, false);
    FlxG.cameras.add(FlxG.camera);
    FlxG.camera.bgColor = 0;

    add(selectedServerTab);
    selectedServerTab.alpha = 0.0001;

    textServer = new FlxText(0,0, 0, "", 16);
    if (textServer.fieldWidth > 195) textServer.fieldWidth = 195;
    textServer.setFormat(Paths.font("discord.ttf"), textServer.size, 0xFFFFFFFF, "left");
    
    var borderSizing = {x: 10, y: 15};
    var colorWhyFlixel = 0xFF111214;

    var tabBG = new FlxSprite().makeGraphic(textServer.fieldWidth + borderSizing.x, textServer.height + borderSizing.y, colorWhyFlixel);
    add_roundedShader(tabBG, 10);
    tabBG.onDraw = function(sprite:FlxSprite) {
        if (textServer.fieldWidth > 195) textServer.fieldWidth = 195;
        if (sprite.width != Std.int(textServer.fieldWidth + borderSizing.x)) {
            sprite.makeGraphic(textServer.fieldWidth + borderSizing.x, textServer.height + borderSizing.y, colorWhyFlixel);
        }
        textServer.setPosition(tabBG.x + 5, tabBG.y + tabBG.height * 0.5 - textServer.height * 0.5);
        sprite.draw();
    };
    selectedServerTab.add(tabBG);
    selectedServerTab.add(textServer);
}

function serverTabUI() {

    serverTab_camera = new FlxCamera(0, 0, 65, FlxG.height);
    serverTab_camera.bgColor = servers_color_bg;
    FlxG.cameras.add(serverTab_camera, false);
    
    serverTabGroup.cameras = [serverTab_camera];
    add(serverTabGroup);

    serverIconGroup.cameras = [serverTab_camera];
    add(serverIconGroup);

    var dmArea = new FlxSprite(0, 10).makeGraphic(50, 50, 0xFF35363c);
    add_roundedShader(dmArea, 0.5, false);
    serverIconGroup.add(dmArea);

    var line = new FlxSprite().makeGraphic(dmArea.width, 2, 0xFF35363c);
    line.x += dmArea.x * 0.5 + 8;
    line.y = dmArea.y + dmArea.height + 5;
    serverTabGroup.add(line);

    for (idx in 0...serverData.length-1) {
        var data = serverData[idx+1];
        if (!data.visible) continue;
        if (data.image == null) data.image = "placeholder";
        var iconPath = Paths.image("servers/" + data.image);
        if (!Assets.exists(iconPath)) iconPath = Paths.image("servers/placeholder");
        var icon = new FlxSprite().loadGraphic(iconPath);
        icon.setGraphicSize(50, 50);
        icon.updateHitbox();
        add_roundedShader(icon, 0.5, false);
        icon.antialiasing = true;
        icon.y = (icon.height + 10) * (idx+1) + 20;
        serverIconGroup.add(icon);
    }
    serverIconGroup.x = serverTab_camera.x + serverTab_camera.width * 0.5 - serverIconGroup.width * 0.5;
}

function categoryTabUI() {
    categoryTab_camera = new FlxCamera(serverTab_camera.width, 0, 300, FlxG.height);
    categoryTab_camera.bgColor = category_color_bg;
    FlxG.cameras.add(categoryTab_camera, false);

    categoryTabGroup.cameras = [categoryTab_camera];
    add(categoryTabGroup);
}

function mainAreaUI() {
    channelArea_camera = new FlxCamera(0, 0, FlxG.width - categoryTab_camera.width - serverTab_camera.width, FlxG.height);
    channelArea_camera.bgColor = channel_color_bg;
    channelArea_camera.x = categoryTab_camera.x + categoryTab_camera.width;
    FlxG.cameras.add(channelArea_camera, false);

    channelAreaGroup.cameras = [channelArea_camera];
    add(channelAreaGroup);

}

function userTabUI() {
    userTab_camera = new FlxCamera(serverTab_camera.width, 0, categoryTab_camera.width, 70);
    userTab_camera.y = FlxG.height - userTab_camera.height;
    userTab_camera.bgColor = userdata_color_bg;
    FlxG.cameras.add(userTab_camera, false);
    
    userTabGroup.cameras = [userTab_camera];
    add(userTabGroup);

    var bitmap = DiscordUtil.user?.getAvatar() ?? null;
    if (bitmap == null) bitmap = Paths.image((FlxG.random.bool(50) ? "no discord" : "pfps/sans"));
    var userIcon = new FlxSprite().loadGraphic(bitmap);
    userIcon.shader = new CustomShader("roundedShader");
    add_roundedShader(userIcon, 0.5, false);
    userIcon.setGraphicSize(50, 50);
    userIcon.updateHitbox();
    userIcon.antialiasing = true;
    userIcon.setPosition(10, userTab_camera.height * 0.5 - userIcon.height * 0.5);

    var userName = new FlxText(0, 0, 0, DiscordUtil.user?.globalName ?? "N / A", 18);
    userName.setFormat(Paths.font("discord.ttf"), userName.size, 0xFFFFFFFF, "left");
    userName.setPosition(userIcon.x + userIcon.width + 10, userIcon.y);

    var shortenedBio = userBio.substr(0, 11);
    if (userBio.length > 11) shortenedBio += "...";
    var biosText = new FlxText(0, 0, 0, shortenedBio, 16);
    biosText.setFormat(Paths.font("discord.ttf"), biosText.size, 0xff949494, "left");
    biosText.setPosition(userIcon.x + userIcon.width + 10, userName.y + userName.height * 0.75);
    

    var underUserIcon = new FlxSprite().makeGraphic((userIcon.width + 15) + (userName.width + 10) + 15, 60, 0xFF35363c);
    add_roundedShader(underUserIcon, 5, true);
    underUserIcon.x = userIcon.x - 5;
    underUserIcon.y = userIcon.y + userIcon.height * 0.5 - underUserIcon.height * 0.5;
    underUserIcon.alpha = 0;
    userTabGroup.add(underUserIcon);

    underUserIcon.onDraw = function(sprite:FlxSprite) {
        var hovered = mouseOver(sprite, userTab_camera);
        sprite.alpha = hovered ? 1 : 0;
        sprite.draw();
    };

    userTabGroup.add(biosText);
    userTabGroup.add(userName);
    userTabGroup.add(userIcon);
}

var hoveredServer:Bool = false;
function setHoveredServer(serverIcon:FlxSprite, idx:Int) {
    selectedServerTab.setPosition(serverIcon.x + serverIcon.width + 10, serverIcon.y + serverIcon.height * 0.5 - selectedServerTab.height * 0.5);
    if (FlxG.mouse.justReleased) {
        selectListType(switch(idx) {
            case 0: "Direct Messages";
            case 1: "Servers";
        });
    }
    if (hoveredServer) return;
    UIState.state.currentCursor = "button";
    textServer.fieldWidth = 0;
    hoveredServer = true;
    
    serverTween();
}

var fadeServerTween:FlxTween;
function unHoverServer() {
    if (!hoveredServer) return;
    UIState.state.currentCursor = "arrow";
    hoveredServer = false;

    serverTween();
}

function serverTween(?time:Float) {
    if (time == null) time = 0.1;
    var alpha = (hoveredServer) ? 1 : 0.0001;
    if (fadeServerTween != null) fadeServerTween.cancel();
    fadeServerTween = FlxTween.tween(selectedServerTab, {alpha: alpha}, time, {ease: FlxEase.quadInOut});
}

function update(elapsed:Float) {
	if (controls.SWITCHMOD && !isTyping) {
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new ModSwitchMenu());
	}

	if (FlxG.keys.justPressed.SEVEN && !isTyping) {
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new EditorPicker());
	}

    if (controls.ACCEPT && !isTyping) {
        // for now
        FlxG.switchState(new FreeplayState());
    }

    var hoveredItems = 0;
    for (idx in 0...serverIconGroup.members.length) {
        var icon = serverIconGroup.members[idx];
        if (icon.shader != null) {
            var cornerValue = (FlxG.mouse.overlaps(icon)) ? 0.35 : 0.5;
            icon.shader.corner_pixel = FlxMath.lerp(icon.shader.corner_pixel, cornerValue, elapsed*15);
        }
        if (FlxG.mouse.overlaps(icon)) {
            selectedServerTab.members[1].text = serverData[idx].name;
            setHoveredServer(icon, idx);
            continue;
        }
        hoveredItems++;
    }
    if (hoveredItems == serverIconGroup.members.length) unHoverServer();
    
    isTyping = (UIState.state.currentFocus != null);
}

var __layoutScript_category:Script;
var __layoutScript_main:Script;
function selectListType(?type:String) {
    // var type = type ?? "Direct Messages";
    destroyScript(__layoutScript_category, categoryTabGroup);
    destroyScript(__layoutScript_main, channelAreaGroup);

    var category_path = "data/states/DiscordMenu States/Main Layouts/" + type + "/categories";
    var main_path = "data/states/DiscordMenu States/Main Layouts/" + type + "/main";
    if (!Assets.exists(Paths.script(category_path)) || !Assets.exists(Paths.script(main_path))) return;
    initScript(__layoutScript_main = importScript(main_path), channelAreaGroup, channelArea_camera);
    initScript(__layoutScript_category = importScript(category_path), categoryTabGroup, categoryTab_camera, (script) -> {
        script.set("getMainScript", () -> { return __layoutScript_main; });
    });

}

function initScript(script:Script, _group, _camera:FlxCamera, ?extra) {
    var group = _group;
    var camera = _camera;
    var addExtra = extra ?? (script) -> {};
    script.set("add", (item) -> {
        if (item is FlxSprite || item is FlxText) item.antialiasing = true;
        group.add(item);
    });
    script.set("getCamera", () -> { return camera; });

    addExtra(script);

    script.load();
    script.call("create");
}

function destroyScript(script:Script, group) {
    if (group != null) {
        while (group.members.length > 0) {
            var item = group.members[0];
            item.destroy();
            group.remove(item, true);
        }
    }
    FlxG.state.stateScripts.remove(script);
    script?.active = false;
    script?.destroy();
}

// import openfl.Lib;
// import lime.ui.Window;
// import openfl.display.Sprite;
// import lime.app.Application;
// import funkin.backend.assets.ModsFolder;

// var test = new Sprite();
// function postCreate() {
//     var testBitmapData = BitmapData.fromFile(Paths.image("game/go"));
//     trace("testBitmapData: " + testBitmapData);
//     new FlxTimer().start(0.10, function(timer) {
//         var app = Lib.application.createWindow({
//             title: "NO I DONT",
//             width: 1280,
//             height: 720,
//             borderless: false,
//             alwaysOnTop: true,
//             frameRate: 60,
//         });

//         app.x = 30;
//         app.y = 100;

//         app.stage.color = 0xFF2FFF00;
//         test.addChild(new Bitmap(testBitmapData));
//         app.stage.addChild(test);
//     });
// }

// import openfl.Lib;
// import lime.ui.Window;
// import flixel.util.FlxTimer;
// import openfl.geom.Matrix;
// import openfl.geom.Rectangle;
// import openfl.display.Sprite;
// import lime.app.Application;
// import openfl.display.BitmapData;
// import openfl.display.Bitmap;
// import flixel.math.FlxMath;
// var bf = new Sprite();
// function postCreate()
// {
//     new FlxTimer().start(0.10, function(timer)
//     {
//         var app = Lib.application.createWindow({
//             title: "LJ LIKES MEN",
//             width: 1280,
//             height: 720,
//             borderless: false,
//             alwaysOnTop: true,
//             frameRate: 200,
//         });

//         app.x = 30;
//         app.y = 100;

//         app.stage.color = 0xFF2FFF00;
//         bf = new Sprite();
//         bf.addChild(new Bitmap(BitmapData.fromFile("assets/images/menus/LJ.png")));
//         app.stage.addChild(bf);
//     });
// }