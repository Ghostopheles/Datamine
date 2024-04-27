local L = Datamine.Strings;
local Registry = Datamine.EventRegistry;
local Events = Datamine.Events;

------------

DatamineMapViewerMixin = {};

function DatamineMapViewerMixin:OnLoad()
    self:SetMapTitle(L.GENERIC_NA);

    Registry:RegisterCallback(Events.MAPVIEW_MAP_LOADED, self.OnMapLoaded, self);

    Datamine.MapViewer = self;
end

function DatamineMapViewerMixin:OnMapLoaded(wdtID, ...)
    local mapName = Datamine.Maps.GetMapNameByWdtID(wdtID);
    print("Loaded map: " .. mapName);
    self:SetMapTitle(mapName);

    self.ErrorText:Hide();
end

function DatamineMapViewerMixin:SetMapTitle(mapName)
    local mapTitle = format(L.MAPVIEW_MAP_TITLE, mapName);
    self.MapTitleContainer.Text:SetText(mapTitle);
end

function DatamineMapViewerMixin:ShowErrorText(text)
    self.ErrorText:SetText(text);
    self.ErrorText:Show();
end

function DatamineMapViewerMixin:HandleNoContentMap()
    print("no content")
    self:ShowErrorText(L.MAPVIEW_WARNING_NO_CONTENT);
end

function DatamineMapViewerMixin:LoadWDT(...)
    self.Controller:LoadWDT(...);
end