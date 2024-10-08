# Datamine

An addon designed to make in-game data more accessible by reducing barriers around the availability of certain data. Features an advanced and intuitive UI, allowing customization of outfits, includes an in-game map viewer, enables the searching of items and spells, and lets you view models by ID, CreatureDisplayInfoID, and more.

> [!TIP]
> To open the Datamine UI in-game, you can either use `/dm ui` or click the Datamine entry in the addon compartment. The addon compartment can be found by clicking the tiny button below the calendar button on the minimap.

Example:
![image](https://github.com/Ghostopheles/Datamine/assets/10636803/f241614b-b28a-4468-8f8a-d21855e59f7a)

# Features

## Explorer

The Datamine explorer allows you to easily search for a few different things in the game, viewing all available in-game information about said thing.
Currently supports:
- Items
- Spells
- Achievements

## ModelViewer

This magical bit of engineering allows you to view (most) m2 models in the game with ease.
Supports model being set by:
- FileDataID
- CreatureDisplayInfoID

Additionally, if you're viewing a player model, you're able to try on items by ItemID, view transmogs with an ItemModifiedAppearanceID, or view entire transmog sets with the TransmogSetID!

You can also play SpellVisualKits and AnimationKits on the currently displayed model, by using a SpellVisualKitID or an AnimKitID, respectively.

Another tab you'll see on the right side of the model viewer is the **Outfit** tab. With this tab you can see all the currently shown gear on your character, hide them with a simple click, or search for them in the explorer using the magnifying glass button.
- You can also view details about each item by clicking beside the item link.

## Theater

In the theater tab, you can play pre-rendered movies in-game using their MovieID, included is the ability to automatically loop the movie, and you can even toggle subtitles.

## Map Viewer

The map viewer lets you view the minimap textures for any in-game map by either clicking it's name from the map picker, or by navigating to a MapID or WDT FileDataID using the details panel.

> [!IMPORTANT]
> In order to use the map viewer, Datamine requires access to external data. I'll include a baseline set of data in each release. To help keep people up-to-date, I've included [instructions](GENERATING_MAP_DATA.md) to generate your own map data.

The map viewer is highly experimental and may have some performance issues, though in my experience, performance was unaffected.

## Slash Commands

Datamine's base command is `/dm` or `/datamine`.

- `help` - Gives you some help.
- `ui` - Toggles the Datamine UI.
- `item <itemID>` - Dumps the item info for the given `itemID` to the chat frame. Data for certain items may not be visible in-game.
- `spell <spellID>` Same as above but for spells. Data for certain spells may not be visible in-game.
- `questline <uiMapID> [<questID>]` Provides information about questlines on a given map ID, and optionally, the questline a quest belongs to.

More commands are available in-game and can be viewed with the `/dm help` command.
