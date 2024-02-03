local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("Datamine", "enUS", true);

-- BEGIN LOCALIZATION

L["ADDON_TITLE"] = "Datamine";

L["WORKSPACE_MODE_EXPLORER"] = "Explorer";
L["WORKSPACE_MODE_MOVIE"] = "Theater";

L["THEATER_MODE_MOVIE_ID"] = "Movie ID";
L["THEATER_MODE_MOVIE_ID_EB_INSTRUCTIONS"] = "Enter MovieID...";
L["THEATER_MODE_SUBTITLE_TOGGLE"] = "Enable subtitles";
L["THEATER_MODE_CONTROLS_TITLE"] = "Movie Controls";
L["THEATER_MODE_LOOP_TOGGLE"] = "Loop movie";
L["THEATER_MODE_LOADING_MOVIE"] = "Loading movie...";
L["THEATER_MODE_DOWNLOAD_PROGRESS"] = "%d%%";

-- END LOCALIZATION

Datamine.Strings = AceLocale:GetLocale("Datamine", false);