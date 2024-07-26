local addonName, Datamine_Internal = ...;

Datamine = {};

Datamine.Constants = {};
Datamine.Constants.AddonName = addonName;
Datamine.Constants.DataTypes = {
    Item = 1,
    Spell = 2,
    Achievement = 3,
};

Datamine.Utils = {};
Datamine.Console = LibStub:GetLibrary("LibDevConsole");
Datamine.Debug = {};

--@debug
Datamine.Debug.DebugEnabled = true;
--@end-debug@

--[===[@non-debug@
Datamine.Debug.DebugEnabled = false;
--@end-non-debug@]===]

function Datamine_OnAddonCompartmentClick()
    DatamineUnifiedFrame:Toggle();
end

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

function Datamine.Utils.GetStringFromDataType(dataType)
    local rev = tInvert(Datamine.Constants.DataTypes);
    return rev[dataType];
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

function Datamine.DumpTableWithDisplayKeys(module, tableTitle, displayKeys, message, showQuotes)
    if not message then
        return;
    end

    if displayKeys then
        assert(#displayKeys == #message, "DisplayKeys and Table length mismatch.");
    end

    local prefix = GenerateDumpPrefix(module, tableTitle);
    print(prefix);

    local i = 1;
    for k, v in pairs(message) do
        if type(v) ~= "string" then
            v = tostring(v);
        end

        local valueString = "|r=\"" .. v .. "\"";

        if not showQuotes then
            valueString = string.gsub(valueString, "\"", "");
        end

        local key;
        if not displayKeys then
            key = k;
        else
            key = displayKeys[i];
        end

        print("|cff88ccff[" .. i .. "] " .. key .. valueString);
        i = i + 1;
    end
end

function Datamine.WrapTextInParenthesis(text, withLeadingSpace)
    if withLeadingSpace then
        return " (" .. text .. ")";
    else
        return "(" .. text .. ")";
    end
end

function Datamine.IsInDanger()
    local inInstance, instanceType = IsInInstance();
    local inMythicKeystone = C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive();
    local inCombat = InCombatLockdown();

    if inInstance then
        if instanceType == "raid" and IsInRaid() then
            if inCombat then
                return true;
            end
        elseif inMythicKeystone then
            return true;
        end
    end

    return false;
end

StaticPopupDialogs["DATAMINE_CONFIRM_RELOAD"] = {
	text = "Are you sure you want to reload?",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self) C_UI.Reload() end,
	hideOnEscape = true,
	timeout = 0,
	exclusive = true,
	showAlert = true,
};

function Datamine.QuickReload()
    if Datamine.IsInDanger() then
        StaticPopup_Show("DATAMINE_CONFIRM_RELOAD");
    else
        C_UI.Reload();
    end
end

function Datamine.ToggleDeprecationFallbacks()
    local cvar = "loadDeprecationFallbacks";
    local value = C_CVar.GetCVarBool(cvar);
    local newValue = value and 0 or 1;
    C_CVar.SetCVar(cvar, newValue);
    Datamine.QuickReload();
end

-- print-dependent utils

function Datamine.Utils.Profile(func, ...)
    local start = debugprofilestop();
    local output = func(...);
    local stop = debugprofilestop();
    local outString = format("Executed in %dms.", stop - start);
    Datamine.Print("Profiling", outString);
    return output;
end

local function _P(...)
    Datamine.Print("Utils", ...);
end

function Datamine.Utils.PrintWorldPos()
    local token = "player";
    local map = C_Map.GetBestMapForUnit(token);
    local mapPos = C_Map.GetPlayerMapPosition(map, token);
    local continentID, worldPos = C_Map.GetWorldPosFromMapPos(map, mapPos);

    _P(format("Continent: %d X: %.f Y: %.2f", continentID, worldPos.x, worldPos.y));
end

function Datamine.Utils.GetUnitCreatureID(unitToken)
    local guid = UnitGUID(unitToken);
    if not guid then
        Datamine.Print("Utils")
        return;
    end
    local creatureID = select(6, strsplit("-", guid));
    return tonumber(creatureID);
end

function Datamine.Utils.PrintMouseoverCreatureID()
    local creatureID = Datamine.Utils.GetUnitCreatureID("mouseover");
    if creatureID then
        _P(format("Creature ID: %d", creatureID));
    end
end

---@param timeout number
---@param callback function
---@return function
function Datamine.Utils.Debounce(timeout, callback)
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