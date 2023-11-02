local moduleName = "Explorer";
local Print = function(...)
    Datamine.Print(moduleName, ...);
end;

local DatamineExplorerItemDataProvider = CreateDataProvider();
local DatamineExplorerInfoPageMixin = {};

function DatamineExplorerInfoPageMixin:Init(dataProvider, title)
    self:SetAllPoints();

    self.Title = title;

    self.TitleText = self:CreateFontString(nil, nil, "GameFontHighlight");
    self.TitleText:ClearAllPoints();
    self.TitleText:SetPoint("TOPLEFT");
    self.TitleText:SetPoint("TOPRIGHT");
    self.TitleText:SetHeight(20);

    self.TitleText:SetJustifyH("CENTER");
    self.TitleText:SetScale(2);
    self.TitleText:SetText(self.Title);

    self.ScrollFrame = CreateFrame("ScrollFrame", nil, self, "WowScrollBoxList");
    self.ScrollFrame:SetPoint("BOTTOMRIGHT");
    self.ScrollFrame:SetPoint("TOPLEFT", self.TitleText, "BOTTOMLEFT");

    self.ScrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar");
    self.ScrollBar:SetPoint("TOPLEFT", self.ScrollFrame, "TOPRIGHT", -20, -8);
    self.ScrollBar:SetPoint("BOTTOMLEFT", self.ScrollFrame, "BOTTOMRIGHT", -20, 5);
    self.ScrollBar:SetHideIfUnscrollable(true);

    self.ScrollView = CreateScrollBoxListLinearView();

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollFrame, self.ScrollBar, self.ScrollView);

    self.ScrollView:SetElementInitializer("DatamineExplorerDataEntryTemplate", function(frame, data)
        frame.Text = frame:CreateFontString(nil, nil, "GameFontHighlight");
        frame.Text:SetAllPoints();
        frame.Text:SetJustifyH("LEFT");
        frame.Text:SetText(data.key .. ": " .. data.value);
    end)

    self.ScrollFrame:SetDataProvider(dataProvider);

    self.LoadingSpinner = CreateFrame("Frame", nil, self, "OutlineLoadingSpinnerTemplate");
    self.LoadingSpinner:SetPoint("CENTER");
    self.LoadingSpinner.Text = self.LoadingSpinner:CreateFontString(nil, nil, "GameFontHighlight");
    self.LoadingSpinner.Text:SetPoint("TOP", self.LoadingSpinner, "BOTTOM", 0, -8);
    self.LoadingSpinner.Text:SetText("Loading...");
    self.LoadingSpinner:Hide();

    self.Loading = false;
end

function DatamineExplorerInfoPageMixin:SetLoading(isLoading)
    if isLoading then
        self.ScrollFrame:Hide();
        self.LoadingSpinner:Show();
        self.LoadingSpinner.Text:SetText("Loading " .. self.Title .. "...");
        Datamine.Explorer.SearchBox:Disable();
        self.Loading = true;
    else
        self.ScrollFrame:Show();
        self.LoadingSpinner:Hide();
        Datamine.Explorer.SearchBox:Enable();
        self.Loading = false;
    end
end

function DatamineExplorerInfoPageMixin:IsLoading()
    return self.Loading;
end

function DatamineExplorerInfoPageMixin:PopulateDataProviderFromCallback(itemData)
    DatamineExplorerItemDataProvider:Flush();

    if itemData == false then
        self:SetLoading(false);
        return;
    end

    for i, value in ipairs(itemData) do
        if not value or value == "" then
            value = "N/A";
        elseif type(value) == "boolean" then
            value = tostring(value);
        end

        local data = {
            key = Datamine.Item.ItemInfoKeys[i],
            value = value;
        };
        DatamineExplorerItemDataProvider:Insert(data);
    end
    self:SetLoading(false);
end

local function CreateInfoPage(parent, dataProvider, title)
    local f = CreateFrame("Frame", "DatamineInfoPage" .. title, parent);

    Mixin(f, DatamineExplorerInfoPageMixin);
    f:Init(dataProvider, title);

    return f;
end

Datamine.Explorer = CreateFrame("Frame", "DatamineExplorerFrame", UIParent, "PortraitFrameFlatTemplate");
Datamine.Explorer.Events = CreateFromMixins(CallbackRegistryMixin);
Datamine.Explorer.Events:OnLoad();
Datamine.Explorer.Events:SetUndefinedEventsAllowed(true);



function Datamine.Explorer:InitFrame()
    self:SetSize(1280, 720);
    self:SetPoint("TOP", 0, -200);
    self:SetTitle("Datamine Explorer");
    self:SetToplevel(true);

    ButtonFrameTemplate_HidePortrait(self);

    self.SearchBox = CreateFrame("EditBox", nil, self, "SearchBoxTemplate");
    self.SearchBox:SetNumeric(true);
    self.SearchBox:SetAutoFocus(false);
    self.SearchBox:SetHeight(20);
    self.SearchBox:SetPoint("TOPLEFT", self.Bg, 13, -8);
    self.SearchBox:SetPoint("RIGHT", self.Bg, "TOP");
    self.SearchBox:HookScript("OnEscapePressed", function() self:Hide() end);
    self.SearchBox:HookScript("OnKeyDown", function(_, key)
        if key == "ENTER" then
            Datamine.Explorer:AddPageForItemID(self.SearchBox:GetNumber());
        end
    end)

    self.InfoContainer = CreateFrame("Frame", nil, self);
    self.InfoContainer:SetPoint("TOPLEFT", self.SearchBox, "BOTTOMLEFT", 0, -10);
    self.InfoContainer:SetPoint("BOTTOMRIGHT", self.Bg, "BOTTOM", 0, 10);

    self:Show();
end

function Datamine.Explorer:AddPageForItemID(itemID)
    local page = CreateInfoPage(self.InfoContainer, DatamineExplorerItemDataProvider, "Item: " .. itemID);
    page:SetLoading(true);

    Datamine.Item:GetOrFetchItemInfoByID(itemID, function(itemData) page:PopulateDataProviderFromCallback(itemData) end);
end

Datamine.Explorer:InitFrame()



