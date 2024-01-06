local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;
local Transmog = Datamine.Transmog;

local UI_MAIN = Datamine.Unified;

-------------

DatamineModelSceneActorMixin = CreateFromMixins(ModelSceneActorMixin);

function DatamineModelSceneActorMixin:ResetModel()
    self:SetPosition(0, 0, 0);
    self:MarkScaleDirty();
end

function DatamineModelSceneActorMixin:OnModelLoaded()
    self:ResetModel();
    Registry:TriggerEvent(Events.MODEL_LOADED_INTERNAL, self);
end

function DatamineModelSceneActorMixin:GetScaledActiveBoundingBox()
    local scale = self:GetScale();
    local x1, y1, z1, x2, y2, z2 = self:GetActiveBoundingBox();
    if x1 ~= nil then
        return x1 * scale, y1 * scale, z1 * scale, x2 * scale, y2 * scale, z2 * scale;
    end
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

    self:SetMinZoomDistance(1);
    self:SetMaxZoomDistance(25);
    self:SetZoomDistance(6.8);

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
        return IsShiftKeyDown() and .012 or 0.025;
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

DatamineModelSceneMixin.DefaultRaceActorOffsets = {
    Default = {
        x = 0,
        y = 0,
        z = 0,
    },
    DracthyrDragon = {
        x = -0.50,
        y = 0.80,
        z = -0.10
    },
};

DatamineModelSceneMixin.PlayerActorDefaults = {
    Scale = 1.05,
    Yaw = -1
};

DatamineModelSceneMixin.ActorInfoID = {
    MOUNT = 1,
    PET = 7,
};

function DatamineModelSceneMixin:OnLoad_Custom()
    self.ControlFrame:SetModelScene(self);
    self.FirstShow = true;

    self:ClearScene();
    self:SetViewInsets(0, 0, 0, 0);
    self:ReleaseAllActors();
    EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function() self:SetFromModelSceneID(596) end);

    self.actorTemplate = "DatamineModelSceneActorTemplate";

    Registry:RegisterCallback(Events.MODEL_LOADED_INTERNAL, self.OnModelLoaded_Internal, self);

    self:UpdateNativeFormButton();
end

function DatamineModelSceneMixin:OnFirstShow()
    self:SetupPlayerActor();
    self:SetupCamera();
    self:SetupCameraDefaults();
    self.FirstShow = false;
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

function DatamineModelSceneMixin:OnMouseDown_Custom()
    self:GetExternalControls():SetDoUpdate(true);

    if self:IsRightMouseButtonDown() then
        self:StartPanning();
    end
end

function DatamineModelSceneMixin:OnMouseUp_Custom()
    self:GetExternalControls():SetDoUpdate(false);
    self:StopPanning();
end

function DatamineModelSceneMixin:OnUpdate_Custom()
    if self.IsPanning then
        local actor = self:GetActiveActor();
        local actorScale = actor:GetScale();
        local cursorX, cursorY = GetCursorPosition();
        local scale = UIParent:GetEffectiveScale();

        local camera = self:GetActiveCamera();
        local cameraYaw = camera:GetYaw();
        local cameraZoom = camera:GetZoomPercent() or camera:GetMinZoomPercent();
        local cameraZoomModifier = 2;

        --local scaleModifier = actorScale < 1 and (scale * actorScale) or (scale / actorScale);
        local scaleModifier = (scale * actorScale);

        local transformationRatio = 52 * 2 ^ (cameraZoom * cameraZoomModifier) * scaleModifier;

        local dx = (cursorX - self.CursorX) / transformationRatio;
		local dy = (cursorY - self.CursorY) / transformationRatio;
        -- apply the sine and negative cosine of the camera yaw to correct for the viewport angle when moving the model
		local newActorX = self.ActorPosition.x + (dx * math.sin(cameraYaw));
        local newActorY = self.ActorPosition.y + (dx * -math.cos(cameraYaw));
		local newActorZ = self.ActorPosition.z + dy;

        actor:SetPosition(newActorX, newActorY, newActorZ);
    end
end

function DatamineModelSceneMixin:OnModelLoaded_Internal(actor)
    self.ActiveActor = actor;

    Registry:TriggerEvent(Events.MODEL_LOADED, actor);
    Registry:TriggerEvent(Events.MODEL_OUTFIT_UPDATED);
end

function DatamineModelSceneMixin:OnDressModel()
    Registry:TriggerEvent(Events.MODEL_DRESSED);
end

function DatamineModelSceneMixin:UpdateNativeFormButton()
    local _, raceFileName = UnitRace("player");
    if raceFileName == "Dracthyr" or raceFileName == "Worgen" then
        self.NativeFormToggleButton:SetScript("OnClick", function()
            local useNativeForm = self:GetUseNativeForm();
            self:SetUseNativeForm(not useNativeForm);
        end);

        self.NativeFormToggleButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.NativeFormToggleButton, "ANCHOR_TOP");
            GameTooltip:SetText("Toggle Alternate Form", 1, 1, 1);
            GameTooltip:Show();
        end);

        self.NativeFormToggleButton:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);

        self.NativeFormToggleButton:Show();
        self.NativeFormToggleButton:Enable();
    else
        self.NativeFormToggleButton:Hide();
        self.NativeFormToggleButton:Disable();
    end
end

function DatamineModelSceneMixin:StartPanning()
    self.IsPanning = true;
    local actor = self:GetActiveActor();
    local x, y, z = actor:GetPosition();
    self.ActorPosition = CreateVector3D(x, y, z);
    self.ActorYaw = actor:GetYaw();
	local cursorX, cursorY = GetCursorPosition();
	self.CursorX = cursorX;
	self.CursorY = cursorY;
end

function DatamineModelSceneMixin:StopPanning()
    self.IsPanning = false;
end

function DatamineModelSceneMixin:Reset()
    self:SetupPlayerActor(true);
    self:ResetCamera();

    Registry:TriggerEvent(Events.MODEL_RESET);
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

    camera:SetMinZoomDistance(1);
    camera:SetMaxZoomDistance(25);
    camera:SetZoomDistance(6.8);
end

function DatamineModelSceneMixin:SetupCameraDefaults()
    self.CameraDefaults = self:GetCameraPosition();
end

function DatamineModelSceneMixin:GetCameraPosition()
    local forwardX, forwardY, forwardZ = self:GetCameraForward();
    local rightX, rightY, rightZ = self:GetCameraRight();
    local upX, upY, upZ = self:GetCameraUp();

    local camera = self:GetActiveCamera();
    local targetX, targetY, targetZ = camera:GetTarget();
    local panningXOffset, panningYOffset = camera.panningXOffset, camera.panningYOffset;
    local zoom = camera:GetZoomDistance();

    return {
        forward = CreateVector3D(forwardX, forwardY, forwardZ),
        right = CreateVector3D(rightX, rightY, rightZ),
        up = CreateVector3D(upX, upY, upZ),
        target = CreateVector3D(targetX, targetY, targetZ),
        panning = CreateVector2D(panningXOffset, panningYOffset),
        zoom = zoom
    };
end

function DatamineModelSceneMixin:ResetCamera()
    local cameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(1);
    local camera = self:GetActiveCamera();

    CAMERA_INFO = cameraInfo;

    local cameraDefaults = self.CameraDefaults;
    camera:SetTarget(cameraDefaults.target.x, cameraDefaults.target.y, cameraDefaults.target.z);

    camera:SetYaw(cameraInfo.yaw);
    camera:SetPitch(cameraInfo.pitch);
    camera:SetRoll(cameraInfo.roll);

    camera.panningXOffset = cameraDefaults.panning.x;
    camera.panningYOffset = cameraDefaults.panning.y;

    camera:SnapAllInterpolatedValues();
    camera:UpdateCameraOrientationAndPosition();
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

function DatamineModelSceneMixin:GetPlayerActorPositionOffsets()
    local useNativeForm = self:GetUseNativeForm();
    local _, raceFileName = UnitRace("player");
    if raceFileName == "Dracthyr" and useNativeForm then
        return self.DefaultRaceActorOffsets.DracthyrDragon;
    else
        return self.DefaultRaceActorOffsets.Default;
    end
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
    actor:SetUseCenterForOrigin(true, false, false);
    actor:SetYaw(self.PlayerActorDefaults.Yaw);
    actor:SetScale(self.PlayerActorDefaults.Scale);
    actor:ResetModel();

    local actorOffsets = self:GetPlayerActorPositionOffsets();
    actor:SetPosition(actorOffsets.x, actorOffsets.y, actorOffsets.z);
end

function DatamineModelSceneMixin:ViewMount(mountID)
    local actorInfo = C_ModelInfo.GetModelSceneActorInfoByID(self.ActorInfoID.MOUNT);
    local actor = self:GetActiveActor();
    local displayID = C_MountJournal.GetMountInfoExtraByID(mountID);
    actor:ApplyFromModelSceneActorInfo(actorInfo);
    actor:SetModelByCreatureDisplayID(displayID);
end

function DatamineModelSceneMixin:ViewPet(displayID)
    local actorInfo = C_ModelInfo.GetModelSceneActorInfoByID(self.ActorInfoID.PET);
    local actor = self:GetActiveActor();
    actor:ApplyFromModelSceneActorInfo(actorInfo);
    actor:SetModelByCreatureDisplayID(displayID);
end

function DatamineModelSceneMixin:TryOnByItemModifiedAppearanceID(appearanceIDs)
    local actor = self:GetActiveActor();
    if type(appearanceIDs) == "table" then
        for _, appearanceID in pairs(appearanceIDs) do
            actor:TryOn(appearanceID);
        end
    else
        actor:TryOn(appearanceIDs);
    end

    Registry:TriggerEvent(Events.MODEL_OUTFIT_UPDATED);
end

function DatamineModelSceneMixin:TryOnByItemID(itemID)
    local _, itemModifiedAppearanceID = C_TransmogCollection.GetItemInfo(itemID);
    return self:TryOnByItemModifiedAppearanceID(itemModifiedAppearanceID);
end

function DatamineModelSceneMixin:TryOnByTransmogSetID(transmogSetID)
    local actor = self:GetActiveActor();
    local itemModifiedAppearanceIDs = C_TransmogSets.GetAllSourceIDs(transmogSetID);
    if itemModifiedAppearanceIDs and #itemModifiedAppearanceIDs > 0 then
        actor:Undress();
    end

    return self:TryOnByItemModifiedAppearanceID(itemModifiedAppearanceIDs);
end

function DatamineModelSceneMixin:SetModelByFileID(fdid)
    local actor = self:GetActiveActor();
    return actor:SetModelByFileID(fdid);
end

function DatamineModelSceneMixin:SetModelByCreatureDisplayID(cdid)
    local actor = self:GetActiveActor();
    return actor:SetModelByCreatureDisplayID(cdid);
end

function DatamineModelSceneMixin:ApplySpellVisualKit(svkid)
    if svkid == 0 then svkid = nil; end;
    local actor = self:GetActiveActor();
    return actor:SetSpellVisualKit(svkid);
end

function DatamineModelSceneMixin:PlayAnimKit(akid)
    local actor = self:GetActiveActor();
    if akid == nil or akid == 0 then
        return actor:StopAnimationKit();
    end
    return actor:PlayAnimationKit(akid);
end

function DatamineModelSceneMixin:TryOnTransmogSet()
    local actor = self:GetActiveActor();
    local itemModifiedAppearanceIDs = C_TransmogSets.GetAllSourceIDs(transmogSetID);
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

    self.UpdatedCallback = function(editBox) self:CheckDefaults(editBox) end;

    self.X:HookScript("OnTextChanged", self.UpdatedCallback);
    self.Y:HookScript("OnTextChanged", self.UpdatedCallback);
    self.Z:HookScript("OnTextChanged", self.UpdatedCallback);

    self.Title:SetTextScale(0.85);

    Registry:RegisterCallback(Events.MODEL_CONTROLS_DEFAULTS_UPDATED, self.OnModelControlsDefaultsUpdated, self);
end

function DatamineModelControlsLabelledEditBoxRowMixin:OnModelControlsDefaultsUpdated()
    self:SetDefaults();
    self.UpdatedCallback(self.X);
    self.UpdatedCallback(self.Y);
    self.UpdatedCallback(self.Z);
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

DatamineModelControlsTreeMixin.ArmorSlotNames = {
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
    RING0 = FINGER0SLOT,
    RING1 = FINGER1SLOT,
    TRINKET0 = TRINKET0SLOT,
    TRINKET1 = TRINKET1SLOT,
    MAINHAND = MAINHANDSLOT,
    SECONDARYHAND = SECONDARYHANDSLOT,
    RANGED = RANGEDSLOT
};

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

    local function OutfitSort(a, b)
        local idxA = tIndexOf(Transmog.ArmorSlotVisualOrder, a.data.SlotID);
        local idxB = tIndexOf(Transmog.ArmorSlotVisualOrder, b.data.SlotID);
        return idxA < idxB;
    end

    self.OutfitTab = self:AddTopLevelItem({
        Text = "Outfit",
        SortFunc = OutfitSort,
    });

    self.AdvancedTab = self:AddTopLevelItem({
        Text = "Advanced",
    });

    self:SetupLocationControls();
    self:SetupCameraControls();
    self:SetupAdvancedPanel();

    self:SetDoUpdate(false);

    self.TransformTab:SetCollapsed(true);
    self.OutfitTab:SetCollapsed(true);

    Registry:RegisterCallback(Events.MODEL_RESET, self.OnModelReset, self);
    Registry:RegisterCallback(Events.MODEL_LOADED, self.OnModelLoaded, self);
    Registry:RegisterCallback(Events.MODEL_DRESSED, self.OnOutfitUpdated, self);
    Registry:RegisterCallback(Events.MODEL_OUTFIT_UPDATED, self.OnOutfitUpdated, self);
end

function DatamineModelControlsTreeMixin:OnShow()
    self.ModelScene = self:GetScene();
end

function DatamineModelControlsTreeMixin:OnUpdate()
    if not self:IsShown() then
        return;
    end

    if self.DoUpdate then
        self:UpdateLocationControls();
        self:UpdateCameraControls();
    end

    if self.OutfitDirty then
        self:UpdateOutfit();
    end
end

function DatamineModelControlsTreeMixin:OnModelLoaded()
    self:SetEditBoxDefaults();
    self:UpdateLocationControls();
    self:UpdateCameraControls();
end

function DatamineModelControlsTreeMixin:OnModelReset()
    self:OnModelLoaded();
end

function DatamineModelControlsTreeMixin:OnOutfitUpdated()
    self:MarkOutfitDirty();
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
        Text = "Translate",
        ControlID = "LocationControls",
        DataFetch = function() return self:GetActorPosition(); end,
        Callback = LocationCallback,
        DefaultsFunc = GetLocationDefaults,
        OverlordFrame = self,
        Template = "DatamineModelControlsLabelledEditBoxRowTemplate",
    });
end

function DatamineModelControlsTreeMixin:SetupCameraControls()
    local function CameraViewCallback(x, y, z)
        local camera = self.ModelScene:GetActiveCamera();
        camera:SetYaw(x);
        camera:SetPitch(y);
        camera:SetRoll(z);
        camera:UpdateCameraOrientationAndPosition();
    end

    local function GetCameraViewDefaults()
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
        Callback = CameraViewCallback,
        DefaultsFunc = GetCameraViewDefaults,
        OverlordFrame = self,
        Template = "DatamineModelControlsLabelledEditBoxRowTemplate",
    });
end

function DatamineModelControlsTreeMixin:MarkOutfitDirty()
    self.OutfitDirty = true;
end

function DatamineModelControlsTreeMixin:FlushOutfitPanel()
    for _, node in pairs(self.OutfitTab:GetNodes()) do
        node:Flush();
        node:Invalidate();
    end

    self.OutfitTab:Flush();
    self.OutfitTab:Invalidate();
end

function DatamineModelControlsTreeMixin:UpdateOutfit()
    if not self.OutfitDirty then
        return;
    end

    local actor = self.ModelScene:GetActiveActor();
    local itemTransmogInfoList = actor:GetItemTransmogInfoList();
    self:LoadOutfit(itemTransmogInfoList);
    self.OutfitDirty = false;
end

function DatamineModelControlsTreeMixin:LoadOutfit(itemTransmogInfoList)
    self:FlushOutfitPanel();

    local mainHandInfo = itemTransmogInfoList[INVSLOT_MAINHAND];
    if mainHandInfo.secondaryAppearanceID == Constants.Transmog.MainHandTransmogIsPairedWeapon then
        local pairedTransmogID = C_TransmogCollection.GetPairedArtifactAppearance(mainHandInfo.appearanceID);
        if pairedTransmogID then
            itemTransmogInfoList[INVSLOT_OFFHAND].appearanceID = pairedTransmogID;
        end
    end

    for _, slotID in ipairs(Transmog.ArmorSlotVisualOrder) do
        local transmogInfo = itemTransmogInfoList[slotID];
        local data = {
            OverlordFrame = self,
            Template = "DatamineModelControlsOutfitPanelEntryTemplate",
            RequestedExtent = 32,
            SlotID = slotID,
        };

        if transmogInfo then
            if transmogInfo.appearanceID and transmogInfo.appearanceID ~= Constants.Transmog.NoTransmogID then
                data.AppearanceID = transmogInfo.appearanceID;
            end

            if transmogInfo.secondaryAppearanceID and transmogInfo.secondaryAppearanceID ~= Constants.Transmog.NoTransmogID then
                data.SecondaryAppearanceID = transmogInfo.secondaryAppearanceID;
            end
        end

        self.OutfitTab:Insert(data);
    end
end

function DatamineModelControlsTreeMixin:RemoveAppearance(appearanceID, secondaryAppearanceID, illusionID)
    secondaryAppearanceID = secondaryAppearanceID or Constants.Transmog.NoTransmogID;
    illusionID = illusionID or Constants.Transmog.NoTransmogID;

    local hiddenAppearanceID = Transmog:GetHiddenAppearanceForAppearanceID(appearanceID);

    if hiddenAppearanceID then
        self:GetScene():TryOnByItemModifiedAppearanceID(hiddenAppearanceID);
    end
end

function DatamineModelControlsTreeMixin:SearchItemByAppearanceID(itemModifiedAppearanceID)
    local itemID = Transmog:GetItemIDForAppearanceID(itemModifiedAppearanceID);
    local explorer = UI_MAIN.GetExplorer();

    explorer:SetSearchMode(Datamine.Constants.DataTypes.Item);
    explorer:Search(itemID);
end

function DatamineModelControlsTreeMixin:SetupAdvancedPanel()
    self.AdvancedTab:Insert({
        Text = "Set model by FileDataID",
        Instructions = "Enter a FileDataID...",
        Callback = function(fdid) return self:GetScene():SetModelByFileID(fdid) end,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    self.AdvancedTab:Insert({
        Text = "Set model by DisplayInfoID",
        Instructions = "Enter a DisplayInfoID...",
        Callback = function(cdid) return self:GetScene():SetModelByCreatureDisplayID(cdid) end,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    self.AdvancedTab:Insert({
        Text = "Try on ItemID",
        Instructions = "Enter an ItemID...",
        Callback = function(iid) return self:GetScene():TryOnByItemID(iid) end,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    self.AdvancedTab:Insert({
        Text = "Try on ItemModifiedAppearanceID",
        Instructions = "Enter an ItemModifiedAppearanceID...",
        Callback = function(imaid) return self:GetScene():TryOnByItemModifiedAppearanceID(imaid) end,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    self.AdvancedTab:Insert({
        Text = "Try on TransmogSetID",
        Instructions = "Enter a TransmogSetID...",
        Callback = function(tsid) return self:GetScene():TryOnByTransmogSetID(tsid) end,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    self.AdvancedTab:Insert({
        Text = "Apply SpellVisualKit",
        Instructions = "Enter a SpellVisualKitID...",
        Callback = function(svkid) return self:GetScene():ApplySpellVisualKit(svkid) end,
        Template = "DatamineModelControlsAdvancedPanelEntryTemplate",
        RequestedExtent = 40,
    });

    self.AdvancedTab:Insert({
        Text = "Play AnimationKit",
        Instructions = "Enter an AnimKitID...",
        Callback = function(akid) return self:GetScene():PlayAnimKit(akid) end,
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
    local xCPos, yCPos, zCPos = camera:GetPosition();

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
        },
        CameraPosition = {
            x = xCPos,
            y = yCPos,
            z = zCPos,
        },
    };

    Registry:TriggerEvent(Events.MODEL_CONTROLS_DEFAULTS_UPDATED);
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

DatamineModelControlsOutfitPanelEntryMixin = {};

function DatamineModelControlsOutfitPanelEntryMixin:Init(node)
    self.data = node:GetData();
    node:Flush();
    self.Overlord = self.data.OverlordFrame;

    self.Text:SetTextScale(0.80);
    node:SetCollapsed(true);

    self.IsEmpty = false;
    self.IsHidden = false;

    if not self.data.AppearanceID or self.data.AppearanceID == Constants.Transmog.NoTransmogID then
        self:SetupEmptySlot();
        self.IsEmpty = true;
    elseif Transmog:IsHiddenAppearance(self.data.AppearanceID) then
        self:SetupHiddenSlot();
        self.IsHidden = true;
        self.IsEmpty = false;
    else
        self:SetupPopulatedSlot();
        self.IsEmpty = false;
    end

    self:UpdateButtonVisiblity();
end

function DatamineModelControlsOutfitPanelEntryMixin:SetupEmptySlot()
    self.Icon:Reset();
    self.Icon:SetItemButtonTexture(134400); -- question mark icon

    self.Text:SetText("Empty");
end

function DatamineModelControlsOutfitPanelEntryMixin:SetupHiddenSlot()
    self.Icon:Reset();
    self.Icon.icon:SetAtlas("transmog-icon-hidden");
    self.Icon.icon:Show();

    self.Text:SetText("Hidden");
end

function DatamineModelControlsOutfitPanelEntryMixin:SetupPopulatedSlot()
    local node = self:GetElementData();
    local categoryID, visualID, canEnchant, icon, isCollected, itemLink, _, _, itemSubTypeIndex = C_TransmogCollection.GetAppearanceSourceInfo(self.data.AppearanceID);
    local transmogInfo = {
        AppearanceID = self.data.AppearanceID;
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

    self.Text:SetText(itemLink);

    self.Icon:SetItem(itemLink);
    self.Icon:SetScript("OnClick", function() self:GetElementData():ToggleCollapsed() end);

    self:SetScript("OnHyperlinkClick", self.OnHyperlinkClick);
    self:SetScript("OnHyperlinkEnter", self.OnHyperlinkEnter);
    self:SetScript("OnHyperlinkLeave", self.OnHyperlinkLeave);

    self.HideButton:SetScript("OnClick", function() self:OnHideButtonClick() end);
    self.SearchButton:SetScript("OnClick", function() self:OnSearchButtonClick() end);
end

function DatamineModelControlsOutfitPanelEntryMixin:OnHideButtonClick()
    UI_MAIN.GetModelView().ModelScene:GetActiveActor():UndressSlot(self.data.SlotID);
end

function DatamineModelControlsOutfitPanelEntryMixin:OnSearchButtonClick()
    local appearanceID = self:GetData().AppearanceID;
    if appearanceID then
        self.Overlord:SearchItemByAppearanceID(appearanceID);
    end
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
    if not (self.IsEmpty or self.IsHidden) then
        self:GetElementData():ToggleCollapsed();
    end
end

function DatamineModelControlsOutfitPanelEntryMixin:UpdateButtonVisiblity()
    if not self.IsEmpty and not self.IsHidden then
        self.HideButton:Show();
        self.HideButton:Enable();

        self.SearchButton:Show();
        self.SearchButton:Enable();
    else
        self.HideButton:Hide();
        self.HideButton:Disable();

        self.SearchButton:Hide();
        self.SearchButton:Disable();
    end
end

-------------

DatamineModelControlsAdvancedPanelEntryMixin = {};

function DatamineModelControlsAdvancedPanelEntryMixin:Init(node)
    local data = node:GetData();

    self.Title:SetText(data.Text);
    self.Title:SetTextScale(0.85);

    self.EntryBox:SetHeight(self:GetHeight() / 2);
    self.EntryBox.Instructions:SetText(data.Instructions);
    self.EntryBox:SetNumeric(true);
    self.EntryBox.Callback = function() data.Callback(self.EntryBox:GetNumber()); end;
end
