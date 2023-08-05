Datamine.Questline = CreateFrame("Frame");

local moduleName = "QuestLineData";

local QuestInfoKeys = {
    "QuestLineName",
    "StartingQuestName",
    "QuestLineID",
    "QuestID",
    "X",
    "Y",
    "IsHidden",
    "IsLegendary",
    "IsDaily",
    "floorLocation",
};

local Print = function(...)
    Datamine.Print(moduleName, ...);
end;

local Dump = function(tableTitle, ...)
    Datamine.Dump(moduleName, tableTitle, ...);
end;

local DumpTableWithDisplayKeys = function(tableTitle, ...)
    Datamine.DumpTableWithDisplayKeys(moduleName, tableTitle, QuestInfoKeys, ...);
end;

function Datamine.Questline:Init()
    self.LastRequestedUiMapID = nil;
    self.LastRequestedQuestID = nil;
    self.WaitingForQuestLineInfo = false;

    self:SetScript("OnEvent", self.OnEvent);
    self:RegisterEvent("QUESTLINE_UPDATE");
end

function Datamine.Questline:OnEvent(event, ...)
    if self.LastRequestedUiMapID and self.WaitingForQuestLineInfo then
        if event == "QUESTLINE_UPDATE" then
            local requestRequired = ...;
            self:OnQuestlineInfoReceived(requestRequired);
        end
    end
end

function Datamine.Questline:OnQuestlineInfoReceived(requestRequired)
    if requestRequired == true then
        Print("why is this true still?");
    else
        local data;
        if self.LastRequestedQuestID then
            data = C_QuestLine.GetQuestLineInfo(self.LastRequestedQuestID, self.LastRequestedUiMapID);
        else
            data = C_QuestLine.GetAvailableQuestLines(self.LastRequestedUiMapID);
        end

        if not data then
            Print("Questline data unavailable.");
            return;
        end

        self:PrettyDumpQuestlineData(data);
    end
end

function Datamine.Questline:PrettyDumpQuestlineData(questLineInfo)
    if not questLineInfo or questLineInfo == {} then
        Print("No questlines found for map " .. self.LastRequestedUiMapID)
        return;
    end

    local mapName = C_Map.GetMapInfo(self.LastRequestedUiMapID).name;
    local questLinkPrefix = "questInfo";

    if not self.LastRequestedQuestID then
        Print("Questlines for map " .. self.LastRequestedUiMapID .. Datamine.WrapTextInParenthesis(mapName, true) .. "  >>");
        for _, quest in pairs(questLineInfo) do
            local questName = QuestUtils_GetQuestName(quest.questID);

            if quest.floorLocation then
                quest.floorLocation = Datamine.GetEnumValueName(Enum.QuestLineFloorLocation, quest.floorLocation) .. Datamine.WrapTextInParenthesis(quest.floorLocation, true);
            end

            local questLink = Datamine.Links.GenerateLinkWithCallback(questLinkPrefix .. Datamine.Links.SEPARATOR .. quest.questID, quest.questID, Datamine.Quest.HandleLink);

            Dump(questName .. " " .. questLink .. " >>", quest);
        end
    else
        Print("Questline info for map " .. self.LastRequestedUiMapID .. Datamine.WrapTextInParenthesis(mapName, true) .. " and quest " .. self.LastRequestedQuestID);
        local quest = questLineInfo;
        local questName = QuestUtils_GetQuestName(quest.questID);

        if quest.floorLocation then
            quest.floorLocation = Datamine.GetEnumValueName(Enum.QuestLineFloorLocation, quest.floorLocation) .. Datamine.WrapTextInParenthesis(quest.floorLocation, true);
        end

        local questLink = Datamine.Links.GenerateLinkWithCallback(questLinkPrefix .. Datamine.Links.SEPARATOR .. quest.questID, quest.questID, Datamine.Quest.HandleLink);

        Dump(questName .. " " .. questLink .. " >>", quest);
    end

    self.LastRequestedUiMapID = nil;
    self.LastRequestedQuestID = nil;
    self.WaitingForQuestLineInfo = false;
end

function Datamine.Questline:GetOrFetchQuestlineInfoForMap(uiMapID, questID)
    uiMapID = tonumber(uiMapID);
    assert(uiMapID, "GetOrFetchQuestlineInfoForMap requires a valid uiMapID.");

    local questLineInfo;
    self.LastRequestedUiMapID = uiMapID;

    if questID then
        self.LastRequestedQuestID = questID;
        questLineInfo = C_QuestLine.GetQuestLineInfo(questID, uiMapID);
    else
        questLineInfo = C_QuestLine.GetAvailableQuestLines(uiMapID);
    end

    if not questLineInfo then
        Print("Questline data unavailable.");
        return;
    end

    if #questLineInfo == 0 then
        self.WaitingForQuestLineInfo = true;
        C_QuestLine.RequestQuestLinesForMap(uiMapID);
    else
        self:PrettyDumpQuestlineData(questLineInfo);
    end
end

Datamine.Questline:Init();

local helpMessage = "Retrieve all available questlines for a given uiMapID. Optionally, provide a questID to retrieve the questline it belongs to.";
local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<uiMapID> [<questID>]", helpMessage);

Datamine.Slash:RegisterCommand("questline", function(uiMapID, questID) Datamine.Questline:GetOrFetchQuestlineInfoForMap(tonumber(uiMapID), tonumber(questID)) end, helpString);