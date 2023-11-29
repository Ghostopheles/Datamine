DataminePlayerModelMixin = CreateFromMixins(ModelFrameMixin);

function DataminePlayerModelMixin:ResetModel()
    self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self:SetPosition(0, 0, 0);
	self.zoomLevel = self.minZoom;
	self:SetPortraitZoom(self.zoomLevel);
    self:SetUnit("player");
end

local ModelSettingsOverride = { panMaxLeft = -1.5, panMaxRight = 1.5, panMaxTop = 1.5, panMaxBottom = -1.5, panValue = 38 };

function DataminePlayerModelMixin:OnUpdate(elapsedTime)
	local rotationsPerSecond = ROTATIONS_PER_SECOND;

	-- Mouse drag rotation
	if (self.mouseDown) then
		if ( self.rotationCursorStart ) then
			local x = GetCursorPosition();
			local diff = (x - self.rotationCursorStart) * MODELFRAME_DRAG_ROTATION_CONSTANT;
			self.rotationCursorStart = GetCursorPosition();
			self.rotation = self.rotation + diff;
			if ( self.rotation < 0 ) then
				self.rotation = self.rotation + (2 * PI);
			end
			if ( self.rotation > (2 * PI) ) then
				self.rotation = self.rotation - (2 * PI);
			end
			self:SetRotation(self.rotation, false);
		end
	elseif ( self.panning ) then
		local modelScale = self:GetModelScale();
		local cursorX, cursorY = GetCursorPosition();
		local scale = UIParent:GetEffectiveScale();
		if self.panningFrame then 
			self.panningFrame:SetPoint("BOTTOMLEFT", cursorX / scale - 16, cursorY / scale - 16);	-- half the texture size to center it on the cursor
		end
		-- settings
		local settings = ModelSettingsOverride;
		local zoom = self.zoomLevel or self.minZoom;
		zoom = 1 + zoom - self.minZoom;	-- want 1 at minimum zoom

		-- Panning should require roughly the same mouse movement regardless of zoom level so the model moves at the same rate as the cursor
		-- This formula more or less works for all zoom levels, found via trial and error
		local transformationRatio = settings.panValue * 2 ^ (zoom * 2) * scale / modelScale;

		local dx = (cursorX - self.cursorX) / transformationRatio;
		local dy = (cursorY - self.cursorY) / transformationRatio;
		local cameraY = self.cameraY + dx;
		local cameraZ = self.cameraZ + dy;
		-- bounds
		scale = scale * modelScale;
		local maxCameraY = settings.panMaxRight * scale;
		cameraY = min(cameraY, maxCameraY);
		local minCameraY = settings.panMaxLeft * scale;
		cameraY = max(cameraY, minCameraY);
		local maxCameraZ = settings.panMaxTop * scale;
		cameraZ = min(cameraZ, maxCameraZ);
		local minCameraZ = settings.panMaxBottom * scale;
		cameraZ = max(cameraZ, minCameraZ);

		self:SetPosition(self.cameraX, cameraY, cameraZ);
	end

	-- Rotate buttons
	local leftButton, rightButton;
	if ( self.controlFrame ) then
		leftButton = self.controlFrame.rotateLeftButton;
		rightButton = self.controlFrame.rotateRightButton;
	else
		leftButton = self.RotateLeftButton or (self:GetName() and _G[self:GetName().."RotateLeftButton"]);
		rightButton = self.RotateRightButton or (self:GetName() and _G[self:GetName().."RotateRightButton"]);
	end

	self:UpdateRotation(leftButton, rightButton, elapsedTime, rotationsPerSecond);
end

function DataminePlayerModelMixin:GetScaledActiveBoundingBox()
	local scale = self:GetScale();
	local x1, y1, z1, x2, y2, z2 = self:GetScaledActiveBoundingBox();
	if x1 ~= nil then
		return x1 * scale, y1 * scale, z1 * scale, x2 * scale, y2 * scale, z2 * scale;
	end
end

function DataminePlayerModelMixin:OnModelLoaded()
	local scene = self:GetParent();
	local minX = math.huge;
	local minY = math.huge;
	local minZ = math.huge;
	local maxX = -math.huge;
	local maxY = -math.huge;
	local maxZ = -math.huge;
	for i=1, scene:GetNumActors() do
		local actor = scene:GetActorAtIndex(i);
		local x, y, z = actor:GetScaledPosition();
		local x1, y1, z1, x2, y2, z2 = actor:GetScaledActiveBoundingBox();
		if x1 ~= nil then
			minX = math.min(minX, x + x1);
			minY = math.min(minY, y + y1);
			minZ = math.min(minZ, z + z1);
			maxX = math.min(maxX, x + x2);
			maxY = math.min(maxY, y + y2);
			maxZ = math.min(maxZ, z + z2);
		end
	end
	local lx = maxX - minX;
	local ly = maxY - minY;
	local lz = maxZ - minZ;
	local size = math.sqrt(lx ^ 2 + ly ^ 2 + lz ^ 2) * 1.5;
	local angle = math.max(lx, ly) < lz and 0 or 45 / 2;
	local camera = scene:GetActiveCamera();
	camera:SetPitch(math.rad(angle));
	camera:SetTarget(minX + lx / 2, minY + ly / 2, minZ + lz / 2);
	camera:SetMinZoomDistance(size);
	camera:SetMaxZoomDistance(size);
	camera:SetZoomDistance(size);
	camera:SnapAllInterpolatedValues();
end