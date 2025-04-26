# Datamine

An addon designed to make in-game data more accessible by reducing barriers around the availability of certain data. Features in-depth tooltip information and customization, an advanced and intuitive UI, allowing customization of outfits, includes an in-game map viewer, enables the searching of items and spells, and lets you view models by ID, CreatureDisplayInfoID, and more.

> [!TIP]
> To open the Datamine UI in-game, you can either use `/dm ui` or click the Datamine entry in the addon compartment (or use a keybind). The addon compartment can be found by clicking the tiny button below the calendar button on the minimap.

Example:
![image](https://github.com/user-attachments/assets/fe4e3252-c5cc-41a3-b878-521cdb7834db)

# Features

## Tooltips
Datamine adds a plethora of useful information to (almost) all tooltips in the game. This includes things like SpellIDs for spell tooltips, ItemIDs for items, etc.

The tooltip info is entirely customizable, meaning you only see what you want to see, or you could optionally disable the system entirely.

![image](https://github.com/user-attachments/assets/e474e338-7298-4adf-9a5c-102f27aa7770)

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
> The map viewer is currently defunct (stuck in the past, lacking newer map content) while I fix my tooling.

## Slash Commands

Datamine's base command is `/dm` or `/datamine`.

- `help` - Gives you some help.
- `ui` - Toggles the Datamine UI.
- `item <itemID>` - Dumps the item info for the given `itemID` to the chat frame. Data for certain items may not be visible in-game.
- `spell <spellID>` Same as above but for spells. Data for certain spells may not be visible in-game.
- `questline <uiMapID> [<questID>]` Provides information about questlines on a given map ID, and optionally, the questline a quest belongs to.

More commands are available in-game and can be viewed with the `/dm help` command.
