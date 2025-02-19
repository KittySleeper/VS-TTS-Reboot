//a

var friendsTest = [
    {name: "ItsLJcool"}, {name: "YahyaModder"}, {name: "Moro the Goober"}, {name: "Crimson"}
];

var mainScript:Script;

var _camera = FlxG.camera;

var selectedFriend:Int = 0;
function create() {
    _camera = getCamera();
    mainScript = getMainScript();

    var directTab = new FlxText(20, 0, 0, "Direct Messages", 16);
    directTab.setFormat(Paths.font("discord.ttf"), directTab.size, 0xFFFFFFFF, "left");
    directTab.y = 225;
    add(directTab);

    for (idx=>data in friendsTest) {
        var iconPath = Paths.image("pfps/" + data.name);
        if (!Assets.exists(iconPath)) iconPath = Paths.image('pfps/sans');
        var icon = new FlxSprite().loadGraphic(iconPath);
        icon.setGraphicSize(40, 40);
        icon.updateHitbox();
        add_roundedShader(icon, 0.5, false);
        icon.x = directTab.x;
        icon.y = (directTab.height + icon.height) * (idx+1) + directTab.y - 20;

        var text = new FlxText(0, 0, 0, data.name, 18);
        text.setFormat(Paths.font("discord.ttf"), text.size, 0xFFFFFFFF, "left");
        text.x = icon.x + icon.width + 10;
        text.y = icon.y + icon.height * 0.5 - text.height * 0.5;
        
        var underIcon = new FlxSprite().makeGraphic(_camera.width - 20, icon.height + 15, 0xFF35363c);
        add_roundedShader(underIcon, 5, true);
        underIcon.x = _camera.width * 0.5 - underIcon.width * 0.5;
        underIcon.y = icon.y + icon.height * 0.5 - underIcon.height * 0.5;
        underIcon.alpha = 0;
        add(underIcon);
        
        underIcon.onDraw = function(sprite:FlxSprite) {
            var hovered = mouseOver(sprite, _camera);
            sprite.alpha = (hovered || selectedFriend == idx) ? 0.6 : 0;
            sprite.draw();

            if (!mouseOver(sprite, _camera)) return;
            if (!FlxG.mouse.justReleased) return;
            updateSelectedFriend(idx);
        };

        add(text);
        add(icon);
    }

    updateSelectedFriend(0);
}

function updateSelectedFriend(idx:Int) {
    selectedFriend = idx;
    mainScript.call("_setUserData", [friendsTest[selectedFriend]]);
    mainScript.call("updateMessages", [friendsTest[selectedFriend]]);
}