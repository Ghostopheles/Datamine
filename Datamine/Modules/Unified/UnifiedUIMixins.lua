local L = Datamine.Strings;
local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

local DataTypes = Datamine.Constants.DataTypes;
local DataKeys = {
    [DataTypes.Item] = Datamine.Item.ItemInfoKeys,
    [DataTypes.Spell] = Datamine.Spell.SpellInfoKeys,
    [DataTypes.Achievement] = Datamine.Achievement.AchievementInfoKeys,
};
local FetchFuncs = {
    [DataTypes.Item] = function(...) Datamine.Item:GetOrFetchItemInfoByID(...) end,
    [DataTypes.Spell] = function(...) Datamine.Spell:GetOrFetchSpellInfoByID(...) end,
    [DataTypes.Achievement] = function(...) Datamine.Achievement:GetAchievementInfoByID(...) end,
};

local UI_MAIN = Datamine.Unified;

-------------

DatamineCustomAtlasMixin = {};

function DatamineCustomAtlasMixin:OnLoad_Base()
    if self.FileName and not self.FilePath then
        self.FilePath = Datamine.CustomAtlas:GetAtlasFilePath(self.FileName);
    elseif self.FilePath and not self.FileName then
        self.FileName = Datamine.CustomAtlas:GetAtlasFileName(self.FilePath);
    else
        return;
    end

    self:SetTexture(self.FilePath);
    self:ApplyAtlas();
end

function DatamineCustomAtlasMixin:ApplyAtlas()
    local atlasInfo = Datamine.CustomAtlas:GetAtlasInfo(self.FileName, self.AtlasName);
    if not atlasInfo then
        return;
    end

    self:SetTexCoord(atlasInfo.left, atlasInfo.right, atlasInfo.top, atlasInfo.bottom);

    if self.UseAtlasSize then
        self:SetSize(atlasInfo.width, atlasInfo.height);
    end
end

function DatamineCustomAtlasMixin:SetCustomAtlas(atlasName)
    self.AtlasName = atlasName;
    self:ApplyAtlas();
end

-------------

DatamineTooltipButtonMixin = {};

function DatamineTooltipButtonMixin:OnEnter_Base()
    if not self.TooltipText and not self.GetTooltipText then
        return;
    end

    if self.TooltipDeferShowFor then
        local showFunc = function()
            if MouseIsOver(self) then
                self:ShowTooltip();
            end
        end
        C_Timer.After(self.TooltipDeferShowFor, showFunc);
    else
        self:ShowTooltip();
    end
end

function DatamineTooltipButtonMixin:OnLeave_Base()
    self:HideTooltip();
end

function DatamineTooltipButtonMixin:ShowTooltip()
    local text = self.TooltipText or self:GetTooltipText();
    local anchor = self.TooltipAnchorPoint or "ANCHOR_TOP";
    local offsetX = self.TooltipOffsetX or 0;
    local offsetY = self.TooltipOffsetY or 0;
    local textColor = self.TooltipTextColor or CreateColor(1, 1, 1, 1);

    GameTooltip:SetOwner(self, anchor, offsetX, offsetY);
    GameTooltip:SetText(text, textColor.r, textColor.g, textColor.b, textColor.a, self.TooltipWrapText);
    GameTooltip:Show();
end

function DatamineTooltipButtonMixin:HideTooltip()
    GameTooltip:Hide();
end

-------------

DatamineCloseButtonMixin = {};

function DatamineCloseButtonMixin:OnClick()
    local parent = self:GetParent();
    if parent then
        local continueHide = true;
        if parent.OnCloseCallback then
            continueHide = parent.OnCloseCallback(parent);
        end

        if continueHide then
            parent:Hide();
        end
    end
end

-------------

DatamineTextButtonMixin = {};

function DatamineTextButtonMixin:SetText(text)
    self.Text:SetText(text)
end

-------------

DatamineLightGray = CreateColor(0.25, 0.25, 0.25, 1);
DatamineMediumGray = CreateColor(0.18, 0.18, 0.18, 1);
DatamineDarkGray = CreateColor(0.1, 0.1, 0.1, 1);
DatamineDefaultBackgroundColor = DatamineDarkGray;

-------------

DatamineColorBackgroundMixin = {};

function DatamineColorBackgroundMixin:OnLoad()
    local color = _G[self.ColorName] or DatamineDefaultBackgroundColor;
    self:SetColorTexture(color.r, color.g, color.b, color.a);
end

-------------

DatamineTitleContainerMixin = {};

function DatamineTitleContainerMixin:OnLoad()
    if self.TitleText then
        self:SetText(self.TitleText);
    end
end

function DatamineTitleContainerMixin:SetText(text)
    self.Text:SetText(text);
end

-------------

DatamineMovableTitleContainerMixin = {};

function DatamineMovableTitleContainerMixin:OnMouseDown()
    self:GetParent():StartMoving();
end

function DatamineMovableTitleContainerMixin:OnMouseUp()
    self:GetParent():StopMovingOrSizing();
end

-------------

DatamineToolbarMixin = {};

function DatamineToolbarMixin:OnLoad()
    self.Buttons = {};
end

function DatamineToolbarMixin:AddButton(atlasOrTexturePath, callback, tooltipText)
    local template = tooltipText and "DatamineTooltipButtonTemplate" or "DatamineGenericButtonTemplate";
    local button = CreateFrame("Button", nil, self, template);

    local isAtlas = not strmatch(atlasOrTexturePath:lower(), "interface/addons/");

    local anchorPoint;
    local relativePoint;
    if #self.Buttons == 0 then
        anchorPoint = self;
        relativePoint = "TOPLEFT";
    else
        anchorPoint = self.Buttons[#self.Buttons];
        relativePoint = "TOPRIGHT";
    end

    local xOffset = 5;
    local yOffset = 0;

    button:SetPoint("TOPLEFT", anchorPoint, relativePoint, xOffset, yOffset);
    button:SetSize(30, 30);

    if tooltipText then
        button.TooltipText = tooltipText;
    end

    if isAtlas then
        button.Icon = Datamine.CustomAtlas:CreateCustomAtlasTexture("Toolbar.png", atlasOrTexturePath, true, button);
        button.Icon:ClearAllPoints();
        button.Icon:SetPoint("TOPLEFT");
    else
        button.Icon = button:CreateTexture(nil, "ARTWORK");
        button.Icon:SetTexture(atlasOrTexturePath, nil, nil, "TRILINEAR");
        button.Icon:SetSize(22, 22);
        button.Icon:SetPoint("CENTER");
    end

    button.Icon:Show();

    if callback then
        button:SetScript("OnClick", callback);
    end

    tinsert(self.Buttons, button);

    return button;
end

-------------

DatamineSearchBoxMixin = {};

function DatamineSearchBoxMixin:OnEnterPressed()
    local value = self:GetNumber();
    local searchFunc = self:GetParent().Search;
    if searchFunc then
        searchFunc(self:GetParent(), value);
    end
end

-------------

DatamineDataFrameElementMixin = {};
DatamineDataFrameElementMixin.DefaultMaxLines = 2;
DatamineDataFrameElementMixin.DefaultValueTextJustification = "RIGHT";

function DatamineDataFrameElementMixin:Init(node)
    local data = node:GetData();
    local key = data.KeyValue.Key;
    local value = data.KeyValue.Value;

    if data.KeyValue.FontStringSettings then
        self:ApplyFontStringSettings(data.KeyValue.FontStringSettings);
    end

    local orderIndex = data.OrderIndex;

    if Datamine.Debug.IsDebugEnabled() then
        local dbgKey = format("[%d] %s:", orderIndex, key);
        self.KeyText:SetText(dbgKey);
    else
        self.KeyText:SetText(key);
    end
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
end

function DatamineDataFrameElementMixin:OnHyperlinkClick(link, text, button)
    SetItemRef(link, text, button);
end

function DatamineDataFrameElementMixin:OnHyperlinkEnter(link, _)
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
    GameTooltip:SetHyperlink(link);
    GameTooltip:Show();
end

function DatamineDataFrameElementMixin:OnHyperlinkLeave()
    GameTooltip:Hide();
end

function DatamineDataFrameElementMixin:OnSort()
end

function DatamineDataFrameElementMixin:ApplyFontStringSettings(settings)
    local maxValueLines = settings.Value and settings.Value.MaxLines or self.DefaultMaxLines;
    self.ValueText:SetMaxLines(maxValueLines);

    local valueJustifyH = settings.Value and settings.Value.JustifyH or self.DefaultValueTextJustification;
    self.ValueText:SetJustifyH(valueJustifyH);
end

-------------

DatamineScrollableDataFrameMixin = {};

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
    },
    [SEARCH_HELP_TYPE.CREATURE] = {
        Header = L.EXPLORER_HELP_TEXT_CREATURE_HEADER,
        Details = L.EXPLORER_HELP_TEXT_CREATURE,
    },
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

local function SortByOrderIndex(a, b)
    local idxA = a:GetData().OrderIndex;
    local idxB = b:GetData().OrderIndex;

    if idxA == idxB then
        return false;
    end

    return idxA < idxB;
end

local HooksSetup = false;
function DatamineScrollableDataFrameMixin:OnLoad()
    -- override base visibility behavior because it's unholy
    local anchorsWithScrollBar = {
        CreateAnchor("TOPLEFT", 4, -45),
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, -13, 4),
    };

    local anchorsWithoutScrollBar = {
        anchorsWithScrollBar[1],
        CreateAnchor("BOTTOMRIGHT", -4, 4);
    };

    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar);

    Registry:RegisterCallback(Events.SEARCH_BEGIN, self.OnSearchBegin, self);
    Registry:RegisterCallback(Events.SEARCH_RESULT, self.OnSearchResult, self);
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);

    self.DataEntryCount = 0;

    self:RegisterEvent("GLOBAL_MOUSE_UP");
    self:RegisterEvent("CURSOR_CHANGED");
    self:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...);
        end
    end);

    self.DragDropNineSlice.Center:SetAlpha(0.25);
    self.Background_Base:Hide();

    self:SetupHooks();
end

function DatamineScrollableDataFrameMixin:OnShow()
    local textType = self.Failed and SEARCH_HELP_TYPE.FAIL or SEARCH_HELP_TYPE.HELP;
    self:ShowHelpText(textType);
end

function DatamineScrollableDataFrameMixin:ShouldHandleModifiedItemClick()
    if not self:IsVisible() or not self:IsShown() then
        return false;
    end

    local workspace = UI_MAIN.GetUI().Workspace;
    if workspace:GetMode() ~= workspace.Modes.DEFAULT then
        return false;
    end

    if not Datamine.Settings.IsExplorerModifierDown() then
        return false;
    end

    return true;
end

function DatamineScrollableDataFrameMixin:SetupHooks()
    if HooksSetup then
        return;
    end

    local function Callback(itemLink)
        if not self:ShouldHandleModifiedItemClick() then
            return;
        end

        local item = Datamine.Structures.CreateLink(itemLink);
        local explorer = self:GetParent();
        explorer:SetSearchMode(DataTypes.Item);
        explorer:Search(item.ItemID);
    end

    hooksecurefunc("HandleModifiedItemClick", Callback);
    HooksSetup = true;
end

function DatamineScrollableDataFrameMixin:GLOBAL_MOUSE_UP()
    if MouseIsOver(self) and DatamineUnifiedFrame:IsShown() then
        local explorer = self:GetParent();
        local searched = false;

        if CursorHasItem() then
            local item = C_Cursor.GetCursorItem();
            if not item:IsValid() then
                return;
            end

            local itemID = C_Item.GetItemID(item);
            explorer:SetSearchMode(DataTypes.Item);
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

            explorer:SetSearchMode(DataTypes.Spell);
            explorer:Search(spellID);
            searched = true;
        end

        if searched then
            self:SetExplorerHighlightShown(false);
            ClearCursor();
        end
    end
end

local SUPPORTED_CURSOR_TYPES = {
    [Enum.UICursorType.Item] = true,
    [Enum.UICursorType.Spell] = true,
    [Enum.UICursorType.PetAction] = true,
};

function DatamineScrollableDataFrameMixin:CURSOR_CHANGED(...)
    local _, newCursorType, _ = ...;
    if SUPPORTED_CURSOR_TYPES[newCursorType] then
        self:SetExplorerHighlightShown(true);
    else
        self:SetExplorerHighlightShown(false);
    end
end

function DatamineScrollableDataFrameMixin:OnSearchBegin(dataID)
    self:SetLoading(true);
    self.DataID = dataID;

    self.HelpText:Hide();
    self.HelpTextDetails:Hide();

    self.Failed = false;
end

function DatamineScrollableDataFrameMixin:OnSearchModeChanged()
    self:RefreshDataProvider();

    self:UpdatePreviewButtonVisiblity();
    self:ShowHelpText(SEARCH_HELP_TYPE.HELP);
end

function DatamineScrollableDataFrameMixin:OnSearchResult(dataID)
    local modeText = UI_MAIN.GetExplorerSearchModeName();
    self.Title:SetText(modeText .. " " .. dataID);
    self.Title:Show();

    self:UpdatePreviewButtonVisiblity();
    self:SetLoading(false);
end

function DatamineScrollableDataFrameMixin:OnFail()
    self:SetLoading(false);
    self:ShowHelpText(SEARCH_HELP_TYPE.FAIL);

    self.Icon:Hide();
    self.Title:Hide();

    self.Failed = true;
end

function DatamineScrollableDataFrameMixin:ShouldShowPreviewButton()
    local searchMode = UI_MAIN.GetExplorerSearchMode();
    if searchMode ~= DataTypes.Item or not self:IsPopulated() then
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

function DatamineScrollableDataFrameMixin:UpdatePreviewButtonVisiblity()
    self.PreviewButton:SetShown(self:ShouldShowPreviewButton());
end

function DatamineScrollableDataFrameMixin:IsPopulated()
    return self.DataProvider:GetSize(false) > 0;
end

function DatamineScrollableDataFrameMixin:SetExplorerHighlightShown(shouldShow)
    if self:IsShown() then
        self.DragDropNineSlice:SetShown(shouldShow);

        if shouldShow then
            self:ShowHelpText(SEARCH_HELP_TYPE.DRAGDROP);
        else
            self:ShowHelpText(SEARCH_HELP_TYPE.HELP);
        end
    end
end

function DatamineScrollableDataFrameMixin:RefreshDataProvider()
    self.ScrollView:FlushDataProvider();
    self.Icon:Hide();
    self.Title:Hide();
end

function DatamineScrollableDataFrameMixin:ShowHelpText(textType, lowerHeader, lowerDetails)
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

function DatamineScrollableDataFrameMixin:GetDataKeys()
    local searchMode = UI_MAIN.GetExplorerSearchMode();
    return DataKeys[searchMode];
end

function DatamineScrollableDataFrameMixin:GetCurrentData()
    return self.CurrentData;
end

-- 'a' or 'an'?
function DatamineScrollableDataFrameMixin:GetFormattedHelpDetailsText(textType)
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

function DatamineScrollableDataFrameMixin:Populate(data, dataID)
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

    if searchMode == DataTypes.Achievement then
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

        if key == "Hyperlink" and searchMode == DataTypes.Item then
            self.Icon:SetItem(value);
        end

        if key == "Icon" and (searchMode ~= DataTypes.Item) then
            self.Icon.icon:SetTexture(value);
        end

        local valueJustifyH = "RIGHT";
        local maxValueLines = 2;
        local extent = 27;
        if searchMode == DataTypes.Achievement then
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

    if searchMode == DataTypes.Achievement then
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

function DatamineScrollableDataFrameMixin:SetLoading(isLoading)
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

function DatamineScrollableDataFrameMixin:IsLoading()
    return self.Loading;
end

-------------

DataminePreviewButtonMixin = {};

function DataminePreviewButtonMixin:OnLoad()
    self.TooltipAnchorPoint = "ANCHOR_TOPLEFT";
end

function DataminePreviewButtonMixin:OnClick()
    local dataID = UI_MAIN.GetExplorerDataID();
    local searchMode = UI_MAIN.GetExplorerSearchMode();
    local data = UI_MAIN.GetExplorerData();

    if searchMode ~= DataTypes.Item then
        return;
    end

    if data.IsDressable == "true" then
        local transmogSetID = C_Item.GetItemLearnTransmogSet(dataID);
        if transmogSetID then
            self:TryOnTransmogSet(transmogSetID);
        else
            self:TryOnItem(dataID);
        end
    elseif data.ItemSubType == "Companion Pets" then
        self:ViewCompanion(dataID);
    elseif data.ItemSubType == "Mount" then
        self:ViewMount(dataID);
    end
end

function DataminePreviewButtonMixin:GetTooltipText()
    local fmt = "View %s";
    local searchModeText = UI_MAIN.GetExplorerSearchModeName();
    return format(fmt, searchModeText);
end

function DataminePreviewButtonMixin:GetModelScene()
    return UI_MAIN.GetModelView().ModelScene;
end

function DataminePreviewButtonMixin:TryOnTransmogSet(id)
    local scene = self:GetModelScene();
    scene:TryOnByTransmogSetID(id);
end

function DataminePreviewButtonMixin:TryOnItem(id)
    local scene = self:GetModelScene();
    scene:TryOnByItemID(id);
end

function DataminePreviewButtonMixin:ViewCompanion(id)
    local scene = self:GetModelScene();
    local _, _, _, _, _, _, _, _, _, _, _, displayID, _ = C_PetJournal.GetPetInfoByItemID(id);
    scene:ViewPet(displayID);
end

function DataminePreviewButtonMixin:ViewMount(id)
    local scene = self:GetModelScene();
    local mountID = C_MountJournal.GetMountFromItem(id);

    if not mountID then return end;
    scene:ViewMount(mountID);
end

-------------

DatamineUnifiedExplorerTabMixin = {};

local DEFAULT_SEARCH_MODE = UI_MAIN.GetExplorerDefaultSearchMode();

function DatamineUnifiedExplorerTabMixin:OnLoad()
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);
    self:SetSearchMode(DEFAULT_SEARCH_MODE);

    local function SearchModeMenu(button)
        local elements = {};
        for k, v in pairs(DataTypes) do
            local element = {
                Text = k,
                Callback = function() self:SetSearchMode(v) end,
            };
            tinsert(elements, element);
        end

        UI_MAIN.ShowContextMenu(elements, button);
    end

    local modeButton = self.Header.SearchModeButton;
    modeButton:SetScript("OnClick", SearchModeMenu);
end

function DatamineUnifiedExplorerTabMixin:GetSearchMode()
    return self.SearchMode;
end

function DatamineUnifiedExplorerTabMixin:SetCurrentDataID(number)
    self.CurrentDataID = number;
end

function DatamineUnifiedExplorerTabMixin:GetCurrentDataID()
    return self.CurrentDataID;
end

function DatamineUnifiedExplorerTabMixin:GetDataFetchFunc()
    return FetchFuncs[self.SearchMode];
end

function DatamineUnifiedExplorerTabMixin:SetSearchMode(searchMode)
    if not tContains(DataTypes, searchMode) then
        return;
    end

    if searchMode == self.SearchMode then
        return;
    end

    self.SearchMode = searchMode;
    Registry:TriggerEvent(Events.SEARCH_MODE_CHANGED);
end

function DatamineUnifiedExplorerTabMixin:OnSearchModeChanged()
    local searchModeStr = Datamine.Utils.GetEnumValueName(DataTypes, self:GetSearchMode());
    self.SearchBox.Instructions:SetText("Enter " .. searchModeStr .. "ID...");
    self.SearchBox:SetText("");
end

function DatamineUnifiedExplorerTabMixin:Search(number)
    Registry:TriggerEvent(Events.SEARCH_BEGIN, number);
    self:SetCurrentDataID(number);
    self:GetDataFetchFunc()(number, function(data) self.DataFrame:Populate(data, number) end);
end

-------------

DatamineUnifiedModelViewTabMixin = {};
DatamineUnifiedModelViewTabMixin.Modes = {
    PLAYERMODEL = 1,
    SCENE = 2,
};

function DatamineUnifiedModelViewTabMixin:OnLoad()
end

function DatamineUnifiedModelViewTabMixin:OnShow()
end

function DatamineUnifiedModelViewTabMixin:OnViewModeChanged(viewMode)
    if viewMode == self.Modes.PLAYERMODEL then
        self.ModelScene:Hide();
        self.PlayerModel:Show();
    elseif viewMode == self.Modes.SCENE then
        self.PlayerModel:Hide();
        self.ModelScene:Show();
    end

    self.ViewMode = viewMode;
end

function DatamineUnifiedModelViewTabMixin:SetViewMode(viewMode)
    self.ViewMode = viewMode;
    Registry:TriggerEvent(Events.MODEL_VIEW_MODE_CHANGED, self.ViewMode);
end

-------------

DatamineWorkspaceMixin = {};
DatamineWorkspaceMixin.Modes = {
    DEFAULT = 1,
    CODE = 2,
    STORAGE = 3,
    MOVIE = 4,
    MAPS = 5,
    CREATURE = 6,
};

function DatamineWorkspaceMixin:OnLoad()
    self.ModeFrames = {
        [self.Modes.DEFAULT] = {
            self.ExplorerTab,
            self.ModelViewTab,
            self.DetailsTab,
        },
        [self.Modes.MOVIE] = {
            self.TheaterTab,
        },
        [self.Modes.MAPS] = {
            self.MapViewTab,
        },
        [self.Modes.STORAGE] = {
            self.StorageTab,
        },
        [self.Modes.CREATURE] = {
            self.CreatureViewTab,
        },
    };

    Registry:RegisterCallback(Events.WORKSPACE_MODE_CHANGED, self.OnModeChanged, self);
    self:SetMode(self.Modes.DEFAULT);

    local toolbar = self:GetParent().Toolbar;
    do
        local tooltipText = L.WORKSPACE_MODE_EXPLORER;
        local cb = function() self:SetMode(self.Modes.DEFAULT); end;
        toolbar:AddButton(UI_MAIN.GetIconPath("home"), cb, tooltipText);
    end

    do
        local tooltipText = L.WORKSPACE_MODE_MOVIE;
        local cb = function() self:SetMode(self.Modes.MOVIE); end;
        toolbar:AddButton(UI_MAIN.GetIconPath("play"), cb, tooltipText);
    end

    do
        local tooltipText = L.WORKSPACE_MODE_MAPS;
        local cb = function() self:SetMode(self.Modes.MAPS); end;
        toolbar:AddButton(UI_MAIN.GetIconPath("map-marker"), cb, tooltipText);
    end

    do
        local tooltipText = L.WORKSPACE_MODE_STORAGE;
        local cb = function() self:SetMode(self.Modes.CREATURE); end;
        toolbar:AddButton(UI_MAIN.GetIconPath("database"), cb, tooltipText);
    end
end

function DatamineWorkspaceMixin:OnModeChanged()
    local newFrames = self.ModeFrames[self:GetMode()];

    if not newFrames then
        return;
    end

    self:HideAllChildren();
    for _, frame in pairs(newFrames) do
        frame:Show();
    end
end

function DatamineWorkspaceMixin:SetMode(newMode)
    if newMode == self.Mode or not self.ModeFrames[newMode] then
        return;
    end

    self.Mode = newMode;
    Registry:TriggerEvent(Events.WORKSPACE_MODE_CHANGED, newMode);
end

function DatamineWorkspaceMixin:GetMode()
    return self.Mode;
end

function DatamineWorkspaceMixin:HideAllChildren()
    for _, frame in pairs({self:GetChildren()}) do
        frame:Hide();
    end
end

-------------

local UI_SCALE = 0.55;
local RESIZE_HINT_POPUP_DELAY = 0.45;

DatamineUnifiedFrameMixin = {};

function DatamineUnifiedFrameMixin:OnLoad()
    self.TitleContainer.Text:SetText(L.ADDON_TITLE);

    Registry:RegisterCallback(Events.WORKSPACE_MODE_CHANGED, self.OnWorkspaceModeChanged, self);
    Registry:RegisterCallback(Events.UI_RESIZE_START, self.OnResizeStart, self);
    Registry:RegisterCallback(Events.UI_RESIZE_END, self.OnResizeEnd, self);
    Registry:RegisterCallback(Events.UI_SIZE_RESET, self.OnResetSize, self);
    EventUtil.ContinueOnAddOnLoaded("Datamine", function() self:OnAddonLoaded() end);

    tinsert(UISpecialFrames, self:GetName());

    self:SetupResizeButton();
    self:SetupAnimations();
end

function DatamineUnifiedFrameMixin:OnShow()
end

function DatamineUnifiedFrameMixin:OnHide()
    Registry:TriggerEvent(Events.UI_MAIN_HIDE);
end

function DatamineUnifiedFrameMixin:OnAddonLoaded()
    -- check if we have a saved frame size and set the size accordingly
    local width, height;
    if not Datamine.Settings.HasSavedFrameSize() then
        width, height = self:CalculateDefaultFrameSize();
        Datamine.Settings.SetSavedFrameSize(width, height);
    else
        width, height = Datamine.Settings.GetSavedFrameSize();
    end
    self:SetSize(width, height);
end

function DatamineUnifiedFrameMixin:OnResizeStart()
    self.ResizeBorder:Show();
    self:StartSizing();
end

function DatamineUnifiedFrameMixin:OnResizeEnd()
    self.ResizeBorder:Hide();
    self:StopMovingOrSizing();

    local screenSize = C_VideoOptions.GetCurrentGameWindowSize();
    local w, h = self:GetSize();
    w = Clamp(w, 10, screenSize.x);
    h = Clamp(h, 10, screenSize.y);

    Datamine.Settings.SetSavedFrameSize(self:GetSize());
end

function DatamineUnifiedFrameMixin:OnResetSize()
    local w, h = self:CalculateDefaultFrameSize();
    Datamine.Settings.SetSavedFrameSize(w, h);
    self:SetSize(w, h);
    self:ClearAllPoints();
    self:SetPoint("CENTER");
end

function DatamineUnifiedFrameMixin:OnWorkspaceModeChanged(newMode)
end

function DatamineUnifiedFrameMixin:CalculateDefaultFrameSize()
    local screenSize = C_VideoOptions.GetCurrentGameWindowSize();
    screenSize:ScaleBy(UI_SCALE);
    return screenSize:GetXY();
end

function DatamineUnifiedFrameMixin:SetupResizeButton()
    self.ResizeButton:SetScript("OnMouseDown", function()
        Registry:TriggerEvent(Events.UI_RESIZE_START);
    end);

    self.ResizeButton:SetScript("OnMouseUp", function()
        Registry:TriggerEvent(Events.UI_RESIZE_END);
    end);

    self.ResizeButton:SetScript("OnDoubleClick", function()
        Registry:TriggerEvent(Events.UI_SIZE_RESET);
    end);

    local timer;
    self.ResizeButton:SetScript("OnEnter", function()
        timer = C_Timer.NewTimer(RESIZE_HINT_POPUP_DELAY, function()
            GameTooltip:SetOwner(self.ResizeButton, "ANCHOR_CURSOR");
            GameTooltip:SetText(L.RESIZE_BUTTON_HINT_TOOLTIP, 1, 1, 1, 1);
            GameTooltip:Show();
        end);
    end);

    self.ResizeButton:SetScript("OnLeave", function()
        if timer and not timer:IsCancelled() then
            timer:Cancel();
        end

        if GameTooltip:IsOwned(self.ResizeButton) then
            GameTooltip:Hide();
        end
    end);
end

function DatamineUnifiedFrameMixin:SetupAnimations()
    local duration = 0.15;

    local animGroup = self:CreateAnimationGroup();
    animGroup:SetLooping("NONE");
    animGroup:SetToFinalAlpha(true);
    animGroup:SetScript("OnPlay", function()
        if animGroup.State == "SHOWING" then
            self:Show();
        end
    end);
    animGroup:SetScript("OnFinished", function()
        if animGroup.State == "HIDING" then
            self:Hide();
        end
    end);

    local alphaAnim = animGroup:CreateAnimation("ALPHA");
    alphaAnim:SetDuration(duration);
    alphaAnim:SetFromAlpha(0);
    alphaAnim:SetToAlpha(1);
    alphaAnim:SetSmoothing("IN");
    animGroup.AlphaAnim = alphaAnim;

    self.ShowAnim = animGroup;
end

function DatamineUnifiedFrameMixin:ShouldResetSizeAndPosition()
    return self.ShouldResetFrameSize;
end

function DatamineUnifiedFrameMixin:ResetSizeAndPosition()
    self:ClearAllPoints();
    self:SetPoint("CENTER");
    self:SetSize(DEFAULT_W, DEFAULT_H);

    self.ShouldResetFrameSize = false;
end

function DatamineUnifiedFrameMixin:SetAllowResize(allow)
    self:SetResizable(allow);
    self.ResizeButton:SetShown(allow);
end

function DatamineUnifiedFrameMixin:Toggle()
    self.ShowAnim:Stop();
    if not self:IsShown() then
        self.ShowAnim.State = "SHOWING";
        self.ShowAnim:Play();
    else
        self.ShowAnim.State = "HIDING";
        local reverse = true;
        self.ShowAnim:Play(reverse);
    end
end

function DatamineUnifiedFrameMixin:GetModelScene()
    return self.Workspace.ModelViewTab.ModelScene;
end