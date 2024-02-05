---@class Page : Frame
DatamineModelFrameControlPanelPageMixin = {};

function DatamineModelFrameControlPanelPageMixin:Init()
    self.DEFAULT_Y_OFFSET = -10;
    self.DEFAULT_BUTTON_WIDTH = 128;
    self.DEFAULT_EDIT_BOX_HEIGHT = 20;

    self:SetPoint("TOPLEFT", self:GetParent(), 15, -40);
    self:SetPoint("BOTTOMRIGHT", -15, 25);

    self.FrameContainer = {};

    self:SetScript("OnShow", self.OnShow);

    return self;
end

function DatamineModelFrameControlPanelPageMixin:OnShow()
    for _, frame in ipairs(self.FrameContainer) do
        if frame.SetText and frame:IsObjectType("EditBox") then
            frame:SetText("");
        end
    end
end

function DatamineModelFrameControlPanelPageMixin:GetAnchorPoint()
    local anchorPoint;
    local numFrames = #self.FrameContainer;

    if numFrames > 0 then
        anchorPoint = self.FrameContainer[numFrames]
    else
        anchorPoint = self;
    end

    return anchorPoint;
end

---@param labelText string
---@param textScaleOverride? number
function DatamineModelFrameControlPanelPageMixin:AddLabel(labelText, textScaleOverride)
    local anchorPoint = self:GetAnchorPoint();

    local label = self:CreateFontString(nil, "ARTWORK", "GameFontNormal");
    label:SetJustifyH("CENTER");
    label:SetText(labelText);

    if anchorPoint == self then
        label:SetPoint("TOPLEFT", anchorPoint, 0, self.DEFAULT_Y_OFFSET);
        label:SetPoint("TOPRIGHT", anchorPoint, 0, self.DEFAULT_Y_OFFSET);
    else
        label:SetPoint("TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, self.DEFAULT_Y_OFFSET);
        label:SetPoint("TOPRIGHT", anchorPoint, "BOTTOMRIGHT", 0, self.DEFAULT_Y_OFFSET);
    end

    label:SetTextScale(textScaleOverride or 1);
    label:SetTextColor(1, 1, 1, 1);

    tinsert(self.FrameContainer, label);
end

---@param buttonText string
---@param buttonFunc function
---@param frameName? string
function DatamineModelFrameControlPanelPageMixin:AddWideButton(buttonText, buttonFunc, frameName)
    local anchorPoint = self:GetAnchorPoint();

    local button = CreateFrame("Button", frameName, self, "UIPanelButtonTemplate");
    button:SetPoint("TOPLEFT", anchorPoint, "BOTTOMLEFT", -5, -5);
    button:SetPoint("TOPRIGHT", anchorPoint, "BOTTOMRIGHT", 0, -5);
    button:SetText(buttonText);
    button:RegisterForClicks("AnyUp");
    button:SetScript("OnClick", buttonFunc);

    tinsert(self.FrameContainer, button);
end

---@param buttonData table<string, function>
---@param frameName? string
function DatamineModelFrameControlPanelPageMixin:AddButtonPair(buttonData, frameName)
    local anchorPoint = self:GetAnchorPoint();

    local buttonContainer = CreateFrame("Frame", frameName, self);
    buttonContainer:SetPoint("TOPLEFT", anchorPoint, "BOTTOMLEFT");
    buttonContainer:SetPoint("TOPRIGHT", anchorPoint, "BOTTOMRIGHT");
    buttonContainer:SetHeight(25);

    local i = 1;
    for buttonText, buttonFunc in pairs(buttonData) do
        if i > 2 then
            break;
        end

        local button = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate");
        button:SetWidth(self.DEFAULT_BUTTON_WIDTH / 1.35);
        button:SetText(buttonText);
        button:RegisterForClicks("AnyUp");
        button:SetScript("OnClick", buttonFunc);

        if i == 1 then
            button:SetPoint("LEFT", 10, 0);
        else
            button:SetPoint("RIGHT", -10, 0);
        end

        i = i + 1;
    end

    tinsert(self.FrameContainer, buttonContainer);
end

---@param labelText string
---@param instructions string
---@param callback function
function DatamineModelFrameControlPanelPageMixin:AddEntryBox(labelText, instructions, callback, frameName, isNumeric)
    local anchorPoint = self:GetAnchorPoint()

    local entryBox = CreateFrame("EditBox", nil, self, "DatamineEditBoxTemplate");
    entryBox:SetPoint("TOPLEFT", anchorPoint, "BOTTOMLEFT", 0, -20);
    entryBox:SetPoint("TOPRIGHT", anchorPoint, "BOTTOMRIGHT", 0, -20);
    entryBox:SetHeight(self.DEFAULT_EDIT_BOX_HEIGHT);
    entryBox:SetNumeric(isNumeric);
    entryBox.LabelText = labelText;
    entryBox.Instructions:SetText(instructions);
    entryBox.Callback = callback;

    if frameName then
        self[frameName] = entryBox;
    end

    tinsert(self.FrameContainer, entryBox);
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
    self.Header:SetTextColor(1, 1, 1, 1);

    self:SetupModelScenePage();
    self:SetupPlayerModelPage();
end

function DatamineModelFrameControlPanelMixin:Refresh()
end

---@return Page
function DatamineModelFrameControlPanelMixin:AddPage(pageName)
    local page = CreateFrame("Frame", pageName, self);
    Mixin(page, DatamineModelFrameControlPanelPageMixin);

    return page:Init();
end

function DatamineModelFrameControlPanelMixin:SetupModelScenePage()
    local page = self:AddPage("DatamineModelScenePage");
    local modelScene = self:GetParent().ModelScene;

    page:AddLabel("Weapon Sheathe");
    page:AddButtonPair({
        ["Unsheathe"] = function() modelScene:GetPlayerActor():SetSheathed(false) end,
        ["Sheathe"] = function() modelScene:GetPlayerActor():SetSheathed(true) end,
    }, "SheatheButtonContainer");

    page:AddLabel("Dress State");
    page:AddButtonPair({
        ["Dress"] = function() DatamineModelViewFrame:SetDressState(true) end,
        ["Undress"] = function() DatamineModelViewFrame:SetDressState(false) end
    }, "DressButtonContainer");

    page:AddLabel("Model");

    local fdidEntryBoxCallback = function(...) return DatamineModelViewFrame:SetModelByFileID(...); end;
    page:AddEntryBox("Set model by FileDataID", "FileDataID...", fdidEntryBoxCallback, nil, true);

    local displayIDEntryBoxCallback = function(...) return DatamineModelViewFrame:SetModelByCreatureDisplayID(...); end;
    page:AddEntryBox("Set model by DisplayID", "DisplayID...", displayIDEntryBoxCallback, nil, true);

    local spellVisualKitEntryBoxCallback = function(...) return DatamineModelViewFrame:ApplySpellVisualKit(...); end;
    page:AddEntryBox("Apply a looping SpellVisualKitID", "SpellVisualKitID...", spellVisualKitEntryBoxCallback, nil, true);

    local animationKitEntryBoxCallback = function(...) return DatamineModelViewFrame:PlayAnimationKit(...); end;
    page:AddEntryBox("Play a looping AnimKitID", "AnimKitID...", animationKitEntryBoxCallback, nil, true);

    local itemEntryBoxCallback = function(...) return Datamine.ModelView:TryOnByItemID(...) end;
    page:AddEntryBox("Try on ItemID", "ItemID...", itemEntryBoxCallback, nil, true);

    local itemModifiedAppearanceEntryBoxCallback = function(...) return Datamine.ModelView:TryOnByItemModifiedAppearanceID({...}) end;
    page:AddEntryBox("Try on ItemModifiedAppearanceID", "ItemModifiedAppearanceID...", itemModifiedAppearanceEntryBoxCallback, nil, true);

    self.Pages.ModelScenePage = page;
end

function DatamineModelFrameControlPanelMixin:SetupPlayerModelPage()
    local page = self:AddPage("DataminePlayerModelPage");
    page:AddLabel("Player Model (wip af, might break)");

    local creatureAndDisplayIDEntryBoxCallback = function()
        local creatureID = page.CreatureIDEntryBox:GetNumber();
        local displayID = page.DisplayIDEntryBox:GetNumber();

        if not displayID or strtrim(displayID) == "" then
            displayID = 0;
        end

        if strtrim(creatureID) ~= "" then
            return DatamineModelViewFrame:SetCreature(creatureID, displayID);
        end

        return DatamineModelViewFrame:GetActor():SetDisplayInfo(displayID);
    end;
    page:AddEntryBox("Set CreatureID", "CreatureID...", creatureAndDisplayIDEntryBoxCallback, "CreatureIDEntryBox", true);
    page:AddEntryBox("Set DisplayID", "DisplayID...", creatureAndDisplayIDEntryBoxCallback, "DisplayIDEntryBox", true);

    local itemIDEntryBoxCallback = function(...)
        return DatamineModelViewFrame:GetActor():SetItem(...);
    end;
    page:AddEntryBox("Set model by ItemID", "ItemID...", itemIDEntryBoxCallback, nil, true);

    local animationKitEntryBoxCallback = function(...) return DatamineModelViewFrame:PlayAnimationKit(...); end;
    page:AddEntryBox("Play a looping AnimKitID", "AnimKitID...", animationKitEntryBoxCallback, nil, true);

    self.Pages.PlayerModelPage = page;
end