local L = Datamine.Strings;
local Registry = Datamine.EventRegistry;
local Events = Datamine.Events;
local Popup = Datamine.Popup;
local Search = Datamine.Search;
local Database = Datamine.Database;

------------

DatamineCreaturePickerMixin = {};

function DatamineCreaturePickerMixin:OnLoad()
    local titleBar = self.TitleBar;
    local creatureList = self.CreatureList;

    titleBar.TitleText:SetText(L.CREATUREVIEW_LIST_TITLE);
    creatureList.Background_Base:Hide();

    creatureList.HelpText:SetText(L.CREATUREVIEW_TEXT_HELP_HEADER);
    creatureList.HelpTextDetails:SetText(L.CREATUREVIEW_TEXT_HELP);

    creatureList:SetFailText(nil, L.CREATUREVIEW_LIST_SEARCH_FAIL_TEXT);

    self:SetupSearchBox();
end

function DatamineCreaturePickerMixin:OnShow()
    if self.SearchTask then
        self.SearchTask:ClearSearchQuery();
    end

    if not self.Populated then
        self:PopulateCreatures();
    end

    self.TitleBar.SearchBox:SetText("");
    self.CreatureList.ScrollBox:ScrollToBegin();
end

function DatamineCreaturePickerMixin:SetupSearchBox()
    local searchBox = self.TitleBar.SearchBox;
    local creatureList = self.CreatureList;

    creatureList:SetEditBox(searchBox);
end

function DatamineCreaturePickerMixin:PopulateCreatures()
    local creatureList = self.CreatureList;

    creatureList.HelpText:Hide();
    creatureList.HelpTextDetails:Hide();

    creatureList.ScrollView:SetPadding(2, 2, 2, 2, 2);

    local allCreatures = {};
    local creatures = Datamine.Database:GetAllCreatureEntries();
    for creatureID, creatureInfo in pairs(creatures) do
        local locale = GetLocale();
        local data = {
            ID = creatureID,
            Text = creatureInfo.Name[locale],
            TextScale = 0.9,
            Callback = function() end,
            BackgroundAlpha = 0.5,
        };

        tinsert(allCreatures, data);
    end

    local function AlphabeticalSort(a, b)
        return a.Text < b.Text;
    end

    table.sort(allCreatures, AlphabeticalSort);
    creatureList:SetSearchDataSource(allCreatures, "Text");

    self.Populated = true;
end