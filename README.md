# Datamine

An addon designed to make in-game data more accessible by reducing barriers around the availability of certain data.

Example:
![image](https://github.com/Ghostopheles/Datamine/assets/10636803/0f8d6924-e516-44dc-bf86-e98be7ca9d84)

### Slash Commands

Datamine's base command is `/dm` or `/datamine`.

- `help` - Gives you some help.
- `item <itemID>` - Dumps the item info for the given `itemID` to the chat frame. Data for certain items may not be visible in-game.
- `spell <spellID>` Same as above but for spells. Data for certain spells may not be visible in-game.
- `questline <uiMapID> [<questID>]` Provides information about questlines on a given map ID, and optionally, the questline a quest belongs to.

More commands are available in-game and can be viewed with the `/dm help` command.

### Roadmap

These are things I want to add, subject to change, might get scrapped, yadda-yadda. Items marked with 🤠 are things I've already built, but still need to port over to this addon.

#### Data

Things to dump with slash commands like `/dm item` and `/dm spell`.

- [x] Quest and Questline Info
- [ ] Generate Wowhead links from item/spell/quest IDs
- [ ] Item appearance info 🤠
- [ ] Transmog set info 🤠

#### Dressing Room/Model Viewer

- [ ] View model by FileDataID 🤠
- [ ] View CreatureDisplayInfo by ID 🤠
- [ ] Try on items by itemID 🤠
- [x] Try on items by itemModifiedAppearanceID 🤠
- [ ] Try on transmog set by TransmogSetID 🤠
- [ ] Apply SpellVisualKits 🤠

#### Barber Shop

- [ ] Preview customization choices by optionID + choiceID 🤠

#### Other

- [ ] Add a console command variant of every slash command
- [ ] User configuration
