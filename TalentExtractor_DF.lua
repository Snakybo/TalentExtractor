-- Talent Parser, a World of Warcraft addon to extract in-game data.
-- Copyright (C) 2024  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local initialSpecs = {
	WARRIOR = 1446,
	PALADIN = 1451,
	HUNTER = 1448,
	ROGUE = 1453,
	PRIEST = 1452,
	DEATHKNIGHT = 1455,
	SHAMAN = 1444,
	MAGE = 1449,
	WARLOCK = 1454,
	MONK = 1450,
	DRUID = 1447,
	DEMONHUNTER = 1456,
	EVOKER = 1465
}

--- @type Addon
local Addon = select(2, ...)

--- @type TalentProvider
local Provider = {
	minInterfaceVersion = 110000,
	maxInterfaceVersion = 120000,

	events = {
		"PLAYER_ENTERING_WORLD",
		"PLAYER_TALENT_UPDATE"
	},

	GetSize = function()
		return 2
	end,

	GetKey = function(index)
		if index == 1 then
			local _, fileName = UnitClass("player")
			return initialSpecs[fileName]
		end

		local id = GetSpecializationInfo(GetSpecialization())
		return id
	end,

	GetClassInfo = function()
		local name, fileName = UnitClass("player")

		return {
			className = name,
			classFileName = fileName
		}
	end,

	GetSpecInfo = function(index)
		if index == 1 then
			local _, fileName = UnitClass("player")

			return {
				specIndex = 5,
				specId = initialSpecs[fileName]
			}
		end

		index = GetSpecialization()
		local id, name, _, icon = GetSpecializationInfo(index)

		return {
			specIndex = index,
			specId = id,
			specName = name,
			specIcon = icon
		}
	end,

	GetPvpTalentInfo = function(index)
		local pvpTalents = {}

		if index == 1 then
			return pvpTalents
		end

		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(1)
		if slotInfo == nil then
			return pvpTalents
		end

		for i = 1, #slotInfo.availableTalentIDs do
			local id, name, icon = GetPvpTalentInfoByID(slotInfo.availableTalentIDs[i])

			table.insert(pvpTalents, {
				id = id,
				name = name,
				icon = icon
			})
		end

		return {
			pvpTalents = pvpTalents
		}
	end
}

Addon:RegisterProvider(Provider)
