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
        if creatureInfo.Name[locale] then
            local data = {
                ID = creatureID,
                Text = creatureInfo.Name[locale],
                TextScale = 0.9,
                Callback = function() self:GetParent():TrySetCreature(creatureID); end,
                BackgroundAlpha = 0.5,
                Data = creatureInfo,
            };

            tinsert(allCreatures, data);
        end
    end

    local function AlphabeticalSort(a, b)
        return a.Text < b.Text;
    end

    table.sort(allCreatures, AlphabeticalSort);
    creatureList:SetSearchDataSource(allCreatures, "Text");

    self.Populated = true;
end

------------

DatamineCreatureViewMixin = {};

function DatamineCreatureViewMixin:OnLoad()
    self:SetWaitingForCreature(nil);
    self:RegisterEvent("TOOLTIP_DATA_UPDATE");

    self.LoadingOverlay.Spinner.Text:SetText(L.CREATUREVIEW_LOADING);
end

function DatamineCreatureViewMixin:OnEvent(event, ...)
    if type(self[event]) == "function" then
        self[event](self, ...);
    end
end

function DatamineCreatureViewMixin:OnUpdate()
    self:UpdateLoadOverlayVisibility();
end

function DatamineCreatureViewMixin:TOOLTIP_DATA_UPDATE(dataInstanceID)
    if self.WaitingForCreature then
        self:TrySetCreature(self.WaitingForCreature);
    end
end

function DatamineCreatureViewMixin:UpdateLoadOverlayVisibility()
    local overlay = self.LoadingOverlay;
    if self.Loading then
        if overlay.AnimOut:IsPlaying() then
            overlay.AnimOut:Stop();
        end

        if not overlay:IsShown() then
            local reverse = true;
            overlay.AnimIn:Play(reverse);
            overlay:Show();
        end
    elseif overlay:IsShown() then
        overlay.AnimOut:Play();
    end
end

function DatamineCreatureViewMixin:SetLoading(isLoading)
    self.Loading = isLoading;
end

function DatamineCreatureViewMixin:SetWaitingForCreature(creatureID)
    self.WaitingForCreature = creatureID;
    self:SetLoading(creatureID ~= nil);
end

function DatamineCreatureViewMixin:SetCreature(creatureID)
    self.Model:SetCreature(creatureID);
    self:SetWaitingForCreature(nil);
end

function DatamineCreatureViewMixin:TrySetCreature(creatureID)
    local guid = format("unit:Creature-0-0-0-0-%s-0", creatureID);
    local data = C_TooltipInfo.GetHyperlink(guid);
    if not data then
        self:SetWaitingForCreature(creatureID);
    else
        self:SetCreature(creatureID);
    end
end