---@class DatamineTableUtil
local TU = {};

---@param tbl table
---@return boolean isEmpty
function TU.IsEmpty(tbl)
    return next(tbl) == nil;
end

------------

Datamine.TableUtil = TU;