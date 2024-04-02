local L = Datamine.Strings;
local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;
local Collector = Datamine.Collector;

------------

DatamineCreatureExplorerEntryMixin = {};

function DatamineCreatureExplorerEntryMixin:OnLoad()
    self.Background:ClearAllPoints();
    self.Text:SetScale(0.9);
end

------------

DatamineCreatureExplorerMixin = {};

DatamineCreatureExplorerMixin.Modes = {
    ID = "ID",
    Name = "Name",
    Zone = "Zone",
};

function DatamineCreatureExplorerMixin:OnLoad()
    self.SearchMode = self.Modes.ID;
    self.IsSearching = false;

    self:SetupView();
    self:SetupHelpText();
    self:SetupSearchManager();
end

function DatamineCreatureExplorerMixin:OnShow()
    self:Populate();

    local showHelpText = self.View.DataProvider:GetSize(false) == 0;
    self.HelpText:SetShown(showHelpText);
    self.HelpTextDetails:SetShown(showHelpText);
end

function DatamineCreatureExplorerMixin:SetupView()
    local view = self.View;
    view.ScrollView:SetPadding(2, 2, 2, 2, 2);
    view.Background_Base:Hide();
end

function DatamineCreatureExplorerMixin:SetupHelpText()
    self.HelpText:SetText(L.STORAGE_VIEW_TEXT_HELP_HEADER);
    self.HelpTextDetails:SetText(L.STORAGE_VIEW_TEXT_HELP);
end

function DatamineCreatureExplorerMixin:SetupSearchManager()
    local search = self.SearchManager;

    search.Label:SetText("Search by: ");

    local bContainer = search.ButtonContainer;

    bContainer.expand = false;
    bContainer.align = "center";
    bContainer.fixedHeight = 22;
    bContainer.fixedWidth = 225;

    bContainer.topPadding = 2;
    bContainer.bottomPadding = 2;
    bContainer.leftPadding = 2;
    bContainer.rightPadding = 2;

    bContainer.spacing = 2;

    local width = (bContainer.fixedWidth - 8) / 3;
    for i, button in ipairs(bContainer.Buttons) do
        button.layoutIndex = i;
        button.expand = true;
        button.align = "center";
        button:SetWidth(width);
        button:SetText(L["STORAGE_VIEW_SEARCH_MODE_BUTTON_"..i]);
    end

    bContainer:MarkDirty();
end

function DatamineCreatureExplorerMixin:OnModeButtonClicked(mode)
    self.SearchMode = mode;
    self:Populate();
end

function DatamineCreatureExplorerMixin:Populate()
    local view = self.View;
    local mode = self.SearchMode;
    local creatures = Collector.GetAllCreatureEntries();

    view:Reset();

    local function SortByID(a, b)
        local idA, idB = tonumber(a.data.ID), tonumber(b.data.ID);
        return idA <= idB;
    end

    view.DataProvider:SetSortComparator(SortByID);

    for creatureID, entry in pairs(creatures) do
        local text;
        if mode == self.Modes.ID then
            text = format("Creature %d", creatureID);
        elseif mode == self.Modes.Name then
            text = entry.Name[GetLocale()];
        end

        local data = {
            Template = "DatamineCreatureExplorerEntryTemplate",
            Text = text,
            IsTopLevel = true,
            ShowChevron = false,
            CanExpand = false,
            Callback = function() print(text) end,
            ID = creatureID,
        };
        view:AddTopLevelItem(data);
    end
end

------------

DatamineStorageViewMixin = {};

function DatamineStorageViewMixin:OnLoad()
    --EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
    --    DatamineUnifiedFrame:Show();
    --    DatamineUnifiedFrame.Workspace:SetMode(3);
    --end);
end