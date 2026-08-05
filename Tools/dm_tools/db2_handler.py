import httpx

from dataclasses import dataclass

from dm_tools import SHARED_CLIENT_HEADERS


@dataclass(frozen=True, slots=True)
class Map:
    ID: int = None
    Directory: str = None
    MapName_lang: str = None
    MapDescription0_lang: str = None
    MapDescription1_lang: str = None
    PvpShortDescription_lang: str = None
    PvpLongDescription_lang: str = None
    Corpse_0: int = None
    Corpse_1: int = None
    MapType: int = None
    InstanceType: int = None
    ExpansionID: int = None
    AreaTableID: int = None
    LoadingScreenID: int = None
    TimeOfDayOverride: int = None
    ParentMapID: int = None
    CosmeticParentMapID: int = None
    TimeOffset: int = None
    MinimapIconScale: int = None
    CorpseMapID: int = None
    MaxPlayers: int = None
    WindSettingsID: int = None
    ZmpFileDataID: int = None
    WdtFileDataID: int = None
    NavigationMaxDistance: int = None
    PreloadFileDataID: int = None
    Flags_0: str = None
    Flags_1: str = None
    Flags_2: str = None

CLIENT_TIMEOUT = 30.0
client = httpx.Client(
    base_url=f"https://wago.tools/db2", headers=SHARED_CLIENT_HEADERS, http2=True, timeout=CLIENT_TIMEOUT
)

class DB2:
    def __init__(self, db2_name: str, row_type: type):
        self.name = db2_name
        self.row_type = row_type

    def read(self) -> list:
        endpoint = f"/{self.name}/csv"
        res = client.get(endpoint)
        res.raise_for_status()

        key = []
        rows = []
        for row in res.iter_lines():
            if not key:
                key = row.split(",")
                continue

            row = row.replace('"', "")
            row_data = dict(zip(key, row.split(",")))
            entry = self.row_type(**row_data)
            if not entry:
                continue
            rows.append(entry)
        return rows

MAP_DB2 = DB2("Map", Map)
