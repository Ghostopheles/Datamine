local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("Datamine", "enUS", true);

-- BEGIN LOCALIZATION

L["ADDON_TITLE"] = "Datamine";

L["CONFIG_COLOR_PICKER_TEXT"] = COLOR_PICKER;

L["CONFIG_CHAT_PREFIX_COLOR_NAME"] = "Chat prefix color";
L["CONFIG_CHAT_PREFIX_COLOR_TOOLTIP"] = "Color of the prefix used for chat output";

L["CONFIG_DEBUGTARGETINFO_NAME"] = "Barber shop debug tooltips";
L["CONFIG_DEBUGTARGETINFO_TOOLTIP"] = "Toggles the display of debug tooltips in the barber shop and on character customization screens.";

L["CONFIG_CREATUREDATA_NAME"] = "Collect creature data";
L["CONFIG_CREATUREDATA_TOOLTIP"] = "Collects and stores information about NPCs you encounter in the world. May impact performance slightly.";

L["CONFIG_AUTO_LOAD_MAP_DATA_NAME"] = "Load map data at startup";
L["CONFIG_AUTO_LOAD_MAP_DATA_TOOLTIP"] = "Automatically loads map viewer data at startup. May increase loading times on first login or on reload.";

L["CONFIG_CATEGORY_TOOLTIPS"] = "Tooltips";

L["CONFIG_HEADER_ITEM_TOOLTIPS"] = "Item Tooltips";
L["CONFIG_HEADER_SPELL_TOOLTIPS"] = "Spell Tooltips";
L["CONFIG_HEADER_MACRO_TOOLTIPS"] = "Macro Tooltips";
L["CONFIG_HEADER_TOY_TOOLTIPS"] = "Toy Tooltips";
L["CONFIG_HEADER_MOUNT_TOOLTIPS"] = "Mount Tooltips";

L["CONFIG_TOOLTIP_KEY_COLOR_NAME"] = "Data Key Color";
L["CONFIG_TOOLTIP_KEY_COLOR_TOOLTIP"] = "Color of the data keys on tooltips";

L["CONFIG_TOOLTIP_VALUE_COLOR_NAME"] = "Data Value Color";
L["CONFIG_TOOLTIP_VALUE_COLOR_TOOLTIP"] = "Color of the data values on tooltips";

-- item tooltips

L["CONFIG_TOOLTIP_SHOW_ITEM_ID_NAME"] = "Show Item ID";
L["CONFIG_TOOLTIP_SHOW_ITEM_ID_TOOLTIP"] = "Show item ID";
L["CONFIG_TOOLTIP_SHOW_ITEM_ENCHANT_ID_NAME"] = "Show Enchant ID";
L["CONFIG_TOOLTIP_SHOW_ITEM_ENCHANT_ID_TOOLTIP"] = "Show enchant ID";
L["CONFIG_TOOLTIP_SHOW_ITEM_GEMS_NAME"] = "Show Gem IDs";
L["CONFIG_TOOLTIP_SHOW_ITEM_GEMS_TOOLTIP"] = "Show slotted Gem IDs";
L["CONFIG_TOOLTIP_SHOW_ITEM_CONTEXT_NAME"] = "Show CreationContext";
L["CONFIG_TOOLTIP_SHOW_ITEM_CONTEXT_TOOLTIP"] = "Show ItemCreationContext name and ID";
L["CONFIG_TOOLTIP_SHOW_ITEM_BONUSES_NAME"] = "Show Bonus IDs";
L["CONFIG_TOOLTIP_SHOW_ITEM_BONUSES_TOOLTIP"] = "Show item bonus IDs";
L["CONFIG_TOOLTIP_SHOW_ITEM_MODIFIERS_NAME"] = "Show Modifiers";
L["CONFIG_TOOLTIP_SHOW_ITEM_MODIFIERS_TOOLTIP"] = "Show modifiers";
L["CONFIG_TOOLTIP_SHOW_ITEM_CRAFTER_GUID_NAME"] = "Show Crafter GUID";
L["CONFIG_TOOLTIP_SHOW_ITEM_CRAFTER_GUID_TOOLTIP"] = "For crafted items, shows the GUID of the crafter";
L["CONFIG_TOOLTIP_SHOW_ITEM_EXTRA_ENCHANT_ID_NAME"] = "Show Extra Enchant ID";
L["CONFIG_TOOLTIP_SHOW_ITEM_EXTRA_ENCHANT_ID_TOOLTIP"] = "Show extra enchant ID";
L["CONFIG_TOOLTIP_SHOW_ITEM_SPELL_NAME"] = "Show Item Spell";
L["CONFIG_TOOLTIP_SHOW_ITEM_SPELL_TOOLTIP"] = "Show item spell name and ID";
L["CONFIG_TOOLTIP_SHOW_ITEM_RELIC_BONUSES_NAME"] = "Show Relic Bonuses";
L["CONFIG_TOOLTIP_SHOW_ITEM_RELIC_BONUSES_TOOLTIP"] = "Show slotted relic bonuses";

-- spell tooltips

L["CONFIG_TOOLTIP_SHOW_SPELL_ID_NAME"] = "Show Spell ID";
L["CONFIG_TOOLTIP_SHOW_SPELL_ID_TOOLTIP"] = "Show spell ID";

-- macro tooltips

L["CONFIG_TOOLTIP_SHOW_MACRO_NAME"] = "Show Macro Name";
L["CONFIG_TOOLTIP_SHOW_MACRO_TOOLTIP"] = "Show macro name";
L["CONFIG_TOOLTIP_SHOW_MACRO_ACTION_NAME"] = "Show Macro Action";
L["CONFIG_TOOLTIP_SHOW_MACRO_ACTION_TOOLTIP"] = "Show macro action - either an inventory slot, item or spell";
L["CONFIG_TOOLTIP_SHOW_MACRO_ICON_NAME"] = "Show Macro Icon";
L["CONFIG_TOOLTIP_SHOW_MACRO_ICON_TOOLTIP"] = "Show macro icon ID";

-- toy tooltips

L["CONFIG_TOOLTIP_SHOW_TOY_ICON_NAME"] = "Show Toy Icon";
L["CONFIG_TOOLTIP_SHOW_TOY_ICON_TOOLTIP"] = "Show toy icon ID";

-- mount tooltips

L["CONFIG_TOOLTIP_SHOW_MOUNT_ID_NAME"] = "Show Mount ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ID_TOOLTIP"] = "Show mount ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SPELL_NAME"] = "Show Mount Spell ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SPELL_TOOLTIP"] = "Show mount spell ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ICON_NAME"] = "Show Mount Icon";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ICON_TOOLTIP"] = "Show mount icon ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_FACTION_NAME"] = "Show Mount Faction";
L["CONFIG_TOOLTIP_SHOW_MOUNT_FACTION_TOOLTIP"] = "Show required faction for mount";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SKYRIDING_NAME"] = "Show Mount Skyriding";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SKYRIDING_TOOLTIP"] = "Show whether the mount is capable of Skyriding or not";
L["CONFIG_TOOLTIP_SHOW_MOUNT_DISPLAY_NAME"] = "Show CreatureDisplayInfo ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_DISPLAY_TOOLTIP"] = "Show mount display ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_TYPE_NAME"] = "Show Mount Type ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_TYPE_TOOLTIP"] = "Show mount capabilities ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_MODELSCENE_NAME"] = "Show UiModelSceneID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_MODELSCENE_TOOLTIP"] = "Show UiModelSceneID for mount display";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ANIM_NAME"] = "Show Anim ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ANIM_TOOLTIP"] = "Show mount summon animation ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SPELLVISUAL_NAME"] = "Show SpellVisualKit ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SPELLVISUAL_TOOLTIP"] = "Show spell visual kit ID";

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

L["SEARCH_FAILED_HEADER"] = "Search Failed";
L["SEARCH_FAILED_TEXT"] = "No results found.";

L["WORKSPACE_MODE_EXPLORER"] = "Explorer";
L["WORKSPACE_MODE_MOVIE"] = "Theater";
L["WORKSPACE_MODE_MAPS"] = "Maps";
L["WORKSPACE_MODE_STORAGE"] = "Storage";
L["WORKSPACE_MODE_CREATURES"] = "Creatures";

L["MODEL_CONTROLS_ALT_FORM_BUTTON_TOOLTIP_TEXT"] = "Toggle Alternate Form";

L["MODEL_CONTROLS_TAB_TITLE_TRANSFORM"] = "Transform";
L["MODEL_CONTROLS_TAB_TITLE_OUTFIT"] = "Outfit";
L["MODEL_CONTROLS_TAB_TITLE_ADVANCED"] = "Advanced";
L["MODEL_CONTROLS_TAB_TITLE_TRANSMOG_SET"] = "Transmog Set Items";

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

L["MODEL_CONTROLS_TRANSMOG_SET_SLOT1"] = "Head";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT3"] = "Shoulder";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT4"] = "Shirt";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT5"] = "Chest";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT6"] = "Waist";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT7"] = "Legs";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT8"] = "Feet";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT9"] = "Wrist";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT10"] = "Hands";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT15"] = "Back";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT16"] = "Main Hand";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT17"] = "Off-hand";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT19"] = "Tabard";

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
L["MAPVIEW_PICKER_SEARCH_FAIL_TEXT"] = "No maps found.";
L["MAPVIEW_LOAD_DATA_BUTTON_TEXT"] = "Load maps";
L["MAPVIEW_TEXT_HELP_HEADER"] = "No maps loaded";
L["MAPVIEW_TEXT_HELP"] = "Map data hasn't been loaded yet.|nClick the button below to load map data.";
L["MAPVIEW_LOAD_WARNING_TITLE"] = "Warning";
L["MAPVIEW_LOAD_WARNING_TEXT"] = "Loading map data can take a bit and will likely freeze the game for a few seconds. Don't panic! Click the button below to load saved data.";
L["MAPVIEW_WARNING_NO_CONTENT"] = "Map has no content";
L["MAPVIEW_MAP_TITLE"] = "Current Map: %s";
L["MAPVIEW_DETAILS_TITLE"] = "Map Details";
L["MAPVIEW_DETAILS_HEADER_COORDS"] = "Coordinates";
L["MAPVIEW_DETAILS_HEADER_MISC"] = "Miscellaneous";
L["MAPVIEW_DETAILS_COORDS_WARNING"] = "X and Y are flipped for maps";
L["MAPVIEW_DETAILS_LABEL_Y"] = "Y";
L["MAPVIEW_DETAILS_LABEL_X"] = "X";
L["MAPVIEW_DETAILS_LABEL_MAP"] = "Map";
L["MAPVIEW_DETAILS_LABEL_WDT"] = "WDT";
L["MAPVIEW_DETAILS_GO"] = "Go";
L["MAPVIEW_DETAILS_DESC_TITLE"] = "Description";

L["CREATUREVIEW_LIST_TITLE"] = "Creatures";
L["CREATUREVIEW_LIST_SEARCH_FAIL_TEXT"] = "$Search Failed$";
L["CREATUREVIEW_TEXT_HELP_HEADER"] = "$Header$";
L["CREATUREVIEW_TEXT_HELP"] = "$Help$";
L["CREATUREVIEW_LOADING"] = "Loading Creature...";

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
L["SPELL_INFO_FMT_CAST_TIME"] = "%.1f seconds";
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