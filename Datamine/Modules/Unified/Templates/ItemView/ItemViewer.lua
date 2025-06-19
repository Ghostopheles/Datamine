local L = Datamine.Strings;
local StyleUtil = Datamine.StyleUtil;
local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

local DATA_TYPES = Datamine.Constants.DataTypes;
local DATA_KEYS = {
    [DATA_TYPES.Item] = Datamine.Item.ItemInfoKeys,
    [DATA_TYPES.Spell] = Datamine.Spell.SpellInfoKeys,
    [DATA_TYPES.Achievement] = Datamine.Achievement.AchievementInfoKeys,
};
local DATA_FETCH_FUNCS = {
    [DATA_TYPES.Item] = function(...) Datamine.Item:GetOrFetchItemInfoByID(...) end,
    [DATA_TYPES.Spell] = function(...) Datamine.Spell:GetOrFetchSpellInfoByID(...) end,
    [DATA_TYPES.Achievement] = function(...) Datamine.Achievement:GetAchievementInfoByID(...) end,
};

local ITEM_SLOTS_THAT_CANT_BE_MOGGED = {
    INVTYPE_FINGER,
    INVTYPE_BAG,
    INVTYPE_TRINKET,
    INVTYPE_AMMO,
    INVTYPE_QUIVER,
    INVTYPE_RELIC,
    INVTYPE_THROWN,
    INVTYPE_WEAPONMAINHAND_PET,
    INVTYPE_NON_EQUIP,
    INVTYPE_EQUIPABLESPELL_DEFENSIVE,
    INVTYPE_EQUIPABLESPELL_UTILITY,
    INVTYPE_EQUIPABLESPELL_OFFENSIVE,
    INVTYPE_EQUIPABLESPELL_WEAPON,
};

local SEARCH_HELP_TYPE = {
    HELP = 1,
    FAIL = 2,
    DRAGDROP = 3,
    CREATURE = 4,
};

local SEARCH_HELP_FORMAT = {
    [SEARCH_HELP_TYPE.HELP] = {
        Header = L.EXPLORER_HELP_TEXT_HELP_HEADER,
        Details = L.EXPLORER_HELP_TEXT_HELP,
    },
    [SEARCH_HELP_TYPE.FAIL] = {
        Header = L.EXPLORER_HELP_TEXT_FAIL_HEADER,
        Details = L.EXPLORER_HELP_TEXT_FAIL,
    },
    [SEARCH_HELP_TYPE.DRAGDROP] = {
        Header = L.EXPLORER_HELP_TEXT_DRAGDROP_HEADER,
        Details = L.EXPLORER_HELP_TEXT_DRAGDROP,
    }
};

local SUPPORTED_CURSOR_TYPES = {
    [Enum.UICursorType.Item] = true,
    [Enum.UICursorType.Spell] = true,
    [Enum.UICursorType.PetAction] = true,
};

local function SortByOrderIndex(a, b)
    local idxA = a.OrderIndex;
    local idxB = b.OrderIndex;

    if idxA == idxB then
        return false;
    end

    return idxA < idxB;
end

local UI_MAIN = Datamine.Unified;

------------

DatamineItemViewerMixin = {};

local HooksSetup = false;
function DatamineItemViewerMixin:OnLoad()
    self.ScrollView = CreateScrollBoxListLinearView();

    local function Initializer(frame, data)
        frame:Init(data);
    end

    self.ScrollView:SetElementInitializer("DatamineItemViewerElementTemplate", Initializer);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    local anchorsWithScrollBar = {
        CreateAnchor("TOPLEFT", 4, -45),
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, -13, 4),
    };

    local anchorsWithoutScrollBar = {
        anchorsWithScrollBar[1],
        CreateAnchor("BOTTOMRIGHT", -4, 4);
    };

    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar);

    self:RegisterEvent("GLOBAL_MOUSE_UP");
    self:RegisterEvent("CURSOR_CHANGED");

    Registry:RegisterCallback(Events.SEARCH_BEGIN, self.OnSearchBegin, self);
    Registry:RegisterCallback(Events.SEARCH_RESULT, self.OnSearchResult, self);
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);

    self.DragDropNineSlice.Center:SetAlpha(0.25);
end

function DatamineItemViewerMixin:OnEvent(event, ...)
    if self[event] then
        self[event](self, ...);
    end
end

function DatamineItemViewerMixin:OnShow()
    local textType = self.Failed and SEARCH_HELP_TYPE.FAIL or SEARCH_HELP_TYPE.HELP;
    self:ShowHelpText(textType);
end

function DatamineItemViewerMixin:SetupHooks()
    if HooksSetup then
        return;
    end

    local function Callback(itemLink)
        if not self:ShouldHandleModifiedItemClick() then
            return;
        end

        local item = Datamine.Structures.CreateLink(itemLink);
        local explorer = self:GetParent();
        explorer:SetSearchMode(DATA_TYPES.Item);
        explorer:Search(item.ItemID);
    end

    hooksecurefunc("HandleModifiedItemClick", Callback);
    HooksSetup = true;
end

function DatamineItemViewerMixin:GLOBAL_MOUSE_UP()
    if MouseIsOver(self) and DatamineUnifiedFrame:IsShown() then
        local explorer = self:GetParent();
        local searched = false;

        if CursorHasItem() then
            local item = C_Cursor.GetCursorItem();
            if not item:IsValid() then
                return;
            end

            local itemID = C_Item.GetItemID(item);
            explorer:SetSearchMode(DATA_TYPES.Item);
            explorer:Search(itemID);
            searched = true;
        elseif CursorHasSpell() then
            local spellID;
            local cursorInfo = {GetCursorInfo()};
            local infoType = cursorInfo[1];
            if infoType == "spell" then
                spellID = cursorInfo[4];
            elseif infoType == "petaction" then
                spellID = cursorInfo[2];
            end

            if not spellID then
                return;
            end

            explorer:SetSearchMode(DATA_TYPES.Spell);
            explorer:Search(spellID);
            searched = true;
        end

        if searched then
            self:SetExplorerHighlightShown(false);
            ClearCursor();
        end
    end
end

function DatamineItemViewerMixin:CURSOR_CHANGED(...)
    local _, newCursorType, _ = ...;
    if SUPPORTED_CURSOR_TYPES[newCursorType] then
        self:SetExplorerHighlightShown(true);
    else
        self:SetExplorerHighlightShown(false);
    end
end

function DatamineItemViewerMixin:OnSearchBegin(dataID)
    self:SetLoading(true);
    self.DataID = dataID;

    self.HelpText:Hide();
    self.HelpTextDetails:Hide();

    self.Failed = false;
end

function DatamineItemViewerMixin:OnSearchModeChanged()
    self:RefreshDataProvider();

    self:UpdatePreviewButtonVisiblity();
    self:ShowHelpText(SEARCH_HELP_TYPE.HELP);
end

function DatamineItemViewerMixin:OnSearchResult(dataID)
    local modeText = UI_MAIN.GetExplorerSearchModeName();
    self.Title:SetText(modeText .. " " .. dataID);
    self.Title:Show();

    self:UpdatePreviewButtonVisiblity();
    self:SetLoading(false);
end

function DatamineItemViewerMixin:OnFail()
    self:SetLoading(false);
    self:ShowHelpText(SEARCH_HELP_TYPE.FAIL);

    self.Icon:Hide();
    self.Title:Hide();

    self.Failed = true;
end

function DatamineItemViewerMixin:ShouldShowPreviewButton()
    local searchMode = UI_MAIN.GetExplorerSearchMode();
    if searchMode ~= DATA_TYPES.Item or not self:IsPopulated() then
        return;
    end

    -- we only wanna show the button for things we can actually preview
    -- this means armor (not jewelry), pets, and mounts only

    local itemType = self.CurrentData.ItemClassID;
    local itemSubType = self.CurrentData.ItemSubclassID;
    if (itemType == Enum.ItemClass.Armor) or (itemType == Enum.ItemClass.Weapon) then
        if not tContains(ITEM_SLOTS_THAT_CANT_BE_MOGGED, itemType) then
            return true;
        end
    elseif itemType == Enum.ItemClass.Miscellaneous then
        local miscSubType = Enum.ItemMiscellaneousSubclass;
        if itemSubType == miscSubType.CompanionPet or itemSubType == miscSubType.Mount then
            return true;
        end
    elseif itemType == Enum.ItemClass.Consumable then
        return C_Item.IsDressableItemByID(self.CurrentData.ID);
    end

    return false;
end

function DatamineItemViewerMixin:UpdatePreviewButtonVisiblity()
    self.PreviewButton:SetShown(self:ShouldShowPreviewButton());
end

function DatamineItemViewerMixin:IsPopulated()
    return self.DataProvider and self.DataProvider:GetSize() > 0 or false;
end

function DatamineItemViewerMixin:SetExplorerHighlightShown(shouldShow)
    if self:IsShown() then
        self.DragDropNineSlice:SetShown(shouldShow);

        if shouldShow then
            self:ShowHelpText(SEARCH_HELP_TYPE.DRAGDROP);
        else
            self:ShowHelpText(SEARCH_HELP_TYPE.HELP);
        end
    end
end

function DatamineItemViewerMixin:RefreshDataProvider()
    self.DataProvider = CreateDataProvider();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.Icon:Hide();
    self.Title:Hide();
end

function DatamineItemViewerMixin:ShowHelpText(textType, lowerHeader, lowerDetails)
    if self:IsPopulated() or self:IsLoading() then
        return;
    end

    local headerText = SEARCH_HELP_FORMAT[textType].Header;
    headerText = lowerHeader and headerText:lower() or headerText;

    self.HelpText:SetText(headerText);

    local detailsText = self:GetFormattedHelpDetailsText(textType);
    detailsText = lowerDetails and detailsText:lower() or detailsText;
    self.HelpTextDetails:SetText(detailsText);

    self.HelpText:Show();
    self.HelpTextDetails:Show();
end

function DatamineItemViewerMixin:GetDataKeys()
    local searchMode = UI_MAIN.GetExplorerSearchMode();
    return DATA_KEYS[searchMode];
end

function DatamineItemViewerMixin:GetCurrentData()
    return self.CurrentData;
end

-- 'a' or 'an'?
function DatamineItemViewerMixin:GetFormattedHelpDetailsText(textType)
    local modeText = UI_MAIN.GetExplorerSearchModeName();
    local vowels = {"a", "e", "i", "o", "u"};
    local prefix = tContains(vowels, (modeText:lower():sub(1, 1))) and "an" or "a";
    if modeText then
        local fmt = SEARCH_HELP_FORMAT[textType].Details;
        if textType == SEARCH_HELP_TYPE.FAIL then
            return format(fmt, modeText, UI_MAIN.GetExplorerDataID());
        elseif textType == SEARCH_HELP_TYPE.HELP or textType == SEARCH_HELP_TYPE.DRAGDROP then
            return format(fmt, prefix, modeText);
        elseif textType == SEARCH_HELP_TYPE.CREATURE then
            return fmt;
        end
    end
end

function DatamineItemViewerMixin:Populate(data, dataID)
    self:RefreshDataProvider();

    if not data then
        self:OnFail();
        return;
    end

    local searchMode = UI_MAIN.GetExplorerSearchMode();
    local keys = self:GetDataKeys();
    self.CurrentData = {
        ID = dataID,
    };
    self.DataEntryCount = 0;

    self.DataProvider:SetSortComparator(SortByOrderIndex, false, true);

    if searchMode == DATA_TYPES.Achievement then
        self.Icon.icon:SetTexture(134400);
    end

    local function AddEntry(i, value)
        if value == nil or value == "" then
            value = "N/A";
        elseif type(value) == "boolean" then
            value = tostring(value);
        end

        local key;
        if type(i) == "string" then
            key = i;
        else
            key = keys[i];
        end

        if key == "Hyperlink" and searchMode == DATA_TYPES.Item then
            self.Icon:SetItem(value);
        end

        if key == "Icon" and (searchMode ~= DATA_TYPES.Item) then
            self.Icon.icon:SetTexture(value);
        end

        local valueJustifyH = "RIGHT";
        local maxValueLines = 2;
        local extent = 27;
        if searchMode == DATA_TYPES.Achievement then
            if key == "RewardText" and (value ~= "N/A") then
                extent = 35;
                maxValueLines = 3;
            elseif key == "Description" and (value ~= "N/A") then
                extent = 55;
                maxValueLines = 5;
                valueJustifyH = "CENTER";
            end
        end

        local _data = {
            KeyValue = {
                Key = key,
                Value = value,
                FontStringSettings = {
                    Value = {
                        MaxLines = maxValueLines,
                        JustifyH = valueJustifyH,
                    },
                },
            },
            Template = "DatamineDataFrameElementTemplate",
            IsTopLevel = true,
            ShowChevron = false,
            RequestedExtent = extent,
            OrderIndex = self.DataEntryCount,
        };

        self.CurrentData[key] = value;

        -- skip the "name" entry because Hyperlink covers that
        if _data.KeyValue.Key ~= "Name" then
            self.DataProvider:Insert(_data);
            self.DataEntryCount = self.DataEntryCount + 1;
        end
    end

    if searchMode == DATA_TYPES.Achievement then
        for i, key in pairs(keys) do
            local value = data[key];
            AddEntry(i, value);
        end
    else
        for i, value in pairs(data) do
            AddEntry(i, value);
        end
    end

    self.DataProvider:Sort();
    Registry:TriggerEvent(Events.SEARCH_RESULT, dataID);
end

function DatamineItemViewerMixin:SetLoading(isLoading)
    if isLoading then
        self.ScrollBox:Hide();
        self.Icon:Hide();
        self.Title:Hide();
        self.LoadingSpinner:Show();
        self.Loading = true;
    else
        self.ScrollBox:Show();
        self.Icon:Show();
        self.Title:Show();
        self.LoadingSpinner:Hide();
        self.Loading = false;
    end
end

function DatamineItemViewerMixin:IsLoading()
    return self.Loading;
end

------------

DatamineItemViewerElementMixin = {};
DatamineItemViewerElementMixin.DefaultMaxLines = 2;
DatamineItemViewerElementMixin.DefaultValueTextJustification = "RIGHT";

function DatamineItemViewerElementMixin:Init(data)
    local key = data.KeyValue.Key;
    local value = data.KeyValue.Value;

    if data.KeyValue.FontStringSettings then
        self:ApplyFontStringSettings(data.KeyValue.FontStringSettings);
    end

    local orderIndex = data.OrderIndex;

    self.KeyText:SetText(key);
    self.ValueText:SetText(value);

    if self.KeyText:IsTruncated() then
        self.KeyText:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.KeyText, "ANCHOR_TOPRIGHT");
            GameTooltip:SetText(self.KeyText:GetText(), 1, 1, 1);
            GameTooltip:Show();
        end);

        self.KeyText:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
    end

    if self.ValueText:IsTruncated() then
        self.ValueText:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.ValueText, "ANCHOR_TOPRIGHT");
            GameTooltip:SetText(self.ValueText:GetText(), 1, 1, 1);
            GameTooltip:Show();
        end);

        self.ValueText:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
    end

    if orderIndex % 2 == 0 then
        self.Background:SetAlpha(0.45);
    else
        self.Background:SetAlpha(0.15);
    end

    self.Data = data;
end

function DatamineItemViewerElementMixin:OnHyperlinkClick(link, text, button)
    SetItemRef(link, text, button);
end

function DatamineItemViewerElementMixin:OnHyperlinkEnter(link, _)
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
    GameTooltip:SetHyperlink(link);
    GameTooltip:Show();
end

function DatamineItemViewerElementMixin:OnHyperlinkLeave()
    GameTooltip:Hide();
end

function DatamineItemViewerElementMixin:OnSort()
end

function DatamineItemViewerElementMixin:ApplyFontStringSettings(settings)
    local maxValueLines = settings.Value and settings.Value.MaxLines or self.DefaultMaxLines;
    self.ValueText:SetMaxLines(maxValueLines);

    local valueJustifyH = settings.Value and settings.Value.JustifyH or self.DefaultValueTextJustification;
    self.ValueText:SetJustifyH(valueJustifyH);
end

function DatamineItemViewerElementMixin:GetData()
    return self.Data;
end