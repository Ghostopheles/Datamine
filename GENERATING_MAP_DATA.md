# Generating Map Data

In order to generate map data yourself, you'll need three things:
- Experience with Python and Python 3.12 or newer installed on your machine
- A local clone/download of this repository (not the addon files)
- A bit of patience

> [!CAUTION]
> Generating map data can be a very resource intensive process. By default, the script will use all of the available threads on your machine to make it as fast as possible. This will lead to other applications possibly becoming unresponsive for the duration.

In order to tweak the number of threads the script will use, open `Tools/generate_maps.py` and change `MAX_THREADS` from `os.cpu_count()` to a number of your choosing.

> [!NOTE]
> By default, the script will never redownload files that are already present in the cache. This can be a problem when files are updated. However, as of right now, if any file is out-of-date, you'll need to redownload all of the files from the internet. If you know the `FileDataID` of the WDT, you can manually navigate to the cache at `Tools/dm_tools/cache` and delete the file with that ID to only download that file.

You can override this behavior using the `UPDATE_ALL` variable in `generate_maps.py`. `True` will make it redownload files, `False` will use the cache.

Once you have your environment set up, you can get started:
- Inside the base Datamine directory, open a new terminal window and install the requirements from `requirements.txt`
- Navigate to the `Tools/` directory and run `generate_maps.py`
  - This will automatically download the necessary files to your machine, parse them, generate Lua files, then put everything in the correct place and update the `Datamine_Maps.toc` file
  - After you've generated your maps, you can delete the no-longer-needed wdt files from `Tools/dm_tools/cache`, but beware - deleting these files means you'll have to re-download them from the internet next time you generate maps.

