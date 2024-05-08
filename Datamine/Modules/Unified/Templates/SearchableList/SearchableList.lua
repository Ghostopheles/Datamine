local L = Datamine.Strings;
local Search = Datamine.Search;

---@param timeout number
---@param callback function
---@return function
local function Debounce(timeout, callback)
    local calls = 0;

	local function Decrement()
		calls = calls - 1;

		if calls == 0 then
			callback();
		end
	end

	return function()
		C_Timer.After(timeout, Decrement);
		calls = calls + 1;
	end
end

---@param query string
---@param source table
---@param dataKey? string
---@return DatamineSearchTask searchTask
local function CreateSearchTask(query, source, dataKey)
    local task = Search.CreateSearchTask(query, source, dataKey);
    return task;
end

---@class DatamineSearchableEntryData
---@field Text string
---@field TextScale? number
---@field ID? string | number
---@field Callback? function
---@field NoHighlight? boolean
---@field HideBackground? boolean
---@field BackgroundColor? ColorMixin
---@field BackgroundAlpha? number
---@field SelectionCallback? function

DatamineSearchableEntryMixin = {};

---@param data DatamineSearchableEntryData
function DatamineSearchableEntryMixin:Init(data)
    self.Data = data;
    self:SetText(data.Text, data.TextScale);
    self:SetCallback(data.Callback);
    self:SetNoHighlight(data.NoHighlight);
    self:SetBackground(data.BackgroundColor, data.HideBackground, data.BackgroundAlpha);
    self:SetSelected(data.SelectionCallback);

    self:Show();
end

function DatamineSearchableEntryMixin:OnClick()
    if self.Callback then
        self:Callback();
    end
end

function DatamineSearchableEntryMixin:OnEnter()
    if self.Text:IsTruncated() then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:SetText(self.Text:GetText(), 1, 1, 1, 1);
        GameTooltip:Show();
    end
end

function DatamineSearchableEntryMixin:OnLeave()
    GameTooltip:Hide();
end

function DatamineSearchableEntryMixin:SetCallback(callback)
    self.Callback = callback;
end

function DatamineSearchableEntryMixin:SetNoHighlight(noHighlight)
    local showHighlight;
    if noHighlight ~= nil then
        showHighlight = showHighlight;
    else
        showHighlight = true;
    end

    if showHighlight then
        self.HighlightTexture:SetAllPoints();
    else
        self.HighlightTexture:ClearAllPoints();
    end
end

function DatamineSearchableEntryMixin:SetBackground(backgroundColor, hideBackground, backgroundAlpha)
    if hideBackground then
        self.Background:ClearAllPoints();
        self.Background:Hide();
        return;
    end

    backgroundColor = backgroundColor or DatamineMediumGray;
    self.Background:SetAllPoints();
    self.Background:SetColorTexture(backgroundColor:GetRGB());

    backgroundAlpha = backgroundAlpha or 1;
    self.Background:SetAlpha(backgroundAlpha);
end

function DatamineSearchableEntryMixin:SetText(text, textScale)
    self.Text:SetText(text);

    textScale = textScale or 1;
    self.Text:SetTextScale(textScale);
end

function DatamineSearchableEntryMixin:GetText()
    return self.Text;
end

function DatamineSearchableEntryMixin:SetSelected(selectionCallback)
    if not selectionCallback and not self.Data.SelectionCallback then
        self.SelectionBorder:Hide();
        return;
    end

    local callback = selectionCallback or self.Data.SelectionCallback;
    local isSelected = callback(self.Data);
    self.SelectionBorder:SetShown(isSelected);
end

-------------

DatamineSearchableListMixin = {};

function DatamineSearchableListMixin:OnLoad_Base()
    self.DataProvider = CreateDataProvider();

    self.ScrollView = CreateScrollBoxListLinearView();
    self.ScrollView:SetDataProvider(self.DataProvider);

    local DEFAULT_EXTENT = 20;
    self.ScrollView:SetPanExtent(DEFAULT_EXTENT);
    self.ScrollView:SetElementExtent(DEFAULT_EXTENT);

    local function Initializer(frame, data)
        frame:Init(data);
    end

    self.Template = self.Template or "DatamineSearchableEntryTemplate";
    self.ScrollView:SetElementInitializer(self.Template, Initializer);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, self.ScrollView);

    local anchorsWithScrollBar = {
        CreateAnchor("TOPLEFT", 4, -4);
        CreateAnchor("BOTTOMRIGHT", self.ScrollBar, -13, 4),
    };

    local anchorsWithoutScrollBar = {
        CreateAnchor("TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", -4, 4);
    };

    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar);
end

function DatamineSearchableListMixin:OnSearchStateChanged(state)
    local task = self.SearchTask;
    local progress = task:GetProgress();

    if state == Search.State.FINISHED then
        if progress.Found == 0 then
            self:OnSearchFailed();
        end
        self:OnSearchFinished();
    else
        self.FailHeader:Hide();
        self.FailText:Hide();
    end
end

function DatamineSearchableListMixin:OnSearchTextChanged()
    if not self.SearchSource then
        return;
    end

    local query = self.SearchBox:GetText();
    if not query then
        return;
    end

    if not self.SearchTask then
        self:CreateSearchTask(query);
        self.SearchTask:Start();
    else
        self.SearchTask:SetQuery(query);
    end
end

function DatamineSearchableListMixin:OnResultsChanged(results)
    self.DataProvider:OnResultsChanged(results);
end

function DatamineSearchableListMixin:OnSearchFailed()
    self.FailHeader:Show();
    self.FailText:Show();
end

function DatamineSearchableListMixin:OnSearchFinished()
    self.SearchTask:UnregisterAllCallbacks();
    self.SearchTask = nil;
end

function DatamineSearchableListMixin:CreateSearchTask(query)
    self.SearchTask = CreateSearchTask(query, self.SearchSource, self.SearchDataKey);

    local function UpdateOverlayVisibility()
        local overlay = self.ProgressOverlay;

        if self.SearchTask then
            local state = self.SearchTask:GetState();
            if state == Search.State.RUNNING then
                overlay.AnimOut:Stop();

                if not overlay:IsShown() then
                    local reverse = true;
                    overlay.AnimIn:Play(reverse);
                    overlay.ProgressBar:SetValue(0);
                    overlay:Show();
                end
            elseif state == Search.State.FINISHED and overlay:IsShown() then
                overlay.AnimOut:Play();
            end
        elseif overlay:IsShown() then
            overlay.AnimOut:Play();
        end
    end

    local function UpdateOverlayVisibilityDeferred()
        RunNextFrame(UpdateOverlayVisibility);
    end

    self.SearchTask:RegisterCallback(Search.Events.STATE_CHANGED, UpdateOverlayVisibilityDeferred);

    local function OnProgressChanged(_, progress)
        local overlay = self.ProgressOverlay;
        overlay.ProgressBar:SetSmoothedValue(progress.Searched / progress.Total);
    end

    self.SearchTask:RegisterCallback(Search.Events.PROGRESS_CHANGED, OnProgressChanged);
    self.SearchTask:RegisterCallback(Search.Events.RESULTS_CHANGED, self.OnResultsChanged, self);
    self.SearchTask:RegisterCallback(Search.Events.STATE_CHANGED, self.OnSearchStateChanged, self);
end

function DatamineSearchableListMixin:Reset()
    self.ScrollView:Flush();

    if self.SearchSource then
        self.DataProvider = Search.CreateSearchableDataProvider(self.SearchSource);
    else
        self.DataProvider = CreateDataProvider();
    end

    self.ScrollView:SetDataProvider(self.DataProvider);
    self.SearchTask = nil;
end

function DatamineSearchableListMixin:SetEditBox(editBox)
    assert(not self.SearchBox, "Unable to change searchBox after it's first set");
    self.SearchBox = editBox;
    self.SearchBox:HookScript("OnTextChanged", Debounce(0.25, function() self:OnSearchTextChanged(); end));
end

function DatamineSearchableListMixin:SetSearchDataSource(data, dataKey)
    self.SearchSource = data;
    self.SearchDataKey = dataKey;
    self:Reset();
end

function DatamineSearchableListMixin:SetFailText(header, text)
    self.FailHeader:SetText(header or L.SEARCH_FAILED_HEADER);
    self.FailText:SetText(text or L.SEARCH_FAILED_TEXT);
end