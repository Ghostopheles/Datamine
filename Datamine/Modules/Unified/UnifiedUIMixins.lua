local Events = Datamine.Events;
local Registry = Datamine.EventRegistry;

DatamineLightGray = CreateColor(0.18, 0.18, 0.18, 1);
DatamineDarkGray = CreateColor(0.1, 0.1, 0.1, 1);

local DataTypes = Datamine.Constants.DataTypes;
local DataKeys = {
    [DataTypes.Item] = Datamine.Item.ItemInfoKeys,
    [DataTypes.Spell] = Datamine.Spell.SpellInfoKeys,
};
local FetchFuncs = {
    [DataTypes.Item] = function(...) Datamine.Item:GetOrFetchItemInfoByID(...) end,
    [DataTypes.Spell] = function(...) Datamine.Spell:GetOrFetchSpellInfoByID(...) end,
};

-------------

DatamineCloseButtonMixin = {};

function DatamineCloseButtonMixin:OnClick()
    local parent = self:GetParent();
    if parent then
        local continueHide = true;
        if parent.OnCloseCallback then
            continueHide = parent.OnCloseCallback(parent);
        end

        if continueHide then
            parent:Hide();
        end
    end
end

-------------

DatamineTitleContainerMixin = {};

function DatamineTitleContainerMixin:OnLoad()
    if self.TitleText then
        self:SetText(self.TitleText);
    end
end

function DatamineTitleContainerMixin:SetText(text)
    self.Text:SetText(text);
end

-------------

DatamineMovableTitleContainerMixin = {};

function DatamineMovableTitleContainerMixin:OnMouseDown()
    self:GetParent():StartMoving();
end

function DatamineMovableTitleContainerMixin:OnMouseUp()
    self:GetParent():StopMovingOrSizing();
end

-------------

DatamineSearchBoxMixin = {};

function DatamineSearchBoxMixin:OnEnterPressed()
    local value = self:GetNumber();
    local searchFunc = self:GetParent().Search;
    if searchFunc then
        searchFunc(self:GetParent(), value);
    end
end

-------------

DatamineDataFrameElementMixin = {};

function DatamineDataFrameElementMixin:Init(data)
    self.KeyText:SetText(data.key .. ":");
    self.ValueText:SetText(data.value);

    if self.KeyText:IsTruncated() then
        self.KeyText:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.KeyText, "ANCHOR_TOPRIGHT");
            GameTooltip:SetText(data.key, 1, 1, 1);
            GameTooltip:Show();
        end);

        self.KeyText:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
    end

    if self.ValueText:IsTruncated() then
        self.ValueText:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.ValueText, "ANCHOR_TOPRIGHT");
            GameTooltip:SetText(self.ValueText:GetText(), 1, 1, 1);
            GameTooltip:Show();
        end);

        self.ValueText:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
    end
end

function DatamineDataFrameElementMixin:OnHyperlinkClick(link, text, button)
    SetItemRef(link, text, button);
end

function DatamineDataFrameElementMixin:OnHyperlinkEnter(link, _)
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
    GameTooltip:SetHyperlink(link);
    GameTooltip:Show();
end

function DatamineDataFrameElementMixin:OnHyperlinkLeave()
    GameTooltip:Hide();
end

-------------

DatamineScrollableDataFrameMixin = {};

function DatamineScrollableDataFrameMixin:OnLoad()
    self.DataProvider = CreateDataProvider();

    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);
    self.ScrollView:SetElementInitializer("DatamineDataFrameElementTemplate", function(frame, data)
        frame:Init(data, self);
    end);

    self.ScrollBox:SetInterpolateScroll(true);
    self.ScrollBar:SetInterpolateScroll(true);
    self.ScrollBar:SetHideIfUnscrollable(true);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    Registry:RegisterCallback(Events.SEARCH_BEGIN, self.OnSearchBegin, self);
    Registry:RegisterCallback(Events.SEARCH_RESULT, self.OnSearchResult, self);
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);

    --self:SetLoading(false);
end

function DatamineScrollableDataFrameMixin:OnSearchBegin(dataID)
    self.DataID = dataID;
end

function DatamineScrollableDataFrameMixin:OnSearchModeChanged(searchMode)
    self.SearchMode = searchMode;
end

function DatamineScrollableDataFrameMixin:OnSearchResult(dataID)
    local modeText = Datamine.GetEnumValueName(DataTypes, self.SearchMode);
    self.Title:SetText(modeText .. " " .. dataID);
    self.Title:Show();
    self.PreviewItemButton:Show();
end

function DatamineScrollableDataFrameMixin:OnFail()
end

function DatamineScrollableDataFrameMixin:RefreshDataProvider()
    self.ScrollView:FlushDataProvider();
end

function DatamineScrollableDataFrameMixin:GetDataKeys()
    return DataKeys[self.SearchMode];
end

function DatamineScrollableDataFrameMixin:Populate(data, dataID)
    self:RefreshDataProvider();

    if not data then
        self:SetLoading(false);
        self:OnFail();
    end

    local keys = self:GetDataKeys();

    for i, value in ipairs(data) do
        if value == nil or value == "" then
            value = "N/A";
        elseif type(value) == "boolean" then
            value = tostring(value);
        end

        local key = keys[i];

        if key == "Hyperlink" and self.SearchMode == DataTypes.Item then
            self.Icon:SetItem(value);
        end

        if key == "Icon" and self.SearchMode == DataTypes.Spell then
            self.Icon.icon:SetTexture(value);
        end

        local _data = {
            key = keys[i],
            value = value
        };
        self.DataProvider:Insert(_data);
    end

    self:SetLoading(false);
    Registry:TriggerEvent(Events.SEARCH_RESULT, dataID);
end

function DatamineScrollableDataFrameMixin:SetLoading(isLoading)
    if isLoading then
        self.ScrollBox:Hide();
        self.Icon:Hide();
        self.Title:Hide();
        self.LoadingSpinner:Show();
        self.Loading = true;
    else
        self.ScrollBox:Show();
        self.Icon:Show();
        self.Title:Show();
        self.LoadingSpinner:Hide();
        self.Loading = false;
    end
end

function DatamineScrollableDataFrameMixin:IsLoading()
    return self.Loading;
end

-------------

DataminePreviewItemButtonMixin = {};

function DataminePreviewItemButtonMixin:OnClick()
    local dataID = self:GetParent().DataID;
    DatamineUnifiedFrame.Workspace.ModelViewTab:SetMode("playerModel");
    DatamineUnifiedFrame.Workspace.ModelViewTab.PlayerModel:SetItem(dataID);
end

function DataminePreviewItemButtonMixin:OnEnter()
end

function DataminePreviewItemButtonMixin:OnLeave()
end

-------------

DatamineUnifiedExplorerTabMixin = {};

function DatamineUnifiedExplorerTabMixin:OnLoad()
    Registry:RegisterCallback(Events.SEARCH_MODE_CHANGED, self.OnSearchModeChanged, self);

    self:SetSearchMode(DataTypes.Item);
end

function DatamineUnifiedExplorerTabMixin:GetSearchMode()
    return self.SearchMode;
end

function DatamineUnifiedExplorerTabMixin:GetDataFetchFunc()
    return FetchFuncs[self.SearchMode];
end

function DatamineUnifiedExplorerTabMixin:SetSearchMode(searchMode)
    if not tContains(DataTypes, searchMode) then
        return;
    end

    self.SearchMode = searchMode;
    Registry:TriggerEvent(Events.SEARCH_MODE_CHANGED, self.SearchMode);
end

function DatamineUnifiedExplorerTabMixin:OnSearchModeChanged(searchMode)
    local searchModeStr = Datamine.GetEnumValueName(DataTypes, searchMode);
    self.SearchBox.Instructions:SetText("Enter " .. searchModeStr .. "ID...");
    self.SearchBox:SetText("");
end

function DatamineUnifiedExplorerTabMixin:Search(number)
    Registry:TriggerEvent(Events.SEARCH_BEGIN, number);
    self:GetDataFetchFunc()(number, function(data) self.DataFrame:Populate(data, number) end);
end

-------------

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
        return .008;
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

-------------

DatamineModelSceneMixin = {};

function DatamineModelSceneMixin:OnLoadCustom()
    self.ControlFrame:SetModelScene(self);
    self.FirstShow = true;

    self:ClearScene();
    self:SetViewInsets(0, 0, 0, 0);
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
    DatamineUnifiedFrame.Workspace.DetailsTab.Controls:UpdateTransform();
    DatamineUnifiedFrame.Workspace.DetailsTab.Controls:UpdateRotation();
    self.FirstShow = false;

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

function DatamineModelSceneMixin:GetExternalControls()
    return self:GetParent():GetParent().DetailsTab.Controls;
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

    local defaultZoom = camera:GetZoomDistance();
    camera:SetMinZoomDistance(1);
    camera:SetMaxZoomDistance(25);
    camera:SetZoomDistance(defaultZoom);
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

function DatamineModelSceneMixin:SetupPlayerActor(force)
    if self.ActiveActor or (not self.FirstShow and not force) then
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

function DatamineModelControlsEditBoxMixin:OnLoad()
end

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

function DatamineModelControlsEditBoxMixin:OnTextChanged(userInput)
    if self:GetText() ~= self:GetDefaultValue() then
        return;
    end
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
    local filtered = self:Filter(text);
    filtered = self:Round(filtered);
    self:SetText(filtered);
end

function DatamineModelControlsEditBoxMixin:SetTextUnfiltered(text)
    if not text then
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
end

function DatamineModelControlsEditBoxMixin:GetDefaultValue()
    return self.DefaultValue;
end

function DatamineModelControlsEditBoxMixin:Reset()
    local default = self:GetDefaultValue();
    self:SetText(default);

    if self.Callback then
        self.Callback(self:GetText());
    end
end

-------------

DatamineModelControlsLabelledEditBoxRowMixin = {};

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

DatamineModelControlsExternalMixin = {};

function DatamineModelControlsExternalMixin:GetScene()
    return self:GetParent():GetParent().ModelViewTab.ModelScene;
end

function DatamineModelControlsExternalMixin:GetCameraXYZ()
    local camera = self.ModelScene:GetActiveCamera();
    local x, y, z = camera:GetYaw(), camera:GetPitch(), camera:GetRoll();
    return x, y, z;
end

function DatamineModelControlsExternalMixin:GetActorPosition()
    local actor = self.ModelScene:GetActiveActor();
    if not actor then
        return;
    end

    return actor:GetPosition();
end

function DatamineModelControlsExternalMixin:GetActorRotation()
    local actor = self.ModelScene:GetActiveActor();
    if not actor then
        return;
    end

    return actor:GetYaw(), actor:GetPitch(), actor:GetRoll();
end

function DatamineModelControlsExternalMixin:GetCameraOrientation()
    local camera = self.ModelScene:GetActiveCamera();
    return camera:GetYaw(), camera:GetPitch(), camera:GetRoll();
end

function DatamineModelControlsExternalMixin:OnLoad()
    local textScale = 0.95;

    self.Transform.Title:SetText("Transform");
    self.Transform.Title:SetTextScale(textScale);

    self.Rotation.Title:SetText("Rotation");
    self.Rotation.Title:SetTextScale(textScale);

    self:SetDoUpdate(false);
end

function DatamineModelControlsExternalMixin:OnShow()
    self.ModelScene = DatamineUnifiedFrame:GetModelScene();

    if not self.EditBoxTargetsSet then
        self:SetEditBoxTargets();
    end
end

function DatamineModelControlsExternalMixin:OnUpdate()
    if not self:IsShown() or not self.DoUpdate then
        return;
    end

    self:UpdateTransform();
    self:UpdateRotation();
end

function DatamineModelControlsExternalMixin:SetDoUpdate(doUpdate)
    self.DoUpdate = doUpdate;
end

function DatamineModelControlsExternalMixin:OnEnterPressed()
end

function DatamineModelControlsExternalMixin:SetEditBoxDefaults()
    local camera = self.ModelScene:GetActiveCamera();
    local actor = self.ModelScene:GetActiveActor();

    local xT, yT, zT = actor:GetPosition();
    local xC, yC, zC = camera:GetYaw(), camera:GetPitch(), camera:GetRoll();

    self.Transform.X:SetDefaultValue(xT);
    self.Transform.Y:SetDefaultValue(yT);
    self.Transform.Z:SetDefaultValue(zT);

    self.Rotation.X:SetDefaultValue(xC);
    self.Rotation.Y:SetDefaultValue(yC);
    self.Rotation.Z:SetDefaultValue(zC);
end

function DatamineModelControlsExternalMixin:SetEditBoxTargets()
    local function TransformCallback()
        local actor = self.ModelScene:GetActiveActor();
        local x, y, z = self.Transform.X:GetText(), self.Transform.Y:GetText(), self.Transform.Z:GetText();
        actor:SetPosition(x, y, z);
    end

    self.Transform.X:SetCallback(TransformCallback);
    self.Transform.Y:SetCallback(TransformCallback);
    self.Transform.Z:SetCallback(TransformCallback);

    local function RotationCallback()
        local camera = self.ModelScene:GetActiveCamera();
        local x, y, z = self.Rotation.X:GetText(), self.Rotation.Y:GetText(), self.Rotation.Z:GetText();
        camera:SetYaw(x);
        camera:SetPitch(y);
        camera:SetRoll(z);
        camera:UpdateCameraOrientationAndPosition();
    end

    self.Rotation.X:SetCallback(RotationCallback);
    self.Rotation.Y:SetCallback(RotationCallback);
    self.Rotation.Z:SetCallback(RotationCallback);

    self.EditBoxTargetsSet = true;
end

function DatamineModelControlsExternalMixin:UpdateTransform()
    local x, y, z = self:GetActorPosition();
    self.Transform.X:SetTextUnfiltered(x or 0);
    self.Transform.Y:SetTextUnfiltered(y or 0);
    self.Transform.Z:SetTextUnfiltered(z or 0);
end

function DatamineModelControlsExternalMixin:UpdateRotation()
    local x, y, z = self:GetCameraOrientation();
    self.Rotation.X:SetTextUnfiltered(x or 0);
    self.Rotation.Y:SetTextUnfiltered(y or 0);
    self.Rotation.Z:SetTextUnfiltered(z or 0);
end

-------------

DataminePlayerModelMixin2 = CreateFromMixins(ModelFrameMixin);

function DataminePlayerModelMixin2:ResetModel()
    self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self:SetPosition(0, 0, 0);
	self.zoomLevel = self.minZoom;
	self:SetPortraitZoom(self.zoomLevel);
    self:SetUnit("player");
end

-------------

DatamineUnifiedModelViewTabMixin = {};
DatamineUnifiedModelViewTabMixin.Modes = {
    PLAYERMODEL = 1,
    SCENE = 2,
};

function DatamineUnifiedModelViewTabMixin:OnLoad()
end

function DatamineUnifiedModelViewTabMixin:OnShow()
end

function DatamineUnifiedModelViewTabMixin:OnViewModeChanged(viewMode)
    if viewMode == self.Modes.PLAYERMODEL then
        self.ModelScene:Hide();
        self.PlayerModel:Show();
    elseif viewMode == self.Modes.SCENE then
        self.PlayerModel:Hide();
        self.ModelScene:Show();
    end

    self.ViewMode = viewMode;
end

function DatamineUnifiedModelViewTabMixin:SetViewMode(viewMode)
    self.ViewMode = viewMode;
    Registry:TriggerEvent(Events.MODEL_VIEW_MODE_CHANGED, self.ViewMode);
end

-------------

DatamineUnifiedFrameMixin = {};

function DatamineUnifiedFrameMixin:Toggle()
    if not self:IsShown() then
        self:Show();
    else
        self:Hide();
    end
end

function DatamineUnifiedFrameMixin:GetModelScene()
    return self.Workspace.ModelViewTab.ModelScene;
end