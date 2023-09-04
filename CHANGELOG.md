# Datamine v1.6

##### Added
* Added two console commands that can be used while in the barber shop
    * `PreviewCustomizationChoice` allows you to view a customization choice using a ChrCustomizationOptionID and a ChrCustomizationChoiceID
    * `SetDressState` allows you to manually toggle your character's dress state using 1 or 0
    * If the console is not enabled, you can enable it with `/console enable` or by launching your game with the `-console` flag
* Added a new slash command `/dm appearanceinfo` to return some transmog data from an AppearanceID
* Added a command `/dm tryonitem` to try on an item by itemID. Note that item IDs can have multiple appearances, so this might not be 100% what you're expecting.

##### Fixed
* Fixed an infinite loop in the `/dm quest` command
* Various modelviewing bugs

##### Removed
* Temporarily changed the `/dm appearance` command to work with ItemModifiedAppearanceID instead of ItemAppearanceID, cause the latter was broken

# Datamine v1.5

##### Added
* Added a new model viewer to allow users to preview a bunch of different models in the game
    * View models by model `FileDataID`
    * View model by `CreatureDisplayInfoID`
    * View `SpellVisualKit`s
    * Play an `AnimationKitID`
    * Switching the mode at the bottom will allow you to view a couple *more* things (this may be buggy)
        * View item models by `ItemID`
        * View Creatures by `CreatureID` and `DisplayID`
    * The base mode will allow you to view transmogs with the below commands, real spicy
* Added a few item appearance related commands
    * `/dm transmogset`: Preview a transmog set by `TransmogSetID`
    * `/dm appearance`: Preview an item by `ItemAppearanceID`
    * `/dm modifiedappearance`: Preview an item by `ItemModifiedAppearanceID`
    * `/dm dressup`: Shows the *new* and **shiny** Datamine model viewer/dress up frame

##### Changed
* Changed up some formatting for the `/dm help` command, would like feedback on it!

# Datamine v1.2

##### Added
* Added `/dm soundkit`, `/dm soundfile`, and `/dm mog`. Check `/dm help` for more information on these commands
* Added the beginnings of my custom model viewer
    * Currently only supports one-at-a-time ItemModifiedAppearanceID entries
    * In the future, will support viewing CreatureDisplayIDs, models by FileDataID, and much more
* Begun work on a settings system for some user configuration

##### Fixed
* Fixed an issue that would cause the addon to spam chat when receiving item, spell, and quest info from the server
