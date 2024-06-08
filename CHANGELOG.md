# Datamine v2.2.1

##### Fixed
* Creature names will no longer be cached with inaccurate names
* Map data loading should now be more reliable
* Fixed an issue related to spell data searching in the explorer
* Fixed a creature data caching issue related to logging spells cast by players on a creature
* Fixed an issue that caused players to be cached as if they were creatures
* Maps are now named by directory rather than map name. Should help clear up any possible duplicates, and may give you more maps to explore now
* Updated maps for 11.0.0.55000

##### Added
* A creature viewer for taking a peek at collected creature data (still in early development)
* A transmog set tab to the details display on the model view page. This will show the different items per slot in the transmog set currently being displayed on the model (also still in early development)
* Selection boxes indicating which element is currently selected in the various scrollable lists throughout Datamine

##### Notes
* The creature viewer and the transmog set tab are both still under construction. They're not going to work perfectly and are lacking features and polish


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