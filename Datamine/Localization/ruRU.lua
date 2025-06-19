local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("Datamine", "ruRU", true);
--Translation ZamestoTV
-- BEGIN LOCALIZATION

L["ADDON_TITLE"] = "Datamine";

L["CONFIG_COLOR_PICKER_TEXT"] = COLOR_PICKER;

L["CONFIG_CHAT_PREFIX_COLOR_NAME"] = "Цвет префикса чата";
L["CONFIG_CHAT_PREFIX_COLOR_TOOLTIP"] = "Цвет префикса, используемого для вывода в чат";

L["CONFIG_DEBUGTARGETINFO_NAME"] = "Отладочные всплывающие подсказки в парикмахерской";
L["CONFIG_DEBUGTARGETINFO_TOOLTIP"] = "Переключает отображение отладочных всплывающих подсказок в парикмахерской и на экранах настройки персонажа.";

L["CONFIG_CREATUREDATA_NAME"] = "Сбор данных о существах";
L["CONFIG_CREATUREDATA_TOOLTIP"] = "Собирает и сохраняет информацию о NPC, с которыми вы сталкиваетесь в мире. Может слегка повлиять на производительность.";

L["CONFIG_AUTO_LOAD_MAP_DATA_NAME"] = "Загружать данные карты при запуске";
L["CONFIG_AUTO_LOAD_MAP_DATA_TOOLTIP"] = "Автоматически загружает данные просмотрщика карт при запуске. Может увеличить время загрузки при первом входе или перезагрузке.";

L["CONFIG_SHOW_MODEL_INFO_NAME"] = "Показывать информацию о модели в предварительных просмотрах";
L["CONFIG_SHOW_MODEL_INFO_TOOLTIP"] = "Показывает дополнительную информацию о модели в ModelPreviewFrame, часто используемом для магазина.";

-- debug settings
L["CONFIG_CATEGORY_DEBUG"] = "Отладка";

L["CONFIG_DEBUG_SHOW_ALL_TOOLTIP_DATA_NAME"] = "Показывать все данные всплывающих подсказок";
L["CONFIG_DEBUG_SHOW_ALL_TOOLTIP_DATA_TOOLTIP"] = "Показывать все данные всплывающих подсказок независимо от их конфигурации";

-- explorer settings

L["CONFIG_CATEGORY_EXPLORER"] = "Исследователь";

L["CONFIG_EXPLORER_USE_MODIFIER_NAME"] = "Включить поиск с модификатором";
L["CONFIG_EXPLORER_USE_MODIFIER_TOOLTIP"] = "Переключает возможность поиска предмета в исследователе с помощью клика с модификатором";

L["CONFIG_EXPLORER_MODIFIER_NAME"] = "Модификатор поиска";
L["CONFIG_EXPLORER_MODIFIER_TOOLTIP"] = "Клик по предмету с удержанием этой клавиши выполнит поиск этого предмета в исследователе предметов";
L["CONFIG_EXPLORER_MODIFIER_ALT_TOOLTIP"] = "Искать целевой предмет при удержании " .. ALT_KEY;
L["CONFIG_EXPLORER_MODIFIER_CTRL_TOOLTIP"] = "Искать целевой предмет при удержании " .. CTRL_KEY;
L["CONFIG_EXPLORER_MODIFIER_SHIFT_TOOLTIP"] = "Искать целевой предмет при удержании " .. SHIFT_KEY;

-- tooltip settings

L["CONFIG_CATEGORY_TOOLTIPS"] = "Всплывающие подсказки";

L["CONFIG_HEADER_ITEM_TOOLTIPS"] = "Всплывающие подсказки предметов";
L["CONFIG_HEADER_SPELL_TOOLTIPS"] = "Всплывающие подсказки заклинаний";
L["CONFIG_HEADER_MACRO_TOOLTIPS"] = "Всплывающие подсказки макросов";
L["CONFIG_HEADER_TOY_TOOLTIPS"] = "Всплывающие подсказки игрушек";
L["CONFIG_HEADER_MOUNT_TOOLTIPS"] = "Всплывающие подсказки маунтов";
L["CONFIG_HEADER_UNIT_TOOLTIPS"] = "Всплывающие подсказки юнитов";
L["CONFIG_HEADER_AURA_TOOLTIPS"] = "Всплывающие подсказки аур";
L["CONFIG_HEADER_ACHIEVEMENT_TOOLTIPS"] = "Всплывающие подсказки достижений";
L["CONFIG_HEADER_BATTLE_PET_TOOLTIPS"] = "Всплывающие подсказки боевых питомцев";
L["CONFIG_HEADER_CURRENCY_TOOLTIPS"] = "Всплывающие подсказки валют";
L["CONFIG_HEADER_GOBJECT_TOOLTIPS"] = "Всплывающие подсказки игровых объектов";
L["CONFIG_HEADER_QUEST_TOOLTIPS"] = "Всплывающие подсказки заданий";
L["CONFIG_HEADER_TRAIT_TOOLTIPS"] = "Всплывающие подсказки черт";

L["CONFIG_TOOLTIP_KEY_COLOR_NAME"] = "Цвет ключа данных";
L["CONFIG_TOOLTIP_KEY_COLOR_TOOLTIP"] = "Цвет ключей данных во всплывающих подсказках";

L["CONFIG_TOOLTIP_ENABLE_NAME"] = "Включить информацию во всплывающих подсказках";
L["CONFIG_TOOLTIP_ENABLE_TOOLTIP"] = "Если включено, добавляет дополнительную информацию в большинство всплывающих подсказок в игре";

L["CONFIG_TOOLTIP_VALUE_COLOR_NAME"] = "Цвет значений данных";
L["CONFIG_TOOLTIP_VALUE_COLOR_TOOLTIP"] = "Цвет значений данных во всплывающих подсказках";

L["CONFIG_TOOLTIP_USE_MODIFIER_NAME"] = "Использовать модификатор переопределения";
L["CONFIG_TOOLTIP_USE_MODIFIER_TOOLTIP"] = "Переключает использование модификатора переопределения всплывающих подсказок";

L["CONFIG_TOOLTIP_MODIFIER_NAME"] = "Модификатор переопределения";
L["CONFIG_TOOLTIP_MODIFIER_TOOLTIP"] = "При удержании этой клавиши все данные всплывающих подсказок будут показаны независимо от настроек ниже";
L["CONFIG_TOOLTIP_MODIFIER_ALT_TOOLTIP"] = "Переопределять настройки при удержании " .. ALT_KEY;
L["CONFIG_TOOLTIP_MODIFIER_CTRL_TOOLTIP"] = "Переопределять настройки при удержании " .. CTRL_KEY;
L["CONFIG_TOOLTIP_MODIFIER_SHIFT_TOOLTIP"] = "Переопределять настройки при удержании " .. SHIFT_KEY;

-- item tooltips

L["CONFIG_TOOLTIP_SHOW_ITEM_ID_NAME"] = "Показывать ID предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_ID_TOOLTIP"] = "Показывать ID предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_ENCHANT_ID_NAME"] = "Показывать ID чар";
L["CONFIG_TOOLTIP_SHOW_ITEM_ENCHANT_ID_TOOLTIP"] = "Показывать ID чар";
L["CONFIG_TOOLTIP_SHOW_ITEM_GEMS_NAME"] = "Показывать ID камней";
L["CONFIG_TOOLTIP_SHOW_ITEM_GEMS_TOOLTIP"] = "Показывать ID вставленных камней";
L["CONFIG_TOOLTIP_SHOW_ITEM_CONTEXT_NAME"] = "Показывать CreationContext";
L["CONFIG_TOOLTIP_SHOW_ITEM_CONTEXT_TOOLTIP"] = "Показывать имя и ID ItemCreationContext";
L["CONFIG_TOOLTIP_SHOW_ITEM_BONUSES_NAME"] = "Показывать ID бонусов";
L["CONFIG_TOOLTIP_SHOW_ITEM_BONUSES_TOOLTIP"] = "Показывать ID бонусов предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_MODIFIERS_NAME"] = "Показывать модификаторы";
L["CONFIG_TOOLTIP_SHOW_ITEM_MODIFIERS_TOOLTIP"] = "Показывать модификаторы";
L["CONFIG_TOOLTIP_SHOW_ITEM_CRAFTER_GUID_NAME"] = "Показывать GUID крафтера";
L["CONFIG_TOOLTIP_SHOW_ITEM_CRAFTER_GUID_TOOLTIP"] = "Для созданных предметов показывает GUID крафтера";
L["CONFIG_TOOLTIP_SHOW_ITEM_EXTRA_ENCHANT_ID_NAME"] = "Показывать ID дополнительных чар";
L["CONFIG_TOOLTIP_SHOW_ITEM_EXTRA_ENCHANT_ID_TOOLTIP"] = "Показывать ID дополнительных чар";
L["CONFIG_TOOLTIP_SHOW_ITEM_SPELL_NAME"] = "Показывать заклинание предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_SPELL_TOOLTIP"] = "Показывать имя и ID заклинания предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_RELIC_BONUSES_NAME"] = "Показывать бонусы реликвий";
L["CONFIG_TOOLTIP_SHOW_ITEM_RELIC_BONUSES_TOOLTIP"] = "Показывать бонусы вставленных реликвий";
L["CONFIG_TOOLTIP_SHOW_ITEM_CLASS_NAME"] = "Показывать класс предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_CLASS_TOOLTIP"] = "Показывать имя и ID класса предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_SUBCLASS_NAME"] = "Показывать подкласс предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_SUBCLASS_TOOLTIP"] = "Показывать имя и ID подкласса предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_EQUIP_SLOT_NAME"] = "Показывать слот экипировки";
L["CONFIG_TOOLTIP_SHOW_ITEM_EQUIP_SLOT_TOOLTIP"] = "Показывать слот экипировки предмета";
L["CONFIG_TOOLTIP_SHOW_ITEM_ICON_NAME"] = "Показывать FileID иконки";
L["CONFIG_TOOLTIP_SHOW_ITEM_ICON_TOOLTIP"] = "Показывать ID файла иконки предмета";
L["CONFIG_TOOLTIP_SHOW_APPEARANCE_ID_NAME"] = "Показывать ID внешнего вида предмета";
L["CONFIG_TOOLTIP_SHOW_APPEARANCE_ID_TOOLTIP"] = "Показывать базовый ID внешнего вида предмета";
L["CONFIG_TOOLTIP_SHOW_MODIFIED_APPEARANCE_ID_NAME"] = "Показывать ID измененного внешнего вида предмета";
L["CONFIG_TOOLTIP_SHOW_MODIFIED_APPEARANCE_ID_TOOLTIP"] = "Показывать ID измененного внешнего вида предмета";
L["CONFIG_TOOLTIP_SHOW_KEYSTONE_CM_ID_NAME"] = "Показывать ID режима испытаний ключа";
L["CONFIG_TOOLTIP_SHOW_KEYSTONE_CM_ID_TOOLTIP"] = "Показывать ID режима испытаний для всплывающих подсказок ключа";
L["CONFIG_TOOLTIP_SHOW_KEYSTONE_LEVEL_NAME"] = "Показывать уровень ключа";
L["CONFIG_TOOLTIP_SHOW_KEYSTONE_LEVEL_TOOLTIP"] = "Показывать уровень для всплывающих подсказок ключа";
L["CONFIG_TOOLTIP_SHOW_KEYSTONE_AFFIXES_NAME"] = "Показывать аффиксы ключа";
L["CONFIG_TOOLTIP_SHOW_KEYSTONE_AFFIXES_TOOLTIP"] = "Показывать аффиксы для всплывающих подсказок ключа";

-- spell tooltips

L["CONFIG_TOOLTIP_SHOW_SPELL_ID_NAME"] = "Показывать ID заклинания";
L["CONFIG_TOOLTIP_SHOW_SPELL_ID_TOOLTIP"] = "Показывать ID заклинания";

-- macro tooltips

L["CONFIG_TOOLTIP_SHOW_MACRO_NAME"] = "Показывать имя макроса";
L["CONFIG_TOOLTIP_SHOW_MACRO_TOOLTIP"] = "Показывать имя макроса";
L["CONFIG_TOOLTIP_SHOW_MACRO_ACTION_NAME"] = "Показывать действие макроса";
L["CONFIG_TOOLTIP_SHOW_MACRO_ACTION_TOOLTIP"] = "Показывать действие макроса — либо слот инвентаря, предмет, либо заклинание";
L["CONFIG_TOOLTIP_SHOW_MACRO_ICON_NAME"] = "Показывать иконку макроса";
L["CONFIG_TOOLTIP_SHOW_MACRO_ICON_TOOLTIP"] = "Показывать ID иконки макроса";

-- toy tooltips

L["CONFIG_TOOLTIP_SHOW_TOY_ICON_NAME"] = "Показывать иконку игрушки";
L["CONFIG_TOOLTIP_SHOW_TOY_ICON_TOOLTIP"] = "Показывать ID иконки игрушки";

-- mount tooltips

L["CONFIG_TOOLTIP_SHOW_MOUNT_ID_NAME"] = "Показывать ID маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ID_TOOLTIP"] = "Показывать ID маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SPELL_NAME"] = "Показывать ID заклинания маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SPELL_TOOLTIP"] = "Показывать ID заклинания маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ICON_NAME"] = "Показывать иконку маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ICON_TOOLTIP"] = "Показывать ID иконки маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_FACTION_NAME"] = "Показывать фракцию маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_FACTION_TOOLTIP"] = "Показывать требуемую фракцию для маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SKYRIDING_NAME"] = "Показывать возможность небесного полета";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SKYRIDING_TOOLTIP"] = "Показывать, способен ли маунт к небесному полету";
L["CONFIG_TOOLTIP_SHOW_MOUNT_DISPLAY_NAME"] = "Показывать CreatureDisplayInfo ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_DISPLAY_TOOLTIP"] = "Показывать ID отображения маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_TYPE_NAME"] = "Показывать ID типа маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_TYPE_TOOLTIP"] = "Показывать ID возможностей маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_MODELSCENE_NAME"] = "Показывать UiModelSceneID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_MODELSCENE_TOOLTIP"] = "Показывать UiModelSceneID для отображения маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ANIM_NAME"] = "Показывать ID анимации";
L["CONFIG_TOOLTIP_SHOW_MOUNT_ANIM_TOOLTIP"] = "Показывать ID анимации призыва маунта";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SPELLVISUAL_NAME"] = "Показывать SpellVisualKit ID";
L["CONFIG_TOOLTIP_SHOW_MOUNT_SPELLVISUAL_TOOLTIP"] = "Показывать ID визуального набора заклинаний";

-- unit tooltips

L["CONFIG_TOOLTIP_SHOW_UNIT_TOKEN_NAME"] = "Показывать токен юнита";
L["CONFIG_TOOLTIP_SHOW_UNIT_TOKEN_TOOLTIP"] = "Показывать токен юнита";
L["CONFIG_TOOLTIP_SHOW_UNIT_TYPE_NAME"] = "Показывать тип юнита";
L["CONFIG_TOOLTIP_SHOW_UNIT_TYPE_TOOLTIP"] = "Показывать тип юнита, например, Creature, ClientActor, Player и т.д.";
L["CONFIG_TOOLTIP_SHOW_UNIT_CREATURE_ID_NAME"] = "Показывать ID существа";
L["CONFIG_TOOLTIP_SHOW_UNIT_CREATURE_ID_TOOLTIP"] = "Показывать ID существа для NPC";
L["CONFIG_TOOLTIP_SHOW_UNIT_DISPLAY_ID_NAME"] = "Показывать ID отображения";
L["CONFIG_TOOLTIP_SHOW_UNIT_DISPLAY_ID_TOOLTIP"] = "Показывать CreatureDisplayInfoID для NPC";
L["CONFIG_TOOLTIP_SHOW_UNIT_NPC_CLASS_NAME"] = "Показывать класс NPC";
L["CONFIG_TOOLTIP_SHOW_UNIT_NPC_CLASS_TOOLTIP"] = "Показывать название класса для NPC";

-- aura tooltips

L["CONFIG_TOOLTIP_SHOW_AURA_ID_NAME"] = "Показывать ID заклинания ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_ID_TOOLTIP"] = "Показывать ID заклинания ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_ICON_NAME"] = "Показывать ID иконки";
L["CONFIG_TOOLTIP_SHOW_AURA_ICON_TOOLTIP"] = "Показывать ID иконки ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_DISPEL_NAME"] = "Показывать название рассеивания";
L["CONFIG_TOOLTIP_SHOW_AURA_DISPEL_TOOLTIP"] = "Показывать название рассеивания для рассеиваемых аур";
L["CONFIG_TOOLTIP_SHOW_AURA_BOSS_AURA_NAME"] = "Показывать ауру босса";
L["CONFIG_TOOLTIP_SHOW_AURA_BOSS_AURA_TOOLTIP"] = "Показывать, была ли аура наложена боссом";
L["CONFIG_TOOLTIP_SHOW_AURA_CHARGES_NAME"] = "Показывать заряды";
L["CONFIG_TOOLTIP_SHOW_AURA_CHARGES_TOOLTIP"] = "Показывать заряды ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_MAX_CHARGES_NAME"] = "Показывать максимальные заряды";
L["CONFIG_TOOLTIP_SHOW_AURA_MAX_CHARGES_TOOLTIP"] = "Показывать максимальные заряды ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_SOURCE_UNIT_NAME"] = "Показывать токен юнита-источника";
L["CONFIG_TOOLTIP_SHOW_AURA_SOURCE_UNIT_TOOLTIP"] = "Показывать токен юнита, наложившего ауру";
L["CONFIG_TOOLTIP_SHOW_AURA_SOURCE_NAME"] = "Показывать имя источника";
L["CONFIG_TOOLTIP_SHOW_AURA_SOURCE_TOOLTIP"] = "Показывать имя юнита, наложившего ауру. |cnRED_FONT_COLOR:Может быть неточным|r";
L["CONFIG_TOOLTIP_SHOW_AURA_INSTANCE_ID_NAME"] = "Показывать ID экземпляра ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_INSTANCE_ID_TOOLTIP"] = "Показывать ID экземпляра ауры для использования с API C_UnitAuras";
L["CONFIG_TOOLTIP_SHOW_AURA_STACKS_NAME"] = "Показывать стаки ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_STACKS_TOOLTIP"] = "Показывать стаки ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_PLAYER_APPLICABLE_NAME"] = "Показывать применимость игроком";
L["CONFIG_TOOLTIP_SHOW_AURA_PLAYER_APPLICABLE_TOOLTIP"] = "Показывать, может ли аура быть наложена действием игрока";
L["CONFIG_TOOLTIP_SHOW_AURA_FROM_PLAYER_OR_PET_NAME"] = "Показывать от игрока или питомца";
L["CONFIG_TOOLTIP_SHOW_AURA_FROM_PLAYER_OR_PET_TOOLTIP"] = "Показывать, была ли аура наложена игроком или питомцем игрока";
L["CONFIG_TOOLTIP_SHOW_AURA_POINTS_NAME"] = "Показывать очки ауры";
L["CONFIG_TOOLTIP_SHOW_AURA_POINTS_TOOLTIP"] = "Показывать очки ауры. Значения варьируются в зависимости от исходного заклинания";
L["CONFIG_TOOLTIP_SHOW_AURA_IS_PRIVATE_NAME"] = "Показывать приватность";
L["CONFIG_TOOLTIP_SHOW_AURA_IS_PRIVATE_TOOLTIP"] = "Показывать, является ли аура приватной";

-- achievement tooltips

L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_ID_NAME"] = "Показывать ID достижения";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_ID_TOOLTIP"] = "Показывать ID достижения";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_PLAYER_GUID_NAME"] = "Показывать GUID игрока";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_PLAYER_GUID_TOOLTIP"] = "Показывать GUID игрока, на которого ссылается всплывающая подсказка достижения";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_COMPLETED_NAME"] = "Показывать завершение";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_COMPLETED_TOOLTIP"] = "Показывать, завершено ли достижение";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_DATE_NAME"] = "Показывать дату завершения";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_DATE_TOOLTIP"] = "Показывать дату завершения достижения, если применимо";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_CRITERIA_NAME"] = "Показывать критерии достижения";
L["CONFIG_TOOLTIP_SHOW_ACHIEVEMENT_CRITERIA_TOOLTIP"] = "Показывать критерии для завершения достижения";

-- battle pet tooltips

L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_SPECIES_NAME"] = "Показывать ID вида боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_SPECIES_TOOLTIP"] = "Показывать ID вида";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_LEVEL_NAME"] = "Показывать уровень боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_LEVEL_TOOLTIP"] = "Показывать уровень боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_BREED_QUALITY_NAME"] = "Показывать качество породы";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_BREED_QUALITY_TOOLTIP"] = "Показывать качество породы боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_MAX_HEALTH_NAME"] = "Показывать максимальное здоровье боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_MAX_HEALTH_TOOLTIP"] = "Показывать максимальное здоровье питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_POWER_NAME"] = "Показывать силу боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_POWER_TOOLTIP"] = "Показывать характеристику силы боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_SPEED_NAME"] = "Показывать скорость боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_SPEED_TOOLTIP"] = "Показывать характеристику скорости боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_ID_NAME"] = "Показывать GUID боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_ID_TOOLTIP"] = "Показывать GUID боевого питомца, также известный как petID";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_DISPLAY_ID_NAME"] = "Показывать ID отображения боевого питомца";
L["CONFIG_TOOLTIP_SHOW_BATTLE_PET_DISPLAY_ID_TOOLTIP"] = "Показывать CreatureDisplayInfoID для боевого питомца";

-- currency tooltips

L["CONFIG_TOOLTIP_SHOW_CURRENCY_ID_NAME"] = "Показывать ID валюты";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_ID_TOOLTIP"] = "Показывать ID валюты";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_ICON_NAME"] = "Показывать ID иконки валюты";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_ICON_TOOLTIP"] = "Показывать FileDataID иконки валюты";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_LIMITED_PER_WEEK_NAME"] = "Показывать недельный лимит";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_LIMITED_PER_WEEK_TOOLTIP"] = "Показывать, есть ли у валюты недельный лимит";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_IS_TRADEABLE_NAME"] = "Показывать возможность обмена валюты";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_IS_TRADEABLE_TOOLTIP"] = "Показывать, можно ли обменивать валюту";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_DISCOVERED_NAME"] = "Показывать обнаруженность";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_DISCOVERED_TOOLTIP"] = "Показывать, была ли валюта обнаружена";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_IS_ACCOUNT_WIDE_NAME"] = "Показывать общесерверную валюту";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_IS_ACCOUNT_WIDE_TOOLTIP"] = "Показывать, является ли валюта общесерверной";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_CAN_XFER_NAME"] = "Показывать возможность передачи валюты";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_CAN_XFER_TOOLTIP"] = "Показывать, можно ли передавать валюту альтам";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_XFER_PERCENTAGE_NAME"] = "Показывать процент передачи";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_XFER_PERCENTAGE_TOOLTIP"] = "Показывать процент валюты, который можно передать альтам";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_AMOUNT_PER_CYCLE_NAME"] = "Показывать количество валюты за цикл";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_AMOUNT_PER_CYCLE_TOOLTIP"] = "Показывать количество валюты, получаемой за цикл, используется для валют катализатора создания";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_CYCLE_DURATION_NAME"] = "Показывать длительность цикла валюты";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_CYCLE_DURATION_TOOLTIP"] = "Показывать длительность цикла валюты в часах";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_HAS_WARMODE_BONUS_NAME"] = "Показывать бонус военного режима для валюты";
L["CONFIG_TOOLTIP_SHOW_CURRENCY_HAS_WARMODE_BONUS_TOOLTIP"] = "Показывать, получает ли валюта бонус военного режима";

L["CONFIG_TOOLTIP_SHOW_GOBJECT_ID_NAME"] = "Показывать ID игрового объекта";
L["CONFIG_TOOLTIP_SHOW_GOBJECT_ID_TOOLTIP"] = "Показывать ID игрового объекта, с которым вы взаимодействуете";

L["CONFIG_TOOLTIP_SHOW_QUEST_ID_NAME"] = "Показывать ID задания";
L["CONFIG_TOOLTIP_SHOW_QUEST_ID_TOOLTIP"] = "Показывать ID задания, отображаемого во всплывающей подсказке";

L["CONFIG_TOOLTIP_SHOW_NODE_ID_NAME"] = "Показывать ID узла черт";
L["CONFIG_TOOLTIP_SHOW_NODE_ID_TOOLTIP"] = "Показывать ID узла черт для текущей черты во всплывающей подсказке";
L["CONFIG_TOOLTIP_SHOW_ENTRY_ID_NAME"] = "Показывать ID записи черты";
L["CONFIG_TOOLTIP_SHOW_ENTRY_ID_TOOLTIP"] = "Показывать ID записи черты для текущей черты во всплывающей подсказке";
L["CONFIG_TOOLTIP_SHOW_SYSTEM_ID_NAME"] = "Показывать ID системы черт";
L["CONFIG_TOOLTIP_SHOW_SYSTEM_ID_TOOLTIP"] = "Показывать ID системы черт во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_TREE_ID_NAME"] = "Показывать ID дерева черт";
L["CONFIG_TOOLTIP_SHOW_TREE_ID_TOOLTIP"] = "Показывать ID дерева черт во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_TREE_CURRENCY_INFO_NAME"] = "Показывать информацию о валюте дерева черт";
L["CONFIG_TOOLTIP_SHOW_TREE_CURRENCY_INFO_TOOLTIP"] = "Показывать информацию о различных валютах дерева черт во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_RANK_NAME"] = "Показывать ранг черты";
L["CONFIG_TOOLTIP_SHOW_RANK_TOOLTIP"] = "Показывать ранг черты во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_ENTRY_TYPE_NAME"] = "Показывать тип записи черты";
L["CONFIG_TOOLTIP_SHOW_ENTRY_TYPE_TOOLTIP"] = "Показывать тип записи черты во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_DEFINITION_ID_NAME"] = "Показывать ID определения черты";
L["CONFIG_TOOLTIP_SHOW_DEFINITION_ID_TOOLTIP"] = "Показывать ID определения черты во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_SUBTREE_ID_NAME"] = "Показывать ID поддерева черт";
L["CONFIG_TOOLTIP_SHOW_SUBTREE_ID_TOOLTIP"] = "Показывать ID поддерева черт во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_ERRORS_NAME"] = "Показывать ошибки черт";
L["CONFIG_TOOLTIP_SHOW_ERRORS_TOOLTIP"] = "Показывать ошибки записи черт во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_PATH_ID_NAME"] = "Показывать ID пути профессиональной специализации";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_PATH_ID_TOOLTIP"] = "Показывать ID пути профессиональной специализации во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_PATH_STATE_NAME"] = "Показывать состояние пути профессиональной специализации";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_PATH_STATE_TOOLTIP"] = "Показывать состояние пути профессиональной специализации во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_PERK_ID_NAME"] = "Показывать ID перка профессиональной специализации";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_PERK_ID_TOOLTIP"] = "Показывать ID перка профессиональной специализации во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_PERK_STATE_NAME"] = "Показывать состояние перка профессиональной специализации";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_PERK_STATE_TOOLTIP"] = "Показывать состояние перка профессиональной специализации во всплывающей подсказке, если применимо";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_TAB_STATE_NAME"] = "Показывать состояние вкладки профессиональной специализации";
L["CONFIG_TOOLTIP_SHOW_PROFSPEC_TAB_STATE_TOOLTIP"] = "Показывать состояние вкладки профессиональной специализации во всплывающей подсказке, если применимо";

-- end tooltips

-- model viewer settings

L["CONFIG_CATEGORY_MODELVIEWER"] = "Просмотрщик моделей";

L["CONFIG_MODELVIEWER_BG_COLOR_NAME"] = "Цвет фона";
L["CONFIG_MODELVIEWER_BG_COLOR_TOOLTIP"] = "Изменить цвет фона, используемый в просмотрщике моделей Datamine";

-- end model viewer settings

L["GENERIC_LOADING"] = "Загрузка...";
L["GENERIC_SEARCHING"] = "Поиск...";
L["GENERIC_EMPTY"] = "Пусто";
L["GENERIC_HIDDEN"] = "Скрыто";
L["GENERIC_APPEARANCE"] = "Внешний вид";
L["GENERIC_SPELL"] = "Заклинание";
L["GENERIC_NA"] = "Н/Д";
L["GENERIC_YES"] = "Да";
L["GENERIC_NO"] = "Нет";
L["GENERIC_OKAY"] = "ОК";
L["GENERIC_CONTINUE"] = "Продолжить";

L["RESIZE_BUTTON_HINT_TOOLTIP"] = "Двойной клик для сброса размера и позиции фрейма";

L["SEARCH_FAILED_HEADER"] = "Поиск не удался";
L["SEARCH_FAILED_TEXT"] = "Результаты не найдены.";

L["WORKSPACE_MODE_EXPLORER"] = "Исследователь";
L["WORKSPACE_MODE_MOVIE"] = "Театр";
L["WORKSPACE_MODE_MAPS"] = "Карты";
L["WORKSPACE_MODE_STORAGE"] = "Существа";
L["WORKSPACE_MODE_CREATURES"] = "Существа";

L["MODEL_CONTROLS_ALT_FORM_BUTTON_TOOLTIP_TEXT"] = "Переключить альтернативную форму";
L["MODEL_CONTROLS_SHEATHE_BUTTON_TOOLTIP_TEXT"] = "Переключить убирание оружия в ножны";
L["MODEL_CONTROLS_CHANGE_BG_COLOR_TOOLTIP_TEXT"] = "Изменить цвет фона";

L["MODEL_CONTROLS_TAB_TITLE_TRANSFORM"] = "Трансформация";
L["MODEL_CONTROLS_TAB_TITLE_OUTFIT"] = "Наряд";
L["MODEL_CONTROLS_TAB_TITLE_ADVANCED"] = "Расширенные";
L["MODEL_CONTROLS_TAB_TITLE_TRANSMOG_SET"] = "Предметы набора трансмогрификации";

L["MODEL_CONTROLS_TRANSFORM_TRANSLATE"] = "Перемещение";
L["MODEL_CONTROLS_TRANSFORM_CAMERA"] = "Камера";

L["MODEL_CONTROLS_ADVANCED_SET_BY_FDID"] = "Установить модель по FileDataID";
L["MODEL_CONTROLS_ADVANCED_SET_BY_FDID_HELP"] = "Введите FileDataID...";
L["MODEL_CONTROLS_ADVANCED_SET_BY_DIID"] = "Установить модель по DisplayInfoID";
L["MODEL_CONTROLS_ADVANCED_SET_BY_DIID_HELP"] = "Введите DisplayInfoID...";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_ITEMID"] = "Примерить ItemID";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_ITEMID_HELP"] = "Введите ItemID...";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_ITEMMODID"] = "Примерить ItemModifiedAppearanceID";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_ITEMMODID_HELP"] = "Введите ItemModifiedAppearanceID...";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_TMOGSET"] = "Примерить TransmogSetID";
L["MODEL_CONTROLS_ADVANCED_TRY_ON_TMOGSET_HELP"] = "Введите TransmogSetID...";
L["MODEL_CONTROLS_ADVANCED_APPLY_SPELLVISKIT"] = "Применить SpellVisualKit";
L["MODEL_CONTROLS_ADVANCED_APPLY_SPELLVISKIT_HELP"] = "Введите SpellVisualKitID...";
L["MODEL_CONTROLS_ADVANCED_PLAY_ANIMKIT"] = "Воспроизвести AnimationKit";
L["MODEL_CONTROLS_ADVANCED_PLAY_ANIMKIT_HELP"] = "Введите AnimKitID...";

L["MODEL_CONTROLS_TRANSMOG_SET_SLOT1"] = "Голова";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT3"] = "Плечи";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT4"] = "Рубашка";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT5"] = "Грудь";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT6"] = "Пояс";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT7"] = "Ноги";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT8"] = "Ступни";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT9"] = "Запястья";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT10"] = "Кисти";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT15"] = "Спина";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT16"] = "Правая рука";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT17"] = "Левая рука";
L["MODEL_CONTROLS_TRANSMOG_SET_SLOT19"] = "Гербовая накидка";

L["THEATER_MODE_MOVIE_ID"] = "ID фильма";
L["THEATER_MODE_MOVIE_ID_EB_INSTRUCTIONS"] = "Введите MovieID...";
L["THEATER_MODE_SUBTITLE_TOGGLE"] = "Включить субтитры";
L["THEATER_MODE_CONTROLS_TITLE"] = "Управление фильмом";
L["THEATER_MODE_LOOP_TOGGLE"] = "Зациклить фильм";
L["THEATER_MODE_LOADING_MOVIE"] = "Загрузка фильма...";
L["THEATER_MODE_DOWNLOAD_PROGRESS"] = "%d%%";
L["THEATER_MODE_ERR_PLAY_FAILED"] = "Не удалось воспроизвести фильм '%s': ошибка с кодом %d (%s).";
L["THEATER_MODE_ERR_INVALID_MOVIE"] = "Фильм '%d' не существует или не воспроизводится.";

L["EXPLORER_HELP_TEXT_HELP_HEADER"] = "Исследователь";
L["EXPLORER_HELP_TEXT_HELP"] = "Введите %s %s ID в поле поиска выше,|nчтобы начать.";
L["EXPLORER_HELP_TEXT_FAIL_HEADER"] = "Поиск не удался";
L["EXPLORER_HELP_TEXT_FAIL"] = "%s %d запрещен или не существует.";
L["EXPLORER_HELP_TEXT_DRAGDROP_HEADER"] = "Исследователь";
L["EXPLORER_HELP_TEXT_DRAGDROP"] = "Перетащите %s %s сюда для поиска.";
L["EXPLORER_HELP_TEXT_CREATURE_HEADER"] = "Исследователь существ";
L["EXPLORER_HELP_TEXT_CREATURE"] = "Пока нет кэшированных существ. Убедитесь, что настройка '|cffffffСбор данных о существах|r' включена, и попробуйте побегать по миру.";

L["STORAGE_VIEW_TEXT_HELP_HEADER"] = "Хранилище";
L["STORAGE_VIEW_TEXT_HELP"] = "В кэше пока нет существ.|nПопробуйте побегать и взаимодействовать с NPC.";
L["STORAGE_VIEW_SEARCH_MODE_BUTTON_1"] = "ID";
L["STORAGE_VIEW_SEARCH_MODE_BUTTON_2"] = "Имя";
L["STORAGE_VIEW_SEARCH_MODE_BUTTON_3"] = "Зона";

L["POPUP_CONFIG_CREATUREDATA_TITLE"] = "Сбор данных";
L["POPUP_CONFIG_CREATUREDATA_TEXT"] = "Привет, спасибо за использование Datamine! С вашего последнего входа я добавил возможность для Datamine собирать данные о NPC, с которыми вы сталкиваетесь и взаимодействуете. Все данные сохраняются в сохраненных переменных аддона Datamine_Data.|n|nЭта функция может слегка снизить производительность в бою, хотите включить сбор данных о NPC?";

L["MAPVIEW_PICKER_TITLE"] = "Выбор карты";
L["MAPVIEW_PICKER_SEARCH_FAIL_TEXT"] = "Карты не найдены.";
L["MAPVIEW_LOAD_DATA_BUTTON_TEXT"] = "Загрузить карты";
L["MAPVIEW_TEXT_HELP_HEADER"] = "Карты не загружены";
L["MAPVIEW_TEXT_HELP"] = "Данные карт еще не загружены.|nНажмите кнопку ниже, чтобы загрузить данные карт.";
L["MAPVIEW_LOAD_WARNING_TITLE"] = "Предупреждение";
L["MAPVIEW_LOAD_WARNING_TEXT"] = "Загрузка данных карт может занять некоторое время и, вероятно, заморозит игру на несколько секунд. Не паникуйте! Нажмите кнопку ниже, чтобы загрузить сохраненные данные.";
L["MAPVIEW_WARNING_NO_CONTENT"] = "Карта не содержит контента";
L["MAPVIEW_MAP_TITLE"] = "Текущая карта: %s";
L["MAPVIEW_DETAILS_TITLE"] = "Детали карты";
L["MAPVIEW_DETAILS_HEADER_COORDS"] = "Координаты";
L["MAPVIEW_DETAILS_HEADER_MISC"] = "Разное";
L["MAPVIEW_DETAILS_COORDS_WARNING"] = "X и Y перевернуты для карт";
L["MAPVIEW_DETAILS_LABEL_Y"] = "Y";
L["MAPVIEW_DETAILS_LABEL_X"] = "X";
L["MAPVIEW_DETAILS_LABEL_MAP"] = "Карта";
L["MAPVIEW_DETAILS_LABEL_WDT"] = "WDT";
L["MAPVIEW_DETAILS_GO"] = "Перейти";
L["MAPVIEW_DETAILS_DESC_TITLE"] = "Описание";

L["CREATUREVIEW_DETAILS_TITLE"] = "Детали существа";
L["CREATUREVIEW_LIST_TITLE"] = "Существа (всего %d)";
L["CREATUREVIEW_LIST_SEARCH_FAIL_TEXT"] = "Существа не найдены.|nУбедитесь, что 'Сбор данных о существах'|nвключен в настройках Datamine.";
L["CREATUREVIEW_TEXT_HELP_HEADER"] = "Существа не зарегистрированы.";
L["CREATUREVIEW_TEXT_HELP"] = "Чтобы начать регистрацию существ для отображения здесь, включите 'Сбор данных о существах' в настройках Datamine.";
L["CREATUREVIEW_LOADING"] = "Загрузка существа...";

-- MODULES --

-- UI Main

L["UI_MAIN_MODULE_NAME"] = "UIMain";

-- Spell Info

L["SPELL_INFO_MODULE_NAME"] = "SpellData";

L["SPELL_INFO_KEYS_NAME"] = "Имя";
L["SPELL_INFO_KEYS_RANK"] = "Ранг";
L["SPELL_INFO_KEYS_ICON"] = "Иконка";
L["SPELL_INFO_KEYS_CASTTIME"] = "Время каста";
L["SPELL_INFO_KEYS_MINRANGE"] = "Мин. дистанция";
L["SPELL_INFO_KEYS_MAXRANGE"] = "Макс. дистанция";
L["SPELL_INFO_KEYS_SPELLID"] = "ID заклинания";
L["SPELL_INFO_KEYS_ORIGINALICON"] = "Оригинальная иконка";
L["SPELL_INFO_KEYS_DESCRIPTION"] = "Описание";
L["SPELL_INFO_KEYS_HYPERLINK"] = "Гиперссылка";

L["SPELL_INFO_FMT_CAST_INSTANT"] = "Мгновенно (%d)";
L["SPELL_INFO_FMT_CAST_TIME"] = "%.1f секунд";
L["SPELL_INFO_FMT_RANGE"] = "%d ярд";

L["FMT_SPELL_INFO_ERR_SPELL_DOES_NOT_EXIST"] = "Запрос для заклинания %d не удался. Заклинание не существует.";
L["FMT_SPELL_INFO_ERR_SPELL_NOT_FOUND"] = "Запрос для заклинания %d не удался. Заклинание запрещено или не существует.";

-- Transmog Info

L["TMOG_INFO_MODULE_NAME"] = "Трансмогрификация";

L["TMOG_INFO_KEYS_SOURCE_TYPE"] = "Тип источника";
L["TMOG_INFO_KEYS_INVENTORY_TYPE"] = "Тип инвентаря";
L["TMOG_INFO_KEYS_VISUALID"] = "VisualID";
L["TMOG_INFO_KEYS_ISCOLLECTED"] = "Собрано";
L["TMOG_INFO_KEYS_SOURCEID"] = "SourceID";
L["TMOG_INFO_KEYS_ITEMID"] = "ItemID";
L["TMOG_INFO_KEYS_CATEGORYID"] = "CategoryID";
L["TMOG_INFO_KEYS_ITEMMODID"] = "ItemModID";

L["TMOG_INFO_ERR_NO_ITEMMODS"] = "ItemModifiedAppearances не найдены для ItemAppearance %d.";
L["TMOG_INFO_RESULT_ITEMMODS"] = "ItemModifiedAppearances для ItemAppearance %d >>"

L["TMOG_INFO_TRY_ON_LINK_TEXT"] = "Примерить";

-- Model Info

L["MODEL_INFO_MODEL_SCENE_ID_FORMAT"] = "ModelSceneID: %s";
L["MODEL_INFO_DISPLAY_ID_FORMAT"] = "DisplayID: %s";
L["MODEL_INFO_FILEDATAID_FORMAT"] = "FileDataID: %s";

-- Slash Commands

L["SLASH_CMD_UI_TOGGLE_HELP"] = "Переключить интерфейс Datamine.";
L["SLASH_CMD_SPELL_INFO_HELP"] = "Получить информацию о заклинании.";
L["SLASH_CMD_TMOG_ITEMMOD_INFO_HELP"] = "Получить информацию об источнике для ItemModifiedAppearanceID.";
L["SLASH_CMD_TMOG_ITEMMOD_FROM_ITEMAPP_HELP"] = "Получить ItemModifiedAppearanceIDs для данного ItemAppearanceID.";
L["SLASH_CMD_SETTINGS_HELP"] = "Открыть настройки Datamine";
L["SLASH_CMD_TOOLTIP_SETTINGS_HELP"] = "Открыть настройки всплывающих подсказок, опционально указать раздел для перехода";
L["SLASH_CMD_TOOLTIP_LAST_ERR_HELP"] = "Показать последнюю ошибку всплывающей подсказки, которая была зафиксирована.";

-- END LOCALIZATION
