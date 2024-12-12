local L = Datamine.Strings;
local Registry = Datamine.EventRegistry;
local Events = Datamine.Events;

------------

DatamineCreaturePickerMixin = {};

function DatamineCreaturePickerMixin:OnLoad()
    local titleBar = self.TitleBar;
    local creatureList = self.CreatureList;

    titleBar.TitleText:SetText(L.CREATUREVIEW_LIST_TITLE);
    creatureList.Background_Base:Hide();

    creatureList:SetHelpText(L.CREATUREVIEW_TEXT_HELP_HEADER, L.CREATUREVIEW_TEXT_HELP);
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
    self:GetParent():TrySetCreature(creatureID);
end

function DatamineCreaturePickerMixin:PopulateCreatures()
    local creatureList = self.CreatureList;

    creatureList.HelpText:Hide();
    creatureList.HelpTextDetails:Hide();

    creatureList.ScrollView:SetPadding(2, 2, 2, 2, 2);

    local function OnClickCallback(frame)
        creatureList.SelectionBehavior:Select(frame);
        self:SetSelectedCreature(frame.Data.ID);
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
                };

                parentCreatures[name] = data;
                tinsert(allCreatures, data);
            end
        end
    end

    local function AlphabeticalSort(a, b)
        return strcmputf8i(a.Text, b.Text) < 0;
    end

    table.sort(allCreatures, AlphabeticalSort);
    creatureList:SetSearchDataSource(allCreatures, "Text");

    self.ParentCreatures = parentCreatures;
    self.Populated = true;

    self.TitleBar.TitleText:SetText(format(L.CREATUREVIEW_LIST_TITLE, #allCreatures));
end

------------

DatamineCreatureDetailsMixin = {};

function DatamineCreatureDetailsMixin:OnLoad()
    self.SelectedVariant = nil;

    Registry:RegisterCallback(Events.CREATUREVIEW_CREATURE_LOADED, self.OnCreatureLoaded, self);

    self.TitleBar.Title:SetText(L.CREATUREVIEW_DETAILS_TITLE);

    Datamine.StyleUtil.AddBorder(self);
end

function DatamineCreatureDetailsMixin:SetupStrings()
    local creatureID = self:GetParent():GetViewingCreature();
    local creature = Datamine.Database:GetCreatureEntryByID(creatureID);
    local displayID = self:GetParent().Model:GetDisplayInfo();

    local idText = format("#%s", creatureID);
    local locale = GetLocale();
    local nameText = creature.Name[locale];
    local locText = locale;

    self.Identification.CreatureID:SetText(idText);
    self.Identification.CreatureName:SetText(nameText);
    self.Identification.Locale:SetText(locText);
    self.Identification.DisplayID:SetText(displayID);
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
    if not variants or self.SelectedVariant then
        return;
    end
end

function DatamineCreatureDetailsMixin:SetVariants(variants)
    local function OnClick(frame)
        local creatureID = frame.Data.ID;
        self.SelectedVariant = creatureID;
        self:GetParent():TrySetCreature(creatureID);
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
        self.Model:SetCamera(2);
        self.Model:RefreshCamera();
        self.Model:SetRotation(0);
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
    elseif overlay:IsShown() and not overlay.AnimOut:IsPlaying() then
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