local Print = function(...) Datamine.Print("ModelView", ...) end;

DatamineModelFrameMixin = CreateFromMixins(DressUpModelFrameMixin, CallbackRegistryMixin);

local MODES = {
    ModelScene = 1,
    PlayerModel = 2,
};

function DatamineModelFrameMixin:OnLoad()
    self:SetTitle("Datamine Model Viewer");
    self:SetSize(600, 800);
    self:ClearAllPoints();
    self:SetPoint("CENTER");

    self:SetMovable(true);
    self.TitleContainer:RegisterForDrag("LeftButton");
    self.TitleContainer:SetScript("OnMouseDown", function()
        self:StartMoving();
    end);
    self.TitleContainer:SetScript("OnMouseUp", function()
        self:StopMovingOrSizing();
    end);

    if DevTool then
        C_Timer.After(1, function() DevTool:AddData(DatamineDressUpFrame.ModelScene, "DatamineDressUpFrame"); end);
    end

    self.ViewingMode = MODES.ModelScene;
end

function DatamineModelFrameMixin:OnShow()
    SetPortraitTexture(DatamineDressUpFramePortrait, "player");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    self:SetupPlayerModel();
    self:SetViewingMode(MODES.ModelScene);
end

function DatamineModelFrameMixin:ToggleControlPanel()
    local show = not self.ControlPanel:IsShown();
    self.ControlPanel:SetShown(show);
end

function DatamineModelFrameMixin:OnPlayerModelActivated()
    self.ModelScene:Hide();
    self.PlayerModel:Show();
    self.ControlPanel.Pages.PlayerModelPage:Show();
    self.ControlPanel.Pages.ModelScenePage:Hide();
end

function DatamineModelFrameMixin:OnModelSceneActivated()
    self.ModelScene:Show();
    self.PlayerModel:Hide();
    self.ControlPanel.Pages.ModelScenePage:Show();
    self.ControlPanel.Pages.PlayerModelPage:Hide();
end

function DatamineModelFrameMixin:SetViewingMode(newMode)
    if newMode == MODES.PlayerModel then
        self:OnPlayerModelActivated();
    elseif newMode == MODES.ModelScene then
        self:OnModelSceneActivated();
    end

    self.ViewingMode = newMode;
end

function DatamineModelFrameMixin:GetActor()
    if self.ViewingMode == MODES.PlayerModel then
        return self.PlayerModel;
    elseif self.ViewingMode == MODES.ModelScene then
        return self.ModelScene:GetPlayerActor();
    end
end

function DatamineModelFrameMixin:ResetEntryBoxes()
    self.ControlPanel.ModelFileIDEntry:SetText("");
    self.ControlPanel.CDisplayInfoIDEntry:SetText("");
end

function DatamineModelFrameMixin:SetupPlayerModel()
    local playerModel = self.PlayerModel;
    if not playerModel then
        playerModel = CreateFrame("PlayerModel", nil, self, "DataminePlayerModelTemplate");
        playerModel:SetAllPoints(self.Inset);
    end

    self.PlayerModel = playerModel;

    if DevTool then
        C_Timer.After(0, function() DevTool:AddData(self.PlayerModel, "PlayerModel") end);
    end
end

function DatamineModelFrameMixin:SetCreature(creatureID, displayID)
    local actor = self:GetActor();

    if not actor then return end;

    creatureID = strtrim(creatureID);
    displayID = strtrim(displayID);
    
    if displayID == "" and creatureID == "" then
        actor:ResetModel();
        return;
    elseif displayID == "" then
        displayID = nil;
    end

    return actor:SetCreature(creatureID, displayID);
end

function DatamineModelFrameMixin:ToggleSceneMode()
    if self.ViewingMode == MODES.ModelScene then
        self:SetViewingMode(MODES.PlayerModel);
    elseif self.ViewingMode == MODES.PlayerModel then
        self:SetViewingMode(MODES.ModelScene);
    end
end

function DatamineModelFrameMixin:SetDressState(dressed)
    local actor = self:GetActor();
    if dressed then
        actor:Dress()
    else
        actor:Undress()
    end
end

function DatamineModelFrameMixin:SetModelByFileID(fdid, enableMips)
    local actor = self:GetActor();

    if not actor then return end;
    fdid = strtrim(fdid);
    return actor:SetModelByFileID(tonumber(fdid), enableMips);
end

function DatamineModelFrameMixin:SetModelByCreatureDisplayID(displayID)
    local actor = self:GetActor();

    if not actor then return end;
    displayID = strtrim(displayID);
    return actor:SetModelByCreatureDisplayID(tonumber(displayID));
end

function DatamineModelFrameMixin:ApplySpellVisualKit(spellVisualKitID, loop)
    local actor = self:GetActor();
    if not actor then return end;

    loop = loop or false;
    spellVisualKitID = strtrim(spellVisualKitID);

    actor:SetSpellVisualKit(tonumber(spellVisualKitID), loop);
    return true;
end

function DatamineModelFrameMixin:PlayAnimationKit(animationKitID, loop)
    local actor = self:GetActor();
    if not actor then return end;

    loop = loop or true;
    animationKitID = strtrim(animationKitID);

    if animationKitID == "" then
        if self.ViewingMode == MODES.ModelScene then
            actor:StopAnimationKit();
        elseif self.ViewingMode == MODES.PlayerModel then
            actor:StopAnimKit();
        end
        return true;
    end

    if self.ViewingMode == MODES.ModelScene then
        actor:PlayAnimationKit(tonumber(animationKitID), loop);
    elseif self.ViewingMode == MODES.PlayerModel then
        actor:PlayAnimKit(tonumber(animationKitID), loop);
    end
    return true;
end

DatamineModelFrameControlPanelMixin = CreateFromMixins(DressUpOutfitDetailsPanelMixin);

--- this is a disaster, don't look too closely
function DatamineModelFrameControlPanelMixin:OnLoad()
	local frameLevel = self:GetParent().NineSlice:GetFrameLevel();
	self:SetFrameLevel(frameLevel + 1);

    self.Pages = {};

    self.Header = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    self.Header:SetPoint("TOP", self, 0, -25);
    self.Header:SetText("Model Controls");
    self.Header:SetTextScale(1.3);
    self.Header:SetTextColor(1, 1, 1, 1);

    self:SetupModelScenePage();
    self:SetupPlayerModelPage();
end

function DatamineModelFrameControlPanelMixin:SetupModelScenePage()
    local page = CreateFrame("Frame", nil, self);
    local buttonWidth = 128;
    local editBoxHeight = 20;
    local modelScene = self:GetParent().ModelScene;

    page:SetPoint("TOPLEFT", self, 25, -50);
    page:SetPoint("BOTTOMRIGHT");

    do -- sheathe state toggle
        local label = page:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        label:SetJustifyH("CENTER");
        label:SetText("Weapon Sheathe");
        label:SetPoint("TOPLEFT", page, 0, 0);
        label:SetPoint("TOPRIGHT", page, -25, 0);
        label:SetTextScale(1);
        label:SetTextColor(1, 1, 1, 1);

        local a = CreateFrame("Button", nil, page, "UIPanelButtonTemplate");
        a:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, 0);
        a:SetWidth(buttonWidth / 1.35);
        a:SetText("Unsheathe");
        a:RegisterForClicks("AnyUp");
        a:SetScript("OnClick", function() modelScene:GetPlayerActor():SetSheathed(false) end);

        local b = CreateFrame("Button", nil, page, "UIPanelButtonTemplate");
        b:SetPoint("LEFT", a, "RIGHT", 10, 0);
        b:SetWidth(buttonWidth / 1.35);
        b:SetText("Sheathe");
        b:RegisterForClicks("AnyUp");
        b:SetScript("OnClick", function() modelScene:GetPlayerActor():SetSheathed(true) end);

        page.SheatheLabel = label;
        page.SheatheButton = a;
        page.UnsheatheButton = b;
    end

    do -- dress state toggles
        local label = page:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        label:SetJustifyH("CENTER");
        label:SetText("Dress State");
        label:SetPoint("TOPLEFT", page.SheatheButton, "BOTTOMLEFT", 0, -10);
        label:SetPoint("TOPRIGHT", page.UnsheatheButton, "BOTTOMRIGHT", 0, -10);
        label:SetTextScale(1);
        label:SetTextColor(1, 1, 1, 1);

        local a = CreateFrame("Button", nil, page, "UIPanelButtonTemplate");
        a:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5);
        a:SetWidth(buttonWidth / 1.35);
        a:SetText("Dress");
        a:RegisterForClicks("AnyUp");
        a:SetScript("OnClick", function() DatamineDressUpFrame:SetDressState(true) end);

        local b = CreateFrame("Button", nil, page, "UIPanelButtonTemplate");
        b:SetPoint("LEFT", a, "RIGHT", 10, 0);
        b:SetWidth(buttonWidth / 1.35);
        b:SetText("Undress");
        b:RegisterForClicks("AnyUp");
        b:SetScript("OnClick", function() DatamineDressUpFrame:SetDressState(false) end);

        page.DressButton = a;
        page.UndressButton = b;
    end

    do -- set model by file ID
        local label = page:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        label:SetJustifyH("CENTER");
        label:SetText("Model");
        label:SetPoint("TOPLEFT", page.DressButton, "BOTTOMLEFT", 0, -10);
        label:SetPoint("TOPRIGHT", page.UndressButton, "BOTTOMRIGHT", 0, -10);
        label:SetTextScale(1);
        label:SetTextColor(1, 1, 1, 1);

        local fileIDEntryBox = CreateFrame("EditBox", nil, page, "DatamineEditBoxTemplate");
        fileIDEntryBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 5, -20);
        fileIDEntryBox:SetPoint("TOPRIGHT", label, "BOTTOMRIGHT", 0, -20);
        fileIDEntryBox:SetHeight(editBoxHeight);
        fileIDEntryBox.LabelText = "Set model by FileDataID";
        fileIDEntryBox.Instructions:SetText("FileDataID...");
        fileIDEntryBox.Callback = function(...) return DatamineDressUpFrame:SetModelByFileID(...); end;

        page.ModelFileIDEntry = fileIDEntryBox;
    end

    do -- set model by creatureDisplayInfo ID
        local cdiIDEntryBox = CreateFrame("EditBox", nil, page, "DatamineEditBoxTemplate");
        cdiIDEntryBox:SetPoint("TOPLEFT", page.ModelFileIDEntry, "BOTTOMLEFT", 0, -20);
        cdiIDEntryBox:SetPoint("TOPRIGHT", page.ModelFileIDEntry, "BOTTOMRIGHT", 0, -20);
        cdiIDEntryBox:SetHeight(editBoxHeight);
        cdiIDEntryBox.LabelText = "Set model by CreatureDisplayInfoID";
        cdiIDEntryBox.Instructions:SetText("CreatureDisplayInfoID...");
        cdiIDEntryBox.Callback = function(...) return DatamineDressUpFrame:SetModelByCreatureDisplayID(...); end;

        page.CDisplayInfoIDEntry = cdiIDEntryBox;
    end

    do -- apply a SpellVisualKit by ID
        local spellVisIDEntryBox = CreateFrame("EditBox", nil, page, "DatamineEditBoxTemplate");
        spellVisIDEntryBox:SetPoint("TOPLEFT", page.CDisplayInfoIDEntry, "BOTTOMLEFT", 0, -20);
        spellVisIDEntryBox:SetPoint("TOPRIGHT", page.CDisplayInfoIDEntry, "BOTTOMRIGHT", 0, -20);
        spellVisIDEntryBox:SetHeight(editBoxHeight);
        spellVisIDEntryBox.LabelText = "Apply a looping SpellVisualKit";
        spellVisIDEntryBox.Instructions:SetText("SpellVisualKitID...");
        spellVisIDEntryBox.Callback = function(...) return DatamineDressUpFrame:ApplySpellVisualKit(...); end;

        page.SpellVisualKitEntryBox = spellVisIDEntryBox;
    end

    do -- play an AnimationKit by ID
        local animKitIDEntryBox = CreateFrame("EditBox", nil, page, "DatamineEditBoxTemplate");
        animKitIDEntryBox:SetPoint("TOPLEFT", page.SpellVisualKitEntryBox, "BOTTOMLEFT", 0, -20);
        animKitIDEntryBox:SetPoint("TOPRIGHT", page.SpellVisualKitEntryBox, "BOTTOMRIGHT", 0, -20);
        animKitIDEntryBox:SetHeight(editBoxHeight);
        animKitIDEntryBox.LabelText = "Play a looping AnimationKitID";
        animKitIDEntryBox.Instructions:SetText("AnimationKitID...");
        animKitIDEntryBox.Callback = function(...) return DatamineDressUpFrame:PlayAnimationKit(...); end;

        page.AnimKitIDEntryBox = animKitIDEntryBox;
    end

    page:SetScript("OnShow", function()
        page.ModelFileIDEntry:SetText("");
        page.CDisplayInfoIDEntry:SetText("");
        page.SpellVisualKitEntryBox:SetText("");
        page.AnimKitIDEntryBox:SetText("");
    end)

    self.Pages.ModelScenePage = page;
end

function DatamineModelFrameControlPanelMixin:SetupPlayerModelPage()
    local page = CreateFrame("Frame", nil, self);
    local editBoxHeight = 20;

    page:SetPoint("TOPLEFT", self, 25, -50);
    page:SetPoint("BOTTOMRIGHT", self, 0, 0);

    do -- set creature ID
        local label = page:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        label:SetJustifyH("CENTER");
        label:SetText("Creature (this page is wip af)");
        label:SetPoint("TOPLEFT", page, 0, 0);
        label:SetPoint("TOPRIGHT", page, -25, 0);
        label:SetTextScale(1);
        label:SetTextColor(1, 1, 1, 1);

        local creatureIDEntryBox = CreateFrame("EditBox", nil, page, "DatamineEditBoxTemplate");
        creatureIDEntryBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -20);
        creatureIDEntryBox:SetPoint("TOPRIGHT", label, "BOTTOMRIGHT", 0, -20);
        creatureIDEntryBox:SetHeight(editBoxHeight);
        creatureIDEntryBox.LabelText = "Set CreatureID";
        creatureIDEntryBox.Instructions:SetText("CreatureID...");

        page.CreatureIDEntryBox = creatureIDEntryBox;
    end

    do -- set displayID for said creatureID
        local displayIDEntryBox = CreateFrame("EditBox", nil, page, "DatamineEditBoxTemplate");
        displayIDEntryBox:SetPoint("TOPLEFT", page.CreatureIDEntryBox, "BOTTOMLEFT", 0, -20);
        displayIDEntryBox:SetPoint("TOPRIGHT", page.CreatureIDEntryBox, "BOTTOMRIGHT", 0, -20);
        displayIDEntryBox:SetHeight(editBoxHeight);
        displayIDEntryBox.LabelText = "Set DisplayID";
        displayIDEntryBox.Instructions:SetText("DisplayID...");

        page.DisplayIDEntryBox = displayIDEntryBox;
    end

    do -- set creature
        local a = CreateFrame("Button", nil, page, "UIPanelButtonTemplate");
        a:SetPoint("TOPLEFT", page.DisplayIDEntryBox, "BOTTOMLEFT", -5, -5);
        a:SetPoint("TOPRIGHT", page.DisplayIDEntryBox, "BOTTOMRIGHT", 0, -5);
        a:SetText("Apply CreatureID and DisplayID");
        a:RegisterForClicks("AnyUp");
        a:SetScript("OnClick", function()
            local creatureID = page.CreatureIDEntryBox:GetText();
            local displayID = page.DisplayIDEntryBox:GetText();
            DatamineDressUpFrame:SetCreature(creatureID, displayID)
        end);

        page.SetCreatureButton = a;
    end

    do -- set model to item by ID
        local label = page:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        label:SetJustifyH("CENTER");
        label:SetText("Items");
        label:SetPoint("TOPLEFT", page.SetCreatureButton, "BOTTOMLEFT", 0, -10);
        label:SetPoint("TOPRIGHT", page.SetCreatureButton, "BOTTOMRIGHT", 0, -10);
        label:SetTextScale(1);
        label:SetTextColor(1, 1, 1, 1);

        local itemIDEntryBox = CreateFrame("EditBox", nil, page, "DatamineEditBoxTemplate");
        itemIDEntryBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -20);
        itemIDEntryBox:SetPoint("TOPRIGHT", label, "BOTTOMRIGHT", 0, -20);
        itemIDEntryBox:SetHeight(editBoxHeight);
        itemIDEntryBox.LabelText = "Set model by ItemID";
        itemIDEntryBox.Instructions:SetText("ItemID...");
        itemIDEntryBox.Callback = function()
            return DatamineDressUpFrame:GetActor():SetItem(itemIDEntryBox:GetText());
        end;

        page.ItemIDEntryBox = itemIDEntryBox;
    end

    do -- play an AnimationKit by ID
        local animKitIDEntryBox = CreateFrame("EditBox", nil, page, "DatamineEditBoxTemplate");
        animKitIDEntryBox:SetPoint("TOPLEFT", page.ItemIDEntryBox, "BOTTOMLEFT", 0, -20);
        animKitIDEntryBox:SetPoint("TOPRIGHT", page.ItemIDEntryBox, "BOTTOMRIGHT", 0, -20);
        animKitIDEntryBox:SetHeight(editBoxHeight);
        animKitIDEntryBox.LabelText = "Play a looping AnimationKitID";
        animKitIDEntryBox.Instructions:SetText("AnimationKitID...");
        animKitIDEntryBox.Callback = function(...) return DatamineDressUpFrame:PlayAnimationKit(...); end;

        page.AnimKitIDEntryBox = animKitIDEntryBox;
    end

    page:SetScript("OnShow", function()
        page.CreatureIDEntryBox:SetText("");
        page.DisplayIDEntryBox:SetText("");
        page.ItemIDEntryBox:SetText("");
        page.AnimKitIDEntryBox:SetText("");
    end)

    self.Pages.PlayerModelPage = page;
end

function DatamineModelFrameControlPanelMixin:Refresh()
end