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
end

function DatamineCreaturePickerMixin:SetupSearchBox()
    local searchBox = self.TitleBar.SearchBox;
    local creatureList = self.CreatureList;

    creatureList:SetEditBox(searchBox);
end

function DatamineCreaturePickerMixin:SetSelectedCreature(creatureID)
    local function FindByCreatureID(_, element)
        return element.ID == self.SelectedCreature;
    end

    local oldFrame = self.CreatureList.ScrollView:FindFrameByPredicate(FindByCreatureID);
    if oldFrame then
        oldFrame.SelectionBorder:Hide();
    end

    self.SelectedCreature = creatureID;

    local newFrame = self.CreatureList.ScrollView:FindFrameByPredicate(FindByCreatureID);
    newFrame.SelectionBorder:Show();

    self:GetParent():TrySetCreature(creatureID);
end

function DatamineCreaturePickerMixin:PopulateCreatures()
    local creatureList = self.CreatureList;

    creatureList.HelpText:Hide();
    creatureList.HelpTextDetails:Hide();

    creatureList.ScrollView:SetPadding(2, 2, 2, 2, 2);

    local function OnClickCallback(frame)
        self:SetSelectedCreature(frame.Data.ID);
    end

    local function SelectionCallback(frame)
        return frame.Data.ID == self.SelectedCreature;
    end

    local allCreatures = {};
    local parentCreatures = {};
    local creatures = Datamine.Database:GetAllCreatureEntries();
    for creatureID, creatureInfo in pairs(creatures) do
        local locale = GetLocale();
        local name = creatureInfo.Name[locale];
        if name then
            local parent = parentCreatures[name];
            if parent then
                if not parent.Variants then
                    parent.Variants = {};
                end

                local data = {
                    CreatureID = creatureID,
                    CreatureInfo = creatureInfo,
                };

                tinsert(parent.Variants, data);
            else
                ---@type DatamineSearchableEntryData
                local data = {
                    ID = creatureID,
                    Text = name,
                    TextScale = 0.9,
                    Callback = OnClickCallback,
                    BackgroundAlpha = 0.5,
                    Misc = creatureInfo,
                    SelectionCallback = SelectionCallback,
                };

                parentCreatures[name] = data;
                tinsert(allCreatures, data);
            end
        end
    end

    local function AlphabeticalSort(a, b)
        return a.Text < b.Text;
    end

    table.sort(allCreatures, AlphabeticalSort);
    creatureList:SetSearchDataSource(allCreatures, "Text");

    self.ParentCreatures = parentCreatures;
    self.Populated = true;
end

------------

DatamineCreatureDetailsMixin = {};

function DatamineCreatureDetailsMixin:OnLoad()
    self.SelectedVariant = nil;

    Registry:RegisterCallback(Events.CREATUREVIEW_CREATURE_LOADED, self.OnCreatureLoaded, self);
end

function DatamineCreatureDetailsMixin:SetupStrings()
    local creatureID = self:GetParent():GetViewingCreature();
    local creature = Datamine.Database:GetCreatureEntryByID(creatureID);

    local idText = format("#%s", creatureID);
    local locale = GetLocale();
    local nameText = creature.Name[locale];
    local locText = locale;

    self.Identification.CreatureID:SetText(idText);
    self.Identification.CreatureName:SetText(nameText);
    self.Identification.Locale:SetText(locText);
end

function DatamineCreatureDetailsMixin:SetupVariantsList()
    local variants = self.Variants;
    local searchBox = variants.SearchBox;
    local list = variants.List;

    list:SetEditBox(searchBox);
end

function DatamineCreatureDetailsMixin:OnCreatureLoaded()
    self:SetupStrings();
    local picker = self:GetParent().CreaturePicker;
    if not picker.ParentCreatures then
        return;
    end

    local creatureID = self:GetParent():GetViewingCreature();
    local creature = Datamine.Database:GetCreatureEntryByID(creatureID);
    local locale = GetLocale();
    local name = creature.Name[locale];

    local parent = picker.ParentCreatures[name];
    if not parent then
        return;
    end

    local variants = parent.Variants;
    if not variants then
        return;
    end

    self:SetVariants(variants);
end

function DatamineCreatureDetailsMixin:SetVariants(variants)
    local function OnClick(frame)
        print(frame.Data.ID);
    end

    DevTools_Dump(variants);

    local function SelectionCallback(frame)
        return frame.Data.ID == self.SelectedVariant;
    end

    local allVariants = {};
    local locale = GetLocale();
    for _, tbl in pairs(variants) do
        ---@type DatamineSearchableEntryData
        local data = {
            ID = tbl.CreatureID,
            Text = tbl.CreatureInfo.Name[locale],
            TextScale = 0.9,
            TextKey = "ID",
            Callback = OnClick,
            BackgroundAlpha = 0.5,
            Misc = tbl.CreatureInfo,
            SelectionCallback = SelectionCallback,
        };
        tinsert(allVariants, data);
    end

    table.sort(allVariants, function(a, b) return a.ID > b.ID; end);
    self.Variants.List:SetSearchDataSource(allVariants, "ID");
end

------------

DatamineCreatureViewMixin = {};

function DatamineCreatureViewMixin:OnLoad()
    self:SetWaitingForCreature(nil);
    self:RegisterEvent("TOOLTIP_DATA_UPDATE");

    self.LoadingOverlay.Spinner.Text:SetText(L.CREATUREVIEW_LOADING);

    self.Model:SetScript("OnModelLoaded", function()
        self:SetWaitingForCreature(nil);
    end);

    Registry:RegisterCallback(Events.CREATUREVIEW_CREATURE_LOADED, self.OnCreatureLoaded, self);
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

function DatamineCreatureViewMixin:OnCreatureLoaded(creatureID)
    self:SetLoading(false);
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
    if creatureID then
        self:SetLoading(true);
    end
    self.WaitingForCreature = creatureID;
end

function DatamineCreatureViewMixin:SetViewingCreature(creatureID)
    self.ViewingCreature = creatureID;
    Registry:TriggerEvent(Events.CREATUREVIEW_CREATURE_LOADED, creatureID);
end

function DatamineCreatureViewMixin:GetViewingCreature()
    return self.ViewingCreature;
end

function DatamineCreatureViewMixin:SetCreature(creatureID)
    self.Model:SetCreature(creatureID);
    self:SetViewingCreature(creatureID);
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