# Datamine v2.1.2

##### Added
* A new main tab to the Datamine UI that allows you to watch pre-rendered movies in-game using a `MovieID` from `Movie.db2`
* Achievement info searching in the explorer
* You can now drag and drop spells on the explorer to search for them
* Item searches now display item's `ItemSpell`

##### Fixed
* Model view camera controls are now much more precise and actually work as expected. Thanks to Peterodox for saving me from the math
* Most strings now use localized strings - accepting crowdsourced localization via Curseforge
* Font usage has been standardized a bit better
* Spacing should be a bit better on the explorer view
* Updated for 10.2.6
* Dracthyr should now start in the correct position in the model viewer

##### Known Issues
* Dracthyr do not start in the correct position in the model viewer

# Datamine v2.1.1

##### Added
* Experimental achievement info searches (might not work)
* Escape now closes the main Datamine frame

##### Fixed
* The item drag and drop feature will no longer eat items if the frame is hidden
* Right shift now works alongside left shift for modelview controls
* Model view controls can once again be expanded (sorry)

# Datamine v2.1

##### Added
* You can now drag items from your bag onto the Datamine Explorer tab to search for that item
* Added additional entry boxes under the 'Advanced' model controls tab
* Added some tooltips to ambiguous buttons (will get better icons eventually!)
* You can now hide pants

##### Fixed
* Fixed errors being thrown by LibDevConsole
* Fixed outfits and player actors misbehaving if you open the UI too quickly after loading in
* Unified some UI state handling and added a couple of easy accessors to the `Datamine.Unified` namespace

# Datamine v2.0

##### Added
* Datamine UI - a fully-featured interface for all of your datamining needs (plus like 10 billion lines of code cause I'm stubborn)
    * You can open the UI with the command `/dm ui`, or bind a key to toggle it in your settings.
    * Features model viewing, item and spell lookups, advanced model controls, and more.
    * All existing functionality in the model viewer and explorer has been migrated to the new UI. Old panels will be kept around but should be considered deprecated.
    * If you have any feedback on the new UI, please let me know! ❤️

Will be adding more and more features to the new UI as time goes on. If you have any questions or suggestions, don't hesitate to reach out.

# Datamine v1.7

##### Added
* Datamine Explorer - a UI for searching up item and spell info
    * In the future, this will be expanded to allow searching for all the different things Datamine currently supports (quests, transmog, etc)
    * This is still very much a work-in-progress, so feedback is welcomed! ❤️
    * You can open this either via the addon compartment button or through a binding

* A setting for the `debugTargetInfo` CVar, which enables debug tooltips in the barber shop and on character customization screens. **This is disabled by default**
    * In the barber shop, this will display IDs for the following:
        * ChrCustomizationOption
        * ChrCustomizationChoice
        * ChrCustomizationCategory
    * On character customization screens, it will also display IDs for:
        * ChrRaces
        * ChrClasses

##### Fixed
* Accidentally overwriting the `ShowColorPicker` function globally. Whoopsies.

# Datamine v1.6.2

##### Added
* Entry box for adding ItemModifiedAppearance's to your character in the Model Viewer

##### Fixed
* Cleaned up some horrific control panel code - will make it significantly easier to add new controls
* Fixed broken "Try On" links in the `/dm appearancemods` command
* Increased the size of the model viewer frame
* Increased max zoom level of the model viewer

# Datamine v1.6.1

##### Added
* Added a button to set model viewer model from target

##### Fixed
* Fixed support for 10.2 PTR, updated libs

# Datamine v1.6

##### Added
* Added two console commands that can be used while in the barber shop
    * `PreviewCustomizationChoice` allows you to view a customization choice using a ChrCustomizationOptionID and a ChrCustomizationChoiceID
    * `SetDressState` allows you to manually toggle your character's dress state using 1 or 0
    * If the console is not enabled, you can enable it with `/console enable` or by launching your game with the `-console` flag
* Added a new slash command `/dm appearanceinfo` to return some transmog data from an itemAppearanceID
* Added a command `/dm appearancemods` to return all itemModifiedAppearanceIDs for a given itemAppearanceID
* Added a command `/dm tryonitem` to try on an item by itemID. Note that item IDs can have multiple appearances, so this might not be 100% what you're expecting

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
