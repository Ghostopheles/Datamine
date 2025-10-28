local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;
local L = Datamine.Strings;

------------

local GRAPH_PAD_LEFT = 50;
local GRAPH_PAD_RIGHT = 30;
local GRAPH_PAD_TOP = 30;
local GRAPH_PAD_BOTTOM = 50;
local GRAPH_PAD_LINE = 50;

------------
-- appearance config

local CFG = DatamineConfig;

local LINE_COLOR = CFG.CurveViewerLineColor and CreateColorFromHexString(CFG.CurveViewerLineColor) or WHITE_FONT_COLOR;
local LINE_THICKNESS = CFG.CurveViewerLineThickness or 2;

local POINT_COLOR = CFG.CurveViewerPointColor and CreateColorFromHexString(CFG.CurveViewerPointColor) or WHITE_FONT_COLOR;
local POINT_SIZE = CFG.CurveVIewerPointSize or 12;

---@param color ColorMixin
local function SetLineColor(color)
    LINE_COLOR = color;
    CFG.CurveViewerLineColor = color:GenerateHexColor();
    Registry:TriggerEvent(Events.CURVEVIEWER_APPEARANCE_UPDATED);
end

---@param thickness number
local function SetLineThickness(thickness)
    LINE_THICKNESS = thickness;
    CFG.CurveViewerLineThickness = thickness;
    Registry:TriggerEvent(Events.CURVEVIEWER_APPEARANCE_UPDATED);
end

---@param color ColorMixin
local function SetPointColor(color)
    POINT_COLOR = color;
    CFG.CurveViewerPointColor = color:GenerateHexColor();
    Registry:TriggerEvent(Events.CURVEVIEWER_APPEARANCE_UPDATED);
end

---@param size number
local function SetPointSize(size)
    POINT_SIZE = size;
    CFG.CurveViewerPointSize = size;
    Registry:TriggerEvent(Events.CURVEVIEWER_APPEARANCE_UPDATED);
end

------------

local function CreateLinePool(parent)
    local function CreateLine()
        local line = parent:CreateLine(nil, "ARTWORK");
        line:SetColorTexture(LINE_COLOR:GetRGBA());
        line:SetThickness(LINE_THICKNESS);
        return line;
    end

    local function ResetLine(_, line)
        line:ClearAllPoints();
    end

    return CreateObjectPool(CreateLine, ResetLine);
end

local function CreateFontStringPool(parent)
    local function CreateFontString()
        local fontString = parent:CreateFontString(nil, "ARTWORK", "DatamineCleanFont");
        return fontString;
    end

    local function ResetFontString(_, fontString)
        fontString:ClearAllPoints();
        fontString:SetText("");
    end

    return CreateObjectPool(CreateFontString, ResetFontString);
end

local function CreateCurvePointPool(parent)
    local function CreatePoint()
        local point = parent:CreateTexture(nil, "ARTWORK");
        point:SetColorTexture(POINT_COLOR:GetRGBA());
        point:SetSize(POINT_SIZE, POINT_SIZE);
        return point;
    end

    local function ResetPoint(_, point)
        point:ClearAllPoints();
    end

    return CreateObjectPool(CreatePoint, ResetPoint);
end

------------

DatamineCurveViewerTabMixin = {};

function DatamineCurveViewerTabMixin:OnLoad()
    Registry:RegisterCallback(Events.UI_RESIZE_END, self.OnUIResizeEnd, self);
    Registry:RegisterCallback(Events.CURVEVIEWER_PLOT_CURVE, self.OnRequestPlotCurve, self);

    self.GridLinesPool = CreateLinePool(self);
    self.CurveLinesPool = CreateLinePool(self);
    self.CurvePointsPool = CreateCurvePointPool(self);
    self.LegendPool = CreateFontStringPool(self);

    MEOW = self;
end

function DatamineCurveViewerTabMixin:OnShow()
    self:SetupGraph();
end

function DatamineCurveViewerTabMixin:OnRequestPlotCurve(curveID)
end

function DatamineCurveViewerTabMixin:OnUIResizeEnd()
    self.GraphSetupDone = false;
    self.GridLinesPool:ReleaseAll();
    self.LegendPool:ReleaseAll();
    self:SetupGraph();
end

function DatamineCurveViewerTabMixin:SetupGraph()
    if self.GraphSetupDone then
        return;
    end

    local width, height = self:GetSize();
    local numHorizontalLines = math.floor((height - GRAPH_PAD_TOP - GRAPH_PAD_BOTTOM) / GRAPH_PAD_LINE);
    local numVerticalLines = math.floor((width - GRAPH_PAD_LEFT - GRAPH_PAD_RIGHT) / GRAPH_PAD_LINE);

    local horizontalLines = {};
    for i = 1, numHorizontalLines do
        local line = self.GridLinesPool:Acquire();
        local yOffset = GRAPH_PAD_TOP + (i * GRAPH_PAD_LINE);
        line:SetStartPoint("TOPLEFT", self, GRAPH_PAD_LEFT, -yOffset);
        line:SetEndPoint("TOPRIGHT", self, -GRAPH_PAD_RIGHT, -yOffset);
        tinsert(horizontalLines, line);
    end

    local verticalLines = {};
    for i = 1, numVerticalLines do
        local line = self.GridLinesPool:Acquire();
        local xOffset = GRAPH_PAD_LEFT + (i * GRAPH_PAD_LINE);
        line:SetStartPoint("TOPLEFT", self, xOffset, -GRAPH_PAD_TOP);
        line:SetEndPoint("BOTTOMLEFT", self, xOffset, GRAPH_PAD_BOTTOM);
        tinsert(verticalLines, line);
    end

    local yLabels = {};
    for i = 1, numHorizontalLines do
        local label = self.LegendPool:Acquire();
        local yOffset = GRAPH_PAD_TOP + (i * GRAPH_PAD_LINE);
        label:SetPoint("RIGHT", self, "TOPLEFT", GRAPH_PAD_LEFT - 5, -yOffset);
        label:SetText(string.format("%.2f", (numHorizontalLines - i) * 0.1));
        tinsert(yLabels, label);
    end

    local xLabels = {};
    for i = 1, numVerticalLines do
        local label = self.LegendPool:Acquire();
        local xOffset = GRAPH_PAD_LEFT + (i * GRAPH_PAD_LINE);
        label:SetPoint("TOP", self, "TOPLEFT", xOffset, - (height - GRAPH_PAD_BOTTOM + 5));
        label:SetText(string.format("%.2f", (i - 1) * 0.1));
        tinsert(xLabels, label);
    end

    self.Labels_X = xLabels;
    self.Labels_Y = yLabels;

    self.GraphSetupDone = true;
end

function DatamineCurveViewerTabMixin:CalculateOffsetForGridCoordinate(x, y)
    local xOffset = GRAPH_PAD_LEFT + (x * GRAPH_PAD_LINE);
    local yOffset = GRAPH_PAD_BOTTOM + (y * GRAPH_PAD_LINE);
    return xOffset, yOffset;
end

function DatamineCurveViewerTabMixin:PlotPointAt(x, y)
    local point = self.CurvePointsPool:Acquire();
    local xOffset, yOffset = self:CalculateOffsetForGridCoordinate(x, y);
    point:SetPoint("CENTER", self, "BOTTOMLEFT", xOffset, yOffset);
    return point;
end

--TODO: Rescale graph according to the min, max, and step values set

function DatamineCurveViewerTabMixin:TestPlot()
    local curveID = 86052;
    for x=0, 50, 1 do
        local y = C_CurveUtil.EvaluateGameCurve(curveID, x);
        self:PlotPointAt(x, y);
    end
end