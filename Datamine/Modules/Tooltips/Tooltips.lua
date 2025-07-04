local S = Datamine.Settings;
local D = Datamine.Debug;
local L = Datamine.Strings;

local Tooltips = {};

local TAB_SIZE = 2;
local TAB = strrep(" ", TAB_SIZE);

local ERROR;
local CURRENT_TOOLTIP;

local MODEL = CreateFrame("PlayerModel");

------------
-- tooltip context management

-- when customizating a tooltip, you must first open the tooltip context with Tooltips.Begin, passing in the tooltip
-- this helps with customization since we don't have to constantly pass the tooltip object around
-- and of course, remember to end the context when done with Tooltips.End()

function Tooltips.Begin(tooltip)
    if CURRENT_TOOLTIP ~= nil and tooltip ~= CURRENT_TOOLTIP then
        return false;
    end

    CURRENT_TOOLTIP = tooltip;
    return true;
end

function Tooltips.GetCurrentTooltip()
    assert(CURRENT_TOOLTIP ~= nil, "Attempt to get tooltip context with no tooltip set");
    return CURRENT_TOOLTIP;
end

function Tooltips.SetLastError(error)
    assert(CURRENT_TOOLTIP, "Attempt to set error without existing tooltip context");
    ERROR = error;
end

function Tooltips.GetLastError()
    return ERROR;
end

function Tooltips.ClearLastError()
    ERROR = nil;
end

function Tooltips.End()
    assert(CURRENT_TOOLTIP, "Attempt to end non-existent tooltip context");
    CURRENT_TOOLTIP = nil;

    local err = Tooltips.GetLastError();
    if err and D.IsDebugEnabled() then
        CallErrorHandler("Error occurred within tooltip context: " .. err);
        Tooltips.ClearLastError();
    end
end

------------

function Tooltips.GetKeyColor()
    return S.GetColor("TooltipKeyColor");
end

function Tooltips.GetValueColor()
    return S.GetColor("TooltipValueColor");
end

function Tooltips.ShouldShow(configKey)
    if D.IsDebugEnabled() and S.GetSetting(D.Setting.Debug_ShowAllTooltipData) then
        return true;
    end

    if not S.GetSetting("TooltipEnableCustomizations") then
        return false;
    end

    if S.GetSetting("TooltipUseModifier") then
        if S.IsTooltipModifierDown() then
            return true;
        end
    end

    return S.GetSetting(configKey);
end

------------

function Tooltips.ColorKeyValueText(key, value)
    local keyColor, valueColor = Tooltips.GetKeyColor(), Tooltips.GetValueColor();
    return keyColor:WrapTextInColorCode(key), valueColor:WrapTextInColorCode(value);
end

function Tooltips.FormatKeyValuePair(key, value)
    return Tooltips.ColorKeyValueText(key, tostring(value));
end

function Tooltips.AddLine(line)
    local tooltip = Tooltips.GetCurrentTooltip();
    local keyColor = Tooltips.GetKeyColor();
    tooltip:AddLine(keyColor:WrapTextInColorCode(line));
end

function Tooltips.AddDoubleLine(left, right, show)
    local tooltip = Tooltips.GetCurrentTooltip();

    tooltip:AddDoubleLine(left, right);
    if show then
        tooltip:Show();
    end
end

function Tooltips.Append(key, value)
    if type(value) == "table" then
        value = strjoin(", ", unpack(value));
    end

    local left, right = Tooltips.FormatKeyValuePair(key, value);
    Tooltips.AddDoubleLine(left, right);
end

function Tooltips.ParseLink(link)
    return Datamine.Structures.CreateLink(link);
end

function Tooltips.GetCreatureDisplayID(creatureID)
    MODEL:SetCreature(creatureID);
    return MODEL:GetDisplayInfo();
end

function Tooltips.GetGObjectIDFromGUID(guid)
    local gobjectID = select(6, string.split("-", guid));
    return gobjectID;
end

function Tooltips.IsItemEquipLocValid(equipLoc)
    if equipLoc ~= "" and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" and equipLoc ~= "INVTYPE_NON_EQUIP" then
        return true;
    end

    return false;
end

function Tooltips.IsCurrentTooltipTraitEntryTooltip()
    local tooltip = Tooltips.GetCurrentTooltip();
    if not tooltip then
        return false;
    end

    local tooltipInfo = tooltip:GetPrimaryTooltipInfo();
    return tooltipInfo.getterName == "GetTraitEntry";
end

------

-- to add new data points to tooltips, find the appropriate function below (or make a new one)
-- add the relevant config key to Settings.lua, with lockeys and default value if it's not true
-- data shouldn't be shown without first going through a Tooltips.ShouldShow check

function Tooltips.OnTooltipSetItem()
    local tooltip = Tooltips.GetCurrentTooltip();
    local itemLink;
    if tooltip.GetItem then
        itemLink = select(2, tooltip:GetItem());
    end
    if not itemLink then
        return;
    end

    local item = Tooltips.ParseLink(itemLink);
    if not item then
        return;
    end

    if Tooltips.ShouldShow("TooltipItemShowItemID") then
        Tooltips.Append("ItemID", item.ItemID);
    end

    if not item.IsKeystone then
        local _, itemType, subType, equipLoc, icon, classID, subclassID = C_Item.GetItemInfoInstant(item.ItemID);
        if Tooltips.ShouldShow("TooltipItemShowItemClass") then
            Tooltips.Append("ItemClass", format("%s (%s)", itemType, classID));
        end

        if Tooltips.ShouldShow("TooltipItemShowItemSubClass") then
            Tooltips.Append("ItemSubClass", format("%s (%s)", subType, subclassID));
        end

        if Tooltips.ShouldShow("TooltipItemShowEquipSlot") and Tooltips.IsItemEquipLocValid(equipLoc) then
            Tooltips.Append("EquipSlot", equipLoc);
        end

        if Tooltips.ShouldShow("TooltipItemShowIcon") then
            Tooltips.Append("Icon", icon);
        end

        if item.EnchantID and Tooltips.ShouldShow("TooltipItemShowEnchantID") then
            Tooltips.Append("EnchantID", item.EnchantID);
        end

        if item.ExtraEnchantID and Tooltips.ShouldShow("TooltipItemShowExtraEnchantID") then
            Tooltips.Append("ExtraEnchantID", item.ExtraEnchantID);
        end

        if (#item.GemIDs > 0) and Tooltips.ShouldShow("TooltipItemShowGemIDs") then
            Tooltips.Append("GemIDs", item.GemIDs);
        end

        if (item.NumBonusIDs > 0) and Tooltips.ShouldShow("TooltipItemShowBonusIDs") then
            Tooltips.Append("BonusIDs", item.BonusIDs);
        end

        if (item.NumModifiers > 0) and Tooltips.ShouldShow("TooltipItemShowModifiers") then
            Tooltips.AddLine("Modifiers");
            for _, modifier in pairs(item.Modifiers) do
                if modifier.Type and modifier.Value then
                    local modifierType = Datamine.Utils.GetEnumValueName(Enum.ItemModification, modifier.Type);
                    Tooltips.Append(TAB .. "- " .. modifierType, modifier.Value);
                end
            end
        end

        if Tooltips.ShouldShow("TooltipItemShowRelicBonuses") then
            for i=1, 3 do
                local numKeyName = "Relic" .. i .. "NumBonusIDs";
                if (item[numKeyName] or 0) > 0 then
                    local keyName = "Relic" .. i .. "BonusIDs";
                    Tooltips.Append(keyName, item[keyName]);
                end
            end
        end

        if item.ItemContext and Tooltips.ShouldShow("TooltipItemShowItemContext") then
            local contextType = Datamine.Utils.GetEnumValueName(Enum.ItemCreationContext, item.ItemContext);
            Tooltips.Append("ItemContext", format("%s (%d)", contextType, item.ItemContext));
        end

        if item.CrafterGUID and Tooltips.ShouldShow("TooltipItemShowCrafterGUID") then
            Tooltips.Append("CrafterGUID", item.CrafterGUID);
        end

        if Tooltips.ShouldShow("TooltipItemShowItemSpellID") then
            local itemSpellName, itemSpellID = C_Item.GetItemSpell(item.ItemID);
            if itemSpellName and itemSpellID then
                Tooltips.Append("ItemSpell", format("%s (%d)", itemSpellName, itemSpellID));
            end
        end

        local itemAppearanceID, itemModifiedAppearanceID = C_TransmogCollection.GetItemInfo(itemLink);
        if itemAppearanceID and Tooltips.ShouldShow("TooltipItemShowAppearanceID") then
            Tooltips.Append("AppearanceID", itemAppearanceID);
        end

        if itemModifiedAppearanceID and Tooltips.ShouldShow("TooltipItemShowModifiedAppearanceID") then
            Tooltips.Append("ModifiedAppearanceID", itemModifiedAppearanceID);
        end
    else
        if Tooltips.ShouldShow("TooltipKeystoneShowChallengeModeID") then
            Tooltips.Append("ChallengeModeID", item.ChallengeModeID);
        end

        if Tooltips.ShouldShow("TooltipKeystoneShowLevel") then
            Tooltips.Append("KeystoneLevel", item.Level);
        end

        if Tooltips.ShouldShow("TooltipKeystoneShowAffixes") then
            Tooltips.Append("Affixes", item.Affixes);
        end
    end
end

function Tooltips.AppendTraitEntryInfo(configID, traitEntryID, skipNodeID)
    assert(Tooltips.GetCurrentTooltip(), "Attempt to append trait entry info without active tooltip context.");

    if Tooltips.ShouldShow("TooltipShowTraitNodeID") and not skipNodeID then
        local tooltip = Tooltips.GetCurrentTooltip();
        local owner = tooltip:GetOwner();
        local nodeInfo = owner.nodeInfo;
        local nodeID;
        if nodeInfo  then
            nodeID = nodeInfo.ID;
        elseif owner.GetNodeID then
            nodeID = owner:GetNodeID();
        elseif owner.GetNodeInfo then
            nodeID = owner:GetNodeInfo().ID;
        end

        if nodeID then
            Tooltips.Append("TraitNodeID", nodeID);
        end
    end

    if Tooltips.ShouldShow("TooltipTraitShowTraitEntryID") then
        Tooltips.Append("TraitEntryID", traitEntryID);
    end

    local entryInfo = C_Traits.GetEntryInfo(configID, traitEntryID);

    local entryEnumName = Datamine.Utils.GetEnumValueName(Enum.TraitNodeEntryType, entryInfo.type);
    local entryType = format("%s (%d)", entryEnumName, entryInfo.type);
    if Tooltips.ShouldShow("TooltipTraitShowTraitEntryType") then
        Tooltips.Append("TraitEntryType", entryType);
    end

    local definitionID = entryInfo.definitionID;
    if definitionID and Tooltips.ShouldShow("TooltipTraitShowDefinitionID") then
        Tooltips.Append("TraitDefinitionID", definitionID);
    end

    local subTreeID = entryInfo.subTreeID;
    if subTreeID and Tooltips.ShouldShow("TooltipTraitShowSubTreeID") then
        Tooltips.Append("TraitSubTreeID", subTreeID);
    end

    local hasErrors = entryInfo.isDisplayError;
    if hasErrors and Tooltips.ShouldShow("TooltipTraitShowErrors") then
        Tooltips.AddLine("TraitErrors");
        for _, conditionID in ipairs(entryInfo.conditionIDs) do
            Tooltips.AddLine(TAB .. "-" .. conditionID);
        end
    end
end

function Tooltips.AppendTraitTreeCurrencyInfo(configID, traitTreeID)
    local excludeStagedChanges = true;
    local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, traitTreeID, excludeStagedChanges);
    Tooltips.AddLine("TraitTreeCurrencies");
    for i, treeCurrency in ipairs(treeCurrencyInfo) do
        local key = format("%s-[%d] TraitCurrencyID", TAB, i);
        Tooltips.Append(key, treeCurrency.traitCurrencyID);

        local _, _, currencyTypesID, _ = C_Traits.GetTraitCurrencyInfo(treeCurrency.traitCurrencyID);
        if currencyTypesID then
            local currencyTypesKey = format("%s %s- CurrencyID", TAB, TAB);
            Tooltips.Append(currencyTypesKey, currencyTypesID);
        end
    end
end

function Tooltips.OnTooltipSetClassTalentTraitEntry()
    local tooltip = Tooltips.GetCurrentTooltip();
    if not tooltip then
        return;
    end

    -- for trait tree entries
    local tooltipInfo = tooltip:GetPrimaryTooltipInfo();
    local traitEntryID, traitRank = unpack(tooltipInfo.getterArgs);
    if Tooltips.ShouldShow("TooltipTraitShowTraitRank") then
        Tooltips.Append("TraitRank", traitRank);
    end

    -- do you want to drink from the firehose?
    local configID = C_ClassTalents.GetActiveConfigID();
    if not configID then
        return;
    end

    Tooltips.AppendTraitEntryInfo(configID, traitEntryID);
end

function Tooltips.OnTooltipSetProfSpecPath(configID, pathID)
    local tooltip = Tooltips.GetCurrentTooltip();
    if not tooltip then
        return;
    end

    local traitEntryID = C_ProfSpecs.GetSpendEntryForPath(pathID);
    local skipNodeID = true;
    Tooltips.AppendTraitEntryInfo(configID, traitEntryID, skipNodeID);

    if Tooltips.ShouldShow("TooltipTraitShowProfSpecPathID") then
        Tooltips.Append("ProfSpecPathNodeID", pathID);
    end

    if Tooltips.ShouldShow("TooltipTraitShowProfSpecPathState") then
        local state = C_ProfSpecs.GetStateForPath(pathID, configID);
        local stateEnumName = Datamine.Utils.GetEnumValueName(Enum.ProfessionsSpecPathState, state);
        Tooltips.Append("ProfSpecPathState", format("%s (%d)", stateEnumName, state));
    end
end

function Tooltips.OnTooltipSetProfSpecPerk(configID, perkID)
    local tooltip = Tooltips.GetCurrentTooltip();
    if not tooltip then
        return;
    end

    local traitEntryID = C_ProfSpecs.GetEntryIDForPerk(perkID);
    local skipNodeID = true;
    Tooltips.AppendTraitEntryInfo(configID, traitEntryID, skipNodeID);

    if Tooltips.ShouldShow("TooltipTraitShowProfSpecPerkID") then
        Tooltips.Append("ProfSpecPerkNodeID", perkID);
    end

    if Tooltips.ShouldShow("TooltipTraitShowProfSpecPerkState") then
        local state = C_ProfSpecs.GetStateForPerk(perkID, configID);
        local stateEnumName = Datamine.Utils.GetEnumValueName(Enum.ProfessionsSpecPerkState, state);
        Tooltips.Append("ProfSpecPerkState", format("%s (%d)", stateEnumName, state));
    end
end

function Tooltips.OnTooltipSetProfSpecTree(configID, traitTreeID)
    local tooltip = Tooltips.GetCurrentTooltip();
    if not tooltip then
        return;
    end

    if Tooltips.ShouldShow("TooltipTraitShowTreeID") then
        Tooltips.Append("TraitTreeID", traitTreeID);
    end

    if Tooltips.ShouldShow("TooltipTraitShowSystemID") then
        local systemID = C_Traits.GetSystemIDByTreeID(traitTreeID);
        Tooltips.Append("TraitSystemID", systemID);
    end

    if Tooltips.ShouldShow("TooltipTraitShowTreeCurrencyInfo") then
        Tooltips.AppendTraitTreeCurrencyInfo(configID, traitTreeID);
    end

    if Tooltips.ShouldShow("TooltipTraitShowProfSpecTabState") then
        local state = C_ProfSpecs.GetStateForTab(traitTreeID, configID);
        local stateEnumName = Datamine.Utils.GetEnumValueName(Enum.ProfessionsSpecTabState, state);
        Tooltips.Append("ProfSpecTabState", format("%s (%d)", stateEnumName, state));
    end
end

function Tooltips.OnTooltipSetSpell()
    local tooltip = Tooltips.GetCurrentTooltip();
    local spellID;
    if tooltip.GetSpell then
        spellID = select(2, tooltip:GetSpell());
    end

    if not spellID then
        return;
    end

    if Tooltips.ShouldShow("TooltipSpellShowSpellID") then
        Tooltips.Append("SpellID", spellID);
    end

    if Tooltips.IsCurrentTooltipTraitEntryTooltip() then
        Tooltips.OnTooltipSetClassTalentTraitEntry();
    end
end

function Tooltips.OnTooltipSetMacro()
    local tooltip = Tooltips.GetCurrentTooltip();
    local tooltipData = tooltip:GetPrimaryTooltipInfo();
    local actionSlot = tooltipData.getterArgs[1];

    if Tooltips.ShouldShow("TooltipMacroShowMacroName") then
        local macroName = GetActionText(actionSlot);
        Tooltips.Append("Macro Name", macroName);
    end

    if Tooltips.ShouldShow("TooltipMacroShowMacroIcon") then
        local icon = GetActionTexture(actionSlot);
        Tooltips.Append("Macro Icon", icon);
    end

    if Tooltips.ShouldShow("TooltipMacroShowMacroAction") then
        local actionType, actionID, subType = GetActionInfo(actionSlot);
        if actionID then
            local actionKey;
            if actionType == "macro" then
                if subType == "spell" then
                    actionKey = "Macro Spell";
                elseif subType == "" then
                    actionKey = "Macro Index";
                elseif subType == "item" then
                    actionKey = "Macro Item";
                    local actionText = GetActionText(actionSlot);

                    local macroIndex = GetMacroIndexByName(actionText);
                    Tooltips.Append("Macro Index", macroIndex);

                    local _, itemLink = GetMacroItem(actionText);
                    if itemLink then
                        local parsedLink = Tooltips.ParseLink(itemLink);
                        if parsedLink then
                            actionID = parsedLink.ItemID;
                        end
                    end
                elseif subType == "MOUNT" then
                    local actionText = GetActionText(actionSlot);
                    local spellID = GetMacroSpell(actionText);
                    local mountID = C_MountJournal.GetMountFromSpell(spellID);
                    actionKey = "MountID";
                    actionID = mountID;
                end
            end

            Tooltips.Append(actionKey, actionID);
        end
    end
end

function Tooltips.OnTooltipSetToy()
    local tooltip = Tooltips.GetCurrentTooltip();
    local itemID = tooltip:GetTooltipData().id;

    if Tooltips.ShouldShow("TooltipToyShowItemID") then
        Tooltips.Append("ItemID", itemID);
    end

    if Tooltips.ShouldShow("TooltipToyShowItemSpell") then
        local itemSpellName, itemSpellID = C_Item.GetItemSpell(itemID);
        if itemSpellName and itemSpellID then
            Tooltips.Append("ItemSpell", format("%s (%d)", itemSpellName, itemSpellID));
        end
    end

    if Tooltips.ShouldShow("TooltipToyShowIcon") then
        local icon = select(3, C_ToyBox.GetToyInfo(itemID));
        Tooltips.Append("Icon", icon);
    end
end

function Tooltips.OnTooltipSetMount()
    local tooltip = Tooltips.GetCurrentTooltip();
    local mountID = tooltip:GetTooltipData().id;

    if Tooltips.ShouldShow("TooltipMountShowMountID") then
        Tooltips.Append("MountID", mountID);
    end

    local mountInfo = {C_MountJournal.GetMountInfoByID(mountID)};
    local spellID = mountInfo[2];
    if not spellID then
        return;
    end

    if Tooltips.ShouldShow("TooltipMountShowSpellID") then
        Tooltips.Append("SpellID", spellID);
    end

    if Tooltips.ShouldShow("TooltipMountShowIcon") then
        Tooltips.Append("Icon", mountInfo[3]);
    end

    if Tooltips.ShouldShow("TooltipMountShowFaction") then
        if mountInfo[8] then
            local faction = mountInfo[9];
            local factionName = faction == 0 and "Horde" or "Alliance";
            Tooltips.Append("Faction", factionName);
        end
    end

    if Tooltips.ShouldShow("TooltipMountShowSkyriding") then
        Tooltips.Append("Skyriding", mountInfo[13]);
    end

    local extraMountInfo = {C_MountJournal.GetMountInfoExtraByID(mountID)};

    if Tooltips.ShouldShow("TooltipMountShowDisplay") then
        Tooltips.Append("DisplayID", extraMountInfo[1]);
    end

    if Tooltips.ShouldShow("TooltipMountShowType") then
        Tooltips.Append("MountTypeID", extraMountInfo[5]);
    end

    if Tooltips.ShouldShow("TooltipMountShowModelScene") then
        Tooltips.Append("UiModelSceneID", extraMountInfo[6]);
    end

    if Tooltips.ShouldShow("TooltipMountShowAnim") then
        Tooltips.Append("AnimID", extraMountInfo[7]);
    end

    if Tooltips.ShouldShow("TooltipMountShowSpellVisual") then
        Tooltips.Append("SpellVisualKitID", extraMountInfo[8]);
    end
end

function Tooltips.OnTooltipSetUnit()
    local tooltip = Tooltips.GetCurrentTooltip();
    local _, unit, guid = tooltip:GetUnit();
    local unitType = strsplit("-", guid, 2);
    local isNPC = unitType == "Creature";

    if Tooltips.ShouldShow("TooltipUnitShowUnitToken") then
        Tooltips.Append("UnitToken", unit);
    end

    if Tooltips.ShouldShow("TooltipUnitShowType") then
        Tooltips.Append("Type", unitType);
    end

    if isNPC then
        local creatureID = Datamine.Database:GetCreatureIDFromGUID(guid);
        if Tooltips.ShouldShow("TooltipUnitShowCreatureID") then
            Tooltips.Append("CreatureID", creatureID);
        end

        if D.DebugEnabled then
            creatureID = tonumber(creatureID);
            if creatureID then
                local x, y, distance = ClosestUnitPosition(creatureID);
                if x and y and distance then
                    Tooltips.AddLine("Position");
                    Tooltips.Append(TAB .. "- X:", format("%.2f", x));
                    Tooltips.Append(TAB .. "- Y:", format("%.2f", y));
                    Tooltips.Append(TAB .. "- Distance:", format("%.2f", distance));
                end
            end
        end

        if Tooltips.ShouldShow("TooltipUnitShowDisplayID") then
            local displayID = Tooltips.GetCreatureDisplayID(creatureID);
            Tooltips.Append("DisplayID", displayID);
        end

        if Tooltips.ShouldShow("TooltipUnitShowNPCClass") then
            local _, class = C_PlayerInfo.GetClass({guid=guid});
            local className = LocalizedClassList()[class];
            Tooltips.Append("Class", className);
        end
    end
end

function Tooltips.OnTooltipSetUnitAura()
    local tooltip = Tooltips.GetCurrentTooltip();
    local tooltipInfo = tooltip:GetPrimaryTooltipInfo();
    local spellID = tooltipInfo.tooltipData.id;

    if Tooltips.ShouldShow("TooltipAuraShowSpellID") then
        Tooltips.Append("SpellID", spellID);
    end

    local args = tooltipInfo.getterArgs;
    local aura = C_UnitAuras.GetAuraDataByIndex(unpack(args));

    if not aura then
        return;
    end

    if Tooltips.ShouldShow("TooltipAuraShowIcon") then
        Tooltips.Append("Icon", aura.icon);
    end

    if aura.dispelName and Tooltips.ShouldShow("TooltipAuraShowDispel") then
        Tooltips.Append("DispelName", aura.dispelName);
    end

    if Tooltips.ShouldShow("TooltipAuraShowIsBossAura") then
        Tooltips.Append("IsBossAura", aura.isBossAura);
    end

    if aura.charges and Tooltips.ShouldShow("TooltipAuraShowCharges") then
        Tooltips.Append("Charges", aura.charges);
    end

    if aura.maxCharges and Tooltips.ShouldShow("TooltipAuraShowMaxCharges") then
        Tooltips.Append("MaxCharges", aura.maxCharges);
    end

    if aura.sourceUnit then
        if Tooltips.ShouldShow("TooltipAuraShowSourceUnit") then
            Tooltips.Append("SourceUnit", aura.sourceUnit);
        end

        if Tooltips.ShouldShow("TooltipAuraShowSourceName") then
            Tooltips.Append("SourceName", UnitName(aura.sourceUnit));
        end
    end

    if Tooltips.ShouldShow("TooltipAuraShowInstanceID") then
        Tooltips.Append("AuraInstanceID", aura.auraInstanceID);
    end

    if (aura.applications > 0) and Tooltips.ShouldShow("TooltipAuraShowStacks") then
        Tooltips.Append("Stacks", aura.applications);
    end

    if Tooltips.ShouldShow("TooltipAuraShowPlayerApplicable") then
        Tooltips.Append("PlayerApplicable", aura.canApplyAura);
    end

    if Tooltips.ShouldShow("TooltipAuraShowFromPlayerOrPet") then
        Tooltips.Append("FromPlayerOrPet", aura.isFromPlayerOrPlayerPet);
    end

    if aura.points and #aura.points > 0 and Tooltips.ShouldShow("TooltipAuraShowPoints") then
        Tooltips.AddLine("Points");
        for k, v in pairs(aura.points) do
            Tooltips.Append(format(TAB .. "- [%d]", k), v);
        end
    end

    if Tooltips.ShouldShow("TooltipAuraShowIsPrivate") then
        Tooltips.Append("IsPrivateAura", C_UnitAuras.AuraIsPrivate(spellID));
    end
end

function Tooltips.OnTooltipSetAchievement(achievementID)
    if not achievementID then
        local tooltip = Tooltips.GetCurrentTooltip();
        local tooltipInfo = tooltip:GetPrimaryTooltipInfo();
        local link = Tooltips.ParseLink(tooltipInfo.getterArgs[1]);
        if not link then
            return;
        end

        if Tooltips.ShouldShow("TooltipAchievementShowID") then
            Tooltips.Append("AchievementID", link.ID);
        end

        if Tooltips.ShouldShow("TooltipAchievementShowPlayerGUID") then
            Tooltips.Append("PlayerGUID", link.PlayerGUID);
        end

        local isCompleted = link.Completed == 1;
        if Tooltips.ShouldShow("TooltipAchievementShowCompleted") then
            Tooltips.Append("IsCompleted", isCompleted);
        end

        if isCompleted and Tooltips.ShouldShow("TooltipAchievementShowDate") then
            local month, day, year = link.Month, link.Day, link.Year;
            Tooltips.Append("Date", format("%d/%d/%d", month, day, year));
        end

        if Tooltips.ShouldShow("TooltipAchievementShowCriteria") then
            Tooltips.AddLine("Criteria");
            for i=1, 4 do
                local criteria = link["Criteria"..i];
                Tooltips.Append(format("%s- [%d]", TAB, i), criteria);
            end
        end
    else
        if Tooltips.ShouldShow("TooltipAchievementShowID") then
            Tooltips.Append("AchievementID", achievementID);
        end
    end
end

-- companion pet == battle pet for our use case
function Tooltips.OnTooltipSetCompanionPet()
    local tooltip = Tooltips.GetCurrentTooltip();
    local tooltipInfo = tooltip:GetPrimaryTooltipInfo();
    local petID = tooltipInfo.getterArgs[1];
    if tooltipInfo.getterName == "GetAction" then
        petID = select(2, GetActionInfo(petID));
    end
    if not petID or petID == "" then
        return;
    end

    local link = Tooltips.ParseLink(C_PetJournal.GetBattlePetLink(petID));
    if not link then
        return;
    end

    if Tooltips.ShouldShow("TooltipBattlePetShowSpeciesID") then
        Tooltips.Append("SpeciesID", link.SpeciesID);
    end

    if Tooltips.ShouldShow("TooltipBattlePetShowLevel") then
        Tooltips.Append("Level", link.Level);
    end

    if Tooltips.ShouldShow("TooltipBattlePetShowBreedQuality") then
        Tooltips.Append("BreedQuality", link.BreedQuality);
    end

    if Tooltips.ShouldShow("TooltipBattlePetShowMaxHealth") then
        Tooltips.Append("MaxHealth", link.MaxHealth);
    end

    if link.Power and Tooltips.ShouldShow("TooltipBattlePetShowPower") then
        Tooltips.Append("Power", link.Power);
    end

    if link.Speed and Tooltips.ShouldShow("TooltipBattlePetShowSpeed") then
        Tooltips.Append("Speed", link.Speed);
    end

    if Tooltips.ShouldShow("TooltipBattlePetShowPetID") then
        Tooltips.Append("PetID", petID);
    end

    if link.DisplayID and Tooltips.ShouldShow("TooltipBattlePetShowDisplayID") then
        Tooltips.Append("DisplayID", link.DisplayID);
    end
end

function Tooltips.OnTooltipSetCurrency()
    local tooltip = Tooltips.GetCurrentTooltip();
    local currencyID = tooltip:GetTooltipData().id;
    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);

    if currencyInfo.isHeader then
        return;
    end

    if Tooltips.ShouldShow("TooltipCurrencyShowCurrencyID") then
        Tooltips.Append("CurrencyID", currencyID);
    end

    if Tooltips.ShouldShow("TooltipCurrencyShowIcon") then
        Tooltips.Append("Icon", currencyInfo.iconFileID);
    end

    if Tooltips.ShouldShow("TooltipCurrencyShowLimitedPerWeek") then
        Tooltips.Append("LimitedPerWeek", currencyInfo.canEarnPerWeek);
    end

    if Tooltips.ShouldShow("TooltipCurrencyShowTradeable") then
        Tooltips.Append("Tradeable", currencyInfo.isTradeable);
    end

    if Tooltips.ShouldShow("TooltipCurrencyShowDiscovered") then
        Tooltips.Append("Discovered", currencyInfo.discovered);
    end

    local function IsValid(value)
        return value ~= nil;
    end

    if IsValid(currencyInfo.isAccountWide) and Tooltips.ShouldShow("TooltipCurrencyShowAccountWide") then
        Tooltips.Append("AccountWide", currencyInfo.isAccountWide);
    end

    if IsValid(currencyInfo.transferPercentage) then
        local isTransferable = currencyInfo.isAccountTransferable;
        if Tooltips.ShouldShow("TooltipCurrencyShowTransferable") then
            Tooltips.Append("Transferable", isTransferable);
        end

        if isTransferable and Tooltips.ShouldShow("TooltipCurrencyShowTransferPercentage") then
            Tooltips.Append("TransferPercentage", format("%d%%", currencyInfo.transferPercentage));
        end
    end

    if IsValid(currencyInfo.rechargingAmountPerCycle) and Tooltips.ShouldShow("TooltipCurrencyShowAmountPerCycle") then
        Tooltips.Append("AmountPerCycle", currencyInfo.rechargingAmountPerCycle);
    end

    if IsValid(currencyInfo.rechargingCycleDurationMS) and Tooltips.ShouldShow("TooltipCurrencyShowCycleDuration") then
        local durationHours = Round(currencyInfo.rechargingCycleDurationMS / 3.6e6);
        Tooltips.Append("CycleDuration (Hours)", durationHours);
    end

    if Tooltips.ShouldShow("TooltipCurrencyShowHasWarmodeBonus") then
        local hasWarModeBonus = C_CurrencyInfo.DoesWarModeBonusApply(currencyID);
        Tooltips.Append("HasWarModeBonus", hasWarModeBonus);
    end
end

local function IsGObjectGUID(guid)
    if not guid then
        return false;
    end

    local id = string.split("-", guid, 2);
    return id == "GameObject";
end

local GOBJECT_TOKENS = {
    "npc",
    "softinteract",
    "softtarget"
};

function Tooltips.OnTooltipSetObject()
    local guid;
    for _, token in pairs(GOBJECT_TOKENS) do
        local _guid = UnitGUID(token);
        if IsGObjectGUID(_guid) then
            guid = _guid;
            break;
        end
    end

    if not IsGObjectGUID(guid) then
        return;
    end

    if Tooltips.ShouldShow("TooltipObjectShowID") then
        local gobjectID = Tooltips.GetGObjectIDFromGUID(guid);
        Tooltips.Append("GameObjectID", gobjectID);
    end
end

function Tooltips.OnTooltipSetQuest(questID)
    if not questID then
        local tooltip = Tooltips.GetCurrentTooltip();
        local data = tooltip:GetTooltipData();
        questID = data.id;
    end

    if Tooltips.ShouldShow("TooltipQuestShowQuestID") then
        Tooltips.Append("QuestID", questID);
    end
end

------------

function Tooltips.Wrap(func, tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local success, err = pcall(func);
    if not success then
        Tooltips.SetLastError(err);
    end

    Tooltips.End();
end

local TOOLTIP_LEAVE_TICKER;

function Tooltips.StartOnLeaveTickerForObject(object, callback)
    TOOLTIP_LEAVE_TICKER = C_Timer.NewTicker(0, function()
        if GetMouseFoci()[1] ~= object and GetMouseFoci()[2] ~= object then
            callback(object);
            TOOLTIP_LEAVE_TICKER:Cancel();
            TOOLTIP_LEAVE_TICKER = nil;
        end
    end);
end

function Tooltips.WrapOwnTooltip(func, owner, manageVisibility, anchor)
    local tooltip = GameTooltip;
    if not Tooltips.Begin(tooltip) then
        return;
    end

    if manageVisibility then
        tooltip:ClearAllPoints();
        if not anchor then
            tooltip:SetPoint("TOPRIGHT", owner, "TOPLEFT", 0, 0);
            tooltip:SetOwner(owner, "ANCHOR_PRESERVE");
        else
            tooltip:SetOwner(owner, anchor);
        end
    end

    local success, err = pcall(func);
    if not success then
        Tooltips.SetLastError(err);
    end

    tooltip:Show();

    Tooltips.End();
end

------------
-- the joys of not supporting classic omegalul

local _W = function(func) return function(tooltip) Tooltips.Wrap(func, tooltip); end end;

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, _W(Tooltips.OnTooltipSetItem));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, _W(Tooltips.OnTooltipSetSpell));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, _W(Tooltips.OnTooltipSetMacro));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, _W(Tooltips.OnTooltipSetToy));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, _W(Tooltips.OnTooltipSetMount));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, _W(Tooltips.OnTooltipSetUnit));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, _W(Tooltips.OnTooltipSetUnitAura));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, _W(Tooltips.OnTooltipSetAchievement));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.CompanionPet, _W(Tooltips.OnTooltipSetCompanionPet));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, _W(Tooltips.OnTooltipSetCurrency));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Object, _W(Tooltips.OnTooltipSetObject));
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, _W(Tooltips.OnTooltipSetQuest));

-- the joys of tooltips that sidestep the above system
local callbackNames = {
    "TaskPOI.TooltipShown",
    "MapCanvas.QuestPin.OnEnter",
    "QuestMapLogTitleButton.OnEnter",
    "OnQuestBlockHeader.OnEnter",
};

local callbacksToManageVisiblity = {
    ["OnQuestBlockHeader.OnEnter"] = true
};

for _, callbackName in ipairs(callbackNames) do
    EventRegistry:RegisterCallback(callbackName, function(_, block, blockID)
        Tooltips.WrapOwnTooltip(function() Tooltips.OnTooltipSetQuest(blockID); end, block, callbacksToManageVisiblity[callbackName]);
    end);
end

------------
--- achievement frame tooltips

local LAST_ACHIEVEMENT_TOOLTIP_OWNER;
local function OnAchievementEnter(_, self)
    if not self:IsVisible() then
        return;
    end

    local data = self:GetData();
    Tooltips.WrapOwnTooltip(function() Tooltips.OnTooltipSetAchievement(data.id); end, self, true, "ANCHOR_RIGHT");
    LAST_ACHIEVEMENT_TOOLTIP_OWNER = self;
end

local function OnAchievementLeave(_, self)
    if self and not self:IsVisible() then
        return;
    end

    GameTooltip:Hide();
end

EventRegistry:RegisterCallback("AchievementFrameAchievement.OnEnter", OnAchievementEnter);
EventRegistry:RegisterCallback("AchievementFrameAchievement.OnLeave", OnAchievementLeave);
EventUtil.ContinueOnAddOnLoaded("Blizzard_AchievementUI", function() -- ensure the tooltips hide correctly when the achievement frame is closed
    AchievementFrame:HookScript("OnHide", function()
        if LAST_ACHIEVEMENT_TOOLTIP_OWNER and GameTooltip:IsOwned(LAST_ACHIEVEMENT_TOOLTIP_OWNER) then
            GameTooltip:Hide();
            LAST_ACHIEVEMENT_TOOLTIP_OWNER = nil;
        end
    end);
end);

------------
--- profession spec trait tooltips

local function GetCurrentProfSpecConfigID()
    return ProfessionsFrame and ProfessionsFrame.SpecPage and ProfessionsFrame.SpecPage.configID;
end

local function OnSpecPathEntered(_, pathID, _)
    Tooltips.Begin(GameTooltip);

    local configID = GetCurrentProfSpecConfigID();
    Tooltips.OnTooltipSetProfSpecPath(configID, pathID);
    GameTooltip:Show(); -- to fix sizing issues

    Tooltips.End();
end

local function OnSpecPerkEntered(_, perkID)
    Tooltips.Begin(GameTooltip);

    local configID = GetCurrentProfSpecConfigID();
    Tooltips.OnTooltipSetProfSpecPerk(configID, perkID);
    GameTooltip:Show();

    Tooltips.End();
end

local function OnSpecTabEntered(_, traitTreeID)
    Tooltips.Begin(GameTooltip);

    local configID = GetCurrentProfSpecConfigID();
    Tooltips.OnTooltipSetProfSpecTree(configID, traitTreeID);
    GameTooltip:Show();

    Tooltips.End();
end

EventRegistry:RegisterCallback("ProfessionSpecs.SpecPathEntered", OnSpecPathEntered);
EventRegistry:RegisterCallback("ProfessionSpecs.SpecPerkEntered", OnSpecPerkEntered);
EventRegistry:RegisterCallback("ProfessionSpecs.SpecTabEntered", OnSpecTabEntered);

------------
Datamine.Tooltips = Tooltips;

local helpMessage = L.SLASH_CMD_TOOLTIP_LAST_ERR_HELP;
Datamine.Slash:RegisterCommand("tooltiperror", function() local err = Tooltips.GetLastError() if err then Datamine.Utils.Print("Tooltips", "Pushing error to error handler."); CallErrorHandler(err); end end, helpMessage, "Tooltips");