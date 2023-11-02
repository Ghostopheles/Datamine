local moduleName = "Explorer";
local Print = function(...)
    Datamine.Print(moduleName, ...);
end;

local DatamineExplorerInfoPageMixin = {};

function DatamineExplorerInfoPageMixin:Init(title)
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

    self.Icon = CreateFrame("ItemButton", nil, self);
    self.Icon:SetPoint("CENTER", self.TitleText, "CENTER", -120, 0);
    self.Icon:EnableMouse(false);

    self:SetHyperlinksEnabled(true);

    self.ScrollFrame = CreateFrame("ScrollFrame", nil, self, "WowScrollBoxList");
    self.ScrollFrame:SetPoint("BOTTOMRIGHT");
    self.ScrollFrame:SetPoint("TOPLEFT", self.TitleText, "BOTTOMLEFT");

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
    self.DataProvider:Flush();

    if not itemData then
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
        self.DataProvider:Insert(data);
    end
    self:SetLoading(false);
end

local function CreateInfoPage(parent, title)
    local f = CreateFrame("Frame", "DatamineInfoPage" .. title, parent);

    Mixin(f, DatamineExplorerInfoPageMixin);
    f:Init(title);

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

    self.History = {
        Back = {};
        Forward = {};
    };

    self.CurrentlyDisplayedPage = nil;
end

function Datamine.Explorer:PushCurrentPageToHistory()
    if self.CurrentlyDisplayedPage then
        self.CurrentlyDisplayedPage:Hide();
        tinsert(self.History.Back, self.CurrentlyDisplayedPage);
    end

    if #self.History.Back > 4 then
        tremove(self.History.Back, 1);
    end
end

function Datamine.Explorer:AddPageForItemID(itemID)
    self:PushCurrentPageToHistory();

    local page = CreateInfoPage(self.InfoContainer, "Item: " .. itemID);
    page:SetLoading(true);

    Datamine.Item:GetOrFetchItemInfoByID(itemID, function(itemData) page:PopulateDataProviderFromCallback(itemData) end);
    self.CurrentlyDisplayedPage = page;
end

Datamine.Explorer:InitFrame()



