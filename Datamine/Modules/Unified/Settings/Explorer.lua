local L = Datamine.Strings;
local S = Datamine.Settings;

local parentCategory = S.GetTopLevelCategory();
local category = Settings.RegisterVerticalLayoutSubcategory(parentCategory, L.CONFIG_CATEGORY_EXPLORER);

local useModifierSetting, useModifierInitializer;
do
    local variable = "ExplorerUseModifier";
    local name = L.CONFIG_EXPLORER_USE_MODIFIER_NAME;
    local tooltip = L.CONFIG_EXPLORER_USE_MODIFIER_TOOLTIP;
    local default = false;

    useModifierSetting = S.RegisterSetting(category, variable, name, default);
    useModifierInitializer = S.CreateCheckbox(category, useModifierSetting, tooltip);
end

do
    local function isParentSelected()
        return S.GetSetting("ExplorerUseModifier");
    end

    local variable = "ExplorerModifierKey";
    local name = L.CONFIG_EXPLORER_MODIFIER_NAME;
    local tooltip = L.CONFIG_EXPLORER_MODIFIER_TOOLTIP;
    local default = "CTRL";

    local optionTooltips = {
        [1] = L.CONFIG_EXPLORER_MODIFIER_ALT_TOOLTIP,
        [2] = L.CONFIG_EXPLORER_MODIFIER_CTRL_TOOLTIP,
        [3] = L.CONFIG_EXPLORER_MODIFIER_SHIFT_TOOLTIP,
    };

    local options = Settings.CreateModifiedClickOptions(optionTooltips, true);
    local setting = S.RegisterSetting(category, variable, name, default);
    local initializer = S.CreateDropdown(category, setting, options, tooltip);
    initializer:SetParentInitializer(useModifierInitializer, isParentSelected);
end

function S.IsExplorerModifierDown()
    local key = S.GetSetting("ExplorerModifierKey");
    if key == "ALT" then
        return IsAltKeyDown();
    elseif key == "CTRL" then
        return IsControlKeyDown();
    elseif key == "SHIFT" then
        return IsShiftKeyDown();
    end
end