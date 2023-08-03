SLASH_DMINE1, SLASH_DMINE2 = "/dm", "/datamine"

local Print = function(...)
    Datamine.Print("Slash", ...);
end

Datamine.Slash = {};
Datamine.Slash.Commands = {};

function Datamine.Slash:RegisterCommand(cmd, func)
    self.Commands[cmd] = func;
end

function SlashCmdList.DMINE(msg)
    local args = {strsplit(" ", msg)};
    local cmd = args[1];
    if not cmd then
        Print("You gotta give me something, man.");
        return;
    end
    table.remove(args, 1);

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