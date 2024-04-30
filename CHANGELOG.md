# Datamine v2.2.0

##### Fixed
* Playing movies in the theater tab will now properly respect the 'loop movie' setting
* The 'defaults' button on the model scene transform tab should now work more consistently
* Dracthyr should now actually start in the correct position in the model viewer
* SpellData fetching should now work properly on the War Within alpha (thanks QartemisT)

##### Added
* Creature data collection! Now you can be your very own Wowhead!
    * Caches creatures that you see and interact with the in the world
    * Stores BroadcastText, Spells, Name, Reactions and InstanceIDs
    * The raw data can be found at `<game_path>/WTF/Account/<account>/SavedVariables/Datamine_Data.lua`
    * The saved variables file *may* fill up fairly quickly with data, so be sure to back it up manually if you don't want to lose any data.

* Map viewer! You can now view minimap textures for every valid map in the game, without exiting the game!
    * Currently still under construction, will have some rough edges, and the maps can sometimes be hard to navigate, and content can be hard to find
    * Allows you to view most important map data, like MapID, WDTFileDataID, World Coordinates, Description, and soon to be much more
    * Involves a fairly cumbersome data-generation step, but pre-packaged data will be provided with every full release
        * Keep in mind that this data can easily become outdated through new builds and hotfixes
        * Instructions for generating the data yourself can be found [here](GENERATING_MAP_DATA.md)

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