//a
import hxvlc.flixel.FlxVideoSprite;

var subCamera:FlxCamera;

var loadVid:FunkinSprite;
var loadBG:FunkinSprite;
var tipText:FunkinText;

function create(e) {
	e.cancel();

	subCamera = new FlxCamera();
	subCamera.bgColor = 0;
	FlxG.cameras.add(subCamera, false);
	subCamera.alpha = e.transOut ? 0 : 1;

	cameras = [subCamera];

	loadBG = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, 0xFF24242C);
	add(loadBG);

	_lastTip ??= FlxG.random.getObject(tipList);
	tipText = new FunkinText(0, FlxG.height*0.5 + 112.5, FlxG.width, !e.transOut ? _lastTip : _lastTip = FlxG.random.getObject(tipList));
	tipText.setFormat(Paths.font("Discord Fonts/Bold.TTF"), 20, 0xFFFFFFFF, "center");
	tipText.borderSize = 0;

	loadVid = new FunkinSprite();
	loadVid.loadSprite(Paths.image("discord shit/discordLogo"));
	loadVid.animation.addByPrefix("rotate", "rotate", 30, true);
	loadVid.playAnim("rotate");
	loadVid.screenCenter();
	add(loadVid);

	add(tipText);

	FlxTween.tween(subCamera, {alpha: e.transOut ? 1 : 0}, 0.5, {ease: FlxEase.cubeOut, onComplete: (_) -> {
		finish();
	}});
}

function onFinish(e) {
	e.cancel();
	if (newState != null)
		FlxG.switchState(newState);
	if (!transOut)
		close();
}

function onClose() {
	FlxG.cameras.remove(subCamera);
}