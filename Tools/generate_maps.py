import os
import concurrent.futures

from dm_tools import WDTReader, WDT, MAP_DB2, Map

MAX_THREADS = os.cpu_count()
UPDATE_ALL = False

parent_directory = os.path.dirname(os.getcwd())
ADDON_DIR = os.path.join(parent_directory, "Datamine_Maps")
OUTPUT_DIR = os.path.join(ADDON_DIR, "Generated")

TOC_FILE_LIST_LINE_NO = 17

os.makedirs(OUTPUT_DIR, exist_ok=True)

LUA_FORMAT = """-- This file was generated by generate_maps.py
-- WDTFileDataID: {wdtFileDataID}
-- Map Name: {map_name}

local _, Datamine_Maps = ...;

Datamine_Maps[{wdtFileDataID}] = {{
    {map_info}
}};
"""


def tabs(depth: int):
    return "\t" * depth


def add_map_files_to_toc():
    toc_path = os.path.join(ADDON_DIR, "Datamine_Maps.toc")
    with open(toc_path, "r") as f:
        toc_lines = f.readlines()

    with open(toc_path, "w") as f:
        f.truncate()
        f.writelines(toc_lines[:TOC_FILE_LIST_LINE_NO])

        for file in os.listdir(OUTPUT_DIR):
            if file.endswith(".lua"):
                f.write(f"Generated/{file}\n")
            else:
                os.remove(os.path.join(OUTPUT_DIR, file))


def lua_format(wdtFileDataID: int, map_name: str, map_info: str):
    return LUA_FORMAT.format(
        wdtFileDataID=wdtFileDataID, map_name=map_name, map_info=map_info
    )


def format_map_grids(map_grids: list[WDT]):
    all_grids = "{"

    # map textures
    mapTextures = f"\n{tabs(2)}MapTextures = {{"
    mapTexturesN = f"\n{tabs(2)}MapTexturesN = {{"
    minimapTextures = f"\n{tabs(2)}MinimapTextures = {{"
    for grid in map_grids:
        mapTextures += f"\n{tabs(3)}{grid.mapTexture},"
        mapTexturesN += f"\n{tabs(3)}{grid.mapTextureN},"
        minimapTextures += f"\n{tabs(3)}{grid.minimapTexture},"

    mapTextures += f"\n{tabs(2)}}},"
    mapTexturesN += f"\n{tabs(2)}}},"
    minimapTextures += f"\n{tabs(2)}}},"

    all_grids += mapTextures
    all_grids += mapTexturesN
    all_grids += minimapTextures
    all_grids += f"\n{tabs(1)}}}"

    return all_grids


def format_map_info(map: Map, map_grids_str: str) -> str:
    map_info = f"""MapName = "{map.MapName_lang}",
    MapID = {map.ID},
    Directory = [[{map.Directory}]],
    MapDescription0 = [[{map.MapDescription0_lang}]],
    MapDescription1 = [[{map.MapDescription1_lang}]],
    MapType = {map.MapType},
    InstanceType = {map.InstanceType},
    ExpansionID = {map.ExpansionID},
    ParentMapID = {map.ParentMapID},
    CosmeticParentMapID = {map.CosmeticParentMapID},
    Grids = {map_grids_str}"""

    return map_info


wdt_reader = WDTReader()
maps = MAP_DB2


def write_map_file(map: Map):
    if map.WdtFileDataID == 0:
        return

    map_grids = wdt_reader.get_file_info(map.WdtFileDataID)

    if not map_grids:
        return

    map_grids_str = format_map_grids(map_grids)
    map_info = format_map_info(map, map_grids_str)

    map_name = map.Directory.replace(" ", "")
    output_file = os.path.join(OUTPUT_DIR, f"Map_{map_name}.lua")
    with open(output_file, "w") as f:
        f.write(
            lua_format(
                wdtFileDataID=map.WdtFileDataID, map_name=map_name, map_info=map_info
            )
        )


_maps = []
for map in maps.read():
    _maps.append(map)

with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_THREADS) as executor:
    futures = [executor.submit(write_map_file, map) for map in _maps]
    concurrent.futures.wait(futures)

add_map_files_to_toc()
