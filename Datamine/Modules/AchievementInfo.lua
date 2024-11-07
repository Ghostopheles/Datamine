Datamine.Achievement = {};

local moduleName = "AchievementInfo";

local AchievementInfoKeys = {
    "ID",
    "Name",
    "Points",
    "IsCompleted",
    "Month",
    "Day",
    "Year",
    "Description",
    "Flags",
    "Icon",
    "RewardText",
    "IsGuildAchievement",
    "EarnedByThisCharacter",
    "EarnedBy",
    "IsStatistic",
    "CategoryID",
    "Hyperlink",
};
Datamine.Achievement.AchievementInfoKeys = AchievementInfoKeys;

local CriteriaInfoKeys = {
    "Name",
    "Type",
    "IsCompleted",
    "Quanity",
    "ReqQuantity",
    "CharacterName",
    "Flags",
    "AssetID",
    "QuantityString",
    "CriteriaID",
    "Eligible",
    "Duration",
    "Elapsed"
};
Datamine.Achievement.CriteriaInfoKeys = CriteriaInfoKeys;

local Print = function(...)
    Datamine.Utils.Print(moduleName, ...);
end

local function CreateTable(keys, data)
    local outTable = {};
    for i, key in ipairs(keys) do
        outTable[key] = data[i];
    end

    return outTable;
end

-- achievement info

function Datamine.Achievement:GetAchievementInfoByID(achievementID, callback)
    local data;
    local achievementInfo = {GetAchievementInfo(achievementID)};

    if #achievementInfo > 0 then
        tinsert(achievementInfo, GetAchievementCategory(achievementID));
        tinsert(achievementInfo, GetAchievementLink(achievementID));

        data = CreateTable(AchievementInfoKeys, achievementInfo);
    end

    if callback and type(callback) == "function" then
        callback(data);
    end

    return data;
end

function Datamine.Achievement:GetAchievementInfoByIndex(categoryID, index)
    local achievementInfo = {GetAchievementInfo(categoryID, index)}
    local id, _ = select(1, achievementInfo);
    tinsert(achievementInfo, GetAchievementCategory(id));
    tinsert(achievementInfo, GetAchievementLink(id));

    return CreateTable(AchievementInfoKeys, achievementInfo);
end

-- criteria

function Datamine.Achievement:GetAchievementCriteriaInfoByID(achievementID, criteriaID)
    return CreateTable(CriteriaInfoKeys, {GetAchievementCriteriaInfoByID(achievementID, criteriaID)});
end

function Datamine.Achievement:GetAchievementCriteriaInfoByIndex(achievementID, index)
    return CreateTable(CriteriaInfoKeys, {GetAchievementCriteriaInfo(achievementID, index)});
end