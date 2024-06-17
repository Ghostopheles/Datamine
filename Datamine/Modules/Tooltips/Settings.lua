local L = Datamine.Strings;
local S = Datamine.Settings;

local parentCategory = S.GetTopLevelCategory();
local category = Settings.RegisterVerticalLayoutSubcategory(parentCategory, L.CONFIG_CATEGORY_TOOLTIPS);

do
    local variable = "TooltipKeyColor";
    local name = L.CONFIG_TOOLTIP_KEY_COLOR_NAME;
    local default = "FFBFBCE0";
    local setting = S.RegisterSetting(category, variable, name, default);
    local tooltip = L.CONFIG_TOOLTIP_KEY_COLOR_TOOLTIP;

    S.CreateColorPickerButton(category, setting, name, tooltip);
end

do
    local variable = "TooltipValueColor";
    local name = L.CONFIG_TOOLTIP_VALUE_COLOR_NAME;
    local default = "FFFFC16A";
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
        local name = L["CONFIG_TOOLTIP_SHOW_" .. _setting.LocKey .. "_NAME"];
        local tooltip = L["CONFIG_TOOLTIP_SHOW_" .. _setting.LocKey .. "_TOOLTIP"];
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
        LocKey = "ITEM_ID",
    },
    [2] = {
        Name = "TooltipItemShowEnchantID",
        LocKey = "ITEM_ENCHANT_ID",
    },
    [3] = {
        Name = "TooltipItemShowGemIDs",
        LocKey = "ITEM_GEMS",
    },
    [4] = {
        Name = "TooltipItemShowItemContext",
        LocKey = "ITEM_CONTEXT",
        Default = false,
    },
    [5] = {
        Name = "TooltipItemShowBonusIDs",
        LocKey = "ITEM_BONUSES",
    },
    [6] = {
        Name = "TooltipItemShowModifiers",
        LocKey = "ITEM_MODIFIERS",
        Default = false,
    },
    [7] = {
        Name = "TooltipItemShowCrafterGUID",
        LocKey = "ITEM_CRAFTER_GUID",
        Default = false,
    },
    [8] = {
        Name = "TooltipItemShowExtraEnchantID",
        LocKey = "ITEM_EXTRA_ENCHANT_ID",
        Default = false,
    },
    [9] = {
        Name = "TooltipItemShowItemSpellID",
        LocKey = "ITEM_SPELL",
    },
    [10] = {
        Name = "TooltipItemShowRelicBonuses",
        LocKey = "ITEM_RELIC_BONUSES",
        Default = false,
    }
};

RegisterSettingsTable(itemSettings);

-- SPELL TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_SPELL_TOOLTIPS);

local spellSettings = {
    [1] = {
        Name = "TooltipSpellShowSpellID",
        LocKey = "SPELL_ID",
    }
};

RegisterSettingsTable(spellSettings);

-- MACRO TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_MACRO_TOOLTIPS);

local macroSettings = {
    [1] = {
        Name = "TooltipMacroShowMacroName",
        LocKey = "MACRO",
    },
    [2] = {
        Name = "TooltipMacroShowMacroAction",
        LocKey = "MACRO_ACTION",
    },
    [3] = {
        Name = "TooltipMacroShowMacroIcon",
        LocKey = "MACRO_ICON",
    },
};

RegisterSettingsTable(macroSettings);

-- TOY TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_TOY_TOOLTIPS);

local toySettings = {
    [1] = {
        Name = "TooltipToyShowItemID",
        LocKey = "ITEM_ID",
    },
    [2] = {
        Name = "TooltipToyShowItemSpell",
        LocKey = "ITEM_SPELL",
    },
    [3] = {
        Name = "TooltipToyShowIcon",
        LocKey = "TOY_ICON",
    },
};

RegisterSettingsTable(toySettings);

-- MOUNT TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_MOUNT_TOOLTIPS);

local mountSettings = {
    [1] = {
        Name = "TooltipMountShowMountID",
        LocKey = "MOUNT_ID",
    },
    [2] = {
        Name = "TooltipMountShowSpellID",
        LocKey = "MOUNT_SPELL",
    },
    [3] = {
        Name = "TooltipMountShowIcon",
        LocKey = "MOUNT_ICON",
    },
    [4] = {
        Name = "TooltipMountShowFaction",
        LocKey = "MOUNT_FACTION",
    },
    [5] = {
        Name = "TooltipMountShowSkyriding",
        LocKey = "MOUNT_SKYRIDING",
    },
    [6] = {
        Name = "TooltipMountShowDisplay",
        LocKey = "MOUNT_DISPLAY",
        Default = false,
    },
    [7] = {
        Name = "TooltipMountShowType",
        LocKey = "MOUNT_TYPE",
        Default = false,
    },
    [8] = {
        Name = "TooltipMountShowModelScene",
        LocKey = "MOUNT_MODELSCENE",
        Default = false,
    },
    [9] = {
        Name = "TooltipMountShowAnim",
        LocKey = "MOUNT_ANIM",
        Default = false,
    },
    [10] = {
        Name = "TooltipMountShowSpellVisual",
        LocKey = "MOUNT_SPELLVISUAL",
        Default = false,
    },
};

RegisterSettingsTable(mountSettings);

-- UNIT TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_UNIT_TOOLTIPS);

local unitSettings = {
    [1] = {
        Name = "TooltipUnitShowUnitToken",
        LocKey = "UNIT_TOKEN",
    },
    [2] = {
        Name = "TooltipUnitShowCreatureID",
        LocKey = "UNIT_CREATURE_ID",
    },
    [3] = {
        Name = "TooltipUnitShowDisplayID",
        LocKey = "UNIT_DISPLAY_ID",
    },
    [4] = {
        Name = "TooltipUnitShowNPCClass",
        LocKey = "UNIT_NPC_CLASS",
        Default = false,
    }
};

RegisterSettingsTable(unitSettings);

-- AURA TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_AURA_TOOLTIPS);

local auraSettings = {
    [1] = {
        Name = "TooltipAuraShowSpellID",
        LocKey = "AURA_ID",
    },
    [2] = {
        Name = "TooltipAuraShowIcon",
        LocKey = "AURA_ICON",
    },
    [3] = {
        Name = "TooltipAuraShowDispel",
        LocKey = "AURA_DISPEL",
        Default = false,
    },
    [4] = {
        Name = "TooltipAuraShowIsBossAura",
        LocKey = "AURA_BOSS_AURA",
        Default = false,
    },
    [5] = {
        Name = "TooltipAuraShowCharges",
        LocKey = "AURA_CHARGES",
        Default = false,
    },
    [6] = {
        Name = "TooltipAuraShowMaxCharges",
        LocKey = "AURA_MAX_CHARGES",
        Default = false,
    },
    [7] = {
        Name = "TooltipAuraShowSourceUnit",
        LocKey = "AURA_SOURCE_UNIT",
    },
    [8] = {
        Name = "TooltipAuraShowSourceName",
        LocKey = "AURA_SOURCE",
        Default = false,
    },
    [9] = {
        Name = "TooltipAuraShowInstanceID",
        LocKey = "AURA_INSTANCE_ID",
    },
    [10] = {
        Name = "TooltipAuraShowStacks",
        LocKey = "AURA_STACKS",
        Default = false,
    },
    [11] = {
        Name = "TooltipAuraShowPlayerApplicable",
        LocKey = "AURA_PLAYER_APPLICABLE",
        Default = false,
    },
    [12] = {
        Name = "TooltipAuraShowFromPlayerOrPet",
        LocKey = "AURA_FROM_PLAYER_OR_PET",
        Default = false,
    },
    [13] = {
        Name = "TooltipAuraShowPoints",
        LocKey = "AURA_POINTS",
        Default = false,
    },
    [14] = {
        Name = "TooltipAuraShowIsPrivate",
        LocKey = "AURA_IS_PRIVATE",
        Default = false,
    },
};

RegisterSettingsTable(auraSettings);

-- ACHIEVEMENT TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_ACHIEVEMENT_TOOLTIPS);

local achievementSettings = {
    [1] = {
        Name = "TooltipAchievementShowID",
        LocKey = "ACHIEVEMENT_ID",
    },
    [2] = {
        Name = "TooltipAchievementShowPlayerGUID",
        LocKey = "ACHIEVEMENT_PLAYER_GUID",
    },
    [3] = {
        Name = "TooltipAchievementShowCompleted",
        LocKey = "ACHIEVEMENT_COMPLETED",
    },
    [4] = {
        Name = "TooltipAchievementShowDate",
        LocKey = "ACHIEVEMENT_DATE",
        Default = false,
    },
    [5] = {
        Name = "TooltipAchievementShowCriteria",
        LocKey = "ACHIEVEMENT_CRITERIA",
        Default = false,
    },
};

RegisterSettingsTable(achievementSettings);

-- BATTLE PET TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_BATTLE_PET_TOOLTIPS);

local battlePetSettings = {
    [1] = {
        Name = "TooltipBattlePetShowSpeciesID",
        LocKey = "BATTLE_PET_SPECIES",
    },
    [2] = {
        Name = "TooltipBattlePetShowLevel",
        LocKey = "BATTLE_PET_LEVEL",
        Default = false,
    },
    [3] = {
        Name = "TooltipBattlePetShowBreedQuality",
        LocKey = "BATTLE_PET_BREED_QUALITY",
        Default = false,
    },
    [4] = {
        Name = "TooltipBattlePetShowMaxHealth",
        LocKey = "BATTLE_PET_MAX_HEALTH",
        Default = false,
    },
    [5] = {
        Name = "TooltipBattlePetShowPower",
        LocKey = "BATTLE_PET_POWER",
        Default = false,
    },
    [6] = {
        Name = "TooltipBattlePetShowSpeed",
        LocKey = "BATTLE_PET_SPEED",
        Default = false,
    },
    [7] = {
        Name = "TooltipBattlePetShowPetID",
        LocKey = "BATTLE_PET_ID",
        Default = false,
    },
    [8] = {
        Name = "TooltipBattlePetShowDisplayID",
        LocKey = "BATTLE_PET_DISPLAY_ID",
    },
};

RegisterSettingsTable(battlePetSettings);

-- CURRENCY TOOLTIPS

S.CreateHeader(category, L.CONFIG_HEADER_CURRENCY_TOOLTIPS);

local currrencySettings = {
    [1] = {
        Name = "TooltipCurrencyShowCurrencyID",
        LocKey = "CURRENCY_ID",
    },
    [2] = {
        Name = "TooltipCurrencyShowIcon",
        LocKey = "CURRENCY_ICON",
    },
    [3] = {
        Name = "TooltipCurrencyShowLimitedPerWeek",
        LocKey = "CURRENCY_LIMITED_PER_WEEK",
    },
    [4] = {
        Name = "TooltipCurrencyShowTradeable",
        LocKey = "CURRENCY_IS_TRADEABLE",
    },
    [5] = {
        Name = "TooltipCurrencyShowDiscovered",
        LocKey = "CURRENCY_DISCOVERED",
        Default = false,
    },
    [6] = {
        Name = "TooltipCurrencyShowAccountWide",
        LocKey = "CURRENCY_IS_ACCOUNT_WIDE",
    },
    [7] = {
        Name = "TooltipCurrencyShowTransferable",
        LocKey = "CURRENCY_CAN_XFER",
    },
    [8] = {
        Name = "TooltipCurrencyShowTransferPercentage",
        LocKey = "CURRENCY_XFER_PERCENTAGE",
    },
    [9] = {
        Name = "TooltipCurrencyShowAmountPerCycle",
        LocKey = "CURRENCY_AMOUNT_PER_CYCLE",
    },
    [10] = {
        Name = "TooltipCurrencyShowCycleDuration",
        LocKey = "CURRENCY_CYCLE_DURATION",
    },
    [11] = {
        Name = "TooltipCurrencyShowHasWarmodeBonus",
        LocKey = "CURRENCY_HAS_WARMODE_BONUS",
        Default = false,
    },
};

RegisterSettingsTable(currrencySettings);