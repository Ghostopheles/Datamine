local addonName, maps = ...;

---@class DatamineMapGrids
---@field MapTextures table<number>
---@field MapTexturesN table<number>
---@field MinimapTextures table<number>

---@class DatamineMapInfo
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

---@param mapName string
---@return DatamineMapInfo?
function Datamine.Maps.GetMapInfoByName(mapName)
    for map in pairs(maps) do
        if map.MapName == mapName then
            return map
        end
    end
end

---@param wdtFileDataID number
---@return DatamineMapInfo?
function Datamine.Maps.GetMapInfoByWdtID(wdtFileDataID)
    return maps[wdtFileDataID];
end

function Datamine.Maps.ConvertCoordsToLookupString(x, y)
    return format("%02d,%02d", x, y);
end

---@class DatamineGridCoords
---@field X number
---@field Y number

---@class DatamineGridData
---@field X number
---@field Y number
---@field TextureID number
---@field NormalizedCoords DatamineGridCoords

---@class DatamineMapCanvasSize : DatamineGridCoords

---@class DatamineMapBounds
---@field TopLeft DatamineGridCoords
---@field BottomRight DatamineGridCoords

---@class DatamineMapDisplayInfo
---@field Grids table<DatamineGridData>
---@field Bounds DatamineMapBounds
---@field CanvasSize DatamineMapCanvasSize

local function GetDistance(x1, y1, x2, y2)
    local xDist = math.abs(x1 - x2);
    local yDist = math.abs(y1 - y2);
    return (xDist + yDist) / 2;
end

---@param map DatamineMapInfo | number
---@return DatamineMapDisplayInfo? mapInfo
local function RemoveEmptyGridsFromMap(map)
    if type(map) == "number" then
        local info = Datamine.Maps.GetMapInfoByWdtID(map);
        if not info then
            return;
        end
        map = info;
    end

    local y, x = 0, 0;
    local mapInfo = {
        Grids = {},
        Bounds = {
            TopLeft = {
                Y = 0,
                X = 0
            },
            BottomRight = {
                Y = 0,
                X = 0
            },
        },
    };

    local halfway = 31;
    local topLeft = mapInfo.Bounds.TopLeft;
    local bottomRight = mapInfo.Bounds.BottomRight;
    for _, grid in pairs(map.Grids.MinimapTextures) do
        local isTop = x < halfway;
        local isLeft = y < halfway;

        local topLeftFound = false;

        local gridData = {
            Y = y,
            X = x,
            TextureID = grid,
        };

        if grid ~= 0 then
            tinsert(mapInfo.Grids, gridData);
            if (isLeft and isTop) and (topLeft.X == 0 and topLeft.Y == 0) then
                topLeft.X = x;
                topLeft.Y = y;
                topLeftFound = true;
            elseif (not isLeft and not isTop) then
                bottomRight.X = x;
                bottomRight.Y = y;
            end
        else
            tinsert(mapInfo.Grids, gridData);
        end

        if y < MAX_TILES_Y then
            y = y + 1;
        else
            y = 0;
            if x < MAX_TILES_X then
                x = x + 1;
            else
                x = 0;
            end
        end
    end

    mapInfo.CanvasSize = {
        Y = mapInfo.Bounds.BottomRight.Y - mapInfo.Bounds.TopLeft.Y,
        X = mapInfo.Bounds.BottomRight.X - mapInfo.Bounds.TopLeft.X,
    };

    print(format("Map Dimensions: %dx%d", mapInfo.CanvasSize.Y, mapInfo.CanvasSize.X));

    local function Sort(a, b)
        local topLeftX, topLeftY = mapInfo.Bounds.TopLeft.X, mapInfo.Bounds.TopLeft.Y;
        local distA = GetDistance(a.X, a.Y, topLeftX, topLeftY);
        local distB = GetDistance(b.X, b.Y, topLeftX, topLeftY);
        return distA < distB;
    end

    --table.sort(mapInfo.Grids, Sort);

    local _y, _x = 0, 0;
    for _, grid in ipairs(mapInfo.Grids) do
        grid.NormalizedCoords = {
            Y = _y,
            X = _x,
        };

        if _y < mapInfo.CanvasSize.Y then
            _y = _y + 1;
        else
            _y = 0;
            if _x < mapInfo.CanvasSize.X then
                _x = _x + 1;
            else
                _x = 0;
            end
        end
    end

    return mapInfo;
end

---@param wdtFileDataID number
---@return DatamineMapDisplayInfo?
function Datamine.Maps.GetMapDisplayInfoByWdtID(wdtFileDataID)
    local map = maps[wdtFileDataID];
    if map then
        return RemoveEmptyGridsFromMap(map);
    end
end