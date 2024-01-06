local moduleName = "UIMain";
local Constants = Datamine.Constants;
local DataTypes = Constants.DataTypes;

Datamine.Unified = {};

---@class CustomAtlasInfo
---@field width number
---@field height number
---@field left number
---@field right number
---@field top number
---@field bottom number

---@class CustomAtlasTexture : Texture
---@field OnLoad_Base function

---@param w number
---@param h number
---@param l number
---@param r number
---@param t number
---@param b number
---@return CustomAtlasInfo
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

local UIToolsFileName = "Blizzard_UITools.blp";

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

local ToolbarFileName = "Toolbar.png";
local ToolbarAtlasInfo = {
    ["custom-toolbar-select"] = CreateAtlasInfo(30, 30, 0, 0.125, 0, 0.125),
    ["custom-toolbar-rotate"] = CreateAtlasInfo(30, 30, 0.25, 0.375, 0, 0.125),
    ["custom-toolbar-localpivot"] = CreateAtlasInfo(30, 30, 0.625, 0.75, 0, 0.125),
    ["custom-toolbar-worldpivot"] = CreateAtlasInfo(30, 30, 0.5, 0.625, 0, 0.125),
    ["custom-toolbar-basepivot"] = CreateAtlasInfo(30, 30, 0.875, 1, 0, 0.125),
    ["custom-toolbar-centerpivot"] = CreateAtlasInfo(30, 30, 0.75, 0.875, 0, 0.125),
    ["custom-toolbar-projects"] = CreateAtlasInfo(30, 30, 0, 0.125, 0.125, 0.25),
    ["custom-toolbar-scale"] = CreateAtlasInfo(30, 30, 0.375, 0.5, 0, 0.125),
    ["custom-toolbar-move"] = CreateAtlasInfo(30, 30, 0.125, 0.25, 0, 0.125)
};

Datamine.CustomAtlas = {};
Datamine.CustomAtlas.BasePath = [[Interface\AddOns\Datamine\Assets\CustomAtlas\]];
Datamine.CustomAtlas.AtlasInfo = {
    [UIToolsFileName] = UIToolsAtlasInfo,
    [ToolbarFileName] = ToolbarAtlasInfo,
};

---@param fileName string
---@param search? boolean Search existing filenames for the extension
---@return string? fileExtension
function Datamine.CustomAtlas:GetFileExtension(fileName, search)
    local pattern = "%.%w+$";
    local extension = fileName:match(pattern);

    -- if the file has no extension, then we check our existing files for the file with the given name
    if extension then
        return extension
    elseif search then
        for fileNameWithExtension, _ in pairs(self.AtlasInfo) do
            local searchPattern = fileName .. pattern;
            if fileNameWithExtension:match(searchPattern) then
                return fileNameWithExtension:match(pattern);
            end
        end
    end
end

---@param fileNameOrPath string
---@return boolean isFilePath
function Datamine.CustomAtlas:IsFilePath(fileNameOrPath)
    local pattern = "[\\/]";
    return fileNameOrPath:find(pattern) ~= nil;
end

---@param fileName string
---@return string? filePath
function Datamine.CustomAtlas:GetAtlasFilePath(fileName)
    if self:GetFileExtension(fileName) then
        return self.BasePath .. fileName;
    end
end

---@param filePath string
---@return string? fileName
function Datamine.CustomAtlas:GetAtlasFileName(filePath)
    return self.FilePathsRev[filePath];
end

---@param fileNameOrPath string
---@param atlasName string
---@return CustomAtlasInfo? atlasInfo
function Datamine.CustomAtlas:GetAtlasInfo(fileNameOrPath, atlasName)
    assert(fileNameOrPath, "Missing FileName or FilePath");
    assert(atlasName, "Missing atlas name.");

    local fileName;
    if self:IsFilePath(fileNameOrPath) then
        fileName = self:GetAtlasFileName(fileNameOrPath);
        if not fileName then
            return;
        end
    else
        fileName = fileNameOrPath;
    end

    local extension = self:GetFileExtension(fileName, true);
    local atlas = self.AtlasInfo[fileName];
    if (not atlas) and (extension ~= nil) then
        atlas = self.AtlasInfo[fileName .. extension];
    end

    return atlas[atlasName];
end

---@param fileNameOrPath string
---@param atlasName string
---@param useAtlasSize? boolean
---@param parent? any
---@param name? string
---@param drawLayer? string
---@return CustomAtlasTexture Texture
function Datamine.CustomAtlas:CreateCustomAtlasTexture(fileNameOrPath, atlasName, useAtlasSize, parent, name, drawLayer)
    parent = parent or UIParent;

    ---@type CustomAtlasTexture
    ---@diagnostic disable-next-line: assign-type-mismatch
    local tex = parent:CreateTexture(name, drawLayer, "DatamineCustomAtlasTemplate");
    if self:IsFilePath(fileNameOrPath) then
        tex.FilePath = fileNameOrPath;
    else
        tex.FileName = fileNameOrPath;
    end

    tex.AtlasName = atlasName;
    tex.UseAtlasSize = useAtlasSize;
    tex:OnLoad_Base();
    return tex;
end

-------------

local DEFAULT_SEARCH_MODE = DataTypes.Item;

function Datamine.Unified.GetUI()
    return DatamineUnifiedFrame;
end

function Datamine.Unified.GetExplorer()
    return Datamine.Unified.GetUI().Workspace.ExplorerTab;
end

function Datamine.Unified.GetModelView()
    return Datamine.Unified.GetUI().Workspace.ModelViewTab;
end


function Datamine.Unified.GetExplorerDefaultSearchMode()
    return DEFAULT_SEARCH_MODE;
end

function Datamine.Unified.GetExplorerSearchMode()
    if not DatamineUnifiedFrame.Workspace then
        return Datamine.Unified.GetExplorerDefaultSearchMode();
    end

    return DatamineUnifiedFrame.Workspace.ExplorerTab:GetSearchMode();
end

function Datamine.Unified.GetExplorerSearchModeName()
    local searchMode = Datamine.Unified.GetExplorerSearchMode();
    return Datamine.GetEnumValueName(DataTypes, searchMode);
end

function Datamine.Unified.GetExplorerDataID()
    return Datamine.Unified.GetExplorer():GetCurrentDataID();
end

function Datamine.Unified.GetExplorerData()
    return Datamine.Unified.GetExplorer().DataFrame:GetCurrentData();
end

function Datamine.Unified.AddToolbarButton(atlasName, callback)
    local toolbar = DatamineUnifiedFrame.Toolbar;
    toolbar:AddButton(atlasName, callback);
end

-------------

do
    local helpString = "Toggle the Datamine UI.";
    Datamine.Slash:RegisterCommand("ui", function() DatamineUnifiedFrame:Toggle(); end, helpString, moduleName);
end