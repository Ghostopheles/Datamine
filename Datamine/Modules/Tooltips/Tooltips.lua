local Tooltips = {};
local Hooks = {};

local ID_TYPE = {
    ITEM = 1
};

local TAB_SIZE = 2;
local TAB = strrep(" ", TAB_SIZE);

local CURRENT_TOOLTIP = nil;

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

function Tooltips.End()
    assert(CURRENT_TOOLTIP, "Attempt to end non-existent tooltip context");
    CURRENT_TOOLTIP = nil;
end

------------

function Tooltips.HookFunction(funcName, callback)
    assert(not Hooks[funcName], "Attempt to hook an already hooked function");

    hooksecurefunc(funcName, callback);
    Hooks[funcName] = true;
end

function Tooltips.HookMethod(frame, funcName, callback)
    if not Hooks[frame] then
        Hooks[frame] = {};
    end

    assert(not Hooks[frame][funcName], "Attempt to hook an already hooked method");

    hooksecurefunc(frame, funcName, callback);
    Hooks[frame][funcName] = true;
end

------------

function Tooltips.GetKeyColor()
    return Datamine.Settings.GetColor("TooltipKeyColor");
end

function Tooltips.GetValueColor()
    return Datamine.Settings.GetColor("TooltipValueColor");
end

function Tooltips.ShouldShow(configKey)
    return Datamine.Settings.GetSetting(configKey);
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

function Tooltips.FormatAndAddDoubleLine(key, value)
    if type(value) == "table" then
        value = strjoin(", ", unpack(value));
    end

    local left, right = Tooltips.FormatKeyValuePair(key, value);
    Tooltips.AddDoubleLine(left, right);
end

function Tooltips.ParseItemLink(itemLink)
    return Datamine.Structures.CreateItemLink(itemLink);
end

------

function Tooltips.OnHyperlinkSet(tooltip, link)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local linkType, linkID = string.match(link, "^(%a+):(%d+)");
    local left, right = Tooltips.FormatKeyValuePair(linkType, linkID);
    Tooltips.AddDoubleLine(left, right);

    Tooltips.End();
end

function Tooltips.OnTooltipSetItem(tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local itemLink;
    if tooltip.GetItem then
        itemLink = select(2, tooltip:GetItem());
    end
    if not itemLink then
        Tooltips.End();
        return;
    end

    local item = Tooltips.ParseItemLink(itemLink);

    if Tooltips.ShouldShow("TooltipItemShowItemID") then
        Tooltips.FormatAndAddDoubleLine("ItemID", item.ItemID);
    end

    if item.EnchantID and Tooltips.ShouldShow("TooltipItemShowEnchantID") then
        Tooltips.FormatAndAddDoubleLine("EnchantID", item.EnchantID);
    end

    if item.ExtraEnchantID and Tooltips.ShouldShow("TooltipItemShowExtraEnchantID") then
        Tooltips.FormatAndAddDoubleLine("ExtraEnchantID", item.ExtraEnchantID);
    end

    if (#item.GemIDs > 0) and Tooltips.ShouldShow("TooltipItemShowGemIDs") then
        Tooltips.FormatAndAddDoubleLine("GemIDs", item.GemIDs);
    end

    if (item.NumBonusIDs > 0) and Tooltips.ShouldShow("TooltipItemShowBonusIDs") then
        Tooltips.FormatAndAddDoubleLine("BonusIDs", item.BonusIDs);
    end

    if (item.NumModifiers > 0) and Tooltips.ShouldShow("TooltipItemShowModifiers") then
        Tooltips.AddLine("Modifiers");
        for _, modifier in pairs(item.Modifiers) do
            if modifier.Type and modifier.Value then
                local modifierType = Datamine.GetEnumValueName(Enum.ItemModification, modifier.Type);
                Tooltips.FormatAndAddDoubleLine(TAB .. "- " .. modifierType, modifier.Value);
            end
        end
    end

    if Tooltips.ShouldShow("TooltipItemShowRelicBonuses") then
        for i=1, 3 do
            local numKeyName = "Relic" .. i .. "NumBonusIDs";
            if (item[numKeyName] or 0) > 0 then
                local keyName = "Relic" .. i .. "BonusIDs";
                Tooltips.FormatAndAddDoubleLine(keyName, item[keyName]);
            end
        end
    end

    if item.ItemContext and Tooltips.ShouldShow("TooltipItemShowItemContext") then
        local contextType = Datamine.GetEnumValueName(Enum.ItemCreationContext, item.ItemContext);
        Tooltips.FormatAndAddDoubleLine("ItemContext", format("%s (%d)", contextType, item.ItemContext));
    end

    if item.CrafterGUID and Tooltips.ShouldShow("TooltipItemShowCrafterGUID") then
        Tooltips.FormatAndAddDoubleLine("CrafterGUID", item.CrafterGUID);
    end

    if Tooltips.ShouldShow("TooltipItemShowItemSpellID") then
        local itemSpellName, itemSpellID = C_Item.GetItemSpell(item.ItemID);
        if itemSpellName and itemSpellID then
            Tooltips.FormatAndAddDoubleLine("ItemSpell", format("%s (%d)", itemSpellName, itemSpellID));
        end
    end

    Tooltips.End();
end

function Tooltips.OnTooltipSetSpell(tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local spellID;
    if tooltip.GetSpell then
        spellID = select(2, tooltip:GetSpell());
    end
    if not spellID then
        Tooltips.End();
        return;
    end

    if Tooltips.ShouldShow("TooltipSpellShowSpellID") then
        Tooltips.FormatAndAddDoubleLine("SpellID", spellID);
    end

    Tooltips.End();
end

function Tooltips.OnTooltipSetMacro(tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local tooltipData = tooltip:GetPrimaryTooltipInfo();
    local actionSlot = tooltipData.getterArgs[1];

    if Tooltips.ShouldShow("TooltipMacroShowMacroName") then
        local macroName = GetActionText(actionSlot);
        Tooltips.FormatAndAddDoubleLine("Macro Name", macroName);
    end

    if Tooltips.ShouldShow("TooltipMacroShowMacroAction") then
        local _, spellID = GetActionInfo(actionSlot);
        local actionKey = IsItemAction(actionSlot) and "Macro Item Slot" or "Macro Spell";
        Tooltips.FormatAndAddDoubleLine(actionKey, spellID);
    end

    if Tooltips.ShouldShow("TooltipMacroShowMacroIcon") then
        local icon = GetActionTexture(actionSlot);
        Tooltips.FormatAndAddDoubleLine("Macro Icon", icon);
    end

    Tooltips.End();
end

function Tooltips.OnTooltipSetToy(tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local itemID = tooltip:GetTooltipData().id;

    if Tooltips.ShouldShow("TooltipToyShowItemID") then
        Tooltips.FormatAndAddDoubleLine("ItemID", itemID);
    end

    if Tooltips.ShouldShow("TooltipToyShowItemSpell") then
        local itemSpellName, itemSpellID = C_Item.GetItemSpell(itemID);
        if itemSpellName and itemSpellID then
            Tooltips.FormatAndAddDoubleLine("ItemSpell", format("%s (%d)", itemSpellName, itemSpellID));
        end
    end

    if Tooltips.ShouldShow("TooltipToyShowIcon") then
        local icon = select(3, C_ToyBox.GetToyInfo(itemID));
        Tooltips.FormatAndAddDoubleLine("Icon", icon);
    end

    Tooltips.End();
end

function Tooltips.OnTooltipSetMount(tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local mountID = tooltip:GetTooltipData().id;

    if Tooltips.ShouldShow("TooltipMountShowMountID") then
        Tooltips.FormatAndAddDoubleLine("MountID", mountID);
    end

    local mountInfo = {C_MountJournal.GetMountInfoByID(mountID)};
    local spellID = mountInfo[2];
    if not spellID then
        Tooltips.End();
        return;
    end

    if Tooltips.ShouldShow("TooltipMountShowSpellID") then
        Tooltips.FormatAndAddDoubleLine("SpellID", spellID);
    end

    if Tooltips.ShouldShow("TooltipMountShowIcon") then
        Tooltips.FormatAndAddDoubleLine("Icon", mountInfo[3]);
    end

    if Tooltips.ShouldShow("TooltipMountShowFaction") then
        if mountInfo[8] then
            local faction = mountInfo[9];
            local factionName = faction == 0 and "Horde" or "Alliance";
            Tooltips.FormatAndAddDoubleLine("Faction", factionName);
        end
    end

    if Tooltips.ShouldShow("TooltipMountShowSkyriding") then
        Tooltips.FormatAndAddDoubleLine("Skyriding", mountInfo[13]);
    end

    local extraMountInfo = {C_MountJournal.GetMountInfoExtraByID(mountID)};

    if Tooltips.ShouldShow("TooltipMountShowDisplay") then
        Tooltips.FormatAndAddDoubleLine("DisplayID", extraMountInfo[1]);
    end

    if Tooltips.ShouldShow("TooltipMountShowType") then
        Tooltips.FormatAndAddDoubleLine("MountTypeID", extraMountInfo[5]);
    end

    if Tooltips.ShouldShow("TooltipMountShowModelScene") then
        Tooltips.FormatAndAddDoubleLine("UiModelSceneID", extraMountInfo[6]);
    end

    if Tooltips.ShouldShow("TooltipMountShowAnim") then
        Tooltips.FormatAndAddDoubleLine("AnimID", extraMountInfo[7]);
    end

    if Tooltips.ShouldShow("TooltipMountShowSpellVisual") then
        Tooltips.FormatAndAddDoubleLine("SpellVisualKitID", extraMountInfo[8]);
    end

    Tooltips.End();
end

------------
-- final setup

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, Tooltips.OnTooltipSetItem);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, Tooltips.OnTooltipSetSpell);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, Tooltips.OnTooltipSetMacro);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, Tooltips.OnTooltipSetToy);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, Tooltips.OnTooltipSetMount);

------------

Datamine.Tooltips = Tooltips;