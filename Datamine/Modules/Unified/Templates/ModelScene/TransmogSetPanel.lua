local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

local OWNED_ATLAS = "common-icon-checkmark";
local UNOWNED_ATLAS = "common-icon-redx";

DatamineModelControlsTransmogSetItemEntryMixin = {};

function DatamineModelControlsTransmogSetItemEntryMixin:OnLoad()
    Registry:RegisterCallback(Events.MODEL_CONTROLS_TRANSMOG_SET_ITEM_SELECTED, self.OnItemSelected, self);
end

function DatamineModelControlsTransmogSetItemEntryMixin:Init(node)
    self.Data = node:GetData();
    self:SetSelected(self.Data.IsSelected);

    local _, _, _, _, isCollected, itemLink = C_TransmogCollection.GetAppearanceSourceInfo(self.Data.SourceID);
    if C_Item.IsItemDataCachedByID(itemLink) then
        self:SetText(itemLink);
        self:SetOwned(isCollected);
    else
        local item = Item:CreateFromItemLink(itemLink);
        item:ContinueOnItemLoad(function()
            local data = {C_TransmogCollection.GetAppearanceSourceInfo(self.Data.SourceID)};
            local isOwned, text = data[5], data[6];
            self:SetText(text);
            self:SetOwned(isOwned);
        end);
    end
end

function DatamineModelControlsTransmogSetItemEntryMixin:SetText(text)
    self.Text:SetText(text);
end

function DatamineModelControlsTransmogSetItemEntryMixin:SetOwned(isOwned)
    local icon = isOwned and OWNED_ATLAS or UNOWNED_ATLAS;
    self.Icon:SetAtlas(icon);
end

function DatamineModelControlsTransmogSetItemEntryMixin:SetSelected(isSelected)
    self.SelectedHighlight:SetShown(isSelected);
    self.IsSelected = isSelected;
end

function DatamineModelControlsTransmogSetItemEntryMixin:OnItemSelected(invSlot, sourceID)
    if invSlot ~= self.Data.InvSlot then
        return;
    end
    self:SetSelected(sourceID == self.Data.SourceID);
end