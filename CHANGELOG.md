# Datamine 2.5.2

### Updated
- Reworked the localization system to remove the dependency on AceLocale
    - This should also prevent issues with missing strings going forward
- Updated map data for 12.1.0.69111

### Fixed
- Fixed a call to the deprecated `MouseIsOver` function
- Improved performance of setting lookups
    - This might be noticable when viewing certain types of tooltips. Thanks Numy for pointing this out.
- Looking up an outfit with malicious data should no longer create a black hole
