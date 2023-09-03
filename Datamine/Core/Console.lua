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

local customCommandInfo = {
    {
        help = "Preview a customization option in the barber shop.\n<optionID> <choiceID>",
        category = commandCategory.Game,
        command = "PreviewCustomizationChoice",
        scriptParameters = "",
        scriptContents = "",
        commandType = commandType.Script,
        commandFunc = PreviewCustomizationChoice,
    },
    {
        help = "Set the dress state of your character in the barber shop.",
        category = commandCategory.Game,
        command = "SetDressState",
        scriptParameters = "",
        scriptContents = "",
        commandType = commandType.Script,
        commandFunc = SetDressState,
    },
}

for _, command in ipairs(customCommandInfo) do
    console:RegisterCommand(command);
end