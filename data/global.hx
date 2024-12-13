//a

var redirectStates:Map<FlxState, String> = [
	MainMenuState => "DiscordMenu States/MainMenuState",
];

function preStateSwitch() { 
    for (redirectState in redirectStates.keys())
        if (FlxG.game._requestedState is redirectState)
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}