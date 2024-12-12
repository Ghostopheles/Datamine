---@class DatamineStyleUtil
local StyleUtil = {};

local function CreateLine(parent, startPoint, endPoint, color, thickness)
    local line = parent:CreateLine();
    line:SetStartPoint(startPoint);
    line:SetEndPoint(endPoint);
    line:SetThickness(thickness);
    line:SetColorTexture(color:GetRGBA());

    return line;
end

---@param parent FrameScriptObject
---@param color ColorMixin?
---@param thickness number?
function StyleUtil.AddBorder(parent, color, thickness)
    color = color or DatamineDarkGray;
    thickness = thickness or 2;

    local border = {};
    border.Left = CreateLine(parent, "BOTTOMLEFT", "TOPLEFT", color, thickness);
    border.Bottom = CreateLine(parent, "BOTTOMLEFT", "BOTTOMRIGHT", color, thickness);
    border.Right = CreateLine(parent, "BOTTOMRIGHT", "TOPRIGHT", color, thickness);
    border.Top = CreateLine(parent, "TOPLEFT", "TOPRIGHT", color, thickness);

    return border;
end

------------

Datamine.StyleUtil = StyleUtil;