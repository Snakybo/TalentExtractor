# WoW Talent Extractor

This simple addon extracts data that may not be accessible at runtime.

Data may contain:

* Class information
* Specialization information
* Talent information
* PvP talent information

Depending on the expansion and implementation, any of these may or may not be extracted.

## Installation

Simply download this repository and drag it into your `Interface/Addons` folder.

## Usage

1. Create a character of every class, a high-level preset is preferred as some data can only be retrieved for the active specialization, so access to spec switching is recommended.
2. If the game version supports it, switch between all available specializations.
3. Repeat for each class

## Toolchain

This addon is stage one of a two-stage process. After extracting all talent data, copy the saved variables file for use in [Talent Parser](https://github.com/Snakybo/TalentParser).
