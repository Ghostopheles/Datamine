local L = Datamine.Strings;
local Registry = Datamine.EventRegistry;
local Events = Datamine.Events;
local Popup = Datamine.Popup;
local Search = Datamine.Search;

------------

DatamineMapPickerMixin = {};

function DatamineMapPickerMixin:OnLoad()
    local titleBar = self.TitleBar;
    local mapList = self.MapList;

    titleBar.TitleText:SetText(L.MAPVIEW_PICKER_TITLE);
    mapList.Background_Base:Hide();
    mapList.LoadButton:SetText(L.MAPVIEW_LOAD_DATA_BUTTON_TEXT);

    mapList.HelpText:SetText(L.MAPVIEW_TEXT_HELP_HEADER);
    mapList.HelpTextDetails:SetText(L.MAPVIEW_TEXT_HELP);

    mapList:SetFailText(nil, L.MAPVIEW_PICKER_SEARCH_FAIL_TEXT);

    mapList.LoadButton:SetScript("OnClick", function() self:LoadMapData(); end);

    self:SetupSearchBox();

    Registry:RegisterCallback(Events.MAPVIEW_MAP_DATA_LOADED, self.PopulateMapData, self);
end

function DatamineMapPickerMixin:OnShow()
    if self.SearchTask then
        self.SearchTask:ClearSearchQuery();
    end

    self.TitleBar.SearchBox:SetText("");
    self.MapList.ScrollBox:ScrollToBegin();
end

function DatamineMapPickerMixin:SetupSearchBox()
    local searchBox = self.TitleBar.SearchBox;
    local mapList = self.MapList;

    mapList:SetEditBox(searchBox);
end

function DatamineMapPickerMixin:LoadMapData()
    local function LoadMaps()
        if not C_AddOns.IsAddOnLoaded("Datamine_Maps") then
            C_AddOns.LoadAddOn("Datamine_Maps");
        end
    end

    local title = L.MAPVIEW_LOAD_WARNING_TITLE;
    local text = L.MAPVIEW_LOAD_WARNING_TEXT;
    Popup.ShowPopup(title, text, LoadMaps, Popup.PopupType.SINGLE);
end

function DatamineMapPickerMixin:SetSelectedWDT(wdtID)
    Datamine.MapViewer:LoadWDT(wdtID);
end

function DatamineMapPickerMixin:PopulateMapData()
    local mapList = self.MapList;

    mapList.HelpText:Hide();
    mapList.HelpTextDetails:Hide();
    mapList.LoadButton:Hide();

    mapList.ScrollView:SetPadding(2, 2, 2, 2, 2);

    local maps = Datamine.Maps;
    local allMaps = {};
    for wdtID, mapInfo in pairs(maps.GetAllMaps()) do
        local data = {
            ID = wdtID,
            Text = mapInfo.MapName,
            TextScale = 0.9,
            Callback = function(frame)
                self.MapList.SelectionBehavior:Select(frame);
                self:SetSelectedWDT(wdtID);
            end,
            BackgroundAlpha = 0.5,
        };

        tinsert(allMaps, data);
    end

    local function AlphabeticalSort(a, b)
        return a.Text < b.Text;
    end

    table.sort(allMaps, AlphabeticalSort);
    mapList:SetSearchDataSource(allMaps, "Text");
end