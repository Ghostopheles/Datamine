local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

DatamineLightGray = CreateColor(0.18, 0.18, 0.18, 1);
DatamineDarkGray = CreateColor(0.1, 0.1, 0.1, 1);

local DataTypes = Datamine.Constants.DataTypes;

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
    self.ScrollView:SetElementInitializer("DatamineDataFrameElementTemplate", function(frame, data)
        frame:Init(data, self);
    end);

    self.ScrollBox:SetInterpolateScroll(true);
    self.ScrollBar:SetInterpolateScroll(true);
    self.ScrollBar:SetHideIfUnscrollable(true);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    Registry:RegisterCallback(Events.SEARCH_BEGIN, self.OnSearchBegin, self);
    Registry:RegisterCallback(Events.SEARCH_RESULT, self.OnSearchResult, self);
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);

    --self:SetLoading(false);
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

function DatamineScrollableDataFrameMixin:Populate(data, dataID)
    self:RefreshDataProvider();

    if not data then
        self:SetLoading(false);
        self:OnFail();
    end

    local keys = Datamine.Item.ItemInfoKeys;

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
        self.DataProvider:Insert(_data);
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

function DataminePreviewItemButtonMixin:OnClick()
    local dataID = self:GetParent().DataID;
    DatamineUnifiedFrame.Workspace.ModelViewTab:SetMode("playerModel");
    DatamineUnifiedFrame.Workspace.ModelViewTab.PlayerModel:SetItem(dataID);
end

function DataminePreviewItemButtonMixin:OnEnter()
end

function DataminePreviewItemButtonMixin:OnLeave()
end

-------------

DatamineUnifiedExplorerTabMixin = {};

function DatamineUnifiedExplorerTabMixin:OnLoad()
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);

    self:SetSearchMode(DataTypes.Item);
end

function DatamineUnifiedExplorerTabMixin:GetSearchMode()
    return self.SearchMode;
end

function DatamineUnifiedExplorerTabMixin:SetSearchMode(searchMode)
    if not tContains(DataTypes, searchMode) then
        return;
    end

    self.SearchMode = searchMode;
    Registry:TriggerEvent(Events.SEARCH_MODE_CHANGED, searchMode);
end

function DatamineUnifiedExplorerTabMixin:OnSearchModeChanged(searchMode)
    local searchModeStr = Datamine.GetEnumValueName(DataTypes, searchMode);
    self.SearchBox.Instructions:SetText("Enter " .. searchModeStr .. "ID...");
    self.SearchBox:SetText("");
end

function DatamineUnifiedExplorerTabMixin:Search(number)
    Registry:TriggerEvent(Events.SEARCH_BEGIN, number);
    Datamine.Item:GetOrFetchItemInfoByID(number, function(itemData) self.DataFrame:Populate(itemData, number) end);
end

-------------

DatamineModelSceneMixin = {};

function DatamineModelSceneMixin:OnLoadCustom()
    self.ControlFrame:SetModelScene(self);
    self.FirstShow = true;

    self:ClearScene();
    self:SetViewInsets(0, 0, 0, 0);
    EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function() self:SetFromModelSceneID(596) end);
end

function DatamineModelSceneMixin:OnShow()
    self:SetupPlayerActor();
end

function DatamineModelSceneMixin:SetupPlayerActor()
    local actor = self:GetPlayerActor();
    if not actor then
        return;
    end

    local sheatheWeapons = true;
    local autoDress = true;
    local hideWeapons = false;
    local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();

    actor:SetModelByUnit("player", true, true, false, true);
    actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
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

function DatamineUnifiedModelViewTabMixin:OnLoad()
end

function DatamineUnifiedModelViewTabMixin:OnShow()
end

function DatamineUnifiedModelViewTabMixin:SetupPlayerActor()
end

function DatamineUnifiedModelViewTabMixin:SetMode(mode)
    if mode == "playerModel" then
        self.ModelScene:Hide();
        self.PlayerModel:Show();
    else
        self.PlayerModel:Hide();
        self.ModelScene:Show();
    end
end