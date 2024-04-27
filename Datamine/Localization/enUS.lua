local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("Datamine", "enUS", true);

-- BEGIN LOCALIZATION

L["ADDON_TITLE"] = "Datamine";

L["CONFIG_DEBUGTARGETINFO_NAME"] = "Barber shop debug tooltips";
L["CONFIG_DEBUGTARGETINFO_TOOLTIP"] = "Toggles the display of debug tooltips in the barber shop and on character customization screens.";

L["CONFIG_CREATUREDATA_NAME"] = "Collect creature data";
L["CONFIG_CREATUREDATA_TOOLTIP"] = "Collects and stores information about NPCs you encounter in the world. May impact performance slightly.";

L["GENERIC_LOADING"] = "Loading...";
L["GENERIC_SEARCHING"] = "Searching...";
L["GENERIC_EMPTY"] = "Empty";
L["GENERIC_HIDDEN"] = "Hidden";
L["GENERIC_APPEARANCE"] = "Appearance";
L["GENERIC_SPELL"] = "Spell";
L["GENERIC_NA"] = "N/A";
L["GENERIC_YES"] = "Yes";
L["GENERIC_NO"] = "No";
L["GENERIC_OKAY"] = "Ok";
L["GENERIC_CONTINUE"] = "Continue";

L["WORKSPACE_MODE_EXPLORER"] = "Explorer";
L["WORKSPACE_MODE_MOVIE"] = "Theater";
L["WORKSPACE_MODE_MAPS"] = "Maps";
L["WORKSPACE_MODE_STORAGE"] = "Storage";

L["MODEL_CONTROLS_ALT_FORM_BUTTON_TOOLTIP_TEXT"] = "Toggle Alternate Form";

L["MODEL_CONTROLS_TAB_TITLE_TRANSFORM"] = "Transform";
L["MODEL_CONTROLS_TAB_TITLE_OUTFIT"] = "Outfit";
L["MODEL_CONTROLS_TAB_TITLE_ADVANCED"] = "Advanced";

L["MODEL_CONTROLS_TRANSFORM_TRANSLATE"] = "Translate";
L["MODEL_CONTROLS_TRANSFORM_CAMERA"] = "Camera";

L["MODEL_CONTROLS_ADVANCED_SET_BY_FDID"] = "Set model by FileDataID";
L["MODEL_CONTROLS_ADVANCED_SET_BY_FDID_HELP"] = "Enter a FileDataID...";
L["MODEL_CONTROLS_ADVANCED_SET_BY_DIID"] = "Set model by DisplayInfoID";
L["MODEL_CONTROLS_ADVANCED_SET_BY_DIID_HELP"] = "Enter a DisplayInfoID...";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_ITEMID"] = "Try on ItemID";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_ITEMID_HELP"] = "Enter an ItemID...";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_ITEMMODID"] = "Try on ItemModifiedAppearanceID";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_ITEMMODID_HELP"] = "Enter an ItemModifiedAppearanceID...";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_TMOGSET"] = "Try on TransmogSetID";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_TMOGSET_HELP"] = "Enter a TransmogSetID...";
L["MODEL_CONTROLS_ADVANCED_APPLY_SPELLVISKIT"] = "Apply SpellVisualKit";
L["MODEL_CONTROLS_ADVANCED_APPLY_SPELLVISKIT_HELP"] = "Enter a SpellVisualKitID...";
L["MODEL_CONTROLS_ADVANCED_PLAY_ANIMKIT"] = "Play AnimationKit";
L["MODEL_CONTROLS_ADVANCED_PLAY_ANIMKIT_HELP"] = "Enter an AnimKitID...";

L["THEATER_MODE_MOVIE_ID"] = "Movie ID";
L["THEATER_MODE_MOVIE_ID_EB_INSTRUCTIONS"] = "Enter MovieID...";
L["THEATER_MODE_SUBTITLE_TOGGLE"] = "Enable subtitles";
L["THEATER_MODE_CONTROLS_TITLE"] = "Movie Controls";
L["THEATER_MODE_LOOP_TOGGLE"] = "Loop movie";
L["THEATER_MODE_LOADING_MOVIE"] = "Loading movie...";
L["THEATER_MODE_DOWNLOAD_PROGRESS"] = "%d%%";
L["THEATER_MODE_ERR_PLAY_FAILED"] = "Unable to play movie wiht ID '%s': failed with error code %d (%s).";
L["THEATER_MODE_ERR_INVALID_MOVIE"] = "Movie '%d' does not exist or is otherwise not playable.";

L["EXPLORER_HELP_TEXT_HELP_HEADER"] = "Explorer";
L["EXPLORER_HELP_TEXT_HELP"] = "Enter %s %s ID in the search box above|nto get started.";
L["EXPLORER_HELP_TEXT_FAIL_HEADER"] = "Search failed";
L["EXPLORER_HELP_TEXT_FAIL"] = "%s %d is forbidden or does not exist.";
L["EXPLORER_HELP_TEXT_DRAGDROP_HEADER"] = "Explorer";
L["EXPLORER_HELP_TEXT_DRAGDROP"] = "Drop %s %s here to search for it.";
L["EXPLORER_HELP_TEXT_CREATURE_HEADER"] = "Creature Explorer";
L["EXPLORER_HELP_TEXT_CREATURE"] = "No creatures cached yet. Make sure the '|cffffffCollect creature data|r' setting is enabled, and try running around a bit.";

L["STORAGE_VIEW_TEXT_HELP_HEADER"] = "Storage";
L["STORAGE_VIEW_TEXT_HELP"] = "There are no creatures in the cache yet.|nTry running around and interacting with some NPCs first.";
L["STORAGE_VIEW_SEARCH_MODE_BUTTON_1"] = "ID";
L["STORAGE_VIEW_SEARCH_MODE_BUTTON_2"] = "Name";
L["STORAGE_VIEW_SEARCH_MODE_BUTTON_3"] = "Zone";

L["POPUP_CONFIG_CREATUREDATA_TITLE"] = "Data Collection";
L["POPUP_CONFIG_CREATUREDATA_TEXT"] = "Hey, thanks for using Datamine! Since you've last logged in, I've added the ability for Datamine to collect data about NPCs you see and interact with. All data is saved to the Datamine_Data addon's saved variables.|n|nThis feature may slightly harm performance in combat, do you want to enable NPC data collection?";

L["MAPVIEW_PICKER_TITLE"] = "Map Picker";
L["MAPVIEW_LOAD_DATA_BUTTON_TEXT"] = "Load maps";
L["MAPVIEW_TEXT_HELP_HEADER"] = "No maps loaded";
L["MAPVIEW_TEXT_HELP"] = "Map data hasn't been loaded yet.|nClick the button below to load map data.";
L["MAPVIEW_LOAD_WARNING_TITLE"] = "Warning";
L["MAPVIEW_LOAD_WARNING_TEXT"] = "Loading map data can take a bit and will likely freeze the game for a few seconds. Don't panic! Click the button below to load saved data.";
L["MAPVIEW_WARNING_NO_CONTENT"] = "Map has no content";
L["MAPVIEW_MAP_TITLE"] = "Current Map: %s";

-- MODULES --

-- UI Main

L["UI_MAIN_MODULE_NAME"] = "UIMain";

-- Spell Info

L["SPELL_INFO_MODULE_NAME"] = "SpellData";

L["SPELL_INFO_KEYS_NAME"] = "Name";
L["SPELL_INFO_KEYS_RANK"] = "Rank";
L["SPELL_INFO_KEYS_ICON"] = "Icon";
L["SPELL_INFO_KEYS_CASTTIME"] = "CastTime";
L["SPELL_INFO_KEYS_MINRANGE"] = "MinRange";
L["SPELL_INFO_KEYS_MAXRANGE"] = "MaxRange";
L["SPELL_INFO_KEYS_SPELLID"] = "SpellID";
L["SPELL_INFO_KEYS_ORIGINALICON"] = "OriginalIcon";
L["SPELL_INFO_KEYS_DESCRIPTION"] = "Description";
L["SPELL_INFO_KEYS_HYPERLINK"] = "Hyperlink";

L["SPELL_INFO_FMT_CAST_INSTANT"] = "Instant (%d)";
L["SPELL_INFO_FMT_CAST_TIME"] = "%d seconds";
L["SPELL_INFO_FMT_RANGE"] = "%d yards";

L["FMT_SPELL_INFO_ERR_SPELL_DOES_NOT_EXIST"] = "Query for spell %d failed. Spell does not exist.";
L["FMT_SPELL_INFO_ERR_SPELL_NOT_FOUND"] = "Query for spell %d failed. Spell is forbidden or does not exist.";

-- Transmog Info

L["TMOG_INFO_MODULE_NAME"] = "Transmog";

L["TMOG_INFO_KEYS_SOURCE_TYPE"] = "SourceType";
L["TMOG_INFO_KEYS_INVENTORY_TYPE"] = "InventoryType";
L["TMOG_INFO_KEYS_VISUALID"] = "VisualID";
L["TMOG_INFO_KEYS_ISCOLLECTED"] = "IsCollected";
L["TMOG_INFO_KEYS_SOURCEID"] = "SourceID";
L["TMOG_INFO_KEYS_ITEMID"] = "ItemID";
L["TMOG_INFO_KEYS_CATEGORYID"] = "CategoryID";
L["TMOG_INFO_KEYS_ITEMMODID"] = "ItemModID";

L["TMOG_INFO_ERR_NO_ITEMMODS"] = "No ItemModifiedAppearances found for ItemAppearance %d.";
L["TMOG_INFO_RESULT_ITEMMODS"] = "ItemModifiedAppearances for ItemAppearance %d >>"

L["TMOG_INFO_TRY_ON_LINK_TEXT"] = "Try On";

-- Slash Commands

L["SLASH_CMD_UI_TOGGLE_HELP"] = "Toggle the Datamine UI.";
L["SLASH_CMD_SPELL_INFO_HELP"] = "Retrieve information about a spell.";
L["SLASH_CMD_TMOG_ITEMMOD_INFO_HELP"] = "Retrieve source info for an ItemModifiedAppearanceID.";
L["SLASH_CMD_TMOG_ITEMMOD_FROM_ITEMAPP_HELP"] = "Retrieve itemModifiedAppearanceIDs for a given itemAppearanceID.";

-- END LOCALIZATION

Datamine.Strings = AceLocale:GetLocale("Datamine", false);