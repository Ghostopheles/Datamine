# Datamine v2.2.0

##### Fixed
* Playing movies in the theater tab will now properly respect the 'loop movie' setting
* The 'defaults' button on the model scene transform tab should now work more consistently
* Dracthyr should now actually start in the correct position in the model viewer

##### Added
* Creature data collection! Now you can be your very own Wowhead!
    * Caches creatures that you see and interact with the in the world
    * Stores BroadcastText, Spells, Name, Reactions and InstanceIDs
    * The raw data can be found at `<game_path>/WTF/Account/<account>/SavedVariables/Datamine_Data.lua`
    * The saved variables file *may* fill up fairly quickly with data, so be sure to back it up manually if you don't want to lose any data.

* Two new console commands
    * `GetBuildInfo`: Dumps info about the current client build, with a few extra bits of information
    * `SetChrModel`: Allows you to change the character model in the barber shop. Only certain models are supported - i.e. Dragonflight dragon mounts, druid forms, warlock pets

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