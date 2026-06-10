from pytoc import TOCFile

from pathlib import Path

toc_path = Path("./Datamine_Maps/Datamine_Maps.toc")
toc = TOCFile(toc_path)
print(toc.get_all_addon_file_names()[:5])
