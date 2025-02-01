//a

import funkin.backend.utils.DiscordUtil;
import flixel.group.FlxTypedSpriteGroup;
import openfl.display.BitmapData;

import funkin.menus.ModSwitchMenu;
import funkin.editors.EditorPicker;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

var serverData = [
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

var serverTabGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
var serverIconGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

var categoryTabGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

var userTabGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

var selectedServerTab:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

function create() {
    FlxG.camera.bgColor = channel_color_bg;
    FlxG.mouse.visible = true;

    serverTabUI();

    categoryTabUI();

    userTabUI();

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
    add(serverTabGroup);

    serverTab = new FlxSprite().makeSolid(65, FlxG.height, servers_color_bg);
    add(serverTab);

    add(serverIconGroup);

    for (idx in 0...serverData.length) {
        var data = serverData[idx];
        if (!data.visible) continue;
        if (data.image == null) data.image = "placeholder";
        var iconPath = Paths.image("servers/" + data.image);
        if (!Assets.exists(iconPath)) iconPath = Paths.image("servers/placeholder");
        var icon = new FlxSprite().loadGraphic(iconPath);
        icon.setGraphicSize(50, 50);
        icon.updateHitbox();
        add_roundedShader(icon, 0.5, false);
        icon.antialiasing = true;
        icon.y = (icon.height + 10) * (idx) + 65;
        serverIconGroup.add(icon);
    }
    serverIconGroup.x = serverTab.x + serverTab.width * 0.5 - serverIconGroup.width * 0.5;
}

function categoryTabUI() {
    categoryTab = new FlxSprite().makeSolid(300, FlxG.height, category_color_bg);
    categoryTab.setPosition(serverTab.x + serverTab.width, FlxG.height * 0.5 - categoryTab.height * 0.5);
    add(categoryTab);
}

function userTabUI() {
    add(userTabGroup);

    var userTab = new FlxSprite().makeSolid(categoryTab.width, 70, userdata_color_bg);
    userTab.setPosition(categoryTab.x, FlxG.height - userTab.height);
    userTabGroup.add(userTab);

    var bitmap = DiscordUtil.user.getAvatar();
    if (bitmap == null) bitmap = Paths.image('no discord');
    var userIcon = new FlxSprite().loadGraphic(bitmap);
    userIcon.shader = new CustomShader("roundedShader");
    add_roundedShader(userIcon, 0.5, false);
    userIcon.setGraphicSize(50, 50);
    userIcon.updateHitbox();
    userIcon.antialiasing = true;
    userIcon.setPosition(userTab.x + 15, userTab.y + userTab.height * 0.5 - userIcon.height * 0.5);
    userTabGroup.add(userIcon);

    var userName = new FlxText(0, 0, 0, DiscordUtil.user.globalName, 18);
    userName.setFormat(Paths.font("discord.ttf"), userName.size, 0xFFFFFFFF, "left");
    userName.setPosition(userIcon.x + userIcon.width + 10, userIcon.y);
    userTabGroup.add(userName);

    var shortenedBio = userBio.substr(0, 11);
    if (userBio.length > 11) shortenedBio += "...";
    var biosText = new FlxText(0, 0, 0, shortenedBio, 16);
    biosText.setFormat(Paths.font("discord.ttf"), biosText.size, 0xff949494, "left");
    biosText.setPosition(userIcon.x + userIcon.width + 10, userName.y + userName.height * 0.75);
    userTabGroup.add(biosText);
}

var hoveredServer:Bool = false;
function setHoveredServer(serverIcon:FlxSprite) {
    selectedServerTab.setPosition(serverIcon.x + serverIcon.width + 10, serverIcon.y + serverIcon.height * 0.5 - selectedServerTab.height * 0.5);
    if (hoveredServer) return;
    Mouse.cursor = "button";
    textServer.fieldWidth = 0;
    hoveredServer = true;
    
    serverTween();
}

var fadeServerTween:FlxTween;
function unHoverServer() {
    if (!hoveredServer) return;
    Mouse.cursor = "arrow";
    hoveredServer = false;

    serverTween();
}

function serverTween(?time:Float) {
    if (time == null) time = 0.25;
    var alpha = (hoveredServer) ? 1 : 0.0001;
    if (fadeServerTween != null) fadeServerTween.cancel();
    fadeServerTween = FlxTween.tween(selectedServerTab, {alpha: alpha}, time, {ease: FlxEase.quadInOut});
}

function update(elapsed:Float) {
	if (controls.SWITCHMOD) {
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new ModSwitchMenu());
	}

	if (FlxG.keys.justPressed.SEVEN) {
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new EditorPicker());
	}

    if (controls.ACCEPT) {
        // for now
        FlxG.switchState(new FreeplayState());
    }

    var hoveredItems = 0;
    for (idx in 0...serverIconGroup.members.length) {
        var icon = serverIconGroup.members[idx];
        var cornerValue = (FlxG.mouse.overlaps(icon)) ? 0.35 : 0.5;
        icon.shader.corner_pixel = FlxMath.lerp(icon.shader.corner_pixel, cornerValue, elapsed*15);
        if (FlxG.mouse.overlaps(icon)) {
            selectedServerTab.members[1].text = serverData[idx].name;
            setHoveredServer(icon);
            continue;
        }
        hoveredItems++;
    }
    if (hoveredItems == serverIconGroup.members.length) unHoverServer(); 
}
