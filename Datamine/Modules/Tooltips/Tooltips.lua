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
-- this prevents us from customizing the same tooltip multiple times, as there can only ever be one tooltip context
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

    Tooltips.FormatAndAddDoubleLine("ItemID", item.ItemID);

    if item.EnchantID then
        Tooltips.FormatAndAddDoubleLine("EnchantID", item.EnchantID);
    end

    if item.ExtraEnchantID then
        Tooltips.FormatAndAddDoubleLine("ExtraEnchantID", item.ExtraEnchantID);
    end

    if #item.GemIDs > 0 then
        Tooltips.FormatAndAddDoubleLine("GemIDs", item.GemIDs);
    end

    if item.NumBonusIDs > 0 then
        Tooltips.FormatAndAddDoubleLine("BonusIDs", item.BonusIDs);
    end

    if item.NumModifiers > 0 then
        Tooltips.AddLine("Modifiers");
        for _, modifier in pairs(item.Modifiers) do
            if modifier.Type and modifier.Value then
                local modifierType = Datamine.GetEnumValueName(Enum.ItemModification, modifier.Type);
                Tooltips.FormatAndAddDoubleLine(TAB .. "- " .. modifierType, modifier.Value);
            end
        end
    end

    for i=1, 3 do
        local numKeyName = "Relic" .. i .. "NumBonusIDs";
        if (item[numKeyName] or 0) > 0 then
            local keyName = "Relic" .. i .. "BonusIDs";
            Tooltips.FormatAndAddDoubleLine(keyName, item[keyName]);
        end
    end

    if item.ItemContext then
        local contextType = Datamine.GetEnumValueName(Enum.ItemCreationContext, item.ItemContext);
        Tooltips.FormatAndAddDoubleLine("ItemContext", format("%s (%d)", contextType, item.ItemContext));
    end

    if item.CrafterGUID then
        Tooltips.FormatAndAddDoubleLine("CrafterGUID", item.CrafterGUID);
    end

    local itemSpellName, itemSpellID = C_Item.GetItemSpell(item.ItemID);
    if itemSpellName and itemSpellID then
        Tooltips.FormatAndAddDoubleLine("ItemSpell", format("%s (%d)", itemSpellName, itemSpellID));
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

    Tooltips.FormatAndAddDoubleLine("SpellID", spellID);
    Tooltips.End();
end

function Tooltips.OnTooltipSetMacro(tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local tooltipData = tooltip:GetPrimaryTooltipInfo();
    local actionSlot = tooltipData.getterArgs[1];

    local macroName = GetActionText(actionSlot);
    Tooltips.FormatAndAddDoubleLine("Macro Name", macroName);

    local _, spellID = GetActionInfo(actionSlot);
    local actionKey = IsItemAction(actionSlot) and "Macro Item Slot" or "Macro Spell";
    Tooltips.FormatAndAddDoubleLine(actionKey, spellID);

    local icon = GetActionTexture(actionSlot);
    Tooltips.FormatAndAddDoubleLine("Macro Icon", icon);

    Tooltips.End();
end

function Tooltips.OnTooltipSetToy(tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local itemID = tooltip:GetTooltipData().id;
    Tooltips.FormatAndAddDoubleLine("ItemID", itemID);

    local itemSpellName, itemSpellID = C_Item.GetItemSpell(itemID);
    if itemSpellName and itemSpellID then
        Tooltips.FormatAndAddDoubleLine("ItemSpell", format("%s (%d)", itemSpellName, itemSpellID));
    end

    local icon = select(3, C_ToyBox.GetToyInfo(itemID));
    Tooltips.FormatAndAddDoubleLine("Icon", icon);

    Tooltips.End();
end

function Tooltips.OnTooltipSetMount(tooltip)
    if not Tooltips.Begin(tooltip) then
        return;
    end

    local mountID = tooltip:GetTooltipData().id;
    Tooltips.FormatAndAddDoubleLine("MountID", mountID);

    local mountInfo = {C_MountJournal.GetMountInfoByID(mountID)};
    local spellID = mountInfo[2];
    if not spellID then
        Tooltips.End();
        return;
    end

    Tooltips.FormatAndAddDoubleLine("SpellID", spellID);
    Tooltips.FormatAndAddDoubleLine("Icon", mountInfo[3]);

    if mountInfo[8] then
        local faction = mountInfo[9];
        local factionName = faction == 0 and "Horde" or "Alliance";
        Tooltips.FormatAndAddDoubleLine("Faction", factionName);
    end

    Tooltips.FormatAndAddDoubleLine("Skyriding", mountInfo[13]);

    local extraMountInfo = {C_MountJournal.GetMountInfoExtraByID(mountID)};
    Tooltips.FormatAndAddDoubleLine("DisplayID", extraMountInfo[1]);
    Tooltips.FormatAndAddDoubleLine("MountTypeID", extraMountInfo[5]);
    Tooltips.FormatAndAddDoubleLine("UiModelSceneID", extraMountInfo[6]);
    Tooltips.FormatAndAddDoubleLine("AnimID", extraMountInfo[7]);
    Tooltips.FormatAndAddDoubleLine("SpellVisualKitID", extraMountInfo[8]);

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