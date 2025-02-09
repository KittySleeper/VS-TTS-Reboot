//a
import funkin.backend.MusicBeatTransition;
import funkin.editors.ui.UIState;

//region helper functions
static function add_roundedShader(sprite:FlxSprite, corner_pixel:Float, ?use_pixels:Bool = true, ?custom_size:Bool = false, ?box_size:Array<Float>) {
	var custom_size = custom_size ?? false;
	var box_size = box_size ?? [sprite.width, sprite.height];
	var use_pixels = use_pixels ?? true;
	sprite.shader = new CustomShader("roundedShader");

	sprite.shader.corner_pixel = corner_pixel;
	sprite.shader.use_pixels = use_pixels;
	sprite.shader.custom_size = custom_size;
	sprite.shader.box_size = box_size;
}

static function getMouseCameraPos(camera:FlxCamera) {
	if (camera == null) return FlxG.mouse.getWorldPosition(FlxG.camera);
	// bruh errors
	var _mousePos = 0;
	try {
		_mousePos = FlxG.mouse.getWorldPosition(camera);
	} catch(e:Error) {}
	return _mousePos;
}

static function mouseOver(object:FlxBasic, camera:FlxCamera) {
	var mousePos = getMouseCameraPos(camera);
	return (mousePos.x > object.x && mousePos.x < object.x + object.width && mousePos.y > object.y && mousePos.y < object.y + object.height);
}
//endregion

static var tipList:Array<String> = CoolUtil.coolTextFile(Paths.file("data/tips.txt"));
static var _lastTip:String = "";

var redirectStates:Map<FlxState, String> = [
	MainMenuState => "DiscordMenu States/ui.MainMenuState",
];

function new() MusicBeatTransition.script = "data/scripts/DiscordTransition";

function preStateSwitch() {
	for (redirectState in redirectStates.keys()) {
		if (!(FlxG.game._requestedState is redirectState)) continue;
		var data = redirectStates.get(redirectState);
		var name = data.split("/").pop();
		var state = (StringTools.startsWith(name, "ui.")) ? new UIState(true, data) : new ModState(data);
		FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
	}
}

function destroy() {
	tipList = _lastTip = null;
	
	FlxG.camera.bgColor = 0xFF000000;
}