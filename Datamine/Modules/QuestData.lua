Datamine.Quest = CreateFrame("Frame");

local moduleName = "QuestData";

local Print = function(...)
    Datamine.Utils.Print(moduleName, ...);
end;

local Dump = function(tableTitle, ...)
    Datamine.Utils.Dump(moduleName, tableTitle, ...);
end;

function Datamine.Quest:Init()
    self.LastRequestedQuestID = nil;
    self.WaitingForQuestInfo = false;

    self:SetScript("OnEvent", self.OnEvent);
    self:RegisterEvent("QUEST_DATA_LOAD_RESULT");
end

function Datamine.Quest:OnEvent(event, ...)
    if self.LastRequestedQuestID and self.WaitingForQuestInfo then
        if event == "QUEST_DATA_LOAD_RESULT" then
            local questID, success = ...;
            if questID == self.LastRequestedQuestID then
                self:OnQuestInfoReceived(questID, success);
            end
        end
    end
end

function Datamine.Quest.IsQuestCached(questID)
    return C_QuestLog.GetTitleForQuestID(questID) ~= nil;
end

function Datamine.Quest.GetQuestTagInfo(questID)
    local tagInfo = C_QuestLog.GetQuestTagInfo(questID);

    if not tagInfo then
        return nil;
    end

    if tagInfo.worldQuestType then
        tagInfo.worldQuestType = Datamine.Utils.GetEnumValueName(Enum.QuestTagType, tagInfo.worldQuestType) .. " (" .. tagInfo.worldQuestType .. ")";
    end

    if tagInfo.quality then
        tagInfo.quality = Datamine.Utils.GetEnumValueName(Enum.WorldQuestQuality, tagInfo.quality) .. " (" .. tagInfo.quality .. ")";
    end

    return tagInfo;
end

function Datamine.Quest.GetQuestLink(questID, addToChatFrame)
    local questTitle = C_QuestLog.GetTitleForQuestID(questID);
    local link = format("|cffffff00|Hquest:%s:-1:0:0:0|h[%s]|h|r", questID, questTitle);
    if addToChatFrame then
        DEFAULT_CHAT_FRAME:AddMessage(link);
    end

    return link;
end

function Datamine.Quest.GetQuestAdditionalHighlights(questID)
    local uiMapID, worldQuests, worldQuestsElite, dungeons, treasures = C_QuestLog.GetQuestAdditionalHighlights(questID);

    if uiMapID or worldQuests or worldQuestsElite or dungeons or treasures then
        local highlights = {
            UiMapID = uiMapID,
            WorldQuests = worldQuests,
            EliteWorldQuests = worldQuestsElite,
            Dungeons = dungeons,
            Treasures = treasures,
        };
        return highlights;
    end
end

function Datamine.Quest:OnQuestInfoReceived(questID, success)
    if success == nil then
        Print("Query for quest " .. questID .. " failed. Quest does not exist.");
        return;
    elseif success == false then
        Print("Query for quest " .. questID .. " failed. Quest is forbidden or does not exist.");
        return;
    end

    self:PrettyDumpQuestInfo(questID);
end

function Datamine.Quest:PrettyDumpQuestInfo(questID)
    local questInfo = {};

    questInfo.DetailsTheme = C_QuestLog.GetQuestDetailsTheme(questID);
    questInfo.DifficultyLevel = C_QuestLog.GetQuestDifficultyLevel(questID);
    questInfo.Objectives = C_QuestLog.GetQuestObjectives(questID);
    questInfo.TagInfo = self.GetQuestTagInfo(questID);
    questInfo.AccountWide = C_QuestLog.IsAccountQuest(questID);
    questInfo.IsFlaggedComplete = C_QuestLog.IsQuestFlaggedCompleted(questID);
    questInfo.Type = C_QuestLog.GetQuestType(questID);
    questInfo.SuggestedGroupSize = C_QuestLog.GetSuggestedGroupSize(questID);
    questInfo.IsImportant = C_QuestLog.IsImportantQuest(questID);
    questInfo.IsLegendary = C_QuestInfoSystem.GetQuestClassification(questID) == Enum.QuestClassification.Legendary;

    local distanceSq, onContinent = C_QuestLog.GetDistanceSqToQuest(questID);

    questInfo.DistanceSqToQuest = distanceSq;
    questInfo.OnSameContinent = onContinent;

    if #questInfo.Objectives == 0 then
        questInfo.Objectives = "N/A";
    end

    if questInfo.TagInfo then
        local worldQuestType = questInfo.TagInfo.worldQuestType;
        if worldQuestType then
            questInfo.TagInfo.worldQuestType = Datamine.Utils.GetEnumValueName(Enum.QuestTagType, worldQuestType);
        end
    end

    local additionalHighlights = Datamine.Quest.GetQuestAdditionalHighlights(questID);
    if additionalHighlights then
        questInfo.AdditionalHighlights = additionalHighlights;
    end

    questInfo.QuestTitle = C_QuestLog.GetTitleForQuestID(questID);

    Dump("Quest info for quest " .. questID .. " >>", questInfo);
    self.LastRequestedQuestID = nil;
    self.WaitingForQuestInfo = false;
end

function Datamine.Quest:GetOrFetchQuestInfoByID(questID)
    questID = tonumber(questID);
    assert(questID, "GetOrFetchQuestInfoByID requires a valid questID.");

    if self.IsQuestCached(questID) then
        self:PrettyDumpQuestInfo(questID);
        return;
    end

    self.LastRequestedQuestID = questID;
    self.WaitingForQuestInfo = true;
    C_QuestLog.RequestLoadQuestByID(questID);
end

function Datamine.Quest.HandleLink(funcPattern)
    local _, questID = strsplit(Datamine.Links.SEPARATOR, funcPattern);
    Datamine.Quest:GetOrFetchQuestInfoByID(questID)
end

Datamine.Quest:Init();

local helpMessage = "Retrieve information about a quest.";
local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<questID>", helpMessage);

Datamine.Slash:RegisterCommand("quest", function(questID) Datamine.Quest:GetOrFetchQuestInfoByID(tonumber(questID)) end, helpString, moduleName);