local addonName, maps = ...;

---@class DatamineMapGrids
---@field MapTextures table<number>
---@field MapTexturesN table<number>
---@field MinimapTextures table<number>

---@class DatamineMapInfo
---@field MapID number
---@field Directory string | number
---@field MapName string
---@field MapDescription0 string
---@field MapDescription1 string
---@field MapType number
---@field InstanceType number
---@field ExpansionID number
---@field ParentMapID number
---@field CosmeticParentMapID number
---@field Grids DatamineMapGrids

local MAX_TILES_X = 64;
local MAX_TILES_Y = 64;
local MAX_TILES = MAX_TILES_X * MAX_TILES_Y;

---@class DatamineMaps
Datamine.Maps = {};

---@return number maxTiles
function Datamine.Maps.GetMaxTiles()
    return MAX_TILES;
end

---@param mapName string
---@return DatamineMapInfo?
function Datamine.Maps.GetMapInfoByName(mapName)
    for _, map in pairs(maps) do
        if map.MapName == mapName then
            return map;
        end
    end
end

---@param wdtFileDataID number
---@return DatamineMapInfo?
function Datamine.Maps.GetMapInfoByWdtID(wdtFileDataID)
    return maps[wdtFileDataID];
end

function Datamine.Maps.GetMapNameByWdtID(wdtID)
    local map = maps[wdtID];
    if map then
        return map.MapName;
    end
end

function Datamine.Maps.GetMapIDByWdtID(wdtID)
    local map = maps[wdtID];
    if map then
        return map.MapID;
    end
end

function Datamine.Maps.GetWdtIDByMapID(mapID)
    for wdtID, map in pairs(maps) do
        if map.MapID == mapID then
            return wdtID;
        end
    end
end

function Datamine.Maps.GetAllMaps()
    return maps;
end

---@class DatamineGridCoords
---@field X number
---@field Y number

---@class DatamineGridData
---@field X number
---@field Y number
---@field TextureID number

---@class DatamineMapCanvasSize : DatamineGridCoords

---@class DatamineMapBounds
---@field Top number
---@field Bottom number
---@field Left number
---@field Right number

---@class DatamineMapDisplayInfo
---@field Grids table<DatamineGridData>
---@field Bounds DatamineMapBounds
---@field HasContent boolean

---@param map DatamineMapInfo | number
---@return DatamineMapDisplayInfo? mapInfo
local function PreprocessMapDisplayInfo(map)
    if type(map) == "number" then
        local info = Datamine.Maps.GetMapInfoByWdtID(map);
        if not info then
            return;
        end
        map = info;
    end

    local mapInfo = {
        Grids = {},
        Bounds = {
            Top = 0, -- x
            Bottom = 0, -- x
            Left = 0, -- y
            Right = 0, -- y
        },
        HasContent = false,
    };


    for i=1, MAX_TILES do
        local y = floor(i % MAX_TILES_Y);
        local x = floor(i / MAX_TILES_Y);

        local grid = map.Grids.MinimapTextures[i] or 0;
        local gridData = {
            Y = y,
            X = x,
            TextureID = grid,
        };

        if grid ~= 0 then
            mapInfo.HasContent = true;

            if mapInfo.Bounds.Left == 0 then
                mapInfo.Bounds.Left = y;
            end
            if mapInfo.Bounds.Top == 0 then
                mapInfo.Bounds.Top = x;
            end

            mapInfo.Bounds.Bottom = x;
            mapInfo.Bounds.Right = y;
        end

        tinsert(mapInfo.Grids, gridData);
    end

    return mapInfo;
end

---@param wdtFileDataID number
---@return DatamineMapDisplayInfo?
function Datamine.Maps.GetMapDisplayInfoByWdtID(wdtFileDataID)
    local map = maps[wdtFileDataID];
    if map then
        return PreprocessMapDisplayInfo(map);
    end
end