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
    assert(CURRENT_TOOLTIP == nil or tooltip == CURRENT_TOOLTIP, "Attempt to begin new tooltip context while a tooltip is already in context");
    CURRENT_TOOLTIP = tooltip;
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
    return WHITE_FONT_COLOR;
end

function Tooltips.GetValueColor()
    return HIGHLIGHT_FONT_COLOR;
end

------------

function Tooltips.ColorKeyValueText(key, value)
    local keyColor, valueColor = Tooltips.GetKeyColor(), Tooltips.GetValueColor();
    return keyColor:WrapTextInColorCode(key), valueColor:WrapTextInColorCode(value);
end

function Tooltips.FormatKeyValuePair(key, value)
    return Tooltips.ColorKeyValueText(key .. ":", tostring(value));
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
    Tooltips.Begin(tooltip);

    local linkType, linkID = string.match(link, "^(%a+):(%d+)");
    local left, right = Tooltips.FormatKeyValuePair(linkType, linkID);
    Tooltips.AddDoubleLine(left, right);

    Tooltips.End();
end

function Tooltips.OnTooltipSetItem(tooltip)
    Tooltips.Begin(tooltip);

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
                Tooltips.FormatAndAddDoubleLine(TAB .. "-" .. modifierType, modifier.Value);
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

    tooltip:Show();
end

------------
-- final setup

Tooltips.HookMethod(ItemRefTooltip, "SetHyperlink", Tooltips.OnHyperlinkSet);
Tooltips.HookMethod(GameTooltip, "SetHyperlink", Tooltips.OnHyperlinkSet);

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, Tooltips.OnTooltipSetItem);

------------

Datamine.Tooltips = Tooltips;