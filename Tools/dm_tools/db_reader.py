"""Python script for extracting minimap textures from WDT files"""

import os
import csv
import time
import httpx

from dm_tools import SHARED_CLIENT_HEADERS, CACHE_PATH, logger

from dataclasses import dataclass, fields


def tabs(depth: int):
    return "\t" * depth


_TABS = {1: tabs(1), 2: tabs(2), 3: tabs(3)}


class Schema:
    @classmethod
    def new(cls, *args, **kwargs):
        return cls(*args, **kwargs)

    def to_lua_table(self, tabOffset: int = 0):
        tbl = "{"

        for field in fields(self):
            tabs = _TABS[1 + tabOffset]
            value = getattr(self, field.name)
            line = "\n" + tabs + f"{field.name} = {value},"

            if field.type is str:
                line.replace(value, f"[[{value}]]")

            tbl += line

        tbl += "\n" + _TABS[tabOffset] + "},"

        return tbl


@dataclass
class Map(Schema):
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
    PreloadFileDataID: int
    Flags_0: str
    Flags_1: str
    Flags_2: str


@dataclass
class ItemBonus(Schema):
    ID: int
    Value_0: int
    Value_1: int
    Value_2: int
    Value_3: int
    ParentItemBonusListID: int
    Type: int
    OrderIndex: int


@dataclass
class ItemBonusList(Schema):
    ID: int
    Flags: int


@dataclass
class ItemBonusListGroup(Schema):
    ID: int
    SequenceSpellID: int
    PlayerConditionID: int
    ItemExtendedCostID: int
    ItemLogicalCostGroupID: int
    ItemGroupIlvlScalingID: int


@dataclass
class ItemBonusListGroupEntry(Schema):
    ID: int
    ItemBonusListGroupID: int
    ItemBonusListID: int
    ItemLevelSelectorID: int
    SequenceValue: int
    ItemExtendedCostID: int
    PlayerConditionID: int
    Flags: int
    ItemLogicalCostGroupID: int


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
    def __init__(self, db2_name: str, entry_type: object):
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
                entry = self.entry_type.new(*row)
                if entry.ID == "ID":
                    continue

                yield entry

    def get_row(self, id: int):
        for entry in self.read():
            if entry.ID == id:
                return entry


MAP_DB2 = DB2("Map", Map)
ITEMBONUS_DB2 = DB2("ItemBonus", ItemBonus)
ITEMBONUSLIST_DB2 = DB2("ItemBonusList", ItemBonusList)
ITEMBONUSLISTGROUP_DB2 = DB2("ItemBonusListGroup", ItemBonusListGroup)
ITEMBONUSLISTGROUPENTRY_DB2 = DB2("ItemBonusListGroupEntry", ItemBonusListGroupEntry)
