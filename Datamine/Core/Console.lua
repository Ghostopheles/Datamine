---@type LibDevConsole
local console = LibStub:GetLibrary("LibDevConsole");

local commandType = Enum.ConsoleCommandType;
local commandCategory = Enum.ConsoleCategory;

local function PreviewCustomizationChoice(optionID, choiceID)
    if not BarberShopFrame or not BarberShopFrame:IsShown() then
        console.AddError("Barber shop must be open to preview customizations.");
        return false;
    end

    optionID, choiceID = tonumber(optionID), tonumber(choiceID);
    if not optionID then
        console.AddError("Invalid option ID.");
        return false;
    elseif not choiceID then
        console.AddError("Invalid choice ID.");
        return false;
    end

    C_BarberShop.PreviewCustomizationChoice(optionID, choiceID);
    console.AddMessage("Appearance updated.");
    return true;
end

local function SetDressState(dressState)
    if not BarberShopFrame or not BarberShopFrame:IsShown() then
        console.AddError("Barber shop must be open to run this command.");
        return false;
    end

    dressState = (strtrim(dressState) == "1");
    C_BarberShop.SetModelDressState(dressState);
    return true;
end

local function SetChrModel(number)
    number = tonumber(number);
    if not number then
        console.AddError("Please provide a ChrModelID");
    end

    C_BarberShop.SetViewingChrModel(number);
end

local function DumpBuildInfo()
    local buildInfo = {};

    local function AddEntry(key, value)
        tinsert(buildInfo, {key = key, value = value});
    end

    local buildVersion, buildNumber, buildDate, interfaceVersion = GetBuildInfo();
    AddEntry("Version", buildVersion);
    AddEntry("Build", buildNumber);
    AddEntry("Build Date", buildDate);
    AddEntry("Interface", interfaceVersion);
    AddEntry("spacer");
    AddEntry("Public Client", tostring(IsPublicBuild()));
    AddEntry("Test Client", tostring(IsTestBuild()));
    AddEntry("Public Test Client", tostring(IsPublicTestClient()));
    AddEntry("Debug Client", tostring(IsDebugBuild()));
    AddEntry("Windows Client", tostring(IsWindowsClient()));
    AddEntry("Linux Client", tostring(IsLinuxClient()));
    AddEntry("Mac Client", tostring(IsMacClient()));
    AddEntry("GM Client", tostring(IsGMClient()));
    AddEntry("64bit Client", tostring(Is64BitClient()));
    AddEntry("spacer");
    AddEntry("Scripts Allowed", tostring(not C_AddOns.GetScriptsDisallowedForBeta()));
    AddEntry("Supports Clip Cursor", tostring(SupportsClipCursor()));

    local maxKeyLength = 0;
    for _, entry in pairs(buildInfo) do
        if #entry.key > maxKeyLength then
            maxKeyLength = #entry.key;
        end
    end

    local buildInfoString = "Client Build Info:\n";
    local padding = 4; -- in spaces
    local tabLength = 3; -- in spaces
    local tab = string.rep(" ", tabLength);
    for _, entry in ipairs(buildInfo) do
        local key, value = entry.key, entry.value;
        local line;
        if key ~= "spacer" then
            line = string.format("%-" .. (maxKeyLength + padding) .. "s : %s\n", key, value);
        else
            line = string.rep("-", 10) .. "\n";
        end
        buildInfoString = buildInfoString .. tab .. line;
    end

    console.AddEcho(buildInfoString);

    return true, true;
end

local customCommandInfo = {
    {
        command = "PreviewCustomizationChoice",
        help = "Preview a customization option in the barber shop.\n<optionID> <choiceID>\nRequires the barber shop to be open.",
        category = commandCategory.Game,
        commandType = commandType.Script,
        commandFunc = PreviewCustomizationChoice,
    },
    {
        command = "SetDressState",
        help = "Set the dress state of your character in the barber shop.\nRequires the barber shop to be open.",
        category = commandCategory.Game,
        commandType = commandType.Script,
        commandFunc = SetDressState,
    },
    {
        command = "SetChrModel",
        help = "Set barber shop character model.\nRequires the barber shop to be open.",
        category = console.CommandCategory.Debug,
        commandType = console.CommandType.Macro,
        commandFunc = SetChrModel,
    },
    {
        command = "GetBuildInfo",
        help = "Dumps client build info the console.",
        category = console.CommandCategory.Debug,
        commandType = console.CommandType.Macro,
        commandFunc = DumpBuildInfo,
    }
}

for _, command in ipairs(customCommandInfo) do
    console.RegisterCommand(command);
end