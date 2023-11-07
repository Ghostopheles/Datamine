local moduleName = "Explorer";
local Print = function(...)
    Datamine.Print(moduleName, ...);
end;

local MSA = LibStub:GetLibrary("MSA-DropDownMenu-1.0");

DatamineExplorerEventRegistry = CreateFromMixins(CallbackRegistryMixin);
DatamineExplorerEventRegistry:OnLoad();
DatamineExplorerEventRegistry:GenerateCallbackEvents(
    {
        "Minimized",
        "Expanded",
        "DataLoadStart",
        "DataLoadComplete",
        "DisplayedPageChanged",
        "HistoryChanged",
        "SearchTypeChanged",
    }
);

local DatamineExplorerInfoPageMixin = {};

local DataTypes = {
    Item = 1;
    Spell = 2;
};

local function GetStringFromDataType(dataType)
    if dataType == DataTypes.Item then
        return "Item";
    elseif dataType == DataTypes.Spell then
        return "Spell";
    end
end

local function GetDataKeys(dataType)
    if dataType == DataTypes.Item then
        return Datamine.Item.ItemInfoKeys;
    elseif dataType == DataTypes.Spell then
        return Datamine.Spell.SpellInfoKeys;
    end
end

function DatamineExplorerInfoPageMixin:Init(dataID, dataType)
    self:SetAllPoints();

    self.DataID = dataID;
    self.DataType = dataType;

    self.Title = GetStringFromDataType(dataType) .. ": " .. dataID;

    self.TitleText = self:CreateFontString(nil, nil, "GameFontHighlight");
    self.TitleText:ClearAllPoints();
    self.TitleText:SetPoint("TOPLEFT");
    self.TitleText:SetPoint("TOPRIGHT");
    self.TitleText:SetHeight(20);

    self.TitleText:SetJustifyH("CENTER");
    self.TitleText:SetScale(2);
    self.TitleText:SetText(self.Title);

    self.Icon = CreateFrame("ItemButton", nil, self);
    self.Icon:SetPoint("CENTER", self.TitleText, "CENTER", -120, 0);
    self.Icon:EnableMouse(false);

    self:SetHyperlinksEnabled(true);

    self.ScrollFrame = CreateFrame("ScrollFrame", nil, self, "WowScrollBoxList");
    self.ScrollFrame:SetPoint("BOTTOMRIGHT");
    self.ScrollFrame:SetPoint("TOPLEFT", self.TitleText, "BOTTOMLEFT", 0, -10);

    self.ScrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar");
    self.ScrollBar:SetPoint("TOPLEFT", self.ScrollFrame, "TOPRIGHT", -20, -8);
    self.ScrollBar:SetPoint("BOTTOMLEFT", self.ScrollFrame, "BOTTOMRIGHT", -20, 5);
    self.ScrollBar:SetHideIfUnscrollable(true);

    self.ScrollView = CreateScrollBoxListLinearView();

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollFrame, self.ScrollBar, self.ScrollView);

    local i = 0;

    self.ScrollView:SetElementInitializer("DatamineExplorerDataEntryTemplate", function(frame, data)
        frame:Init(data, self);

        if i % 2 == 0 then
            frame:SetDefaultAlpha(0.15);
        end

        i = i + 1;
    end)

    self.DataProvider = CreateDataProvider();

    self.ScrollFrame:SetDataProvider(self.DataProvider);

    self.LoadingSpinner = CreateFrame("Frame", nil, self, "OutlineLoadingSpinnerTemplate");
    self.LoadingSpinner:SetPoint("CENTER");
    self.LoadingSpinner.Text = self.LoadingSpinner:CreateFontString(nil, nil, "GameFontHighlight");
    self.LoadingSpinner.Text:SetPoint("TOP", self.LoadingSpinner, "BOTTOM", 0, -8);
    self.LoadingSpinner.Text:SetText("Loading...");
    self.LoadingSpinner:Hide();

    self.Loading = false;

    self:SetScript("OnHyperlinkClick", self.OnHyperlinkClick);
    self:SetScript("OnHyperlinkEnter", self.OnHyperlinkEnter);
    self:SetScript("OnHyperlinkLeave", self.OnHyperlinkLeave);
end

function DatamineExplorerInfoPageMixin:OnHyperlinkClick(link, text, button)
    SetItemRef(link, text, button);
end

function DatamineExplorerInfoPageMixin:OnHyperlinkEnter(link, _)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
    GameTooltip:SetHyperlink(link);
    GameTooltip:Show();
end

function DatamineExplorerInfoPageMixin:OnHyperlinkLeave()
    GameTooltip:Hide();
end

function DatamineExplorerInfoPageMixin:SetLoading(isLoading)
    if isLoading then
        self.ScrollFrame:Hide();
        self.LoadingSpinner:Show();
        self.LoadingSpinner.Text:SetText("Loading " .. self.Title .. "...");
        Datamine.Explorer.SearchBox:Disable();
        self.Loading = true;
        DatamineExplorerEventRegistry:TriggerEvent("DataLoadStart", self.DataID);
    else
        self.ScrollFrame:Show();
        self.LoadingSpinner:Hide();
        Datamine.Explorer.SearchBox:Enable();
        self.Loading = false;
        DatamineExplorerEventRegistry:TriggerEvent("DataLoadComplete", self.DataID);
    end
end

function DatamineExplorerInfoPageMixin:IsLoading()
    return self.Loading;
end

function DatamineExplorerInfoPageMixin:OnFail()
    self.Icon:Hide();
    self.TitleText:SetText("Item is forbidden or does not exist.");
end

function DatamineExplorerInfoPageMixin:PopulateDataProviderFromCallback(data)
    self.DataProvider:Flush();

    if not data then
        self:SetLoading(false);
        self:OnFail();
        return;
    end

    local keys = GetDataKeys(self.DataType);

    for i, value in ipairs(data) do
        if not value or value == "" then
            value = "N/A";
        elseif type(value) == "boolean" then
            value = tostring(value);
        end

        local _data = {
            key = keys[i],
            value = value;
        };
        self.DataProvider:Insert(_data);
    end
    self:SetLoading(false);
end

local function CreateInfoPage(parent, title, dataType)
    local f = CreateFrame("Frame", nil, parent);

    Mixin(f, DatamineExplorerInfoPageMixin);
    f:Init(title, dataType);

    return f;
end

Datamine.Explorer = CreateFrame("Frame", "DatamineExplorerFrame", UIParent, "PortraitFrameFlatTemplate");

function Datamine.Explorer:InitFrame()
    self:SetSize(640, 720);
    self:SetPoint("TOP", 0, -200);
    self:SetTitle("Datamine Explorer");
    self:SetToplevel(true);

    ButtonFrameTemplate_HidePortrait(self);

    self:InitSearchBox();
    self:SetSearchType(DataTypes.Item);

    self.InfoContainer = CreateFrame("Frame", nil, self);

    self:Minimize();
    self:InitHistory();
    self:InitInfoTypeDropdown();

    self.CurrentlyDisplayedPage = nil;

    self:Hide();
end

function Datamine.Explorer:InitSearchBox()
    self.SearchBox = CreateFrame("EditBox", nil, self, "SearchBoxTemplate");
    self.SearchBox:SetNumeric(true);
    self.SearchBox:SetAutoFocus(false);
    self.SearchBox:SetHeight(25);
    self.SearchBox:HookScript("OnEscapePressed", function() self:Hide() end);
    self.SearchBox:HookScript("OnEnterPressed", function()
        local value = self.SearchBox:GetNumber();
        if self.SearchType == DataTypes.Item then
            Datamine.Explorer:AddPageForItemID(value);
        elseif self.SearchType == DataTypes.Spell then
            Datamine.Explorer:AddPageForSpellID(value);
        end
    end);

    DatamineExplorerEventRegistry:RegisterCallback("SearchTypeChanged", function(_, searchType)
        self.SearchBox.Instructions:SetText("Enter " .. GetStringFromDataType(searchType) .. "ID...");
    end);
end

function Datamine.Explorer:InitInfoTypeDropdown()
    self.InfoTypeDropdownToggle = CreateFrame("DropDownToggleButton", nil, self, "UIMenuButtonStretchTemplate");
    self.InfoTypeDropdownToggle:SetSize(120, 21);
    self.InfoTypeDropdownToggle:SetPoint("LEFT", self.SearchBox, "RIGHT", 10, 0);
    self.InfoTypeDropdownToggle:SetText("Search Type");

    self.InfoTypeDropdownToggle.Icon = self.InfoTypeDropdownToggle:CreateTexture(nil, "ARTWORK");
    self.InfoTypeDropdownToggle.Icon:SetTexture([[Interface\ChatFrame\ChatFrameExpandArrow]]);
    self.InfoTypeDropdownToggle.Icon:SetSize(10, 12);
    self.InfoTypeDropdownToggle.Icon:SetPoint("RIGHT", -5, 0);

    self.InfoTypeDropdownToggle.DropDown = MSA_DropDownMenu_Create("DatamineExplorerSearchTypeDropDown", self.InfoTypeDropdownToggle);

    local function DropDownInit(self)
        for k, _ in pairs(DataTypes) do
            local info = MSA_DropDownMenu_CreateInfo();
            info.text = k;
            info.func = function() Datamine.Explorer:SetSearchType(DataTypes[k]) end;
            if DataTypes[k] == Datamine.Explorer.SearchType then
                info.checked = true;
            end
            MSA_DropDownMenu_AddButton(info);
        end
    end

    MSA_DropDownMenu_Initialize(self.InfoTypeDropdownToggle.DropDown, DropDownInit, "MENU");

    self.InfoTypeDropdownToggle:SetScript("OnClick", function()
        local level = 1
        local value = nil
        MSA_ToggleDropDownMenu(level, value, self.InfoTypeDropdownToggle.DropDown, self.InfoTypeDropdownToggle, 5, -2);
    end)

    --self.InfoTypeDropdown:Disable(); -- until this works, disabling it for release
end

function Datamine.Explorer:InitHistory()
    self.HistoryNavigation = CreateFrame("Frame", nil, self, "DatamineExplorerHistoryNavigationTemplate");
    self.HistoryNavigation:SetPoint("RIGHT", self.SearchBox, "LEFT", -10, 0);

    self.HistoryNavigation.BackButton:Disable();
    self.HistoryNavigation.ForwardButton:Disable();

    self.HistoryNavigation.BackButton:SetScript("OnClick", function() self:GoBack() end);
    self.HistoryNavigation.ForwardButton:SetScript("OnClick", function() self:GoForward() end);

    DatamineExplorerEventRegistry:RegisterCallback("HistoryChanged", function(_, direction)
        if direction == self.HistoryDirection.BACK then
            if self.History.LastPageBack then
                self.HistoryNavigation.BackButton:Enable();
            else
                self.HistoryNavigation.BackButton:Disable();
            end
        end

        if direction == self.HistoryDirection.FORWARD then
            if self.History.LastPageForward then
                self.HistoryNavigation.ForwardButton:Enable();
            else
                self.HistoryNavigation.ForwardButton:Disable();
            end
        end
    end);

    self.History = {
        LastPageBack = nil;
        LastPageForward = nil;
    };

    self.HistoryDirection = {
        BACK = "BACK",
        FORWARD = "FORWARD",
    };
end

function Datamine.Explorer:SetSearchType(searchType)
    self.SearchType = searchType;
    DatamineExplorerEventRegistry:TriggerEvent("SearchTypeChanged", searchType);
end

function Datamine.Explorer:PushCurrentPageToHistory()
    if self.CurrentlyDisplayedPage then
        self.History.LastPageBack = self.CurrentlyDisplayedPage;
        self.CurrentlyDisplayedPage:Hide();
        DatamineExplorerEventRegistry:TriggerEvent("HistoryChanged", self.HistoryDirection.BACK);
    end
end

function Datamine.Explorer:PushCurrentPageToForwardHistory()
    if self.CurrentlyDisplayedPage then
        self.History.LastPageForward = self.CurrentlyDisplayedPage;
        self.CurrentlyDisplayedPage:Hide();
        DatamineExplorerEventRegistry:TriggerEvent("HistoryChanged", self.HistoryDirection.FORWARD);
    end
end

function Datamine.Explorer:GoBack()
    self:PushCurrentPageToForwardHistory();
    self.CurrentlyDisplayedPage = self.History.LastPageBack;
    self.CurrentlyDisplayedPage:Show();

    self.History.LastPageBack = nil;
    DatamineExplorerEventRegistry:TriggerEvent("HistoryChanged", self.HistoryDirection.BACK);
    DatamineExplorerEventRegistry:TriggerEvent("DisplayedPageChanged", self.CurrentlyDisplayedPage);
end

function Datamine.Explorer:GoForward()
    self:PushCurrentPageToHistory();
    self.CurrentlyDisplayedPage = self.History.LastPageForward;
    self.CurrentlyDisplayedPage:Show();

    self.History.LastPageForward = nil;
    DatamineExplorerEventRegistry:TriggerEvent("HistoryChanged", self.HistoryDirection.FORWARD);
    DatamineExplorerEventRegistry:TriggerEvent("DisplayedPageChanged", self.CurrentlyDisplayedPage);
end

function Datamine.Explorer:Minimize()
    local searchBoxWidth = self:GetWidth() / 2;

    self.SearchBox:ClearAllPoints();
    self.SearchBox:SetPoint("TOP", self.Bg, 0, -8);
    self.SearchBox:SetWidth(searchBoxWidth);

    self.InfoContainer:ClearAllPoints();
    self.InfoContainer:SetPoint("TOPLEFT", self.Bg, 7, -35);
    self.InfoContainer:SetPoint("BOTTOMRIGHT", self.Bg, -7, 10);

    DatamineExplorerEventRegistry:TriggerEvent("Minimized");
end

function Datamine.Explorer:Expand()
end

function Datamine.Explorer:AddPageForItemID(itemID)
    self:PushCurrentPageToHistory();

    local page = CreateInfoPage(self.InfoContainer, itemID, DataTypes.Item);
    page:SetLoading(true);

    Datamine.Item:GetOrFetchItemInfoByID(itemID, function(itemData) page:PopulateDataProviderFromCallback(itemData) end);
    self.CurrentlyDisplayedPage = page;
    DatamineExplorerEventRegistry:TriggerEvent("DisplayedPageChanged", page);
end

function Datamine.Explorer:AddPageForSpellID(spellID)
    self:PushCurrentPageToHistory();

    local page = CreateInfoPage(self.InfoContainer, spellID, DataTypes.Spell);
    page:SetLoading(true);

    Datamine.Spell:GetOrFetchSpellInfoByID(spellID, function(spellData) page:PopulateDataProviderFromCallback(spellData) end);
    self.CurrentlyDisplayedPage = page;
    DatamineExplorerEventRegistry:TriggerEvent("DisplayedPageChanged", page);
end

function Datamine.Explorer:Toggle()
    if self:IsShown() then
        self:Hide();
    else
        self:Show();
    end
end

Datamine.Explorer:InitFrame()



