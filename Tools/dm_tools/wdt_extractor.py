"""Python script for extracting minimap textures from WDT files"""

import struct

from dataclasses import dataclass

from dm_tools import logger, FileReader


DEFAULT_MAP_SIZE_X = 64
DEFAULT_MAP_SIZE_Y = 64
WDT_FILE_INFO_MARKER = b"DIAM"
WDT_FILE_INFO_MARKER_SIZE = 8


@dataclass
class WDT:
    """structure: (https://wowdev.wiki/WDT)
    uint rootADT;            // reference to fdid of mapname_xx_yy.adt
    uint obj0ADT;            // reference to fdid of mapname_xx_yy_obj0.adt
    uint obj1ADT;            // reference to fdid of mapname_xx_yy_obj1.adt
    uint tex0ADT;            // reference to fdid of mapname_xx_yy_tex0.adt
    uint lodADT;             // reference to fdid of mapname_xx_yy_lod.adt
    uint mapTexture;         // reference to fdid of mapname_xx_yy.blp
    uint mapTextureN;        // reference to fdid of mapname_xx_yy_n.blp
    uint minimapTexture;     // reference to fdid of mapxx_yy.blp
    """

    x: int  # x and y are the grid coords for this obj
    y: int
    rootADT: int
    obj0ADT: int
    obj1ADT: int
    tex0ADT: int
    lodADT: int
    mapTexture: int
    mapTextureN: int
    minimapTexture: int

    def __init__(self, x: int, y: int, data):
        self.x, self.y = x, y
        self.rootADT = data[0]
        self.obj0ADT = data[1]
        self.obj1ADT = data[2]
        self.tex0ADT = data[3]
        self.lodADT = data[4]
        self.mapTexture = data[5]
        self.mapTextureN = data[6]
        self.minimapTexture = data[7]

        self.__all = {
            "rootADT": self.rootADT,
            "obj0ADT": self.obj0ADT,
            "obj1ADT": self.obj1ADT,
            "tex0ADT": self.tex0ADT,
            "lodADT": self.lodADT,
            "mapTexture": self.mapTexture,
            "mapTextureN": self.mapTextureN,
            "minimapTexture": self.minimapTexture,
        }

    def get_all(self):
        return self.__all.items()


class WDTReader(FileReader):
    """Reader/Downloader for WDT files, outputs map grids in the form of a 2-dimensional numpy array"""

    FORMAT = "IIIIIIII"
    TYPE = "WDT"

    def __init__(self, wow_path: str, product: str):
        self.PRODUCT = product
        self.CASC_PATH = wow_path
        super().__init__()

    def get_file_info(
        self,
        fdid: int,
        size_x: int = DEFAULT_MAP_SIZE_X,
        size_y: int = DEFAULT_MAP_SIZE_Y,
    ) -> list[WDT]:
        if int(fdid) == 0:
            return

        logger.info(f"Fetching map info for file {fdid}...")
        obj = self.read_by_fdid(fdid)

        if not obj:
            return

        start = obj.find(WDT_FILE_INFO_MARKER) + WDT_FILE_INFO_MARKER_SIZE
        entry_size = struct.calcsize(self.FORMAT)
        map_grid = []

        try:
            offset = start
            for x in range(size_x):
                for y in range(size_y):
                    data = struct.unpack(self.FORMAT, obj[offset : offset + entry_size])
                    map_grid.append(WDT(x, y, data))
                    offset = offset + entry_size
        except struct.error:
            logger.error(f"Error unpacking file {fdid}", exc_info=True)
            return

        return map_grid
