local _, Datamine_Static = ...;

---@class DatamineStaticItemBonus
---@field ID number
---@field Values table<number>
---@field ParentItemBonusListID number
---@field Type number
---@field OrderIndex number

---@class DatamineStaticItemBonusList
---@field ID number
---@field Flags number

---@class DatamineStaticItemBonusListGroup
---@field ID number
---@field SequenceSpellID number
---@field PlayerConditionID number
---@field ItemExtendedCostID number
---@field ItemLogicalCostGroupID number
---@field ItemGroupIlvlScalingID number

---@class DatamineStaticItemBonusListGroupEntry
---@field ID number
---@field ItemBonusListGroupID number
---@field ItemBonusListID number
---@field ItemLevelSelectorID number
---@field SequenceValue number
---@field ItemExtendedCostID number
---@field PlayerConditionID number
---@field Flags number
---@field ItemLogicalCostGroupID number

---@class DatamineStaticItemBonusModule
local ItemBonus = {};

local _ITEM_BONUS = Datamine_Static.ItemBonus;
local _ITEM_BONUS_LIST = Datamine_Static.ItemBonusList;
local _ITEM_BONUS_LIST_GROUP = Datamine_Static.ItemBonusListGroup;
local _ITEM_BONUS_LIST_GROUP_ENTRY = Datamine_Static.ItemBonusListGroupEntry;

---@param id number
---@return DatamineStaticItemBonus?
function ItemBonus.GetItemBonusByID(id)
    return _DATA[id];
end

function ItemBonus.GetItemBonusIDsForList(id)

end

------------

Datamine.Static.ItemBonus = ItemBonus;