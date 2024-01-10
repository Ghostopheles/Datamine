local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

local DataTypes = Datamine.Constants.DataTypes;
local DataKeys = {
    [DataTypes.Item] = Datamine.Item.ItemInfoKeys,
    [DataTypes.Spell] = Datamine.Spell.SpellInfoKeys,
};
local FetchFuncs = {
    [DataTypes.Item] = function(...) Datamine.Item:GetOrFetchItemInfoByID(...) end,
    [DataTypes.Spell] = function(...) Datamine.Spell:GetOrFetchSpellInfoByID(...) end,
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

function DatamineToolbarMixin:AddButton(atlasName, callback)
    local button = CreateFrame("Button", nil, self, "DatamineGenericButtonTemplate");

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

    button.Icon = Datamine.CustomAtlas:CreateCustomAtlasTexture("Toolbar.png", atlasName, true, button);
    button.Icon:ClearAllPoints();
    button.Icon:SetPoint("TOPLEFT");
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

function DatamineDataFrameElementMixin:Init(data)
    self.KeyText:SetText(data.key .. ":");
    self.ValueText:SetText(data.value);

    self.KeyText:SetTextScale(0.85);
    self.ValueText:SetTextScale(0.85);

    if self.KeyText:IsTruncated() then
        self.KeyText:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.KeyText, "ANCHOR_TOPRIGHT");
            GameTooltip:SetText(data.key, 1, 1, 1);
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

-------------

DatamineScrollableDataFrameMixin = {};

local SEARCH_HELP_TYPE = {
    HELP = 1,
    FAIL = 2,
    DRAGDROP = 3,
};

local SEARCH_HELP_FORMAT = {
    [SEARCH_HELP_TYPE.HELP] = {
        Header = "Explorer",
        Details = [[Enter %s %s ID in the search box above|nto get started.]],
    },
    [SEARCH_HELP_TYPE.FAIL] = {
        Header = "Search failed",
        Details = [[%s %d is forbidden or does not exist.]],
    },
    [SEARCH_HELP_TYPE.DRAGDROP] = {
        Header = "Explorer",
        Details = [[Drop %s %s here to search for it.]],
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

function DatamineScrollableDataFrameMixin:OnLoad()
    self.DataProvider = CreateDataProvider();

    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);

    self.i = 0;
    self.ScrollView:SetElementInitializer("DatamineDataFrameElementTemplate", function(frame, data)
        frame:Init(data, self);

        if self.i % 2 == 0 then
            frame.Background:SetAlpha(0.15);
        else
            frame.Background:SetAlpha(0.35);
        end
        self.i = self.i + 1;
    end);

    self.ScrollBox:SetInterpolateScroll(true);
    self.ScrollBar:SetInterpolateScroll(true);
    self.ScrollBar:SetHideIfUnscrollable(true);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    Registry:RegisterCallback(Events.SEARCH_BEGIN, self.OnSearchBegin, self);
    Registry:RegisterCallback(Events.SEARCH_RESULT, self.OnSearchResult, self);
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);

    self.HelpTextDetails:SetTextScale(0.75);
    self:RegisterEvent("GLOBAL_MOUSE_UP");
    self:RegisterEvent("CURSOR_CHANGED");
    self:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...);
        end
    end);

    self.DragDropNineSlice.Center:SetAlpha(0.25);
end

function DatamineScrollableDataFrameMixin:OnShow()
    local textType = self.Failed and SEARCH_HELP_TYPE.FAIL or SEARCH_HELP_TYPE.HELP;
    self:ShowHelpText(textType);
end

function DatamineScrollableDataFrameMixin:GLOBAL_MOUSE_UP()
    if MouseIsOver(self) and self:IsShown() then
        local item = C_Cursor.GetCursorItem();
        if item and item:IsValid() then
            local itemID = C_Item.GetItemID(item);
            if UI_MAIN.GetExplorerSearchMode() ~= DataTypes.Item then
                self:GetParent():SetSearchMode(DataTypes.Item);
            end
            self:GetParent():Search(itemID);
            self:SetExplorerHighlightShown(false);
            ClearCursor();
        end
    end
end

function DatamineScrollableDataFrameMixin:CURSOR_CHANGED(...)
    local _, newCursorType, _ = ...;
    if newCursorType == Enum.UICursorType.Item then
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
    self:ShowFailText();

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
    if itemType == Enum.ItemClass.Armor then
        if not tContains(ITEM_SLOTS_THAT_CANT_BE_MOGGED, itemType) then
            return true;
        end
    elseif itemType == Enum.ItemClass.Miscellaneous then
        local miscSubType = Enum.ItemMiscellaneousSubclass;
        if itemSubType == miscSubType.CompanionPet or itemSubType == miscSubType.Mount then
            return true;
        end
    end

    return false;
end

function DatamineScrollableDataFrameMixin:UpdatePreviewButtonVisiblity()
    self.PreviewButton:SetShown(self:ShouldShowPreviewButton());
end

function DatamineScrollableDataFrameMixin:IsPopulated()
    return self.DataProvider:GetSize() > 0;
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
    self.CurrentData = {};
    self.i = 0;

    for i, value in ipairs(data) do
        if value == nil or value == "" then
            value = "N/A";
        elseif type(value) == "boolean" then
            value = tostring(value);
        end

        local key = keys[i];

        if key == "Hyperlink" and searchMode == DataTypes.Item then
            self.Icon:SetItem(value);
        end

        if key == "Icon" and searchMode == DataTypes.Spell then
            self.Icon.icon:SetTexture(value);
        end

        local _data = {
            key = keys[i],
            value = value
        };

        self.CurrentData[keys[i]] = value;

        -- skip the "name" entry because Hyperlink covers that
        if _data.key ~= "Name" then
            self.DataProvider:Insert(_data);
        end
    end

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
        self:TryOnItem(dataID);
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

function DataminePreviewButtonMixin:TryOnItem(id)
    local scene = self:GetModelScene();
    local controls = scene:GetExternalControls();
    controls:ViewItemID(id);
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
    modeButton.Text:SetTextScale(0.85);
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
    local searchModeStr = Datamine.GetEnumValueName(DataTypes, self:GetSearchMode());
    self.SearchBox.Instructions:SetText("Enter " .. searchModeStr .. "ID...");
    self.SearchBox:SetText("");
end

function DatamineUnifiedExplorerTabMixin:Search(number)
    Registry:TriggerEvent(Events.SEARCH_BEGIN, number);
    self:SetCurrentDataID(number);
    self:GetDataFetchFunc()(number, function(data) self.DataFrame:Populate(data, number) end);
end

-------------

DataminePlayerModelMixin2 = CreateFromMixins(ModelFrameMixin);

function DataminePlayerModelMixin2:ResetModel()
    self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self:SetPosition(0, 0, 0);
	self.zoomLevel = self.minZoom;
	self:SetPortraitZoom(self.zoomLevel);
    self:SetUnit("player");
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

DatamineUnifiedFrameMixin = {};

function DatamineUnifiedFrameMixin:OnLoad()
    self.TitleContainer.Text:SetText("Datamine");

    tinsert(UISpecialFrames, self:GetName());
end

function DatamineUnifiedFrameMixin:Toggle()
    if not self:IsShown() then
        self:Show();
    else
        self:Hide();
    end
end

function DatamineUnifiedFrameMixin:GetModelScene()
    return self.Workspace.ModelViewTab.ModelScene;
end