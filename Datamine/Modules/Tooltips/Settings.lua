local L = Datamine.Strings;
local S = Datamine.Settings;

local parentCategory = S.GetTopLevelCategory();
local category = Settings.RegisterVerticalLayoutSubcategory(parentCategory, L.CONFIG_CATEGORY_TOOLTIPS);

do
    local variable = "TooltipKeyColor";
    local name = L.CONFIG_TOOLTIP_KEY_COLOR_NAME;
    local default = "FFF542F5";
    local setting = S.RegisterSetting(category, variable, name, default);
    local tooltip = L.CONFIG_TOOLTIP_KEY_COLOR_TOOLTIP;

    S.CreateColorPickerButton(category, setting, name, tooltip);
end

do
    local variable = "TooltipValueColor";
    local name = L.CONFIG_TOOLTIP_VALUE_COLOR_NAME;
    local default = "808080FF"
    local setting = S.RegisterSetting(category, variable, name, default);
    local tooltip = L.CONFIG_TOOLTIP_VALUE_COLOR_TOOLTIP;

    S.CreateColorPickerButton(category, setting, name, tooltip);
end

-- ITEM TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_ITEM_TOOLTIPS);

local tooltipBinarySettings = {
    [1] = {
        Name = "TooltipItemShowItemID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_ID",
    },
    [2] = {
        Name = "TooltipItemShowEnchantID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_ENCHANT_ID",
    },
    [3] = {
        Name = "TooltipItemShowGemIDs",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_GEMS",
    },
    [4] = {
        Name = "TooltipItemShowItemContext",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_CONTEXT",
    },
    [5] = {
        Name = "TooltipItemShowBonusIDs",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_BONUSES",
    },
    [6] = {
        Name = "TooltipItemShowModifiers",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_MODIFIERS",
    },
    [7] = {
        Name = "TooltipItemShowCrafterGUID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_CRAFTER_GUID",
    },
    [8] = {
        Name = "TooltipitemShowExtraEnchantID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_EXTRA_ENCHANT_ID",
    },
};

do
    for _, _setting in ipairs(tooltipBinarySettings) do
        local variable = _setting.Name;
        local name = L[_setting.LocKey .. "_NAME"];
        local tooltip = L[_setting.LocKey .. "_TOOLTIP"];
        local default = true;

        local setting = S.RegisterSetting(category, variable, name, default);
        S.CreateCheckbox(category, setting, tooltip);
    end
end