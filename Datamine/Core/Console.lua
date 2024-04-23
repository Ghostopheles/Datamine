---@type LibDevConsole
local console = Datamine.Console;

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
    local buildVersion, buildNumber, buildDate, interfaceVersion = GetBuildInfo();
    local publicBuild = tostring(IsPublicBuild());
    local testBuild = tostring(IsTestBuild());
    local debugBuild = tostring(IsDebugBuild());
    local windowsClient = tostring(IsWindowsClient());
    local linuxClient = tostring(IsLinuxClient());
    local macClient = tostring(IsMacClient());
    local GMClient = tostring(IsGMClient());
    local bit64Client = tostring(Is64BitClient());
    local scriptsAllowed = tostring(not C_AddOns.GetScriptsDisallowedForBeta());

    local buildInfoStringFormat = [[Client Build Info
      Version:          %s
      Build:            %s
      Build Date:       %s
      Interface:        %s
      Public Build:     %s
      Test Build:       %s
      Debug Build:      %s
      Windows Client:   %s
      Linux Client:     %s
      Mac Client:       %s
      GM Client:        %s
      64bit Client:     %s
      Scripts Allowed:  %s]]

    local buildInfoString = format(buildInfoStringFormat,
        buildVersion,
        buildNumber,
        buildDate,
        interfaceVersion,
        publicBuild,
        testBuild,
        debugBuild,
        windowsClient,
        linuxClient,
        macClient,
        GMClient,
        bit64Client,
        scriptsAllowed
    );

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