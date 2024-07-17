# Generating Map Data

In order to generate map data yourself, you'll need three things:
- Experience with Python and Python 3.12 or newer installed on your machine
- A local clone/download of this repository (not the addon files)
- A bit of patience

> [!CAUTION]
> Generating map data can be a very resource intensive process. By default, the script will use all of the available threads on your machine to make it as fast as possible. This will lead to other applications possibly becoming unresponsive for the duration.

In order to tweak the number of threads the script will use, open `Tools/generate_maps.py` and change `MAX_THREADS` from `os.cpu_count()` to a number of your choosing.

> [!NOTE]
> By default, the script will read the necessary map files from your existing WoW installation. If you want to generate maps for the beta branch, you need to have it installed locally. Be sure to update the `WOW_DIR` variable in `Tools/generate_maps.py` to point to your WoW installation. You can also change `FLAVOR` just below it to change which game flavor you want to generate maps for.

Once you have your environment set up, you can get started:
- Inside the base Datamine directory, open a new terminal window and install the requirements from `requirements.txt`
- Navigate to the `Tools/` directory and run `generate_maps.py`
  - This will automatically grab the necessary files from your WoW installation, parse them, generate Lua files, then put everything in the correct place and update the `Datamine_Maps.toc` file

