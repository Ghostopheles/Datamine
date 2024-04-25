local L = Datamine.Strings;
local Registry = Datamine.EventRegistry;
local Events = Datamine.Events;

---@type DatamineMaps
local Maps;

local MAX_CANVAS_ZOOM = 10;
local MIN_CANVAS_ZOOM = 0.25;

local ZOOM_STEP = 0.25;
local NUM_ZOOM_LEVELS = Round((MAX_CANVAS_ZOOM - MIN_CANVAS_ZOOM) / ZOOM_STEP);

local MAX_TILES_PER_FRAME = 300;

local MAX_TILES_X = 64;
local MAX_TILES_Y = 64;
local MAX_TILES = MAX_TILES_X * MAX_TILES_Y;
local TILE_TEMPLATE_NAME = "DatamineMapTileTemplate";

local function CheckMapsLoaded()
    if not C_AddOns.IsAddOnLoaded("Datamine_Maps") then
        C_AddOns.LoadAddOn("Datamine_Maps");
        Maps = Datamine.Maps;
    end
end

------------

DatamineMapTileMixin = {};

function DatamineMapTileMixin:OnLoad()
    self.ignoreInLayout = true;
end

function DatamineMapTileMixin:Init(textureID, y, x)
	self:ClearAllPoints();
	self:SetSize(64, 64);
    self:SetTileTexture(textureID);

    self.y = y;
    self.x = x;

    self.ignoreInLayout = false;
end

-- have to redefine 'self' here because frame pools are stupid
function DatamineMapTileMixin:Reset(self)
    self.x = nil;
    self.y = nil;
    self.layoutIndex = nil;
    self.ignoreInLayout = true;
end

function DatamineMapTileMixin:SetTileTexture(texture, ...)
	self.Texture = texture;
    if texture and texture ~= 0 then
        self:SetTexture(texture, ...);
    else
        self:MakeEmpty();
    end
end

function DatamineMapTileMixin:MakeEmpty()
    self:SetColorTexture(DatamineLightGray:GetRGB());
end

------------

DatamineMapCanvasMixin = {};

function DatamineMapCanvasMixin:OnLoad()
    self.isHorizontal = true;
    self.layoutFramesGoingRight = true;
    self.layoutFramesGoingUp = false;

    self.TilePool = CreateTexturePool(self, "BACKGROUND", 0, TILE_TEMPLATE_NAME, DatamineMapTileMixin.Reset);
    self.TilePool:SetResetDisallowedIfNew(true);

	self.TextPool = CreateFontStringPool(self, "ARTWORK", 10, "DatamineCleanFontSmall");

    self.DisplayedWDT = 0;
    self.MapInfo = nil;

    self:UpdateCanvasSize();

    Registry:RegisterCallback(Events.MAPVIEW_MAP_LOADED, self.OnMapLoaded, self);

    TEST_CANVAS = self; --TODO: REMOVE ME
end

function DatamineMapCanvasMixin:OnMapLoaded(wdtID, mapInfo)
    self.DisplayedWDT = wdtID;
    self.MapInfo = mapInfo;
    self:MarkDirty();
end

function DatamineMapCanvasMixin:UpdateCanvasSize(gridY, gridX)
    -- get tile size first, then use the size of the grid to set the canvas size
    local templateInfo = C_XMLUtil.GetTemplateInfo(TILE_TEMPLATE_NAME);
    local w, h = templateInfo.width, templateInfo.height;

    self.stride = (gridY or MAX_TILES_Y);
	self.fixedWidth = self.stride * w;
	self.fixedHeight = (gridX or MAX_TILES_X) * h;
end

function DatamineMapCanvasMixin:Clear()
    self:GetParent():SetEnabled(false);
    self.TilePool:ReleaseAll();
	self.TextPool:ReleaseAll();
    self.DisplayedWDT = 0;
    self.MapInfo = nil;
    self:MarkDirty();
end

function DatamineMapCanvasMixin:GetDisplayedWDT()
    return self.DisplayedWDT;
end

function DatamineMapCanvasMixin:LoadMapByWdtID(id)
    CheckMapsLoaded();

    ---@type DatamineMapDisplayInfo?
    local mapInfo = Maps.GetMapDisplayInfoByWdtID(id);
    if not mapInfo then
        return;
    end

	DevTool:AddData(mapInfo, "MAP_INFO");

    if self.TilePool:GetNumActive() > 0 then
        self:Clear();
    end

    local gridY = mapInfo.CanvasSize.Y + 1;
    local gridX = mapInfo.CanvasSize.X + 1;
    self:UpdateCanvasSize(gridY, gridX);

    local i = 1;
    for _, grid in pairs(mapInfo.Grids) do
        local y, x = grid.NormalizedCoords.Y, grid.NormalizedCoords.X;
        local textureID = grid.TextureID;
        local tile = self.TilePool:Acquire();
		tile.layoutIndex = i;
        tile:Init(textureID, y, x);

		local text = self.TextPool:Acquire();
		text:ClearAllPoints();
		text:SetPoint("CENTER", tile);
		text:SetSize(64, 64);
		text:SetText(format("X: %d Y: %d", y, x));
		text.ignoreInLayout = true;

        i = i + 1;
    end
    print(format("Generated %d tiles.", i));

    TEST_MAPINFO = mapInfo;

    Registry:TriggerEvent(Events.MAPVIEW_MAP_LOADED, id, mapInfo);
end

------------

DatamineMapControllerMixin = {};

DatamineMapControllerMixin.ZOOM_BEHAVIOR = {
    SMOOTH = 1,
    FULL = 2,
    NONE = 3
};

DatamineMapControllerMixin.SCALING_MODE = {
    TRANSLATE_FASTER_THAN_SCALE = 1,
    LINEAR = 2
};

DatamineMapControllerMixin.LERP_TYPE = {
    ZOOM = 1,
    PAN_X = 2,
    PAN_Y = 3
};

function DatamineMapControllerMixin:OnLoad()
    local defaultScroll = 0.5;
    self:SetCurrentScroll(defaultScroll, defaultScroll);
    self:SetTargetScroll(defaultScroll, defaultScroll);
    self:SetZoomAmountPerMouseWheelDelta(0.075);
    self:SetMouseWheelZoomMode(self.ZOOM_BEHAVIOR.SMOOTH);
    self:SetScalingMode(self.SCALING_MODE.TRANSLATE_FASTER_THAN_SCALE);

    self.NormalizedLerpAmounts = {
        [self.LERP_TYPE.ZOOM] = 0.15,
        [self.LERP_TYPE.PAN_X] = 0.15,
        [self.LERP_TYPE.PAN_Y] = 0.15,
    };

    self.MouseButtonInfo = {
        LeftButton = { Down = false },
        RightButton = { Down = false },
    };

    Registry:RegisterCallback(Events.MAPVIEW_MAP_CHANGED, self.OnMapChanged, self);
    Registry:RegisterCallback(Events.MAPVIEW_MAP_LOADED, self.OnMapLoaded, self);

    TEST_CONTROLLER = self; --TODO: REMOVE ME
end

function DatamineMapControllerMixin:OnHide()
    for _, mouseButtonInfo in pairs(self.MouseButtonInfo) do
        mouseButtonInfo.Down = false;
    end

    self.CurrentScale = nil;
    self:SetCurrentScroll(nil, nil);
	self:SetEnabled(false);
end

function DatamineMapControllerMixin:OnMouseDown(button)
    if not self:IsEnabled() then
        return;
    end

    local mouseButtonInfo = self.MouseButtonInfo[button];
    if mouseButtonInfo then
        mouseButtonInfo.Down = true;
        mouseButtonInfo.LastX, LastY = self:GetCursorPosition();
        mouseButtonInfo.StartX, StartY = mouseButtonInfo.LastX, mouseButtonInfo.LastY;
    end

    if button == "LeftButton" then
        if self:IsPanning() then
            local scrollX, scrollY = self:GetNormalizedHorizontalScroll(), self:GetNormalizedVerticalScroll();
            self:SetCurrentScroll(scrollX, scrollY);
            self:SetTargetScroll(scrollX, scrollY);
        end

        self.AccumulatedMouseDeltaX = 0.0;
        self.AccumulatedMouseDeltaY = 0.0;
    end
end

function DatamineMapControllerMixin:OnMouseUp(button)
    if not self:IsEnabled() then
        return;
    end

	local cursorX, cursorY = self:GetCursorPosition();
	local isClick = self:WouldCursorPositionBeClick(button, cursorX, cursorY);

	if button == "LeftButton" then
		if self:IsPanning() then
			local deltaX, deltaY = self:GetNormalizedMouseDelta(button);
			self:AccumulateMouseDeltas(GetTickTime(), deltaX, deltaY);

            local targetScroll = self:GetTargetScroll();
			local targetScrollX = Clamp(targetScroll.x + self.AccumulatedMouseDeltaX, self.scrollXExtentsMin, self.scrollXExtentsMax);
			local targetScrollY = Clamp(targetScroll.y + self.AccumulatedMouseDeltaY, self.scrollYExtentsMin, self.scrollYExtentsMax);
            self:SetTargetScroll(targetScrollX, targetScrollY);
		end

	elseif button == "RightButton" then
		if isClick then
			if self:IsMouseOver() then
                ---TODO: make right click do something
			end
		end
	end
	local mouseButtonInfo = self.MouseButtonInfo[button];
	if mouseButtonInfo then
		mouseButtonInfo.Down = false;
	end
end

function DatamineMapControllerMixin:OnMouseWheel(delta)
    if not self:IsEnabled() then
        return;
    end

    local mouseWheelZoomMode = self:GetMouseWheelZoomMode();
	if mouseWheelZoomMode == self.ZOOM_BEHAVIOR.NONE then
		return;
	end

    local canvasScale = self:GetCanvasScale();
	if self:ShouldAdjustTargetPanOnMouseWheel(delta) then
		local cursorX, cursorY = self:GetCursorPosition();
		local normalizedCursorX = self:NormalizeHorizontalSize(cursorX / canvasScale - self.Canvas:GetLeft());
		local normalizedCursorY = self:NormalizeVerticalSize(self.Canvas:GetTop() - cursorY / canvasScale);

		if not self:ShouldZoomInstantly() then
			local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange();
			local minX, maxX, minY, maxY = self:CalculateScrollExtentsAtScale(nextZoomInScale);

			normalizedCursorX, normalizedCursorY = Clamp(normalizedCursorX, minX, maxX), Clamp(normalizedCursorY, minY, maxY);
		end

		self:SetPanTarget(normalizedCursorX, normalizedCursorY);
	end

	if mouseWheelZoomMode == self.ZOOM_BEHAVIOR.SMOOTH then
		self:SetZoomTarget(canvasScale + self:GetZoomAmountPerMouseWheelDelta() * delta)
	elseif mouseWheelZoomMode == self.ZOOM_BEHAVIOR.FULL then
		if delta > 0 then
			self:ZoomIn();
		else
			self:ZoomOut();
		end
	end
end

local DELTA_SCALE_BEFORE_SNAP = .0001;
local DELTA_POSITION_BEFORE_SNAP = .0001;
function DatamineMapControllerMixin:OnUpdate(deltaTime)
    if not self:IsEnabled() then
        return;
    end

    local targetScroll = self:GetTargetScroll();
    local currentScroll = self:GetCurrentScroll();
    if self:IsPanning() then
		local deltaX, deltaY = self:GetNormalizedMouseDelta("LeftButton");

		targetScroll.x = Clamp(targetScroll.x + deltaX, self.scrollXExtentsMin, self.scrollXExtentsMax);
		targetScroll.y = Clamp(targetScroll.y + deltaY, self.scrollYExtentsMin, self.scrollYExtentsMax);

		self:AccumulateMouseDeltas(deltaTime, deltaX, deltaY);
	end

	local cursorX, cursorY = self:GetCursorPosition();
	for _, mouseButtonInfo in pairs(self.MouseButtonInfo) do
		mouseButtonInfo.LastX, mouseButtonInfo.LastY = cursorX, cursorY;
	end

	local scaleScaling, scrollXScaling, scrollYScaling = self:CalculateLerpScaling();

	if self.CurrentScale ~= self.TargetScale then
		local oldScrollX = self:GetNormalizedHorizontalScroll();
		local oldScrollY = self:GetNormalizedVerticalScroll();

		if not self.CurrentScale or math.abs(self.CurrentScale - self.TargetScale) < DELTA_SCALE_BEFORE_SNAP then
			self.CurrentScale = self.TargetScale;
		else
			self.CurrentScale = FrameDeltaLerp(self.CurrentScale, self.TargetScale, self:GetNormalizedLerpAmount(self.LERP_TYPE.ZOOM) * scaleScaling);
		end

		self.Canvas:SetScale(self.CurrentScale);
		self:CalculateScrollExtents();

		self:SetNormalizedHorizontalScroll(oldScrollX);
		self:SetNormalizedVerticalScroll(oldScrollY);
	end

	local panChanged = false;
	if not currentScroll.x or currentScroll.x ~= targetScroll.x then
		if not currentScroll.x or self:IsPanning() or math.abs(currentScroll.x - targetScroll.x) < DELTA_POSITION_BEFORE_SNAP then
			currentScroll.x = targetScroll.x;
		else
			currentScroll.x = FrameDeltaLerp(currentScroll.x, targetScroll.x, self:GetNormalizedLerpAmount(self.LERP_TYPE.PAN_X) * scrollXScaling);
		end

		self:SetNormalizedHorizontalScroll(currentScroll.x);
		panChanged = true;
	end

	if not currentScroll.y or currentScroll.y ~= targetScroll.y then
		if not currentScroll.y or self:IsPanning() or math.abs(currentScroll.y - targetScroll.y) < DELTA_POSITION_BEFORE_SNAP then
			currentScroll.y = targetScroll.y;
		else
			currentScroll.y = FrameDeltaLerp(currentScroll.y, targetScroll.y, self:GetNormalizedLerpAmount(self.LERP_TYPE.PAN_Y) * scrollYScaling);
		end
		self:SetNormalizedVerticalScroll(currentScroll.y);
		panChanged = true;
	end

	if panChanged then
		-- TODO: maybe update something here i dunno
	end
end

----

function DatamineMapControllerMixin:SetEnabled(enabled)
    self.Enabled = enabled;
end

function DatamineMapControllerMixin:IsEnabled()
    return self.Enabled;
end

----

function DatamineMapControllerMixin:CalculateLerpScaling()
	if self:GetScalingMode() == self.SCALING_MODE.TRANSLATE_FASTER_THAN_SCALE then
		-- Because of the way zooming in + isLeftButtonDown is perceived, we want to reduce the zoom weight so that panning completes first
		-- However, for zooming out we want to prefer the zoom then pan
		local SCALE_DELTA_FACTOR = self:IsZoomingOut() and 1.5 or .01;
		local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange();
		local zoomDelta = nextZoomInScale - nextZoomOutScale;
		-- if there's only 1 zoom level
		if zoomDelta == 0 then
			zoomDelta = 1;
		end

        local targetScroll = self:GetTargetScroll();
        local currentScroll = self:GetCurrentScroll();

		local scaleDelta = (math.abs(self:GetCanvasScale() - self.TargetScale) / zoomDelta) * SCALE_DELTA_FACTOR;
		local scrollXDelta = math.abs(currentScroll.x - targetScroll.x);
		local scrollYDelta = math.abs(currentScroll.y - targetScroll.y);

		local largestDelta = math.max(math.max(scaleDelta, scrollXDelta), scrollYDelta);
		if largestDelta ~= 0.0 then
			return scaleDelta / largestDelta, scrollXDelta / largestDelta, scrollYDelta / largestDelta;
		end
		return 1.0, 1.0, 1.0;
	elseif self:GetScalingMode() == self.SCALING_MODE.LINEAR then
		return 1.0, 1.0, 1.0;
	end
end

function DatamineMapControllerMixin:ShouldAdjustTargetPanOnMouseWheel(delta)
    if 1 == 1 then
        return false;
    end

	if self:GetMouseWheelZoomMode() == self.ZOOM_BEHAVIOR.SMOOTH then
		return true;
	end

	if delta > 0 then
		if self:IsAtMaxZoom() then
			return false;
		end

		if self:ShouldZoomInstantly() then
			return true;
		end

		if self:IsZoomingIn() then
			return false;
		end
	else
		if self:IsAtMinZoom() then
			return false;
		end

		if self:ShouldZoomInstantly() then
			return true;
		end

		if self:IsZoomingOut() then
			return false;
		end
	end
	return true;
end

function DatamineMapControllerMixin:WouldCursorPositionBeClick(button, cursorX, cursorY)
	local mouseButtonInfo = self.MouseButtonInfo[button];
	if mouseButtonInfo and mouseButtonInfo.Down and mouseButtonInfo.StartY then
		local MAX_DIST_FOR_CLICK_SQ = 20;
		local deltaX, deltaY = cursorX - mouseButtonInfo.StartX, cursorY - mouseButtonInfo.StartY;
		return deltaX * deltaX + deltaY * deltaY <= MAX_DIST_FOR_CLICK_SQ;
	end
	return false;
end

---- getters/setters

function DatamineMapControllerMixin:SetCurrentScroll(x, y)
    if not self.CurrentScroll then
        self.CurrentScroll = CreateVector2D(x, y);
    else
        if not x and not y then
            self.CurrentScroll.x = nil;
            self.CurrentScroll.y = nil;
        else
            if x then
                self.CurrentScroll.x = x;
            end
            if y then
                self.CurrentScroll.y = y;
            end
        end
    end
end

function DatamineMapControllerMixin:GetCurrentScroll()
    return self.CurrentScroll;
end

--

function DatamineMapControllerMixin:SetTargetScroll(x, y)
    if not self.TargetScroll then
        self.TargetScroll = CreateVector2D(x, y);
    else
        if not x and not y then
            self.TargetScroll.x = nil;
            self.TargetScroll.y = nil;
        else
            if x then
                self.TargetScroll.x = x;
            end
            if y then
                self.TargetScroll.y = y;
            end
        end
    end
end

function DatamineMapControllerMixin:GetTargetScroll()
    return self.TargetScroll; -- since we set this first in OnLoad, not worried about this being nil;
end

--

function DatamineMapControllerMixin:SetScalingMode(scalingMode)
    self.ScalingMode = scalingMode;
end

function DatamineMapControllerMixin:GetScalingMode()
    return self.ScalingMode;
end

--

function DatamineMapControllerMixin:SetMouseWheelZoomMode(zoomMode)
    self.MouseWheelZoomMode = zoomMode;
end

function DatamineMapControllerMixin:GetMouseWheelZoomMode()
    return self.MouseWheelZoomMode;
end

--

function DatamineMapControllerMixin:SetNormalizedLerpAmount(type, value)
    self.NormalizedLerpAmounts[type] = value;
end

function DatamineMapControllerMixin:GetNormalizedLerpAmount(type)
    return self.NormalizedLerpAmounts[type];
end

--

function DatamineMapControllerMixin:SetZoomAmountPerMouseWheelDelta(zoomAmount)
    self.ZoomAmountPerMouseWheelDelta = zoomAmount;
end

function DatamineMapControllerMixin:GetZoomAmountPerMouseWheelDelta()
    return self.ZoomAmountPerMouseWheelDelta;
end

-----------

function DatamineMapControllerMixin:OnMapChanged()
    self:SetEnabled(false);
end

function DatamineMapControllerMixin:OnMapLoaded(...)
    self:SetEnabled(true);
    self:CreateZoomLevels();
    self:CalculateScaleExtents();
	self:CalculateScrollExtents();

    local fmt = "TargetScale: %d\nScrollXExtentsMin: %d\nScrollXExtentsMax: %d\n\nScrollYExtentsMin: %d\nScrollYExtentsMax: %d";
    print(format(fmt, self.TargetScale, self.scrollXExtentsMin, self.scrollXExtentsMax, self.scrollYExtentsMin, self.scrollYExtentsMax));

    self:ResetZoom();
end

-----------

function DatamineMapControllerMixin:CreateZoomLevels()
	self.BaseScale = 1;

	local currentScale = 1;
	local MIN_SCALE_DELTA = 0.01;  -- zoomLevels must have increasing scales
	self.ZoomLevels = {};

	for zoomLevelIndex = 0, NUM_ZOOM_LEVELS - 1 do
		currentScale = math.max(MIN_CANVAS_ZOOM + ZOOM_STEP * zoomLevelIndex, currentScale + MIN_SCALE_DELTA);
		local desiredScale = currentScale * self.BaseScale;
		if desiredScale == 0 then
			desiredScale = 1;
		end

		table.insert(self.ZoomLevels, { Scale = desiredScale })
	end
end

function DatamineMapControllerMixin:CalculateScaleExtents()
	local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange();
	self.TargetScale = Clamp(self.TargetScale or nextZoomOutScale, nextZoomOutScale, nextZoomInScale);
end

function DatamineMapControllerMixin:CalculateScrollExtents()
	self.scrollXExtentsMin, self.scrollXExtentsMax, self.scrollYExtentsMin, self.scrollYExtentsMax = self:CalculateScrollExtentsAtScale(self:GetCanvasScale());
end

function DatamineMapControllerMixin:CalculateScrollExtentsAtScale(scale)
	local xOffset = self:NormalizeHorizontalSize((self:GetWidth() * .5) / scale);
	local yOffset = self:NormalizeVerticalSize((self:GetHeight() * .5) / scale);
	return 0.0 + xOffset, 1.0 - xOffset, 0.0 + yOffset, 1.0 - yOffset;
end

local MOUSE_DELTA_SAMPLES = 100;
local MOUSE_DELTA_FACTOR = 250;
function DatamineMapControllerMixin:AccumulateMouseDeltas(elapsed, deltaX, deltaY)
	-- If the mouse changes direction then clear out the old values so it doesn't slide the wrong direction
	if deltaX > 0 and self.AccumulatedMouseDeltaX < 0 or deltaX < 0 and self.AccumulatedMouseDeltaX > 0 then
		self.AccumulatedMouseDeltaX = 0.0;
	end

	if deltaY > 0 and self.AccumulatedMouseDeltaY < 0 or deltaY < 0 and self.AccumulatedMouseDeltaY > 0 then
		self.AccumulatedMouseDeltaY = 0.0;
	end

	local normalizedSamples = MOUSE_DELTA_SAMPLES * elapsed * 60;
	self.AccumulatedMouseDeltaX = (self.AccumulatedMouseDeltaX / normalizedSamples) + (deltaX * MOUSE_DELTA_FACTOR) / normalizedSamples;
	self.AccumulatedMouseDeltaY = (self.AccumulatedMouseDeltaY / normalizedSamples) + (deltaY * MOUSE_DELTA_FACTOR) / normalizedSamples;
end

function DatamineMapControllerMixin:SetShouldZoomInOnClick(shouldZoomInOnClick)
	self.shouldZoomInOnClick = shouldZoomInOnClick;
end

function DatamineMapControllerMixin:ShouldZoomInOnClick()
	return not not self.shouldZoomInOnClick;
end

function DatamineMapControllerMixin:SetShouldNavigateOnClick(shouldNavigateOnClick)
	self.shouldNavigateOnClick = shouldNavigateOnClick;
end

function DatamineMapControllerMixin:ShouldNavigateOnClick()
	return not not self.shouldNavigateOnClick;
end

-- Optional limiter related to shouldNavigateOnClick checks.
function DatamineMapControllerMixin:SetShouldNavigateIgnoreZoneMapPositionData(ignoreZoneMapPositionData)
	self.ignoreZoneMapPositionData = ignoreZoneMapPositionData;
end

function DatamineMapControllerMixin:ShouldNavigateIgnoreZoneMapPositionData()
	return not not self.ignoreZoneMapPositionData;
end

function DatamineMapControllerMixin:SetShouldPanOnClick(shouldPanOnClick)
	self.shouldPanOnClick = shouldPanOnClick;
end

function DatamineMapControllerMixin:ShouldPanOnClick()
	return not not self.shouldPanOnClick;
end

function DatamineMapControllerMixin:SetShouldZoomInstantly(shouldZoomInstantly)
	self.shouldZoomInstantly = shouldZoomInstantly;
end

function DatamineMapControllerMixin:ShouldZoomInstantly()
	return not not self.shouldZoomInstantly;
end

function DatamineMapControllerMixin:GetMaxZoomViewRect()
	return self:CalculateViewRect(self:GetScaleForMaxZoom());
end

function DatamineMapControllerMixin:GetMinZoomViewRect()
	return self:CalculateViewRect(self:GetScaleForMinZoom());
end

function DatamineMapControllerMixin:CalculateViewRect(scale)
	local childWidth, childHeight = self.Canvas:GetSize();
	local left = self:GetHorizontalScroll() / childWidth;
	local right = left + (self:GetWidth() / scale) / childWidth;
	local top = self:GetVerticalScroll() / childHeight;
	local bottom = top + (self:GetHeight() / scale) / childHeight;
	return CreateRectangle(left, right, top, bottom);
end

function DatamineMapControllerMixin:CalculateZoomScaleAndPositionForAreaInViewRect(left, right, top, bottom, subViewLeft, subViewRight, subViewTop, subViewBottom)
	local childWidth, childHeight = self.Canvas:GetSize();
	local viewWidth, viewHeight = self:GetSize();

	-- this is the desired width/height of the full view given the desired positions for the subview
	local fullWidth = (right - left) / (subViewRight - subViewLeft);
	local fullHeight = (bottom - top) / (subViewTop - subViewBottom);

	local scale = ( viewWidth / fullWidth ) / childWidth;

	-- translate from the upper-left of the subview to the center of the view.
	local fullLeft = left - (fullWidth * subViewLeft);
	local fullBottom = (1.0 - bottom) - (fullHeight * subViewBottom);

	local fullCenterX = fullLeft + (fullWidth / 2);
	local fullCenterY = 1.0 - (fullBottom + (fullHeight / 2));

	return scale, fullCenterX, fullCenterY;
end

function DatamineMapControllerMixin:SetPanTarget(normalizedX, normalizedY)
	self:SetTargetScroll(normalizedX, normalizedY);
end

function DatamineMapControllerMixin:SetZoomTarget(zoomTarget)
	self.ZoomTarget = zoomTarget;
	self.TargetScale = Clamp(zoomTarget, self:GetScaleForMinZoom(), self:GetScaleForMaxZoom());
end

function DatamineMapControllerMixin:ZoomIn()
	local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange();
	if nextZoomInScale > self:GetCanvasScale() then
		if self:ShouldZoomInstantly() then
			local targetScroll = self:GetTargetScroll();
			self:InstantPanAndZoom(nextZoomOutScale, targetScroll.x, targetScroll.y);
		else
			self:SetZoomTarget(nextZoomInScale);
		end
	end
end

function DatamineMapControllerMixin:ZoomOut()
	local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange();
	if nextZoomOutScale < self:GetCanvasScale() then
		if self:ShouldZoomInstantly() then
            local targetScroll = self:GetTargetScroll();
			self:InstantPanAndZoom(nextZoomOutScale, targetScroll.x, targetScroll.y);
		else
			self:SetZoomTarget(nextZoomOutScale);
			self:SetPanTarget(0.5, 0.5);
		end
	end
end

function DatamineMapControllerMixin:ResetZoom()
    self:InstantPanAndZoom(self.ZoomLevels[1].Scale, 0.5, 0.5);
end

function DatamineMapControllerMixin:InstantPanAndZoom(scale, panX, panY, ignoreScaleRatio)
	if not ignoreScaleRatio then
		local scaleRatio = self:GetCanvasScale() / scale;
        local currentScroll = self:GetCurrentScroll();
		panX = Lerp(panX, currentScroll.x or .5, scaleRatio);
		panY = Lerp(panY, currentScroll.y or .5, scaleRatio);
	end

	self.CurrentScale = scale;
	self.TargetScale = self.CurrentScale;
	self.Canvas:SetScale(self.CurrentScale);
	self:CalculateScrollExtents();

	local targetScrollX = Clamp(panX, self.scrollXExtentsMin, self.scrollXExtentsMax);
	local targetScrollY = Clamp(panY, self.scrollYExtentsMin, self.scrollYExtentsMax);
    self:SetTargetScroll(targetScrollX, targetScrollY);
    self:SetCurrentScroll(targetScrollX, targetScrollY);

	self:SetNormalizedHorizontalScroll(targetScrollX);
	self:SetNormalizedVerticalScroll(targetScrollY);
end

function DatamineMapControllerMixin:IsZoomingIn()
	return self:GetCanvasScale() < self.TargetScale;
end

function DatamineMapControllerMixin:IsZoomingOut()
	return self.TargetScale < self:GetCanvasScale();
end

function DatamineMapControllerMixin:IsAtMaxZoom()
	return self:GetCanvasScale() == self:GetScaleForMaxZoom();
end

function DatamineMapControllerMixin:IsAtMinZoom()
	return self:GetCanvasScale() == self:GetScaleForMinZoom();
end

function DatamineMapControllerMixin:CanPan()
	return self:GetCanvasScale() > self.BaseScale;
end

function DatamineMapControllerMixin:GetScaleForMaxZoom()
	return self.ZoomLevels[#self.ZoomLevels].Scale;
end

function DatamineMapControllerMixin:GetScaleForMinZoom()
	return self.ZoomLevels[1].Scale;
end

function DatamineMapControllerMixin:GetZoomLevelIndexForScale(scale)
	local bestIndex = 1;
	for i, zoomLevel in ipairs(self.ZoomLevels) do
		if scale >= zoomLevel.Scale then
			bestIndex = i;
		else
			break;
		end
	end
	return bestIndex;
end

function DatamineMapControllerMixin:GetCurrentZoomRange()
	local index = self:GetZoomLevelIndexForScale(self:GetCanvasScale());
	local nextZoomOutLevel = self.ZoomLevels[index - 1] or self.ZoomLevels[index];
	local nextZoomInLevel = self.ZoomLevels[index + 1] or self.ZoomLevels[index];
	return nextZoomOutLevel.Scale, nextZoomInLevel.Scale;
end

function DatamineMapControllerMixin:IsPanning()
	return self.MouseButtonInfo.LeftButton.Down and not self:IsZoomingOut() and self:CanPan();
end

function DatamineMapControllerMixin:GetCanvasScale()
	if self.CurrentScale and self.CurrentScale ~= 0 then
		return self.CurrentScale;
	end

	if self.TargetScale and self.TargetScale ~= 0 then
		return self.TargetScale;
	end

	return 1;
end

function DatamineMapControllerMixin:GetCursorPosition()
    local currentX, currentY = GetCursorPosition();
    local effectiveScale = self:GetMapViewer():GetEffectiveScale();
    local x = currentX / effectiveScale;
    local y = currentY / effectiveScale;
    return x, y;
end

function DatamineMapControllerMixin:GetCanvasZoomPercent()
	return PercentageBetween(self:GetCanvasScale(), self:GetScaleForMinZoom(), self:GetScaleForMaxZoom());
end

function DatamineMapControllerMixin:SetNormalizedHorizontalScroll(scrollAmount)
	local offset = self:DenormalizeHorizontalSize(scrollAmount);
	self:SetHorizontalScroll(offset - (self:GetWidth() * .5) / self:GetCanvasScale());
end

function DatamineMapControllerMixin:GetNormalizedHorizontalScroll()
	return (2.0 * self:GetHorizontalScroll() * self:GetCanvasScale() + self:GetWidth()) / (2.0 * self.Canvas:GetWidth() * self:GetCanvasScale());
end

function DatamineMapControllerMixin:SetNormalizedVerticalScroll(scrollAmount)
	local offset = self:DenormalizeVerticalSize(scrollAmount);
	self:SetVerticalScroll(offset - (self:GetHeight() * .5) / self:GetCanvasScale());
end

function DatamineMapControllerMixin:GetNormalizedVerticalScroll()
	return (2.0 * self:GetVerticalScroll() * self:GetCanvasScale() + self:GetHeight()) / (2.0 * self.Canvas:GetHeight() * self:GetCanvasScale());
end

function DatamineMapControllerMixin:NormalizeHorizontalSize(size)
	return size / self.Canvas:GetWidth();
end

function DatamineMapControllerMixin:DenormalizeHorizontalSize(size)
	return size * self.Canvas:GetWidth();
end

function DatamineMapControllerMixin:NormalizeVerticalSize(size)
	return size / self.Canvas:GetHeight();
end

function DatamineMapControllerMixin:DenormalizeVerticalSize(size)
	return size * self.Canvas:GetHeight();
end

function DatamineMapControllerMixin:GetNormalizedMouseDelta(button)
	local mouseButtonInfo = self.MouseButtonInfo[button];
	if mouseButtonInfo and mouseButtonInfo then
		local currentX, currentY = self:GetCursorPosition();
		return self:NormalizeHorizontalSize(mouseButtonInfo.LastX - currentX) / self:GetCanvasScale(), self:NormalizeVerticalSize(currentY - mouseButtonInfo.LastY) / self:GetCanvasScale();
	end
	return 0.0, 0.0;
end

function DatamineMapControllerMixin:GetNormalizedCursorPosition()
	local x, y = self:GetCursorPosition();
	return self:NormalizeUIPosition(x, y);
end

-- Normalizes a global UI position to the map canvas
function DatamineMapControllerMixin:NormalizeUIPosition(x, y)
	local scale = self:GetCanvasScale() or 1;
	if scale == 0 then
		scale = 1;
	end

	local left = self.Canvas:GetLeft() or 0;
	local top = self.Canvas:GetTop() or 0;

	return Saturate(self:NormalizeHorizontalSize(x / scale - left)),
		   Saturate(self:NormalizeVerticalSize(top - y / scale));
end

------------

function DatamineMapControllerMixin:GetMapViewer()
    return self:GetParent();
end

------------

function DatamineMapControllerMixin:GetDisplayedWDT()
    return self.Canvas:GetDisplayedWDT();
end

function DatamineMapControllerMixin:LoadWDT(wdtID)
    self.Canvas:LoadMapByWdtID(wdtID);
end

function DM_TEST()
    DatamineUnifiedFrame:Toggle();
    DatamineUnifiedFrame.Workspace:SetMode(5);
    TEST_CONTROLLER:LoadWDT(775971);
end