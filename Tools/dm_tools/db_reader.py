"""Python script for reading DB2 files (in CSV form)"""

import os
import csv
import time
import httpx

from dm_tools import SHARED_CLIENT_HEADERS, CACHE_PATH, logger

from typing import Optional
from dataclasses import dataclass


class EntryBase:
    @classmethod
    def new(cls, *args, **kwargs):
        return cls(*args, **kwargs)


@dataclass
class Map(EntryBase):
    ID: int
    Directory: str
    MapName_lang: str
    MapDescription0_lang: str
    MapDescription1_lang: str
    PvpShortDescription_lang: str
    PvpLongDescription_lang: str
    Corpse_0: int
    Corpse_1: int
    MapType: int
    InstanceType: int
    ExpansionID: int
    AreaTableID: int
    LoadingScreenID: int
    TimeOfDayOverride: int
    ParentMapID: int
    CosmeticParentMapID: int
    TimeOffset: int
    MinimapIconScale: int
    CorpseMapID: int
    MaxPlayers: int
    WindSettingsID: int
    ZmpFileDataID: int
    WdtFileDataID: int
    NavigationMaxDistance: int
    Flags_0: str
    Flags_1: str
    Flags_2: str


@dataclass
class Item(EntryBase):
    ID: int
    AllowableRace: int
    Description_lang: str
    Display3_lang: str
    Display2_lang: str
    Display1_lang: str
    Display_lang: str
    ExpansionID: int
    DmgVariance: float
    LimitCategory: int
    DurationInInventory: int
    QualityModifier: int
    BagFamily: int
    StartQuestID: int
    LanguageID: int
    ItemRange: int
    StatPercentageOfSocket0: int
    StatPercentageOfSocket1: int
    StatPercentageOfSocket2: int
    StatPercentageOfSocket3: int
    StatPercentageOfSocket4: int
    StatPercentageOfSocket5: int
    StatPercentageOfSocket6: int
    StatPercentageOfSocket7: int
    StatPercentageOfSocket8: int
    StatPercentageOfSocket9: int
    StatPercentEditor0: int
    StatPercentEditor1: int
    StatPercentEditor2: int
    StatPercentEditor3: int
    StatPercentEditor4: int
    StatPercentEditor5: int
    StatPercentEditor6: int
    StatPercentEditor7: int
    StatPercentEditor8: int
    StatPercentEditor9: int
    StatModifier_bonusStat0: int
    StatModifier_bonusStat1: int
    StatModifier_bonusStat2: int
    StatModifier_bonusStat3: int
    StatModifier_bonusStat4: int
    StatModifier_bonusStat5: int
    StatModifier_bonusStat6: int
    StatModifier_bonusStat7: int
    StatModifier_bonusStat8: int
    StatModifier_bonusStat9: int
    Stackable: int
    MaxCount: int
    MinReputation: int
    RequiredAbility: int
    SellPrice: int
    BuyPrice: int
    VendorStackCount: int
    PriceVariance: int
    PriceRandomValue: float
    Flags0: str
    Flags1: str
    Flags2: str
    Flags3: str
    OppositeFactionItemID: int
    ModifiedCraftingReagentItemID: int
    ContentTuningID: int
    PlayerLevelToItemLevelCurveID: int
    ItemNameDescriptionID: int
    RequiredTransmogHoliday: int
    RequiredHoliday: int
    Gem_properties: int
    Socket_match_enchantment_ID: int
    TotemCategoryID: int
    InstanceBound: int
    ZoneBound0: int
    ZoneBound1: int
    ItemSet: int
    LockID: int
    PageID: int
    ItemDelay: int
    MinFactionID: int
    RequiredSkillRank: int
    RequiredSkill: int
    ItemLevel: int
    AllowableClass: str
    ArtifactID: int
    SpellWeight: int
    SpellWeightCategory: int
    SocketType0: int
    SocketType1: int
    SocketType2: int
    SheatheType: int
    Material: int
    PageMaterialID: int
    Bonding: int
    DamageType: int
    ContainerSlots: int
    RequiredPVPMedal: int
    RequiredPVPRank: int
    RequiredLevel: int
    InventoryType: int
    OverallQualityID: int


DB2_PATH = os.path.join(CACHE_PATH, "db2")
DB2_INDEX_PATH = os.path.join(DB2_PATH, "index.json")
DB2_DIALECT_NAME = "db2"

CACHE_PERIOD = 86400  # 24 hours

client = httpx.Client(
    base_url=f"https://wago.tools/db2", headers=SHARED_CLIENT_HEADERS, http2=True
)


class DB2Dialect(csv.Dialect):
    """CSV dialect for DB2 files"""

    delimiter = ","
    quotechar = '"'
    doublequote = False
    skipinitialspace = False
    lineterminator = "\n"
    quoting = csv.QUOTE_MINIMAL


csv.register_dialect(DB2_DIALECT_NAME, DB2Dialect)


class DB2:
    def __init__[T: DB2](self, db2_name: str, entry_type: T):
        self.name = db2_name
        self.entry_type = entry_type

        self.file_path = os.path.join(DB2_PATH, f"{self.name}.csv")

        if not os.path.exists(DB2_PATH):
            os.makedirs(DB2_PATH, exist_ok=True)

    def should_update(self) -> bool:
        # if the file doesn't exist, update (duh)
        if not os.path.exists(self.file_path):
            return True

        last_modified = os.path.getmtime(self.file_path)
        if (time.time() - last_modified) > CACHE_PERIOD:
            return True

        return False

    def update(self) -> bool:
        logger.info(f"Updating {self.name}.csv...")
        res = client.get(
            f"/{self.name}/csv", headers=SHARED_CLIENT_HEADERS, follow_redirects=True
        )
        if res.status_code != 200:
            logger.error(
                f"Non-200 status code received while updating {self.name}.csv: {res.status_code}"
            )
            return False

        with open(self.file_path, "wb") as f:
            f.write(res.read())

        logger.info(f"{self.name}.csv updated and saved to cache.")
        return True

    def read(self):
        if self.should_update():
            success = self.update()
            if not success:
                raise Exception(f"Error updating {self.name}.csv")

        with open(self.file_path, "r") as f:
            reader = csv.reader(f, dialect=DB2_DIALECT_NAME)
            for row in reader:
                #if len(row) != 98:
                #    continue
                entry = self.entry_type.new(*row)
                if entry.ID == "ID":
                    continue

                yield entry

    def get_row(self, id: int):
        for entry in self.read():
            if entry.ID == id:
                return entry


MAP_DB2 = DB2("Map", Map)
ITEM_DB2 = DB2("ItemSparse", Item)
