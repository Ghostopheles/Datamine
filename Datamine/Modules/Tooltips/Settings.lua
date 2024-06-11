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

local function RegisterSettingsTable(settings)
    for _, _setting in ipairs(settings) do
        local variable = _setting.Name;
        local name = L[_setting.LocKey .. "_NAME"];
        local tooltip = L[_setting.LocKey .. "_TOOLTIP"];
        local default = true;

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
        Name = "TooltipItemShowExtraEnchantID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_EXTRA_ENCHANT_ID",
    },
    [9] = {
        Name = "TooltipItemShowItemSpellID",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_SPELL",
    },
    [10] = {
        Name = "TooltipItemShowRelicBonuses",
        LocKey = "CONFIG_TOOLTIP_SHOW_ITEM_RELIC_BONUSES",
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
    }
};

RegisterSettingsTable(mountSettings);