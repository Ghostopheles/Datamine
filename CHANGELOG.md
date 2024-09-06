# Datamine v2.3.2

#### Fixed
* Support for 11.0.5.56487

#### Added
* Item tooltips now have a few more useful bits of information
* With the UI open, you can now search for items by using a modified click on the item, configurable in the settings

# Datamine v2.3.1

#### Fixed
* Models will now actually rotate correctly with the mouse after you move them around
    * Thanks to the almighty and incredible @Peterodox for this change
* Fixed a rare script error at load time
* Fixed some unintentionally leaky globals
* Fixed some taint issues in the Settings UI
* Creature viewer sort function has been adjusted for non-english sorting

#### Added
* Added a total creature count to the creature viewer page
* Datamine will now display tooltips in the encounter journal for various elements
* The creature viewer now displays the total number of collected creatures

# Datamine v2.3.0

#### Fixed
* Greatly reduced map data size, updated included map data for 11.0.2.55959

#### Added
* Datamine will now log all the readable items you read, like books, plaques, and everything in-between
    * This currently has no UI associated with it, but I'm planning one in the future
* Fancy new fade-in and fade-out animations

# Datamine v2.2.4

* Support for 11.0.0 prepatch
* Support for 11.0.2.55789

# Datamine v2.2.3

##### Fixed
* Reduced size of included map data significantly and sped up the generation process
* Fixed most* tooltip errors
* Resolved most API errors in TWW (11.0.0+)
* Greatly improved the map viewer

##### Added
* Roboto is dead, long live InterTight

##### Known Issues
* Map viewer coordinates are broken

# Datamine v2.2.2

##### Fixed
* Horrendous temporary toolbar icons are no more
    * Toolbar icons may still be horrendous (I think they're okay)
* Improved creature viewer a tiny bit - still has a long way to go though
* Fixed a bug that caused errors to appear on the user's screen when viewing some tooltips
* Fixed a missing debug function haha

##### Added
* Datamine can now add various IDs to tooltips, configurable in the Blizzard settings.
    * Currently supports the following tooltip types
        * Items
        * Spells
        * Toys
        * Mounts
        * Units
        * Auras
        * Achievements
        * Battle Pets
        * Currencies
        * GameObjects
            * Sort of - in order to see GameObject IDs on tooltips, you need to be interacting with the object (i.e. have the mail frame opened) OR have soft interaction enabled and be looking at the object

# Datamine v2.2.1

##### Fixed
* Creature names will no longer be cached with inaccurate names
* Map data loading should now be more reliable
* Fixed an issue related to spell data searching in the explorer
* Fixed a creature data caching issue related to logging spells cast by players on a creature
* Fixed an issue that caused players to be cached as if they were creatures
* Maps are now named by directory rather than map name. Should help clear up any possible duplicates, and may give you more maps to explore now
* Updated maps for 11.0.0.55000
* Updated map table definition for map generation

##### Added
* A creature viewer for taking a peek at collected creature data (still in early development)
* A transmog set tab to the details display on the model view page. This will show the different items per slot in the transmog set currently being displayed on the model (also still in early development)
* Selection boxes indicating which element is currently selected in the various scrollable lists throughout Datamine

##### Notes
* The creature viewer and the transmog set tab are both still under construction. They're not going to work perfectly and are lacking features and polish