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
