Datamine = {};

Datamine.Constants = {
    AddonName = "Datamine",
};

Datamine.Mixins = {};

Datamine.Console = LibStub:GetLibrary("LibDevConsole");

-- utilities

function Datamine.GetEnumValueName(enum, value)
    local GetName = EnumUtil.GenerateNameTranslation(enum);
    return GetName(value);
end

-- chat output

local function GeneratePrintPrefix(moduleName, addNewLine)
    local prefix;
    local color = "FFF542F5"

    if not moduleName then
        prefix = "|c" .. color .. Datamine.Constants.AddonName .. "|r: ";
    else
        prefix = "|c" .. color .. Datamine.Constants.AddonName .. "|r.|c" .. color .. moduleName .. "|r: ";
    end

    if addNewLine then
        return prefix .. "\n";
    else
        return prefix;
    end
end

local function GenerateDumpPrefix(moduleName, tableTitle)
    local prefix = GeneratePrintPrefix(moduleName);

    if tableTitle then
        return prefix .. tableTitle .. "\n";
    else
        return prefix .. "\n";
    end
end

function Datamine.Print(module, ...)
    if not ... then
        return;
    end

    local message;
    local newTable = {};
    for _, v in ipairs({...}) do
        if v then
            local str = tostring(v);
            table.insert(newTable, str);
        end
    end
    message = strjoin(", ", unpack(newTable));

    local prefix = GeneratePrintPrefix(module);
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