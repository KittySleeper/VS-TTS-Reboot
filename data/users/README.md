# User Data for the mod
Here we should format it like so:
```
data/users
└───ItsLJcool
│   │   messages.json
│   │   quotes.txt
│   │   avitar.png
```
### messages.json
In this json, it should contain all the messages the user will send in the mod, for example; if the user has 3 songs associated, it should have 3 messages in the json.

Here is an examplpe sketch of how the structure should look like (bare minimum):
```
[
    {
        content: "Yoyle Cake!",
        song: "Tutorial",
    },
    {
        content: "Chat what if LJ was so LJ rizz skibidi",
        song: "Ugh",
    }
]
```
The index of the array is the message ID, and when it should be shwon in-game.

How does the message show up? Well each message will be based on save data, so on initalizing the mod, we make new save data for each user. Using reflect, the string should look like: `Username_msgID`.