-------------

DatamineModelSceneControlFrameMixin = CreateFromMixins(ModelSceneControlFrameMixin);

function DatamineModelSceneControlFrameMixin:OnLoad()
	if self.enableZoom then
		local increment = self:GetZoomIncrement();
		self.zoomInButton:SetZoomAmount(increment);
		self.zoomInButton:Init();

		self.zoomOutButton:SetZoomAmount(-increment);
		self.zoomOutButton:Init();
	end
	self.zoomInButton:SetShown(self.enableZoom);
	self.zoomOutButton:SetShown(self.enableZoom);

	if self.enableRotate then
		local increment = self:GetRotateIncrement();
		self.rotateLeftButton:SetRotation("left");
		self.rotateLeftButton:SetRotationIncrement(increment);
		self.rotateLeftButton:Init();

		self.rotateRightButton:SetRotation("right");
		self.rotateRightButton:SetRotationIncrement(increment);
		self.rotateRightButton:Init();
	end
	self.rotateLeftButton:SetShown(self.enableRotate);
	self.rotateRightButton:SetShown(self.enableRotate);

	if self.enableReset then
		self.resetButton:Init();
	end
	self.resetButton:SetShown(self.enableReset);
end

function DatamineModelSceneControlFrameMixin:OnShow()
    self:UpdateLayout();
end

-------------

DatamineModelSceneControlButtonMixin = CreateFromMixins(ModelSceneControlButtonMixin);

function DatamineModelSceneControlButtonMixin:Init(clickTypes, atlas, tooltip, tooltipText)
	self:RegisterForClicks(clickTypes);
	if atlas and self.Icon.SetCustomAtlas then
		self.Icon:SetCustomAtlas(atlas);
	end
	self.tooltip = tooltip;
	self.tooltipText = tooltipText;
end

-------------

DatamineModelSceneZoomButtonMixin = CreateFromMixins(ModelSceneZoomButtonMixin);


function DatamineModelSceneZoomButtonMixin:Init()
	if self.zoomAmount < 0 then
		DatamineModelSceneControlButtonMixin.Init(self, "AnyUp", "uitools-icon-chevron-down", ZOOM_OUT, KEY_MOUSEWHEELDOWN);
	else
		DatamineModelSceneControlButtonMixin.Init(self, "AnyUp", "uitools-icon-chevron-down", ZOOM_IN, KEY_MOUSEWHEELUP);
        self.Icon:SetRotation(math.pi);
	end
end

-------------

DatamineModelSceneRotateButtonMixin = CreateFromMixins(ModelScenelRotateButtonMixin);

function DatamineModelSceneRotateButtonMixin:Init()
	if (self.rotateDirection == "left") then
		DatamineModelSceneControlButtonMixin.Init(self, "AnyUp", "uitools-icon-chevron-left", ROTATE_LEFT, ROTATE_TOOLTIP);
	elseif (self.rotateDirection == "right") then
		DatamineModelSceneControlButtonMixin.Init(self, "AnyUp", "uitools-icon-chevron-right", ROTATE_RIGHT, ROTATE_TOOLTIP);
	else
		assertsafe(false, "Invalid rotation specified: "..tostring(self.rotateDirection));
	end
end

--------------------------------------------------
DatamineModelSceneResetButtonMixin = CreateFromMixins(ModelSceneResetButtonMixin);

function DatamineModelSceneResetButtonMixin:Init()
	local tooltipText = nil;
	DatamineModelSceneControlButtonMixin.Init(self, "AnyUp", "uitools-icon-refresh", RESET_POSITION, tooltipText);
end
