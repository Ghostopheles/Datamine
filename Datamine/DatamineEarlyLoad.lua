Datamine = {};

Datamine.Constants = {
    AddonName = "Datamine",
};

Datamine.Mixins = {};

Datamine.Console = LibStub:GetLibrary("LibDevConsole");

local PrintSettings = {
    "hidecolon",
    "addnewline",
    "hideprefix"
};

-- utilities

function Datamine.GetEnumValueName(enum, value)
    local GetName = EnumUtil.GenerateNameTranslation(enum);
    return GetName(value);
end

-- chat output

local function GetDefaultPrintSettings()
    local tbl = {};
    for _, v in pairs(PrintSettings) do
        tbl[v] = false;
    end

    return tbl;
end

local function GeneratePrintPrefix(moduleName, settings)
    local prefix;
    local color = Datamine.Constants.ChatPrefixColor;

    if not moduleName or moduleName == "none" then
        prefix = color:WrapTextInColorCode(Datamine.Constants.AddonName) .. ": ";
    else
        prefix = color:WrapTextInColorCode(Datamine.Constants.AddonName) .. "." .. color:WrapTextInColorCode(moduleName) .. ": ";
    end

    if settings then
        if settings.hidePrefix then
            return "";
        end
        if settings.hideColon then
            prefix = string.gsub(prefix, ":", "");
        end
        if settings.addNewLine then
            prefix = prefix .. "\n";
        end
    end

    return prefix;
end

local function GenerateDumpPrefix(moduleName, tableTitle)
    local prefix = GeneratePrintPrefix(moduleName);

    if tableTitle then
        return prefix .. tableTitle .. "\n";
    else
        return prefix .. "\n";
    end
end

local function IsSettingString(str)
    str = strlower(str);
    return tContains(PrintSettings, str);
end

function Datamine.Print(module, ...)
    if not module and not ... then
        return;
    end

    local message;
    local settings = GetDefaultPrintSettings();
    local newTable = {};
    for _, v in ipairs({...}) do
        if IsSettingString(v) then
            settings[v] = true;
        else
            local str = tostring(v);
            table.insert(newTable, str);
        end
    end
    message = strjoin(", ", unpack(newTable));

    local prefix = GeneratePrintPrefix(module, settings);
    print(prefix .. message);
end

function Datamine.Dump(module, tableTitle, message)
    if type(tableTitle) == "table" then
        message = tableTitle;
        tableTitle = nil;
    end

    local prefix = GenerateDumpPrefix(module, tableTitle);
    print(prefix);
    DevTools_Dump(message);
end

function Datamine.DumpTableWithDisplayKeys(module, tableTitle, displayKeys, message)
    if not message then
        return;
    end

    assert(#displayKeys == #message, "DisplayKeys and Table length mismatch.");

    local prefix = GenerateDumpPrefix(module, tableTitle);
    print(prefix);

    for i, v in ipairs(message) do
        if type(v) ~= "string" then
            v = tostring(v);
        end

        print("|cff88ccff[" .. i .. "] " .. displayKeys[i] .. "|r=\"" .. v .. "\"");
    end
end

function Datamine.WrapTextInParenthesis(text, withLeadingSpace)
    if withLeadingSpace then
        return " (" .. text .. ")";
    else
        return "(" .. text .. ")";
    end
    
end