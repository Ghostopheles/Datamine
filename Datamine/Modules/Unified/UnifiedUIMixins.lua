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
        print("no atlasInfo for " .. self.AtlasName);
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

    self:AddButton("custom-toolbar-projects");
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

    self:SetLoading(true);
end

function DatamineScrollableDataFrameMixin:OnSearchBegin(dataID)
    self.DataID = dataID;
end

function DatamineScrollableDataFrameMixin:OnSearchModeChanged(searchMode)
    self.SearchMode = searchMode;
end

function DatamineScrollableDataFrameMixin:OnSearchResult(dataID)
    local modeText = Datamine.GetEnumValueName(DataTypes, self.SearchMode);
    self.Title:SetText(modeText .. " " .. dataID);
    self.Title:Show();
    self.PreviewItemButton:Show();
end

function DatamineScrollableDataFrameMixin:OnFail()
end

function DatamineScrollableDataFrameMixin:RefreshDataProvider()
    self.ScrollView:FlushDataProvider();
end

function DatamineScrollableDataFrameMixin:GetDataKeys()
    return DataKeys[self.SearchMode];
end

function DatamineScrollableDataFrameMixin:Populate(data, dataID)
    self:RefreshDataProvider();

    if not data then
        self:SetLoading(false);
        self:OnFail();
    end

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

        if key == "Hyperlink" and self.SearchMode == DataTypes.Item then
            self.Icon:SetItem(value);
        end

        if key == "Icon" and self.SearchMode == DataTypes.Spell then
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

    self:SetLoading(false);
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

DataminePreviewItemButtonMixin = {};

function DataminePreviewItemButtonMixin:OnLoad()
    Registry:RegisterCallback(Events.SEARCH_RESULT, self.OnSearchResult, self);
end

function DataminePreviewItemButtonMixin:OnClick()
    local dataID = self.dataID;
    local searchMode = self.searchMode;
    local data = self.data;

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

function DataminePreviewItemButtonMixin:OnSearchResult(dataID)
    local parent = self:GetParent();
    self.dataID = dataID;
    self.searchMode = parent.SearchMode;
    self.data = parent.CurrentData;
end

function DataminePreviewItemButtonMixin:OnEnter()
end

function DataminePreviewItemButtonMixin:OnLeave()
end

function DataminePreviewItemButtonMixin:GetModelScene()
    return DatamineUnifiedFrame.Workspace.ModelViewTab.ModelScene;
end

function DataminePreviewItemButtonMixin:TryOnItem(id)
    local scene = self:GetModelScene();
    local controls = scene:GetExternalControls();
    controls:ViewItemID(id);
end

function DataminePreviewItemButtonMixin:ViewCompanion(id)
    local scene = self:GetModelScene();
    local _, _, _, _, _, _, _, _, _, _, _, displayID, _ = C_PetJournal.GetPetInfoByItemID(id);
    scene:ViewPet(displayID);
end

function DataminePreviewItemButtonMixin:ViewMount(id)
    local scene = self:GetModelScene();
    local mountID = C_MountJournal.GetMountFromItem(id);

    if not mountID then return end;
    scene:ViewMount(mountID);
end

-------------

DatamineUnifiedExplorerTabMixin = {};

function DatamineUnifiedExplorerTabMixin:OnLoad()
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);
    self:SetSearchMode(DataTypes.Item);

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

    UI_MAIN.AddToolbarButton("custom-toolbar-select", SearchModeMenu);
end

function DatamineUnifiedExplorerTabMixin:GetSearchMode()
    return self.SearchMode;
end

function DatamineUnifiedExplorerTabMixin:GetDataFetchFunc()
    return FetchFuncs[self.SearchMode];
end

function DatamineUnifiedExplorerTabMixin:SetSearchMode(searchMode)
    if not tContains(DataTypes, searchMode) then
        return;
    end

    self.SearchMode = searchMode;
    Registry:TriggerEvent(Events.SEARCH_MODE_CHANGED, self.SearchMode);
end

function DatamineUnifiedExplorerTabMixin:OnSearchModeChanged(searchMode)
    local searchModeStr = Datamine.GetEnumValueName(DataTypes, searchMode);
    self.SearchBox.Instructions:SetText("Enter " .. searchModeStr .. "ID...");
    self.SearchBox:SetText("");
end

function DatamineUnifiedExplorerTabMixin:Search(number)
    Registry:TriggerEvent(Events.SEARCH_BEGIN, number);
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