local L = Datamine.Strings;
local Registry = Datamine.EventRegistry;
local Events = Datamine.Events;

------------

DatamineMapViewerDetailsPanelMixin = {};

function DatamineMapViewerDetailsPanelMixin:OnLoad()
    self.minimumWidth = 150;
    self.minimumHeight = 250;

    self.maximumWidth = 300;
    self.maximumHeight = 800;

    self.expand = true;

    self.topPadding = 4;
    self.bottomPadding = 4;
    self.leftPadding = 4;
    self.rightPadding = 4;

    self.spacing = 4;

    self.Title:SetText(L.MAPVIEW_DETAILS_TITLE);
    self.Title.layoutIndex = 1;
    self.Title.align = "center";

    self.MapIDEntry.Label:SetText(L.MAPVIEW_DETAILS_LABEL_MAP);
    self.MapIDEntry.layoutIndex = self.Title.layoutIndex + 1;
    self.MapIDEntry.align = "center";
    self.MapIDEntry.EditBox:SetScript("OnEnterPressed", function()
        self:GetParent().Controller:LoadMapID(self.MapIDEntry.EditBox:GetNumber());
    end);

    self.WDTEntry.Label:SetText(L.MAPVIEW_DETAILS_LABEL_WDT);
    self.WDTEntry.layoutIndex = self.MapIDEntry.layoutIndex + 1;
    self.WDTEntry.align = "center";
    self.WDTEntry.EditBox:SetScript("OnEnterPressed", function()
        self:GetParent().Controller:LoadWDT(self.WDTEntry.EditBox:GetNumber());
    end);

    self.GoButton:SetText(L.MAPVIEW_DETAILS_GO);
    self.GoButton.layoutIndex = self.WDTEntry.layoutIndex + 1;
    self.GoButton.align = "center";
    self.GoButton:SetScript("OnClick", function()
        self:OnGoButtonClicked();
    end);

    -- IMPORTANT NOTE
    -- because of how these dumb map grids work the X and Y axes are swapped.
    -- Y is horizontal, X is vertical
    self.CoordHeader:SetText(L.MAPVIEW_DETAILS_HEADER_COORDS);
    self.CoordHeader.layoutIndex = self.GoButton.layoutIndex + 1;
    self.CoordHeader.align = "center";

    self.Warning:SetText(L.MAPVIEW_DETAILS_COORDS_WARNING);
    self.Warning.layoutIndex = self.CoordHeader.layoutIndex + 1;
    self.Warning.align = "center";

    self.CoordEntryY.Label:SetText(L.MAPVIEW_DETAILS_LABEL_Y);
    self.CoordEntryY.layoutIndex = self.Warning.layoutIndex + 1;
    self.CoordEntryY.align = "center";

    self.CoordEntryX.Label:SetText(L.MAPVIEW_DETAILS_LABEL_X);
    self.CoordEntryX.layoutIndex = self.CoordEntryY.layoutIndex + 1;
    self.CoordEntryX.align = "center";

    self.MiscHeader:SetText(L.MAPVIEW_DETAILS_HEADER_MISC);
    self.MiscHeader.layoutIndex = self.CoordEntryX.layoutIndex + 1;
    self.MiscHeader.topPadding = 10;
    self.MiscHeader.align = "center";

    self.DescriptionTitle:SetText(L.MAPVIEW_DETAILS_DESC_TITLE);
    self.DescriptionTitle.layoutIndex = self.MiscHeader.layoutIndex + 1;
    self.DescriptionTitle.align = "center";

    self.Description:SetText(L.GENERIC_NA);
    self.Description.layoutIndex = self.DescriptionTitle.layoutIndex + 1;
    self.Description.leftPadding = 4;
    self.Description.rightPadding = 4;
    self.Description.align = "center";

    self:MarkDirty();

    Registry:RegisterCallback(Events.MAPVIEW_MAP_LOADED, self.OnMapLoaded, self);
    Registry:RegisterCallback(Events.MAPVIEW_RIGHT_CLICK, self.OnMapRightClick, self);
end

function DatamineMapViewerDetailsPanelMixin:OnMapLoaded(wdtID)
    local mapInfo = Datamine.Maps.GetMapInfoByWdtID(wdtID);
    if not mapInfo then
        return;
    end

    self.MapIDEntry.EditBox:SetText(mapInfo.MapID);
    self.WDTEntry.EditBox:SetText(wdtID);

    self.CoordEntryY.EditBox:SetText("-0");
    self.CoordEntryX.EditBox:SetText("-0");

    local desc = mapInfo.MapDescription0;
    if desc and desc ~= "" then
        self.Description:SetText(desc);
        self.Description:SetJustifyH("LEFT");
    else
        self.Description:SetText(L.GENERIC_NA);
        self.Description:SetJustifyH("CENTER");
    end

    self:MarkDirty();
end

function DatamineMapViewerDetailsPanelMixin:OnMapRightClick(y, x)
    self.CoordEntryY.EditBox:SetText(y);
    self.CoordEntryX.EditBox:SetText(x);
end

function DatamineMapViewerDetailsPanelMixin:OnGoButtonClicked()
    local mapID = self.MapIDEntry.EditBox:GetNumber();
    local wdtID = self.WDTEntry.EditBox:GetNumber();

    local controller = self:GetParent().Controller;
    if mapID ~= 0 and mapID ~= controller:GetDisplayedMapID() then
        controller:LoadMapID(mapID);
    elseif wdtID ~= 0 and wdtID ~= controller:GetDisplayedWDT() then
        controller:LoadWDT(wdtID);
    end
end

------------

DatamineMapViewerMixin = {};

function DatamineMapViewerMixin:OnLoad()
    self:SetMapTitle(L.GENERIC_NA);

    Registry:RegisterCallback(Events.MAPVIEW_MAP_LOADED, self.OnMapLoaded, self);

    Datamine.MapViewer = self;
end

function DatamineMapViewerMixin:OnMapLoaded(wdtID, ...)
    local mapName = Datamine.Maps.GetMapNameByWdtID(wdtID);
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

function DatamineMapViewerMixin:HandleNoContentMap(wdtID)
    local mapName = Datamine.Maps.GetMapNameByWdtID(wdtID);
    self:SetMapTitle(mapName);
    self:ShowErrorText(L.MAPVIEW_WARNING_NO_CONTENT);
end

function DatamineMapViewerMixin:LoadWDT(...)
    self.Controller:LoadWDT(...);
end