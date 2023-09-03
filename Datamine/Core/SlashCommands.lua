SLASH_DMINE1, SLASH_DMINE2 = "/dm", "/datamine"

local Print = function(...)
    Datamine.Print("Slash", ...);
end

local RawPrint = function(...)
    Datamine.Print("none", ...);
end

local DEFAULT_MODULE_NAME = "None";

Datamine.Slash = {};
Datamine.Slash.Commands = {};
Datamine.Slash.Help = {};
Datamine.Slash.HelpTextColor = "FF2FF05F";
Datamine.Slash.ArgumentColor = "FF3D90EE";
Datamine.Slash.HeaderColor = "FF42F5AA";

function Datamine.Slash.GenerateHelpStringWithArgs(args, helpText)
    local argColor = Datamine.Slash.ArgumentColor;
    local argString = string.format("|c%s%s|r %s", argColor, args, helpText);

    return argString;
end

function Datamine.Slash.HelpCommand(module)
    local self = Datamine.Slash;
    local prefixColor = Datamine.Constants.ChatPrefixColor;
    local preamble = "list of commands:";
    local lineFormat = "    %s %s |c%s%s|r";
    local headerFormat = "Module: |c%s%s|r ->";

    RawPrint("hideColon", preamble);

    for moduleName, moduleHelp in pairs(self.Help) do
        if moduleName == DEFAULT_MODULE_NAME then
            moduleName = "Default";
        end

        if (not module) or (module and (strlower(moduleName) == strlower(module))) then
            local header = string.format(headerFormat, Datamine.Slash.HelpTextColor, moduleName);
            RawPrint("hideColon", header);

            -- always print the help line first
            if moduleName == "Default" then
                local helpLineText = self.Help["None"]["help"];
                local helpLine = string.format(lineFormat, prefixColor:WrapTextInColorCode(SLASH_DMINE1), "help", Datamine.Slash.HelpTextColor, helpLineText);
                RawPrint("hidePrefix", helpLine);
            end

            for cmd, helpText in pairs(moduleHelp) do
                if cmd ~= "help" then
                    local line = string.format(lineFormat, prefixColor:WrapTextInColorCode(SLASH_DMINE1), cmd, Datamine.Slash.HelpTextColor, helpText);
                    RawPrint("hidePrefix", line);
                end
            end
        end
    end
end



function Datamine.Slash:RegisterCommand(cmd, func, help, moduleName)
    assert(self.Commands[cmd] == nil, "Attempted to register duplicate command.");
    self.Commands[cmd] = func;

    if not help then
        help = "No help message provided.";
    end

    moduleName = moduleName or DEFAULT_MODULE_NAME;

    local moduleHelp = self.Help[moduleName] or {};
    moduleHelp[cmd] = help;

    self.Help[moduleName] = moduleHelp;
end

do
	local helpMessage = "Show this message. Optionally, provide a module name to view commands for that module.";
	local helpString = Datamine.Slash.GenerateHelpStringWithArgs("[<moduleName>]", helpMessage);

	Datamine.Slash:RegisterCommand("help", Datamine.Slash.HelpCommand, helpString);
end



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