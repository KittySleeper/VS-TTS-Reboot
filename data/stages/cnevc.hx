//a
import flixel.group.FlxTypedSpriteGroup;

var textOffset:Int = 15;

var playerNames:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
var backgrounds:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

var characters = [];

function create() {
    characters.push(dad);
    characters.push(boyfriend);

    var bgSprite = stage.getSprite("Codename VC");

    insert(2, backgrounds);

    for (idx in 0...characters.length) {
        var char = characters[idx];
        var box = new FlxSprite().makeSolid(1070, 800, char.iconColor);
        box.shader = new CustomShader("bevelShader");
        box.shader.corner_scale = 0.05;

        box.setPosition((bgSprite.x + 400) + ((box.width + 15) * idx), bgSprite.y + 400);
        backgrounds.add(box);
    }

    add(playerNames);

    for (idx in 0...backgrounds.members.length) {
        var bgBox = backgrounds.members[idx];

        var charName = new FlxText(0, 0, 0, characters[idx].curCharacter.split("-")[0], 40);
        charName.font = Paths.font("discord.ttf");

        var shadowBox = new FlxSprite().makeSolid(charName.width + textOffset, charName.height + textOffset, 0xFF000000);
        shadowBox.shader = new CustomShader("bevelShader");
        shadowBox.shader.corner_scale = 0.4;
        shadowBox.alpha = 0.65;
        shadowBox.setPosition(bgBox.x + textOffset, bgBox.y + bgBox.height - shadowBox.height - textOffset);
        playerNames.add(shadowBox);
        
        charName.setPosition(shadowBox.x + (textOffset*0.5), shadowBox.y + (textOffset*0.5));
        playerNames.add(charName);
    }
    
}

var camGame_notes:FlxCamera;
function postCreate() {
    // camGame_notes = new FlxCamera();
    // camGame_notes.bgColor = FlxColor.TRANSPARENT;
    // var oldList = FlxG.cameras.list;
    // for (camera in FlxG.cameras.list) {
    //     if (camera == camGame) continue;
    //     FlxG.cameras.remove(camera, true);
    // }
    // FlxG.cameras.add(camGame_notes, false);
    // for (camera in oldList) {
    //     FlxG.cameras.add(camera, false);
    // }
}

function killLJidnc() {
    for (idx in 0...strumLines.members.length) {
        var strumLine = strumLines.members[idx];
        var bgBox = backgrounds.members[idx];
        strumLine.camera = camGame;
        strumLine.onNoteUpdate.add(noteUpdate);
        for (jdx in 0...strumLine.members.length) {
            var strum = strumLine.members[jdx];
            strum.x = bgBox.x + bgBox.width * 0.5 - (strum.width)*(4 - (jdx+1)) + (strum.width*0.75);
            // if (downscroll) {
            //     strum.y = bgBox.y + bgBox.height - strum.height * 2;
            // } else
                strum.y = bgBox.y - strum.height * 0.75;
            strum.extra.set("validYPos", strum.y);
        }
    }
}

function onCameraMove(e) {
    e.position.set(635, 455);
    FlxG.camera.focusOn(camFollow.getPosition());
    if (Conductor.songPosition < 0) 
        killLJidnc();
}

var noteLeavingAngle:Float = 45;
function noteUpdate(e) {
    var daNote = e.note;
    if (!(daNote.strumTime < Conductor.songPosition -( PlayState.instance.hitWindow *0.45) && !daNote.wasGoodHit)) return;
    
    if (!daNote.extra.exists("randomAngle")) {
        FlxTween.tween(daNote, {y: daNote.y - 200}, Conductor.crochet / 1000, {ease: FlxEase.sineInOut});
        daNote.extra.set("randomAngle", FlxG.random.int(-noteLeavingAngle, noteLeavingAngle));
    }

    e.cancelPositionUpdate();
    daNote.alpha = FlxMath.lerp(daNote.alpha, 0, FlxG.elapsed*5);
    daNote.angle = FlxMath.lerp(daNote.angle, daNote.extra.get("randomAngle"), FlxG.elapsed*2);
}

function onNoteHit(e) {
    var note = e.note;
    var strumLine = note.strumLine;
    var strum = strumLine.members[e.direction];
    if (note.isSustainNote || !strum.extra.exists("validYPos")) return;
    var yDir = (downscroll) ? 7 : 15;
    strum.y -= yDir;
    FlxTween.tween(strum, {y: strum.extra.get("validYPos")}, 0.35, {ease: FlxEase.quartIn});
}