SLASH_DMINE1, SLASH_DMINE2 = "/dm", "/datamine"

local Print = function(...)
    Datamine.Print("Slash", ...);
end

local RawPrint = function(...)
    Datamine.Print("none", ...);
end

Datamine.Slash = {};
Datamine.Slash.Commands = {};
Datamine.Slash.Help = {};
Datamine.Slash.HelpTextColor = "FF2FF05F";
Datamine.Slash.ArgumentColor = "FF3D90EE";

function Datamine.Slash.GenerateHelpStringWithArgs(args, helpText)
    local argColor = Datamine.Slash.ArgumentColor;
    local argString = string.format("|c%s%s|r %s", argColor, args, helpText);

    return argString;
end

function Datamine.Slash.HelpCommand()
    local self = Datamine.Slash;
    local prefixColor = Datamine.Constants.ChatPrefixColor;
    local preamble = "list of commands:";
    local lineFormat = "%s %s |c%s%s|r";

    RawPrint("hideColon", preamble);

    -- always print the help line first
    local helpLine = string.format(lineFormat, prefixColor:WrapTextInColorCode(SLASH_DMINE1), "help", Datamine.Slash.HelpTextColor, self.Help["help"]);
    RawPrint(helpLine);

    for cmd, _ in pairs(self.Commands) do
        if cmd ~= "help" then
            local line = string.format(lineFormat, prefixColor:WrapTextInColorCode(SLASH_DMINE1), cmd, Datamine.Slash.HelpTextColor, self.Help[cmd]);
            RawPrint(line);
        end
    end
end

UnitPower("player", 2);

function Datamine.Slash:RegisterCommand(cmd, func, help)
    assert(self.Commands[cmd] == nil, "Attempted to register duplicate command.");
    self.Commands[cmd] = func;

    if not help then
        help = "No help message provided.";
    end

    self.Help[cmd] = help;
end

Datamine.Slash:RegisterCommand("help", Datamine.Slash.HelpCommand, "Show this message.");

function SlashCmdList.DMINE(msg)
    local args = {strsplit(" ", msg)};
    local cmd = args[1];
    if not cmd then
        Print("You gotta give me something, man.");
        return;
    end
    table.remove(args, 1);

    if strtrim(cmd) == "" then
        cmd = "help";
    end

    local func = Datamine.Slash.Commands[cmd];
    if not func then
        Print("Unknown command: " .. cmd);
        return;
    end

    local _, result = pcall(func, unpack(args));
    if result then
	    Print(result);
    end
end