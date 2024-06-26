local ITEM_KEY_ORDER = {
    "ItemID",
    "EnchantID",
    "GemIDs",
    "SuffixID",
    "UniqueID",
    "LinkLevel",
    "SpecializationID",
    "ModifiersMask",
    "ItemContext",
    "NumBonusIDs",
    "BonusIDs",
    "NumModifiers",
    "Modifiers",
    "Relic1NumBonusIDs",
    "Relic1BonusIDs",
    "Relic2NumBonusIDs",
    "Relic2BonusIDs",
    "Relic3NumBonusIDs",
    "Relic3BonusIDs",
    "CrafterGUID",
    "ExtraEnchantID",
};

local DEFAULTS = {
    ItemID = nil,
    EnchantID = nil,
    GemIDs = {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil,
    },
    SuffixID = nil,
    UniqueID = nil,
    LinkLevel = nil,
    SpecializationID = nil,
    ModifiersMask = 0,
    ItemContext = nil,
    NumBonusIDs = 0,
    BonusIDs = {},
    NumModifiers = 0,
    Modifiers = {},
    Relic1NumBonusIDs = 0,
    Relic1BonusIDs = {},
    Relic2NumBonusIDs = 0,
    Relic2BonusIDs = {},
    Relic3NumBonusIDs = 0,
    Relic3BonusIDs = {},
    CrafterGUID = nil,
    ExtraEnchantID = nil,
};

local ITEM_LINK_NUM_GEM_SLOTS = 4;

local ItemLinkMixin = {};

function ItemLinkMixin:Init(itemLink)
    local linkType, linkData, displayText = LinkUtil.ExtractLink(itemLink);
    assert(linkType == "item", "Invalid link type");

    self.GemIDs = {};
    self.BonusIDs = {};
    self.Modifiers = {};
    self.Relic1BonusIDs = {};
    self.Relic2BonusIDs = {};
    self.Relic3BonusIDs = {};

    local data = strsplittable(":", linkData);

    local i = 1;
    for _, key in pairs(ITEM_KEY_ORDER) do
        local default = DEFAULTS[key];
        local value = data[i];
        if value == "" then
            value = default;
        end

        if key == "GemIDs" then
            for j = 1, ITEM_LINK_NUM_GEM_SLOTS do
                local gemID = data[i];
                self.GemIDs[j] = tonumber(gemID);
                i = i + 1;
            end
        elseif key == "BonusIDs" then
            if self.NumBonusIDs > 0 then
                for j = 1, self.NumBonusIDs do
                    self.BonusIDs[j] = tonumber(data[i]);
                    i = i + 1;
                end
            end
        elseif key == "Modifiers" then
            if self.NumModifiers > 0 then
                for j = 1, self.NumModifiers do
                    local modifier = {
                        Type = tonumber(data[i]),
                        Value = tonumber(data[i + 1]),
                    };
                    self.Modifiers[j] = modifier;
                    i = i + 2;
                end
            end
        elseif key == "Relic1BonusIDs" then
            if self.Relic1NumBonusIDs > 0 then
                for j = 1, self.Relic1NumBonusIDs do
                    self.Relic1BonusIDs[j] = tonumber(data[i]);
                    i = i + 1;
                end
            end
        elseif key == "Relic2BonusIDs" then
            if self.Relic2NumBonusIDs > 0 then
                for j = 1, self.Relic2NumBonusIDs do
                    self.Relic2BonusIDs[j] = tonumber(data[i]);
                    i = i + 1;
                end
            end
        elseif key == "Relic3BonusIDs" then
            if self.Relic3NumBonusIDs > 0 then
                for j = 1, self.Relic3NumBonusIDs do
                    self.Relic3BonusIDs[j] = tonumber(data[i]);
                    i = i + 1;
                end
            end
        else
            if key ~= "CrafterGUID" then
                value = tonumber(value);
            end

            self[key] = value;
            i = i + 1;
        end
    end

    self.DisplayText = displayText;
    self.Initialized = true;
end

------------

local ACHIEVEMENT_KEYS = {
    "ID",
    "PlayerGUID",
    "Completed",
    "Month",
    "Day",
    "Year",
    "Criteria1",
    "Criteria2",
    "Criteria3",
    "Criteria4"
};

local AchievementLinkMixin = {};

function AchievementLinkMixin:Init(linkData)
    local data = strsplittable(":", linkData);

    local i = 2;
    for _, key in pairs(ACHIEVEMENT_KEYS) do
        self[key] = data[i];
        i = i + 1;
    end

    self.Initialized = true;
end

------------

local BATTLEPET_KEYS = {
    "SpeciesID",
    "Level",
    "BreedQuality",
    "MaxHealth",
    "Power",
    "Speed",
    "BattlePetID",
    "DisplayID"
};

local BattlePetLinkMixin = {};

function BattlePetLinkMixin:Init(battlePetLink)
    local linkType, linkData, displayText = LinkUtil.ExtractLink(battlePetLink);
    assert(linkType == "battlepet", "Invalid link type");

    local data = strsplittable(":", linkData);

    local i = 1;
    for _, key in pairs(BATTLEPET_KEYS) do
        self[key] = data[i];
        i = i + 1;
    end

    self.DisplayText = displayText;
    self.Initialized = true;
end

------------

local KEYSTONE_KEYS = {
    "ItemID",
    "ChallengeModeID",
    "Level",
    "Affixes"
};

local KeystoneLinkMixin = {};

function KeystoneLinkMixin:Init(keystoneLink)
    local linkType, linkData, displayText = LinkUtil.ExtractLink(keystoneLink);
    assert(linkType == "keystone", "Invalid link type");

    local data = strsplittable(":", linkData);

    self.Affixes = {};

    local i = 1;
    for _, key in pairs(KEYSTONE_KEYS) do
        if key == "Affixes" then
            for x = 1, 4 do
                tinsert(self.Affixes, data[i + x]);
            end
        else
            self[key] = data[i];
            i = i + 1;
        end
    end

    self.IsKeystone = true;
    self.DisplayText = displayText;
    self.Initialized = true;
end

------------

Datamine.Structures = {};

function Datamine.Structures.CreateItemLink(itemLink)
    local obj = CreateAndInitFromMixin(ItemLinkMixin, itemLink);
    if obj.Initialized then
        return obj;
    end
end

function Datamine.Structures.CreateAchievementLink(achievementLink)
    local obj = CreateAndInitFromMixin(AchievementLinkMixin, achievementLink);
    if obj.Initialized then
        return obj;
    end
end

function Datamine.Structures.CreateBattlePetLink(battlePetLink)
    local obj = CreateAndInitFromMixin(BattlePetLinkMixin, battlePetLink);
    if obj.Initialized then
        return obj;
    end
end

function Datamine.Structures.CreateKeystoneLink(keystoneLink)
    local obj = CreateAndInitFromMixin(KeystoneLinkMixin, keystoneLink);
    if obj.Initialized then
        return obj;
    end
end

local Constructors = {
    item = Datamine.Structures.CreateItemLink,
    keystone = Datamine.Structures.CreateKeystoneLink,
    achievement = Datamine.Structures.CreateAchievementLink,
    battlepet = Datamine.Structures.CreateBattlePetLink,
};

function Datamine.Structures.CreateLink(link)
    local linkType = LinkUtil.ExtractLink(link);
    local constructor = Constructors[linkType];
    if constructor then
        return constructor(link);
    end
end