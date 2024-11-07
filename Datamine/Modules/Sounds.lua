local moduleName = "Sounds";
local Print = function(...) Datamine.Utils.Print(moduleName, ...) end;

Datamine.Sounds = CreateFrame("Frame");
Datamine.Sounds:RegisterEvent("SOUNDKIT_FINISHED");
Datamine.Sounds:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end);

Datamine.Sounds.LastSoundKitHandle = nil;

function Datamine.Sounds:SOUNDKIT_FINISHED(soundHandle)
    if Datamine.Sounds.LastSoundKitHandle and Datamine.Sounds.LastSoundKitHandle == soundHandle then
        Print("Sound ended.");
    end

    self.LastSoundKitHandle = nil;
end

function Datamine.Sounds:PlaySoundKit(soundKitID)
    Print("Playing " .. soundKitID .. ".");
    local willPlay, soundHandle = PlaySound(soundKitID, "SFX", true, true);
    if not willPlay then
        Print("Unable to play sound - possibly an invalid soundKitID, muted SFX channel, or the sound is already playing.");
        return;
    end

    self.LastSoundKitHandle = soundHandle;
end

function Datamine.Sounds:PlaySoundFile(fileDataID)
    Print("Playing sound file " .. fileDataID .. ".");
    local willPlay, _ = PlaySoundFile(fileDataID);
    if not willPlay then
        Print("Invalid fileDataID or SFX channel is muted.");
        return;
    end
end

do
    local helpMessage = "Play a soundfile by SoundKitID.";
    local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<soundKitID>", helpMessage);

    Datamine.Slash:RegisterCommand("soundkit", function(soundKitID) Datamine.Sounds:PlaySoundKit(soundKitID) end, helpString, moduleName);
end

do
    local helpMessage = "Play a soundfile by FileDataID.";
    local helpString = Datamine.Slash.GenerateHelpStringWithArgs("<fileDataID>", helpMessage);

    Datamine.Slash:RegisterCommand("soundfile", function(fileDataID) Datamine.Sounds:PlaySoundFile(fileDataID) end, helpString, moduleName);
end