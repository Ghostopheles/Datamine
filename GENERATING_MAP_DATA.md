# Generating Map Data

In order to generate map data yourself, you'll need three things:
- Experience with Python and Python 3.12 or newer installed on your machine
- A local clone/download of this repository (not the addon files)
- A bit of patience

Once you have your environment set up, you can get started:
- Inside the base Datamine directory, open a new terminal window and install the requirements from `requirements.txt`
- Navigate to the `Tools/` directory and run `generate_maps.py`
  - This will automatically download the necessary files to your machine, parse them, generate Lua files, then put everything in the correct place and update the `Datamine_Maps.toc` file
  - After you've generated your maps, you can delete the no-longer-needed wdt files from `Tools/dm_tools/cache`, but beware - deleting these files means you'll have to re-download them from the internet next time you generate maps.
