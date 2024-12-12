---@class DatamineStyleUtil
local StyleUtil = {};

---@enum DatamineStyleUtilSide
StyleUtil.Side = {
    LEFT = 1,
    RIGHT = 2,
    TOP = 3,
    BOTTOM = 4,
    ALL = 5,
};

local BORDER_THICKNESS = 2;

local SIDE_TO_START_POINT = {
    [StyleUtil.Side.LEFT] = "BOTTOMLEFT",
    [StyleUtil.Side.RIGHT] = "BOTTOMRIGHT",
    [StyleUtil.Side.TOP] = "TOPLEFT",
    [StyleUtil.Side.BOTTOM] = "BOTTOMLEFT",
};

local SIDE_TO_END_POINT = {
    [StyleUtil.Side.LEFT] = "TOPLEFT",
    [StyleUtil.Side.RIGHT] = "TOPRIGHT",
    [StyleUtil.Side.TOP] = "TOPRIGHT",
    [StyleUtil.Side.BOTTOM] = "BOTTOMRIGHT",
};

---Adds a border to the given frame on each given side
---@param frame frame
---@param sides? DatamineStyleUtilSide | DatamineStyleUtilSide[]
---@param borderColor? ColorMixin
---@param thickness? number
function StyleUtil.AddBorder(frame, sides, borderColor, thickness)
    sides = sides or StyleUtil.Side.ALL;
    borderColor = borderColor or DatamineDarkGray;
    thickness = thickness or BORDER_THICKNESS;

    if type(sides) ~= "table" then
        if sides == StyleUtil.Side.ALL then
            sides = {
                StyleUtil.Side.LEFT,
                StyleUtil.Side.RIGHT,
                StyleUtil.Side.TOP,
                StyleUtil.Side.BOTTOM,
            };
        else
            sides = {sides};
        end
    end

    local lines = {};
    for _, side in pairs(sides) do
        local line = frame:CreateLine(nil, "ARTWORK");

        local startPoint, endPoint = SIDE_TO_START_POINT[side], SIDE_TO_END_POINT[side];

        line:SetStartPoint(startPoint, frame);
        line:SetEndPoint(endPoint, frame);

        line:SetThickness(thickness);
        line:SetColorTexture(borderColor:GetRGBA());
        lines[side] = line;
    end

    return lines;
end

---Adds a styled background to the given frame
---@param frame frame
---@param bgColor? ColorMixin
function StyleUtil.AddBackground(frame, bgColor)
    bgColor = bgColor or DatamineDarkGray;

    if frame.Background then
        return frame.Background;
    end

    frame.Background = frame:CreateTexture(nil, "BACKGROUND");
    frame.Background:SetColorTexture(bgColor:GetRGBA());
    frame.Background:SetAllPoints();

    return frame.Background;
end

------------

Datamine.StyleUtil = StyleUtil;