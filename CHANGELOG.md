# Datamine 2.5.4

### Updated
- Reworked map generation tooling, regenerated all maps for 12.1.0.69299

### Fixed
- Fixed a call to a non-existent function in the MovieFrame code
- Fixed an issue with aura secrecy on aura tooltips
    - Unfortunately, this means we get essentially zero tooltip info on these tooltips now, too bad!

# Datamine 2.5.3

### Updated
- Reworked the localization system to remove the dependency on AceLocale
    - This should also prevent issues with missing strings going forward
- Updated map data for 12.1.0.69111

### Fixed
- Fixed a call to the deprecated `MouseIsOver` function
- Improved performance of setting lookups
    - This might be noticable when viewing certain types of tooltips. Thanks Numy for pointing this out.
- Looking up an outfit with malicious data should no longer create a black hole
