function create() {
    var dadBox = new FlxSprite(-285, 150).makeSolid(1070, 800, dad.iconColor);
    insert(2, dadBox);

    var bfBox = new FlxSprite(790, 150).makeSolid(1070, 800, boyfriend.iconColor);
    insert(2, bfBox);

    var stupidDadUserNameBG = new FlxSprite(-275, 865).makeSolid(dad.curCharacter.split("-")[0].length * 35, 65, FlxColor.BLACK);
    stupidDadUserNameBG.alpha = 0.65;
    add(stupidDadUserNameBG);

    var stupidDadUserName = new FlxText(-270, 855, FlxG.width, dad.curCharacter.split("-")[0], 65);
    stupidDadUserName.font = Paths.font("discord.ttf");
    add(stupidDadUserName);

    var stupidBFUserNameBG = new FlxSprite(800, 865).makeSolid(boyfriend.curCharacter.split("-")[0].length * 35, 65, FlxColor.BLACK);
    stupidBFUserNameBG.alpha = 0.65;
    add(stupidBFUserNameBG);

    var stupidBFUserName = new FlxText(795, 855, FlxG.width, boyfriend.curCharacter.split("-")[0], 65);
    stupidBFUserName.font = Paths.font("discord.ttf");
    add(stupidBFUserName);
}

function postCreate() {
    for (strum in strumLines.members[0]) {
        strum.cameras = [camGame];
        strum.x -= 150;
    }

    for (strum in strumLines.members[1]) {
        strum.cameras = [camGame];
        strum.x += 350;
    }
}

function onCameraMove(e) {
    e.position.set(635, 455);
}