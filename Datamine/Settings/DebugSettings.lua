local L = Datamine.Strings;
local S = Datamine.Settings;
local D = Datamine.Debug;

function D.IsDebugEnabled()
    return D.DebugEnabled;
end

if not D.IsDebugEnabled() then
    return;
end

D.Setting = {
    Debug_ShowAllTooltipData = "Debug_ShowAllTooltipData",
};

local parentCategory = S.GetTopLevelCategory();
local category = Settings.RegisterVerticalLayoutSubcategory(parentCategory, L.CONFIG_CATEGORY_DEBUG);

do
    local setting = S.RegisterSetting(category, D.Setting.Debug_ShowAllTooltipData, L.CONFIG_DEBUG_SHOW_ALL_TOOLTIP_DATA_NAME, true);
    S.CreateCheckbox(category, setting, L.CONFIG_DEBUG_SHOW_ALL_TOOLTIP_DATA_TOOLTIP);
end

------------




