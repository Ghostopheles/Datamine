Datamine.Unified = {};

---@param w number
---@param h number
---@param l number
---@param r number
---@param t number
---@param b number
local function CreateAtlasInfo(w, h, l, r, t, b)
    return {
        width = w,
        height = h,
        left = l,
        right = r,
        top = t,
        bottom = b
    };
end

local UIToolsFileName = [[Interface\AddOns\Datamine\Assets\Blizzard_UITools.blp]];

-- need to manually copy over the fucking atlas info because Blizzard decided to remove these textures from the game
local UIToolsAtlasInfo = {
    -- Buttons
    ["uitools-button-background-active"] = CreateAtlasInfo(90, 34, 0.0009765625, 0.0888671875, 0.0078125, 0.2734375),
    ["uitools-button-background-default"] = CreateAtlasInfo(90, 34, 0.0908203125, 0.1787109375, 0.0078125, 0.2734375),
    ["uitools-button-background-disabled"] = CreateAtlasInfo(90, 34, 0.0908203125, 0.1787109375, 0.4609375, 0.7265625),

    -- Icons
    ["uitools-icon-highlight"] = CreateAtlasInfo(24, 24, 0.0009765625, 0.0244140625, 0.2890625, 0.4765625),
    ["uitools-icon-window-resize-down"] = CreateAtlasInfo(8, 8, 0.0478515625, 0.0556640625, 0.2890625, 0.3515625),
    ["uitools-icon-window-resize-over"] = CreateAtlasInfo(8, 8, 0.0703125, 0.078125, 0.2890625, 0.3515625),
    ["uitools-icon-window-resize"] = CreateAtlasInfo(8, 8, 0.080078125, 0.087890625, 0.2890625, 0.3515625),
    ["uitools-icon-search"] = CreateAtlasInfo(20, 20, 0.0908203125, 0.1103515625, 0.2890625, 0.4453125),
    ["uitools-icon-checkmark"] = CreateAtlasInfo(22, 20, 0.0224609375, 0.0439453125, 0.515625, 0.671875),
    ["uitools-icon-chevron-left"] = CreateAtlasInfo(20, 20, 0.0458984375, 0.0654296875, 0.515625, 0.671875),
    ["uitools-icon-chevron-right"] = CreateAtlasInfo(20, 20, 0.0009765625, 0.0205078125, 0.8359375, 0.9921875),
    ["uitools-icon-chevron-down"] = CreateAtlasInfo(20, 20, 0.0009765625, 0.0205078125, 0.4921875, 0.6484375),
    ["uitools-icon-close"] = CreateAtlasInfo(20, 20, 0.0673828125, 0.0869140625, 0.515625, 0.671875),
    ["uitools-icon-checkbox"] = CreateAtlasInfo(20, 20, 0.0009765625, 0.0205078125, 0.6640625, 0.8203125),
    ["uitools-icon-minimize"] = CreateAtlasInfo(20, 20, 0.0224609375, 0.0419921875, 0.6875, 0.84375),
    ["uitools-icon-refresh"] = CreateAtlasInfo(20, 20, 0.0458984375, 0.0654296875, 0.6875, 0.84375),

    -- Scrollbar
    ["uitools-scrollbar-chevron-bottom"] = CreateAtlasInfo(20, 20, 0.0263671875, 0.0458984375, 0.2890625, 0.4453125),
    ["uitools-scrollbar-track"] = CreateAtlasInfo(8, 9, 0.060546875, 0.068359375, 0.2890625, 0.359375),
    ["uitools-scrollbar-chevron-bottom-disabled"] = CreateAtlasInfo(20, 20, 0.1123046875, 0.1318359375, 0.2890625, 0.4453125),
    ["uitools-scrollbar-thumb-over"] = CreateAtlasInfo(8, 9, 0.0478515625, 0.0556640625, 0.3671875, 0.4375),
    ["uitools-scrollbar-thumb-down"] = CreateAtlasInfo(8, 9, 0.060546875, 0.068359375, 0.375, 0.4453125),
    ["uitools-scrollbar-thumb"] = CreateAtlasInfo(8, 9, 0.0703125, 0.078125, 0.3671875, 0.4375),
    ["uitools-scrollbar-chevron-top"] = CreateAtlasInfo(20, 20, 0.1337890625, 0.1533203125, 0.2890625, 0.4453125),
    ["uitools-scrollbar-chevron-bottom-down"] = CreateAtlasInfo(20, 20, 0.1552734375, 0.1748046875, 0.2890625, 0.4453125),
    ["uitools-scrollbar-chevron-bottom-over"] = CreateAtlasInfo(20, 20, 0.0673828125, 0.0869140625, 0.6875, 0.84375),
    ["uitools-scrollbar-chevron-top-over"] = CreateAtlasInfo(20, 20, 0.0908203125, 0.1103515625, 0.7421875, 0.8984375),
    ["uitools-scrollbar-chevron-top-down"] = CreateAtlasInfo(20, 20, 0.1123046875, 0.1318359375, 0.7421875, 0.8984375),
    ["uitools-scrollbar-chevron-top-disabled"] = CreateAtlasInfo(20, 20, 0.1591796875, 0.1787109375, 0.7421875, 0.8984375),

    -- Tabs
    ["uitools-tab-background-default"] = CreateAtlasInfo(128, 32, 0.1806640625, 0.3056640625, 0.2734375, 0.5234375),
    ["uitools-tab-background-active"] = CreateAtlasInfo(128, 32, 0.1806640625, 0.3056640625, 0.0078125, 0.2578125),
    ["uitools-tab-gradient"] = CreateAtlasInfo(32, 32, 0.1806640625, 0.2119140625, 0.5390625, 0.7890625),

    -- Window
    ["uitools-window-background"] = CreateAtlasInfo(34, 34, 0.2138671875, 0.2470703125, 0.5390625, 0.8046875),
    ["uitools-window-background-shadow"] = CreateAtlasInfo(94, 94, 0.3076171875, 0.3994140625, 0.0078125, 0.7421875),

    -- Row
    ["uitools-row-background-01"] = CreateAtlasInfo(552, 32, 0.4013671875, 0.9404296875, 0.2734375, 0.5234375),
    ["uitools-row-background-02"] = CreateAtlasInfo(552, 32, 0.4013671875, 0.9404296875, 0.0078125, 0.2578125),
    ["uitools-row-background-hover"] = CreateAtlasInfo(552, 32, 0.4013671875, 0.9404296875, 0.5390625, 0.7890625),

    -- NineSliceTool
    ["NineSliceTool-DottedLine-Horizontal"] = CreateAtlasInfo(23, 1, 0.0224609375, 0.044921875, 0.4921875, 0.5),
    ["NineSliceTool-DottedLine-Vertical"] = CreateAtlasInfo(1, 23, 0.0576171875, 0.05859375, 0.2890625, 0.46875),

    -- Misc
    ["uitools-title-bar-background"] = CreateAtlasInfo(34, 34, 0.2490234375, 0.2822265625, 0.5390625, 0.8046875),
    ["uitools-search-background"] = CreateAtlasInfo(24, 24, 0.1337890625, 0.1572265625, 0.7421875, 0.9296875),
};

Datamine.Unified.AtlasInfo = {};
Datamine.Unified.AtlasInfo.Categories = {
    UITools = UIToolsAtlasInfo
};
Datamine.Unified.AtlasInfo.FileNames = {
    UITools = UIToolsFileName
};

function Datamine.Unified.AtlasInfo:GetAtlasFileName(category)
    return self.FileNames[category];
end

function Datamine.Unified.AtlasInfo:GetAtlasInfo(category, atlasName)
    return self.Categories[category] and self.Categories[category][atlasName];
end