DatamineModelSceneActorMixin = CreateFromMixins(ModelSceneActorMixin);

function DatamineModelSceneActorMixin:ResetModel()
    self:MarkScaleDirty();
end

-------------

local DATAMINE_CAMERA_NAME = "DatamineOrbitCamera"
DatamineCameraMixin = CreateFromMixins(OrbitCameraMixin);
CameraRegistry:AddCameraFactoryFromMixin(DATAMINE_CAMERA_NAME, DatamineCameraMixin);

function DatamineCameraMixin:OnAdded()
	self.buttonModes = {};
    self.panningXOffset = 0;
    self.panningYOffset = 0;

	self:SetTarget(0, 0, 0);

	local targetSpline = CreateCatmullRomSpline(3);
	targetSpline:AddPoint(0, 0, 0);
	targetSpline:AddPoint(0, 0, .5);

	self:SetTargetSpline(targetSpline);

	self:SetMinZoomDistance(6);
	self:SetMaxZoomDistance(10);

	self:SetZoomDistance(8);

	self:SetYaw(math.pi);
	self:SetPitch(0);
	self:SetRoll(0);

	self:SetZoomInterpolationAmount(.15);
	self:SetYawInterpolationAmount(.15);
	self:SetPitchInterpolationAmount(.15);
	self:SetRollInterpolationAmount(.15);
	self:SetTargetInterpolationAmount(.15);

	self:ResetDefaultInputModes();

    EventRegistry:RegisterFrameEventAndCallback("MODIFIER_STATE_CHANGED", function(_, key, value)
        if key == "LSHIFT" then
            if value == 1 then
                self:SetLeftMouseButtonYMode(ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION);
            elseif value == 0 then
                self:SetLeftMouseButtonYMode(ORBIT_CAMERA_MOUSE_MODE_NOTHING);
            end
        end
    end);
end

function DatamineCameraMixin:GetCameraType()
    return DATAMINE_CAMERA_NAME;
end

function DatamineCameraMixin:GetDeltaModifierForCameraMode(mode)
    if mode == ORBIT_CAMERA_MOUSE_MODE_YAW_ROTATION then
        return .008;
    elseif mode == ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION then
        return -.008;
    elseif mode == ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION then
        return .008;
    elseif mode == ORBIT_CAMERA_MOUSE_MODE_ZOOM then
        return IsShiftKeyDown() and .015 or 0.1;
    elseif mode == ORBIT_CAMERA_MOUSE_MODE_TARGET_HORIZONTAL then
        return .05;
    elseif mode == ORBIT_CAMERA_MOUSE_MODE_TARGET_VERTICAL then
        return .05;
    elseif mode == ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL then
        return 0.93;
    elseif mode == ORBIT_CAMERA_MOUSE_PAN_VERTICAL then
        return 0.93;
    end
    return 0.0;
end

function DatamineCameraMixin:HandleMouseMovement(mode, delta, snapToValue)
	if mode == ORBIT_CAMERA_MOUSE_MODE_YAW_ROTATION then
		self:SetYaw(self:GetYaw() - delta);
		if snapToValue then
			self:SnapToTargetInterpolationYaw();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION then
		self:SetPitch(self:GetPitch() - delta);
		if snapToValue then
			self:SnapToTargetInterpolationPitch();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION then
		self:SetRoll(self:GetRoll() - delta);
		if snapToValue then
			self:SnapToTargetInterpolationRoll();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_ZOOM then
		self:ZoomByPercent(delta);
		if snapToValue then
			self:SnapToTargetInterpolationZoom();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_TARGET_HORIZONTAL then
		local rightX, rightY, rightZ = Vector3D_ScaleBy(delta, self:GetRightVector());
		self:SetTarget(Vector3D_Add(rightX, rightY, rightZ, self:GetTarget()));

		if snapToValue then
			self:SnapToTargetInterpolationTarget();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_MODE_TARGET_VERTICAL then
		local upX, upY, upZ = Vector3D_ScaleBy(delta, self:GetUpVector());
		self:SetTarget(Vector3D_Add(upX, upY, upZ, self:GetTarget()));

		if snapToValue then
			self:SnapToTargetInterpolationTarget();
		end
	elseif mode == ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL then
		self.panningXOffset = self.panningXOffset + delta;
	elseif mode == ORBIT_CAMERA_MOUSE_PAN_VERTICAL then
		self.panningYOffset = self.panningYOffset + delta;
	end
end

-------------

DatamineModelSceneMixin = {};

function DatamineModelSceneMixin:OnLoadCustom()
    self.ControlFrame:SetModelScene(self);
    self.FirstShow = true;

    self:ClearScene();
    self:SetViewInsets(0, 0, 0, 0);
    self:ReleaseAllActors();
    EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function() self:SetFromModelSceneID(596) end);

    self.NativeFormToggleButton:SetScript("OnClick", function()
        local useNativeForm = self:GetUseNativeForm();
        self:SetUseNativeForm(not useNativeForm);
    end);

    self.actorTemplate = "DatamineModelSceneActorTemplate";
end

function DatamineModelSceneMixin:OnShow()
    local useNativeForm = true;
    local _, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
    local _, raceFileName = UnitRace("player");
    if raceFileName == "Dracthyr" or raceFileName == "Worgen" then
        useNativeForm = not inAlternateForm;
    end
    self:SetUseNativeForm(useNativeForm);

    if self.FirstShow then
        self:OnFirstShow();
    end
end

function DatamineModelSceneMixin:OnFirstShow()
    self:SetupPlayerActor();
    self:SetupCamera();
    DatamineUnifiedFrame.Workspace.DetailsTab.Controls:SetEditBoxDefaults();
    self.FirstShow = false;

    self:UpdateOutfitPanel(self.ActiveActor:GetItemTransmogInfoList());

    if DevTool then
        DevTool:AddData(self, "DatamineNewModelScene");
    end
end

function DatamineModelSceneMixin:OnCameraMoveStart()
    self:GetExternalControls():SetDoUpdate(true);
end

function DatamineModelSceneMixin:OnCameraMoveStop()
    self:GetExternalControls():SetDoUpdate(false);
end

function DatamineModelSceneMixin:Reset()
    self:SetupPlayerActor(true);
end

function DatamineModelSceneMixin:GetExternalControls()
    return DatamineUnifiedFrame.Workspace.DetailsTab.Controls;
end

function DatamineModelSceneMixin:CreateCamera()
    local modelSceneCameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(1);
	if modelSceneCameraInfo then
		local camera = CameraRegistry:CreateCameraByType(DATAMINE_CAMERA_NAME);
		if camera then
			if modelSceneCameraInfo.scriptTag then
				self.tagToCamera[modelSceneCameraInfo.scriptTag] = camera;
			end
			self:AddCamera(camera);
			camera:ApplyFromModelSceneCameraInfo(modelSceneCameraInfo, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD);
			return camera;
		end
	end
end

function DatamineModelSceneMixin:SetupCamera()
    self:ReleaseAllCameras();
    local camera = self:CreateCamera();

    if not camera then return end;

    camera:SetMinZoomDistance(1);
    camera:SetMaxZoomDistance(25);
    camera:SetZoomDistance(6.8);
end

--- native form refers to the 'default' form for a race, i.e. worgen form or dracthyr form
function DatamineModelSceneMixin:SetUseNativeForm(useNativeForm, noRefresh)
    self.UseNativeForm = useNativeForm;
    if not noRefresh then
        self:SetupPlayerActor(true);
    end
end

function DatamineModelSceneMixin:GetUseNativeForm()
    return self.UseNativeForm;
end

function DatamineModelSceneMixin:GetActiveActor()
    return self.ActiveActor;
end

function DatamineModelSceneMixin:UpdateOutfitPanel(itemTransmogInfoList)
    local controls = self:GetExternalControls();
    controls:LoadOutfit(itemTransmogInfoList);
end

function DatamineModelSceneMixin:SetupPlayerActor(force)
    if not force and (self.ActiveActor or not self.FirstShow) then
        return;
    end

    local actor = self:GetPlayerActor();
    if not actor then
        return;
    end

    local sheatheWeapons = true;
    local autoDress = true;
    local hideWeapons = false;
    local useNativeForm = self:GetUseNativeForm();
    local holdBowString = true;

    actor:SetModelByUnit("player", sheatheWeapons, autoDress, hideWeapons, useNativeForm, holdBowString);
    actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
    actor:ResetModel();

    self.ActiveActor = actor;
end

-------------

DatamineModelControlsEditBoxMixin = {};

function DatamineModelControlsEditBoxMixin:OnEnterPressed()
    if self.Callback then
        self.Callback(self:GetText());
    end
    self.RevertTextOnFocusLoss = false;
    self:GetParent():CheckDefaults(self);
end

function DatamineModelControlsEditBoxMixin:OnEditFocusGained()
    self.RevertTextOnFocusLoss = true;
    self.BeginningText = self:GetText();
end

function DatamineModelControlsEditBoxMixin:OnEditFocusLost()
    if self.RevertTextOnFocusLoss then
        self:SetText(self.BeginningText);
    end
end

function DatamineModelControlsEditBoxMixin:OnChar(char)
    local text = self:GetText();
    local filtered = self:Filter(text);
    if not filtered and char == "-" then
        filtered = char;
    end

    self:SetText(filtered or "");
end

function DatamineModelControlsEditBoxMixin:IsNilOrEmpty(text)
    return not text or strtrim(text) == "";
end

function DatamineModelControlsEditBoxMixin:Round(text)
    return format("%.2f", text);
end

function DatamineModelControlsEditBoxMixin:Filter(text)
    local filter1 = "[-]?%d+[%.]?%d*";
    local filter2 = "[-]?%d*[%.]?%d+";

    local match;
    local match1 = text:match(filter1);
    local match2 = text:match(filter2);

    if match1 and match2 then
        if text:find(match1) <= text:find(match2) then
            match = match1;
        else
            match = match2;
        end
    elseif match1 then
        match = match1;
    else
        match = match2;
    end

    return match;
end

function DatamineModelControlsEditBoxMixin:SetTextFiltered(text)
    if self:IsNilOrEmpty(text) then
        return;
    end

    local filtered = self:Filter(text);
    filtered = self:Round(filtered);
    self:SetText(filtered);
end

function DatamineModelControlsEditBoxMixin:SetTextUnfiltered(text)
    if self:IsNilOrEmpty(text) then
        return;
    end

    text = self:Round(text);
    if type(text) == "number" then
        self:SetNumber(text);
    else
        self:SetText(text);
    end
end

function DatamineModelControlsEditBoxMixin:SetCallback(callback)
    self.Callback = callback;
end

function DatamineModelControlsEditBoxMixin:SetDefaultValue(defaultValue)
    self.DefaultValue = self:Round(defaultValue);

    local text = self:GetText();
    if self:IsNilOrEmpty(text) then
        self:Reset(true);
    end
end

function DatamineModelControlsEditBoxMixin:GetDefaultValue()
    return self.DefaultValue;
end

function DatamineModelControlsEditBoxMixin:Reset(noCallback)
    local default = self:GetDefaultValue();

    if self:IsNilOrEmpty(default) then
        return;
    end

    self:SetText(default);

    if self.Callback and not noCallback then
        self.Callback(self:GetText());
    end
end

-------------

DatamineModelControlsLabelledEditBoxRowMixin = {};

function DatamineModelControlsLabelledEditBoxRowMixin:Init(node)
    local data = node:GetData();
    self.Title:SetText(data.Text);
    self.ControlID = data.ControlID;
    self.DataFetch = data.DataFetch;
    self.GetDefaults = data.DefaultsFunc;

    self.Callback = function()
        local x, y, z = self:GetXYZ();
        data.Callback(x, y, z);
    end;

    self.Overlord = data.OverlordFrame

    self:Register();
    self:SetDefaults();
    self:SetTargets();

    self.Initialized = true;

    self:Update();
end

function DatamineModelControlsLabelledEditBoxRowMixin:OnLoad()
    self.IsDefaults = {
        [self.X] = true,
        [self.Y] = true,
        [self.Z] = true
    };

    local callback = function(editBox) self:CheckDefaults(editBox) end;

    self.X:HookScript("OnTextChanged", callback);
    self.Y:HookScript("OnTextChanged", callback);
    self.Z:HookScript("OnTextChanged", callback);

    self.Title:SetTextScale(0.85);
end

function DatamineModelControlsLabelledEditBoxRowMixin:OnShow()
    self.X:Enable();
    self.Y:Enable();
    self.Z:Enable();
end

function DatamineModelControlsLabelledEditBoxRowMixin:OnHide()
    self.X:Disable();
    self.Y:Disable();
    self.Z:Disable();
end

function DatamineModelControlsLabelledEditBoxRowMixin:GetXYZ()
    local x, y, z = self.X:GetText(), self.Y:GetText(), self.Z:GetText();
    return x, y, z;
end

function DatamineModelControlsLabelledEditBoxRowMixin:Register()
    self.Overlord[self.ControlID] = self;
end

function DatamineModelControlsLabelledEditBoxRowMixin:Update(force)
    if not self:IsShown() and not force then
        return;
    end

    if not self.Initialized then
        return;
    end

    local x, y, z = self.DataFetch();
    self.X:SetTextUnfiltered(x or 0);
    self.Y:SetTextUnfiltered(y or 0);
    self.Z:SetTextUnfiltered(z or 0);

    -- need to toggle the X editbox because there's some fucked up shit going on
    self.X:Hide();
    self.X:Show();
end

function DatamineModelControlsLabelledEditBoxRowMixin:SetDefaults()
    local x, y, z = self.GetDefaults();
    self.X:SetDefaultValue(x);
    self.Y:SetDefaultValue(y);
    self.Z:SetDefaultValue(z);
end

function DatamineModelControlsLabelledEditBoxRowMixin:SetTargets()
    local target = self.Callback;
    self.X:SetCallback(target);
    self.Y:SetCallback(target);
    self.Z:SetCallback(target);
end

function DatamineModelControlsLabelledEditBoxRowMixin:CheckDefaults(editBox)
    if editBox.RevertTextOnFocusLoss then
        return;
    end

    self.IsDefaults[editBox] = editBox:GetText() == editBox:GetDefaultValue();

    for _, isDefault in pairs(self.IsDefaults) do
        if not isDefault then
            self:SetResetButtonShown(true);
            return;
        end
    end

    self:SetResetButtonShown(false);
end

function DatamineModelControlsLabelledEditBoxRowMixin:SetResetButtonShown(shown)
    self.ResetButton:SetShown(shown)
end

function DatamineModelControlsLabelledEditBoxRowMixin:ResetEditBoxes()
    self.X:Reset();
    self.Y:Reset();
    self.Z:Reset();
end

-------------

DatamineModelControlsTreeMixin = {};

function DatamineModelControlsTreeMixin:GetScene()
    return DatamineUnifiedFrame.Workspace.ModelViewTab.ModelScene;
end

function DatamineModelControlsTreeMixin:GetCameraXYZ()
    local camera = self.ModelScene:GetActiveCamera();
    local x, y, z = camera:GetYaw(), camera:GetPitch(), camera:GetRoll();
    return x, y, z;
end

function DatamineModelControlsTreeMixin:GetActorPosition()
    local actor = self.ModelScene:GetActiveActor();
    if not actor then
        return;
    end

    return actor:GetPosition();
end

function DatamineModelControlsTreeMixin:GetActorRotation()
    local actor = self.ModelScene:GetActiveActor();
    if not actor then
        return;
    end

    return actor:GetYaw(), actor:GetPitch(), actor:GetRoll();
end

function DatamineModelControlsTreeMixin:GetCameraOrientation()
    local camera = self.ModelScene:GetActiveCamera();
    return camera:GetYaw(), camera:GetPitch(), camera:GetRoll();
end

function DatamineModelControlsTreeMixin:OnLoad()
    self.TransformTab = self:AddTopLevelItem({
        Text = "Transform",
        IsTopLevel = true,
    });

    self.OutfitTab = self:AddTopLevelItem({
        Text = "Outfit",
        IsTopLevel = true,
    });

    self.AdvancedTab = self:AddTopLevelItem({
        Text = "Advanced",
        IsTopLevel = true,
    });

    self:SetupLocationControls();
    self:SetupCameraControls();
    self:SetupAdvancedPanel();

    self:SetDoUpdate(false);

    self.DataProvider:CollapseAll();
end

function DatamineModelControlsTreeMixin:OnShow()
    self.ModelScene = self:GetScene();
end

function DatamineModelControlsTreeMixin:OnUpdate()
    if not self:IsShown() or not self.DoUpdate then
        return;
    end

    self:UpdateLocationControls();
    self:UpdateCameraControls();
end

function DatamineModelControlsTreeMixin:SetupLocationControls()
    local function LocationCallback(x, y, z)
        local actor = self.ModelScene:GetActiveActor();
        actor:SetPosition(x, y, z);
    end

    local function GetLocationDefaults()
        if not self.EditBoxDefaults then
            self:SetEditBoxDefaults();
        end

        local defaults = self.EditBoxDefaults.LocationControls;
        return defaults.x, defaults.y, defaults.z;
    end

    self.TransformTab:Insert({
        Text = "Location",
        ControlID = "LocationControls",
        DataFetch = function() return self:GetActorPosition(); end,
        Callback = LocationCallback,
        DefaultsFunc = GetLocationDefaults,
        OverlordFrame = self,
        Template = "DatamineModelControlsLabelledEditBoxRowTemplate",
    });
end

function DatamineModelControlsTreeMixin:SetupCameraControls()
    local function CameraCallback(x, y, z)
        local camera = self.ModelScene:GetActiveCamera();
        camera:SetYaw(x);
        camera:SetPitch(y);
        camera:SetRoll(z);
        camera:UpdateCameraOrientationAndPosition();
    end

    local function GetCameraDefaults()
        if not self.EditBoxDefaults then
            self:SetEditBoxDefaults();
        end

        local defaults = self.EditBoxDefaults.CameraControls;
        return defaults.x, defaults.y, defaults.z;
    end

    self.TransformTab:Insert({
        Text = "Camera",
        ControlID = "CameraControls",
        DataFetch = function() return self:GetCameraOrientation(); end,
        Callback = CameraCallback,
        DefaultsFunc = GetCameraDefaults,
        OverlordFrame = self,
        Template = "DatamineModelControlsLabelledEditBoxRowTemplate",
    });
end

function DatamineModelControlsTreeMixin:SetupOutfitPanel()
    local armorSlots = {
        HEAD = HEADSLOT,
        NECK = NECKSLOT,
        SHOULDER = SHOULDERSLOT,
        BACK = BACKSLOT,
        SHIRT = SHIRTSLOT,
        CHEST = CHESTSLOT,
        WAIST = WAISTSLOT,
        LEGS = LEGSSLOT,
        FEET = FEETSLOT,
        WRIST = WRISTSLOT,
        HANDS = HANDSSLOT,
        RING0 = FINGER1SLOT,
        RING1 = FINGER1SLOT,
        TRINKET0 = TRINKET0SLOT,
        TRINKET1 = TRINKET1SLOT,
        MAINHAND = MAINHANDSLOT,
        SECONDARYHAND = SECONDARYHANDSLOT,
        RANGED = RANGEDSLOT
    };
end

function DatamineModelControlsTreeMixin:LoadOutfit(itemTransmogInfoList)
    DevTool:AddData(itemTransmogInfoList, "Transmog");
    for _, transmogInfo in ipairs(itemTransmogInfoList) do
        local data = {
            OverlordFrame = self,
            Template = "DatamineModelControlsOutfitPanelEntryTemplate",
            RequestedExtent = 32,
            AppearanceID = transmogInfo.appearanceID,
            SecondaryAppearanceID = transmogInfo.secondaryAppearanceID,
            IllusionID = transmogInfo.illusionID,
        };

        if data.AppearanceID and data.AppearanceID ~= 0 then
            self.OutfitTab:Insert(data);
        end
    end
end

function DatamineModelControlsTreeMixin:SetupAdvancedPanel()
    local fdidCallback = function(fdid)
        local actor = self.ModelScene:GetPlayerActor();
        return actor:SetModelByFileID(tonumber(fdid), true);
    end;

    self.AdvancedTab:Insert({
        Text = "Set model by FileDataID",
        Instructions = "Enter a FileDataID...",
        Callback = fdidCallback,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    local creatureDisplayCallback = function(id)
        local actor = self.ModelScene:GetPlayerActor();
        return actor:SetModelByCreatureDisplayID(tonumber(id));
    end;

    self.AdvancedTab:Insert({
        Text = "Set model by DisplayInfoID",
        Instructions = "Enter a DisplayInfoID...",
        Callback = creatureDisplayCallback,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    local itemEntryCallback = function(id)
        local actor = self.ModelScene:GetPlayerActor();
        local _, itemModifiedAppearanceID = C_TransmogCollection.GetItemInfo(id);
        return actor:TryOn(itemModifiedAppearanceID);
    end;

    self.AdvancedTab:Insert({
        Text = "Try on ItemID",
        Instructions = "Enter an ItemID...",
        Callback = itemEntryCallback,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    local itemModAppearanceCallback = function(id)
        local actor = self.ModelScene:GetPlayerActor();
        return actor:TryOn(id);
    end;

    self.AdvancedTab:Insert({
        Text = "Try on ItemModifiedAppearanceID",
        Instructions = "Enter an ItemModifiedAppearanceID...",
        Callback = itemModAppearanceCallback,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });
end

function DatamineModelControlsTreeMixin:SetDoUpdate(doUpdate)
    self.DoUpdate = doUpdate;
end

function DatamineModelControlsTreeMixin:OnEnterPressed()
end

function DatamineModelControlsTreeMixin:SetEditBoxDefaults()
    local actor = self.ModelScene:GetActiveActor();
    local camera = self.ModelScene:GetActiveCamera();

    local xT, yT, zT = actor:GetPosition();
    local xC, yC, zC = camera:GetYaw(), camera:GetPitch(), camera:GetRoll();

    self.EditBoxDefaults = {
        LocationControls = {
            x = xT,
            y = yT,
            z = zT,
        },
        CameraControls = {
            x = xC,
            y = yC,
            z = zC,
        }
    };
end

function DatamineModelControlsTreeMixin:GetEditBoxDefaults(controlID)
    return self.EditBoxDefaults and self.EditBoxDefaults[controlID] or nil;
end

function DatamineModelControlsTreeMixin:UpdateLocationControls()
    if not self.LocationControls then
        return;
    end

    self.LocationControls:Update();
end

function DatamineModelControlsTreeMixin:UpdateCameraControls()
    if not self.CameraControls then
        return;
    end

    self.CameraControls:Update();
end

-------------

local f = false;
DatamineModelControlsOutfitPanelEntryMixin = {};

function DatamineModelControlsOutfitPanelEntryMixin:Init(node)
    if not f then
        RunNextFrame(function() DevTool:AddData(self, "OutfitEntry") end);
        f = true;
    end
    local data = node:GetData();
    node:Flush();
    self.Overlord = data.OverlordFrame;

    local categoryID, visualID, canEnchant, icon, isCollected, itemLink, transmogLink, unk1, itemSubTypeIndex = C_TransmogCollection.GetAppearanceSourceInfo(data.AppearanceID)
    local transmogInfo = {
        CategoryID = categoryID,
        VisualID = visualID,
        CanEnchant = tostring(canEnchant),
        Icon = icon,
        IsCollected = tostring(isCollected),
        ItemSubType = Datamine.GetEnumValueName(Enum.ItemArmorSubclass, (itemSubTypeIndex)) .. " (" .. itemSubTypeIndex .. ")",
    };

    for k, v in pairs(transmogInfo) do
        if k and v then
            node:Insert({
                KeyValue = {
                    Key = k,
                    Value = v,
                },
                Template = "DatamineTabTreeViewChildKeyValueTemplate",
                RequestedExtent = 15,
            });
        end
    end

    self.Text:SetTextScale(0.80);
    self.Text:SetText(itemLink);

    self.Icon:SetItem(itemLink);
    self.Icon:SetScript("OnClick", function() self:GetElementData():ToggleCollapsed() end);

    self:SetScript("OnHyperlinkClick", self.OnHyperlinkClick);
    self:SetScript("OnHyperlinkEnter", self.OnHyperlinkEnter);
    self:SetScript("OnHyperlinkLeave", self.OnHyperlinkLeave);

    node:SetCollapsed(true);
end

function DatamineModelControlsOutfitPanelEntryMixin:OnHyperlinkClick(link, text, button)
    if button == "RightButton" then
        self:GetElementData():ToggleCollapsed();
    else
        SetItemRef(link, text, button);
    end
end

function DatamineModelControlsOutfitPanelEntryMixin:OnHyperlinkEnter(link, _)
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
    GameTooltip:SetHyperlink(link);
    GameTooltip:Show();
end

function DatamineModelControlsOutfitPanelEntryMixin:OnHyperlinkLeave()
    GameTooltip:Hide();
end

function DatamineModelControlsOutfitPanelEntryMixin:OnMouseUp()
    self:GetElementData():ToggleCollapsed();
end

-------------

DatamineModelControlsAdvancedPanelEntryMixin = {};

function DatamineModelControlsAdvancedPanelEntryMixin:Init(node)
    local data = node:GetData();

    self.Title:SetText(data.Text);
    self.Title:SetTextScale(0.85);

    self.EntryBox:SetHeight(self:GetHeight() / 2);
    self.EntryBox.Callback = data.Callback;
    self.EntryBox.Instructions:SetText(data.Instructions);
end
