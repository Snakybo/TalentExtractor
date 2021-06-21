# WoW Talent Extractor

A WoW addon to be used alongside [WoW Talent Parser](https://github.com/Snakybo/TalentParser) to provide talent and PvP talent data for [LibTalentInfo](https://github.com/snakybo/LibTalentInfo).

The usage chain of these three items is:

1. **WoW Talent Extractor (this)** serializes talent and PvP talent data from in-game for manipulation out-of-game.
2. **WoW Talent Parsor parses** parses the serialized data and converts it into a Lua table that is suitable for usage by LibTalentInfo.
3. **LibTalentInfo** injects the data back into the game as a library.

## Installation

Simply download this repository and drag it into your `Interface/Addons` folder.

## Usage

The addon will automatically work when you log in or switch specialization. It captures and serializes information about the talents and PvP talents for the current specialization.

The data is saved inside of the `WTF` folder.

To manipulate the data, use [WoW Talent Parser](https://github.com/Snakybo/TalentParser).
