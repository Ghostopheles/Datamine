local L = Datamine.Strings;
local Registry = Datamine.EventRegistry;
local Events = Datamine.Events;
local Popup = Datamine.Popup;

------------

DatamineMapPickerEntryMixin = {};

function DatamineMapPickerEntryMixin:OnLoad()
    self.Background:ClearAllPoints();
    self.Text:SetScale(0.9);
end

------------

DatamineMapPickerMixin = {};

function DatamineMapPickerMixin:OnLoad()
    self.TitleBar.TitleText:SetText(L.MAPVIEW_PICKER_TITLE);
    self.MapList.Background_Base:Hide();
    self.MapList.LoadButton:SetText(L.MAPVIEW_LOAD_DATA_BUTTON_TEXT);

    self.MapList.HelpText:SetText(L.MAPVIEW_TEXT_HELP_HEADER);
    self.MapList.HelpTextDetails:SetText(L.MAPVIEW_TEXT_HELP);

    self.MapList.LoadButton:SetScript("OnClick", function() self:LoadMapData(); end);

    Registry:RegisterCallback(Events.MAPVIEW_MAP_DATA_LOADED, self.PopulateMapData, self);
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

function DatamineMapPickerMixin:PopulateMapData()
    local mapList = self.MapList;

    mapList.HelpText:Hide();
    mapList.HelpTextDetails:Hide();
    mapList.LoadButton:Hide();

    mapList.ScrollView:SetPadding(2, 2, 2, 2, 2);

    mapList:Reset();

    local maps = Datamine.Maps;
    for wdtID, mapInfo in pairs(maps.GetAllMaps()) do
        local data = {
            Template = "DatamineMapPickerEntryTemplate",
            Text = mapInfo.MapName,
            IsTopLevel = true,
            ShowChevron = false,
            CanExpand = false,
            Callback = function()
                Datamine.MapViewer:LoadWDT(wdtID);
            end,
            ID = wdtID,
        };

        mapList:AddTopLevelItem(data);
    end

    local function SortByText(a, b)
        return a:GetData().Text < b:GetData().Text;
    end
    mapList.DataProvider:SetSortComparator(SortByText, false);
    mapList.DataProvider.node.sortComparator = nil;
    mapList.DataProvider:Invalidate();
end