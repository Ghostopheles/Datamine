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

local useModifierSetting, useModifierInitializer;
do
    local variable = "TooltipUseModifier";
    local name = L.CONFIG_TOOLTIP_USE_MODIFIER_NAME;
    local tooltip = L.CONFIG_TOOLTIP_USE_MODIFIER_TOOLTIP;
    local default = false;

    useModifierSetting = S.RegisterSetting(category, variable, name, default);
    useModifierInitializer = S.CreateCheckbox(category, useModifierSetting, tooltip);
end

do
    local function isParentSelected()
        return S.GetSetting("TooltipUseModifier");
    end

    local variable = "TooltipModifierKey";
    local name = L.CONFIG_TOOLTIP_MODIFIER_NAME;
    local default = "CTRL";
    local tooltip = L.CONFIG_TOOLTIP_MODIFIER_TOOLTIP;

    local optionTooltips = {
        [1] = L.CONFIG_TOOLTIP_MODIFIER_ALT_TOOLTIP,
        [2] = L.CONFIG_TOOLTIP_MODIFIER_CTRL_TOOLTIP,
        [3] = L.CONFIG_TOOLTIP_MODIFIER_SHIFT_TOOLTIP,
    };

    local options = Settings.CreateModifiedClickOptions(optionTooltips, true);
    local setting = S.RegisterSetting(category, variable, name, default);
    local initializer = S.CreateDropdown(category, setting, options, tooltip);
    initializer:SetParentInitializer(useModifierInitializer, isParentSelected);
end

function S.IsTooltipModifierDown()
    local key = S.GetSetting("TooltipModifierKey");
    if key == "ALT" then
        return IsAltKeyDown();
    elseif key == "CTRL" then
        return IsControlKeyDown();
    elseif key == "SHIFT" then
        return IsShiftKeyDown();
    end
end

local function RegisterSettingsTable(settings)
    for _, _setting in ipairs(settings) do
        local variable = _setting.Name;
        local name = L[_setting.LocKey .. "_NAME"];
        local tooltip = L[_setting.LocKey .. "_TOOLTIP"];
        local default;
        if _setting.Default ~= nil then
            default = _setting.Default;
        else
            default = true;
        end

        local setting = S.RegisterSetting(category, variable, name, default);
        S.CreateCheckbox(category, setting, tooltip);
    end
end

-- ITEM TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_ITEM_TOOLTIPS);

local itemSettings = {
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
        Default = false,
    },
    [5] = {
        Name = "TooltipItemShowBonusIDs",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_BONUSES",
    },
    [6] = {
        Name = "TooltipItemShowModifiers",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_MODIFIERS",
        Default = false,
    },
    [7] = {
        Name = "TooltipItemShowCrafterGUID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_CRAFTER_GUID",
        Default = false,
    },
    [8] = {
        Name = "TooltipItemShowExtraEnchantID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_EXTRA_ENCHANT_ID",
        Default = false,
    },
    [9] = {
        Name = "TooltipItemShowItemSpellID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_SPELL",
    },
    [10] = {
        Name = "TooltipItemShowRelicBonuses",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_RELIC_BONUSES",
        Default = false,
    }
};

RegisterSettingsTable(itemSettings);

-- SPELL TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_SPELL_TOOLTIPS);

local spellSettings = {
    [1] = {
        Name = "TooltipSpellShowSpellID",
        LocKey = "CONFIG_TOOLTIP_SHOW_SPELL_ID",
    }
};

RegisterSettingsTable(spellSettings);

-- MACRO TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_MACRO_TOOLTIPS);

local macroSettings = {
    [1] = {
        Name = "TooltipMacroShowMacroName",
        LocKey = "CONFIG_TOOLTIP_SHOW_MACRO",
    },
    [2] = {
        Name = "TooltipMacroShowMacroAction",
        LocKey = "CONFIG_TOOLTIP_SHOW_MACRO_ACTION",
    },
    [3] = {
        Name = "TooltipMacroShowMacroIcon",
        LocKey = "CONFIG_TOOLTIP_SHOW_MACRO_ICON",
    },
};

RegisterSettingsTable(macroSettings);

-- TOY TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_TOY_TOOLTIPS);

local toySettings = {
    [1] = {
        Name = "TooltipToyShowItemID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_ID",
    },
    [2] = {
        Name = "TooltipToyShowItemSpell",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_SPELL",
    },
    [3] = {
        Name = "TooltipToyShowIcon",
        LocKey = "CONFIG_TOOLTIP_SHOW_TOY_ICON",
    },
};

RegisterSettingsTable(toySettings);

-- MOUNT TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_MOUNT_TOOLTIPS);

local mountSettings = {
    [1] = {
        Name = "TooltipMountShowMountID",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_ID",
    },
    [2] = {
        Name = "TooltipMountShowSpellID",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_SPELL",
    },
    [3] = {
        Name = "TooltipMountShowIcon",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_ICON",
    },
    [4] = {
        Name = "TooltipMountShowFaction",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_FACTION",
    },
    [5] = {
        Name = "TooltipMountShowSkyriding",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_SKYRIDING",
    },
    [6] = {
        Name = "TooltipMountShowDisplay",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_DISPLAY",
        Default = false,
    },
    [7] = {
        Name = "TooltipMountShowType",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_TYPE",
        Default = false,
    },
    [8] = {
        Name = "TooltipMountShowModelScene",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_MODELSCENE",
        Default = false,
    },
    [9] = {
        Name = "TooltipMountShowAnim",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_ANIM",
        Default = false,
    },
    [10] = {
        Name = "TooltipMountShowSpellVisual",
        LocKey = "CONFIG_TOOLTIP_SHOW_MOUNT_SPELLVISUAL",
        Default = false,
    },
};

RegisterSettingsTable(mountSettings);

-- UNIT TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_UNIT_TOOLTIPS);

local unitSettings = {
    [1] = {
        Name = "TooltipUnitShowUnitToken",
        LocKey = "CONFIG_TOOLTIP_SHOW_UNIT_TOKEN",
    },
    [2] = {
        Name = "TooltipUnitShowCreatureID",
        LocKey = "CONFIG_TOOLTIP_SHOW_UNIT_CREATURE_ID",
    },
    [3] = {
        Name = "TooltipUnitShowDisplayID",
        LocKey = "CONFIG_TOOLTIP_SHOW_UNIT_DISPLAY_ID",
    },
    [4] = {
        Name = "TooltipUnitShowNPCClass",
        LocKey = "CONFIG_TOOLTIP_SHOW_UNIT_NPC_CLASS",
        Default = false,
    }
};

RegisterSettingsTable(unitSettings);