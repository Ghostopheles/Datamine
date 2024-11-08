local L = Datamine.Strings;
local S = Datamine.Settings;

local parentCategory = S.GetTopLevelCategory();
local category = Settings.RegisterVerticalLayoutSubcategory(parentCategory, L.CONFIG_CATEGORY_TOOLTIPS);

local function CreateSubcategory(title)
    return Settings.RegisterVerticalLayoutSubcategory(category, title);
end

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

local function RegisterSettingsTable(settings, targetCategory)
    targetCategory = targetCategory or category;
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

        local setting = S.RegisterSetting(targetCategory, variable, name, default);
        S.CreateCheckbox(targetCategory, setting, tooltip);
    end
end

-- ITEM TOOLTIPS

local items = CreateSubcategory(L.CONFIG_HEADER_ITEM_TOOLTIPS);

local itemSettings = {
    {
        Name = "TooltipItemShowItemID",
        LocKey = "ITEM_ID",
    },
    {
        Name = "TooltipItemShowEnchantID",
        LocKey = "ITEM_ENCHANT_ID",
    },
    {
        Name = "TooltipItemShowGemIDs",
        LocKey = "ITEM_GEMS",
    },
    {
        Name = "TooltipItemShowItemContext",
        LocKey = "ITEM_CONTEXT",
        Default = false,
    },
    {
        Name = "TooltipItemShowBonusIDs",
        LocKey = "ITEM_BONUSES",
    },
    {
        Name = "TooltipItemShowModifiers",
        LocKey = "ITEM_MODIFIERS",
        Default = false,
    },
    {
        Name = "TooltipItemShowCrafterGUID",
        LocKey = "ITEM_CRAFTER_GUID",
        Default = false,
    },
    {
        Name = "TooltipItemShowExtraEnchantID",
        LocKey = "ITEM_EXTRA_ENCHANT_ID",
        Default = false,
    },
    {
        Name = "TooltipItemShowItemSpellID",
        LocKey = "ITEM_SPELL",
    },
    {
        Name = "TooltipItemShowRelicBonuses",
        LocKey = "ITEM_RELIC_BONUSES",
        Default = false,
    },
    {
        Name = "TooltipItemShowItemClass",
        LocKey = "ITEM_CLASS",
    },
    {
        Name = "TooltipItemShowItemSubClass",
        LocKey = "ITEM_SUBCLASS",
    },
    {
        Name = "TooltipItemShowEquipSlot",
        LocKey = "ITEM_EQUIP_SLOT",
    },
    {
        Name = "TooltipItemShowIcon",
        LocKey = "ITEM_ICON",
    },
    {
        Name = "TooltipKeystoneShowChallengeModeID",
        LocKey = "KEYSTONE_CM_ID",
    },
    {
        Name = "TooltipKeystoneShowLevel",
        LocKey = "KEYSTONE_LEVEL",
    },
    {
        Name = "TooltipKeystoneShowAffixes",
        LocKey = "KEYSTONE_AFFIXES",
    },
};

RegisterSettingsTable(itemSettings, items);

-- SPELL TOOLTIPS

local spells = CreateSubcategory(L.CONFIG_HEADER_SPELL_TOOLTIPS);

local spellSettings = {
    {
        Name = "TooltipSpellShowSpellID",
        LocKey = "SPELL_ID",
    }
};

RegisterSettingsTable(spellSettings, spells);

-- MACRO TOOLTIPS

local macros = CreateSubcategory(L.CONFIG_HEADER_MACRO_TOOLTIPS);

local macroSettings = {
    {
        Name = "TooltipMacroShowMacroName",
        LocKey = "MACRO",
    },
    {
        Name = "TooltipMacroShowMacroAction",
        LocKey = "MACRO_ACTION",
    },
    {
        Name = "TooltipMacroShowMacroIcon",
        LocKey = "MACRO_ICON",
    },
};

RegisterSettingsTable(macroSettings, macros);

-- TOY TOOLTIPS

local toys = CreateSubcategory(L.CONFIG_HEADER_TOY_TOOLTIPS);

local toySettings = {
    {
        Name = "TooltipToyShowItemID",
        LocKey = "ITEM_ID",
    },
    {
        Name = "TooltipToyShowItemSpell",
        LocKey = "ITEM_SPELL",
    },
    {
        Name = "TooltipToyShowIcon",
        LocKey = "TOY_ICON",
    },
};

RegisterSettingsTable(toySettings, toys);

-- MOUNT TOOLTIPS

local mounts = CreateSubcategory(L.CONFIG_HEADER_MOUNT_TOOLTIPS);

local mountSettings = {
    {
        Name = "TooltipMountShowMountID",
        LocKey = "MOUNT_ID",
    },
    {
        Name = "TooltipMountShowSpellID",
        LocKey = "MOUNT_SPELL",
    },
    {
        Name = "TooltipMountShowIcon",
        LocKey = "MOUNT_ICON",
    },
    {
        Name = "TooltipMountShowFaction",
        LocKey = "MOUNT_FACTION",
    },
    {
        Name = "TooltipMountShowSkyriding",
        LocKey = "MOUNT_SKYRIDING",
    },
    {
        Name = "TooltipMountShowDisplay",
        LocKey = "MOUNT_DISPLAY",
        Default = false,
    },
    {
        Name = "TooltipMountShowType",
        LocKey = "MOUNT_TYPE",
        Default = false,
    },
    {
        Name = "TooltipMountShowModelScene",
        LocKey = "MOUNT_MODELSCENE",
        Default = false,
    },
    {
        Name = "TooltipMountShowAnim",
        LocKey = "MOUNT_ANIM",
        Default = false,
    },
    {
        Name = "TooltipMountShowSpellVisual",
        LocKey = "MOUNT_SPELLVISUAL",
        Default = false,
    },
};

RegisterSettingsTable(mountSettings, mounts);

-- UNIT TOOLTIPS

local units = CreateSubcategory(L.CONFIG_HEADER_UNIT_TOOLTIPS);

local unitSettings = {
    {
        Name = "TooltipUnitShowUnitToken",
        LocKey = "UNIT_TOKEN",
    },
    {
        Name = "TooltipUnitShowCreatureID",
        LocKey = "UNIT_CREATURE_ID",
    },
    {
        Name = "TooltipUnitShowDisplayID",
        LocKey = "UNIT_DISPLAY_ID",
    },
    {
        Name = "TooltipUnitShowType",
        LocKey = "UNIT_TYPE",
    },
    {
        Name = "TooltipUnitShowNPCClass",
        LocKey = "UNIT_NPC_CLASS",
        Default = false,
    }
};

RegisterSettingsTable(unitSettings, units);

-- AURA TOOLTIPS

local auras = CreateSubcategory(L.CONFIG_HEADER_AURA_TOOLTIPS);

local auraSettings = {
    {
        Name = "TooltipAuraShowSpellID",
        LocKey = "AURA_ID",
    },
    {
        Name = "TooltipAuraShowIcon",
        LocKey = "AURA_ICON",
    },
    {
        Name = "TooltipAuraShowDispel",
        LocKey = "AURA_DISPEL",
        Default = false,
    },
    {
        Name = "TooltipAuraShowIsBossAura",
        LocKey = "AURA_BOSS_AURA",
        Default = false,
    },
    {
        Name = "TooltipAuraShowCharges",
        LocKey = "AURA_CHARGES",
        Default = false,
    },
    {
        Name = "TooltipAuraShowMaxCharges",
        LocKey = "AURA_MAX_CHARGES",
        Default = false,
    },
    {
        Name = "TooltipAuraShowSourceUnit",
        LocKey = "AURA_SOURCE_UNIT",
    },
    {
        Name = "TooltipAuraShowSourceName",
        LocKey = "AURA_SOURCE",
        Default = false,
    },
    {
        Name = "TooltipAuraShowInstanceID",
        LocKey = "AURA_INSTANCE_ID",
    },
    {
        Name = "TooltipAuraShowStacks",
        LocKey = "AURA_STACKS",
        Default = false,
    },
    {
        Name = "TooltipAuraShowPlayerApplicable",
        LocKey = "AURA_PLAYER_APPLICABLE",
        Default = false,
    },
    {
        Name = "TooltipAuraShowFromPlayerOrPet",
        LocKey = "AURA_FROM_PLAYER_OR_PET",
        Default = false,
    },
    {
        Name = "TooltipAuraShowPoints",
        LocKey = "AURA_POINTS",
        Default = false,
    },
    {
        Name = "TooltipAuraShowIsPrivate",
        LocKey = "AURA_IS_PRIVATE",
        Default = false,
    },
};

RegisterSettingsTable(auraSettings, auras);

-- ACHIEVEMENT TOOLTIPS

local achievements = CreateSubcategory(L.CONFIG_HEADER_ACHIEVEMENT_TOOLTIPS);

local achievementSettings = {
    {
        Name = "TooltipAchievementShowID",
        LocKey = "ACHIEVEMENT_ID",
    },
    {
        Name = "TooltipAchievementShowPlayerGUID",
        LocKey = "ACHIEVEMENT_PLAYER_GUID",
    },
    {
        Name = "TooltipAchievementShowCompleted",
        LocKey = "ACHIEVEMENT_COMPLETED",
    },
    {
        Name = "TooltipAchievementShowDate",
        LocKey = "ACHIEVEMENT_DATE",
        Default = false,
    },
    {
        Name = "TooltipAchievementShowCriteria",
        LocKey = "ACHIEVEMENT_CRITERIA",
        Default = false,
    },
};

RegisterSettingsTable(achievementSettings, achievements);

-- BATTLE PET TOOLTIPS

local battlePets = CreateSubcategory(L.CONFIG_HEADER_BATTLE_PET_TOOLTIPS);

local battlePetSettings = {
    {
        Name = "TooltipBattlePetShowSpeciesID",
        LocKey = "BATTLE_PET_SPECIES",
    },
    {
        Name = "TooltipBattlePetShowLevel",
        LocKey = "BATTLE_PET_LEVEL",
        Default = false,
    },
    {
        Name = "TooltipBattlePetShowBreedQuality",
        LocKey = "BATTLE_PET_BREED_QUALITY",
        Default = false,
    },
    {
        Name = "TooltipBattlePetShowMaxHealth",
        LocKey = "BATTLE_PET_MAX_HEALTH",
        Default = false,
    },
    {
        Name = "TooltipBattlePetShowPower",
        LocKey = "BATTLE_PET_POWER",
        Default = false,
    },
    {
        Name = "TooltipBattlePetShowSpeed",
        LocKey = "BATTLE_PET_SPEED",
        Default = false,
    },
    {
        Name = "TooltipBattlePetShowPetID",
        LocKey = "BATTLE_PET_ID",
        Default = false,
    },
    {
        Name = "TooltipBattlePetShowDisplayID",
        LocKey = "BATTLE_PET_DISPLAY_ID",
    },
};

RegisterSettingsTable(battlePetSettings, battlePets);

-- CURRENCY TOOLTIPS

local currencies = CreateSubcategory(L.CONFIG_HEADER_CURRENCY_TOOLTIPS);

local currrencySettings = {
    {
        Name = "TooltipCurrencyShowCurrencyID",
        LocKey = "CURRENCY_ID",
    },
    {
        Name = "TooltipCurrencyShowIcon",
        LocKey = "CURRENCY_ICON",
    },
    {
        Name = "TooltipCurrencyShowLimitedPerWeek",
        LocKey = "CURRENCY_LIMITED_PER_WEEK",
    },
    {
        Name = "TooltipCurrencyShowTradeable",
        LocKey = "CURRENCY_IS_TRADEABLE",
    },
    {
        Name = "TooltipCurrencyShowDiscovered",
        LocKey = "CURRENCY_DISCOVERED",
        Default = false,
    },
    {
        Name = "TooltipCurrencyShowAccountWide",
        LocKey = "CURRENCY_IS_ACCOUNT_WIDE",
    },
    {
        Name = "TooltipCurrencyShowTransferable",
        LocKey = "CURRENCY_CAN_XFER",
    },
    {
        Name = "TooltipCurrencyShowTransferPercentage",
        LocKey = "CURRENCY_XFER_PERCENTAGE",
    },
    {
        Name = "TooltipCurrencyShowAmountPerCycle",
        LocKey = "CURRENCY_AMOUNT_PER_CYCLE",
    },
    {
        Name = "TooltipCurrencyShowCycleDuration",
        LocKey = "CURRENCY_CYCLE_DURATION",
    },
    {
        Name = "TooltipCurrencyShowHasWarmodeBonus",
        LocKey = "CURRENCY_HAS_WARMODE_BONUS",
        Default = false,
    },
};

RegisterSettingsTable(currrencySettings, currencies);

-- GAME OBJECT TOOLTIPS

local gobjects = CreateSubcategory(L.CONFIG_HEADER_GOBJECT_TOOLTIPS);

local gobjectSettings = {
    {
        Name = "TooltipObjectShowID",
        LocKey = "GOBJECT_ID",
    },
};

RegisterSettingsTable(gobjectSettings, gobjects);

-- QUEST TOOLTIPS

local quests = CreateSubcategory(L.CONFIG_HEADER_QUEST_TOOLTIPS);

local questSettings = {
    {
        Name = "TooltipQuestShowQuestID",
        LocKey = "QUEST_ID",
    },
};

RegisterSettingsTable(questSettings, quests);

------------

local childCategories = {
    item = items,
    spell = spells,
    macro = macros,
    toy = toys,
    mount = mounts,
    unit = units,
    aura = auras,
    achievement = achievements,
    battlepet = battlePets,
    currency = currencies,
    gobject = gobjects,
    quest = quests
};

local function HandleSlash(section)
    local id;
    if not section then
        id = category:GetID();
    else
        section = strlower(section);
        local target = childCategories[section];
        if not target and strsub(section, -1) == "s" then
            section = strsub(section, 1, -2);
            target = childCategories[section];
        end

        if not target then
            id = category:GetID();
        else
            id = target:GetID();
        end
    end

    S.OpenSettings(id);
end

local args = "[<section>]";
local help = Datamine.Slash.GenerateHelpStringWithArgs(args, L.SLASH_CMD_TOOLTIP_SETTINGS_HELP);
Datamine.Slash:RegisterCommand("tt", HandleSlash, help, "tooltips");