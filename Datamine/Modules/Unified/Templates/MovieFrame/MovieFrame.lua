local moduleName = "Theater";
local L = Datamine.Strings;

local Print = function(...)
    Datamine.Utils.Print(moduleName, ...);
end;

---TODO: create a static popup style error message window for play errors

--------------

local START_MOVIE_ERR_CODES = {
    SUCCESS = 0,
    CODEC_FAILURE = 1,
    DATA_MISSING = 2,
    FILE_READ_FAILED = 3,
    FILE_OPEN_FAILED = 4,
};

local START_MOVIE_ERR_STRINGS = tInvert(START_MOVIE_ERR_CODES);

--------------

DatamineMovieFrameMixin = {};

function DatamineMovieFrameMixin:OnHide()
    self:Stop();
end

function DatamineMovieFrameMixin:OnEvent(event, ...)
    if type(self[event]) == "function" then
        self[event](self, ...);
    end
end

function DatamineMovieFrameMixin:OnUpdate(deltaTime)
    MovieFrame_OnUpdate(self, deltaTime);
end

function DatamineMovieFrameMixin:OnMovieFinished()
    self:Stop();
end

function DatamineMovieFrameMixin:ShouldLoop()
    return self:GetParent():GetLoopMovie();
end

-- anchorToSelf essentially just means - should the subtitles be anchored to our MovieFrame or the default one
function DatamineMovieFrameMixin:UpdateSubtitlesAnchor(anchorToSelf)
    if anchorToSelf then
        SubtitlesFrame:SetPoint("BOTTOMLEFT", self);
        SubtitlesFrame:SetPoint("BOTTOMRIGHT", self);

        self.SubtitlesOriginalStrata = SubtitlesFrame:GetFrameStrata();
        SubtitlesFrame:SetFrameStrata("FULLSCREEN");
    else
        SubtitlesFrame:SetPoint("BOTTOMLEFT");
        SubtitlesFrame:SetPoint("BOTTOMRIGHT");
        if self.SubtitlesOriginalStrata then
            SubtitlesFrame:SetFrameStrata(self.SubtitlesOriginalStrata);
        end
    end
end

function DatamineMovieFrameMixin:Play(movieID, byName, resolution)
    self:Show();

    local success, errorCode;
    if byName then
        -- this doesn't work but hey it's here I guess?
        success, errorCode = self:StartMovieByName(movieID, self:ShouldLoop(), resolution);
    else
        success, errorCode = self:StartMovie(movieID, self:ShouldLoop());
    end

    if success then
        local canCancel = true;
        CinematicStarted(Enum.CinematicType.GameMovie, movieID, canCancel);
    else
        self:HandlePlayError(errorCode, movieID);
        return success, errorCode;
    end

    self:UpdateSubtitlesAnchor(true);
    EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicPlay", self);

    return success, errorCode;
end

-- this function does nothing because :StartMovieByName is non-functional
function DatamineMovieFrameMixin:PlayByName(movieName, resolution)
    error(":PlayByName is not supported. Please just use :Play.");
    local byName = true;
    return self:Play(movieName, byName, resolution);
end

function DatamineMovieFrameMixin:Stop(userCancel, errorCode)
    self:StopMovie();
    local didError = errorCode ~= nil;
    CinematicFinished(Enum.CinematicType.GameMovie, userCancel, didError);

    if self:IsShown() then
        self:Hide();
    end

    self:UpdateSubtitlesAnchor(false);
    EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicStop");
end

function DatamineMovieFrameMixin:HandlePlayError(errorCode, movieID)
    StaticPopup_Show("ERROR_CINEMATIC");
    local errString = format(L.THEATER_MODE_ERR_PLAY_FAILED, movieID, errorCode, START_MOVIE_ERR_STRINGS[errorCode]);
    Print(errString); -- TODO: Replace with error popup window
    self:Stop(false, errorCode);
end

--------------

DatamineMovieControlsMixin = {};

function DatamineMovieControlsMixin:OnLoad()
    self.minimumWidth = 150;
    self.maximumWidth = 300;

    self.minimumHeight = 150;
    self.maximumHeight = 650;

    self.topPadding = 2;
    self.bottomPadding = 5;
    self.leftPadding = 5;
    self.rightPadding = 5;

    self.Label:SetText(L.THEATER_MODE_CONTROLS_TITLE);

    self.MovieIDEntryBox:SetWidth(self:GetWidth() - 10);
    self.MovieIDEntryBox.LabelText = L.THEATER_MODE_MOVIE_ID;
    self.MovieIDEntryBox.Instructions:SetText(L.THEATER_MODE_MOVIE_ID_EB_INSTRUCTIONS);

    self.SubtitleToggle.Text:SetText(L.THEATER_MODE_SUBTITLE_TOGGLE);
    self.SubtitleToggle:HookScript("OnClick", function()
        self:GetParent():SetEnableSubtitles(self.SubtitleToggle:GetChecked());
    end);

    self.LoopToggle.Text:SetText(L.THEATER_MODE_LOOP_TOGGLE);
    self.LoopToggle:HookScript("OnClick", function()
        self:GetParent():SetLoopMovie(self.SubtitleToggle:GetChecked());
    end);

    self.MiniControls.StopButton.Icon:SetCustomAtlas("custom-toolbar-pause");

    self.MinimizeButton:SetScript("OnClick", function()
        self:GetParent():CollapseControls();
    end);

    self:MarkDirty();
end

function DatamineMovieControlsMixin:OnShow()
    local parent = self:GetParent();
    self.SubtitleToggle:SetChecked(parent:GetEnableSubtitles());
    self.LoopToggle:SetChecked(parent:GetLoopMovie());
end

--------------

DatamineTheaterTabMixin = {};

function DatamineTheaterTabMixin:OnLoad()
    self.MovieControls.MovieIDEntryBox.Callback = function(number)
        return self:LoadAndPlayMovie(number);
    end;

    self:SetEnableSubtitles(true);
    self:SetLoopMovie(false);

    self.MovieControlsToggle:SetScript("OnClick", function()
        self:ExpandControls();
    end);

    self.LoadingBar:SetScale(1.2);
    self.LoadingBar:SetMinMaxSmoothedValue(0, 100);
    self.LoadingBar.LoadingText:SetText(L.THEATER_MODE_LOADING_MOVIE);
    self.LoadingBar.Label:SetText(L.THEATER_MODE_DOWNLOAD_PROGRESS);

    self.LoadingBar:SetValue(0);
end

function DatamineTheaterTabMixin:OnUpdate()
    if self.PreloadingMovie then
        local _, downloaded, total = GetMovieDownloadProgress(self.PreloadingMovie);
        local percentage = (downloaded / total) * 100;
        self:UpdateLoadingBar(percentage);
        if downloaded == total then
            self:OnMovieDownloaded(self.PreloadingMovie);
            self.PreloadingMovie = nil;
        end
    end
end

function DatamineTheaterTabMixin:UpdateLoadingBar(newValue)
    if not self.LoadingBar:IsShown() then
        self.LoadingBar:Show();
    end

    self.LoadingBar:SetSmoothedValue(newValue);
    local label = format(L.THEATER_MODE_DOWNLOAD_PROGRESS, newValue);
    self.LoadingBar.Label:SetText(label);
end

function DatamineTheaterTabMixin:OnMovieDownloaded(movieID)
    if self.PlayAfterLoad then
        self:Play(movieID);
        self.PlayAfterLoad = false;
    end

    self:UpdateLoadingBar(0);
    self.LoadingBar:Hide();
end

function DatamineTheaterTabMixin:PreloadMovie(movieID)
    self.PreloadingMovie = movieID;
    PreloadMovie(movieID);
end

function DatamineTheaterTabMixin:LoadAndPlayMovie(movieID)
    if not IsMoviePlayable(movieID) then
        Print(format(L.THEATER_MODE_ERR_INVALID_MOVIE, movieID)); -- TODO: Replace with error popup window
        return false;
    end

    self:CollapseControls();
    self.PlayAfterLoad = true;
    self:PreloadMovie(movieID);

    return true;
end

function DatamineTheaterTabMixin:Play(movieID)
    self.MovieFrame:Play(movieID);
end

function DatamineTheaterTabMixin:Stop()
    self.MovieFrame:Stop();
    self.MovieControls.MovieIDEntryBox:SetText("");
end

function DatamineTheaterTabMixin:CollapseControls()
    self.MovieControls:Hide();
    self.MovieControlsToggle:Show();
    self.MovieControlsToggle:Enable();
end

function DatamineTheaterTabMixin:ExpandControls()
    self.MovieControls:Show();
    self.MovieControlsToggle:Hide();
    self.MovieControlsToggle:Disable();
end

function DatamineTheaterTabMixin:SetEnableSubtitles(enableSubtitles)
    self.EnableSubtitles = enableSubtitles;
    self.MovieFrame:EnableSubtitles(self.EnableSubtitles);
end

function DatamineTheaterTabMixin:GetEnableSubtitles()
    return self.EnableSubtitles;
end

function DatamineTheaterTabMixin:SetLoopMovie(loopMovie)
    self.LoopMovie = loopMovie;
end

function DatamineTheaterTabMixin:GetLoopMovie()
    return self.LoopMovie;
end

--------------