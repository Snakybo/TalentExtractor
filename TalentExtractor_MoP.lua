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

--- @type Addon
local Addon = select(2, ...)

--- @type TalentProvider
local Provider = {
	minInterfaceVersion = 50500,
	maxInterfaceVersion = 60000,

	events = {
		"PLAYER_ENTERING_WORLD",
		"PLAYER_TALENT_UPDATE"
	},

	GetSize = function()
		return GetNumSpecializations()
	end,

	GetKey = function(index)
		local id = C_SpecializationInfo.GetSpecializationInfo(index)
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
		local id, name, _, icon = C_SpecializationInfo.GetSpecializationInfo(index)

		return {
			specIndex = index,
			specId = id,
			specName = name,
			specIcon = icon
		}
	end,

	GetTalentInfo = function()
		--- @type Talent[]
		local talents = {}

		for tier = 1, MAX_NUM_TALENT_TIERS do
			for column = 1, NUM_TALENT_COLUMNS do
				local query = {
					tier = tier,
					column = column
				}

				local info = C_SpecializationInfo.GetTalentInfo(query)

				table.insert(talents, {
					id = info.talentID,
					name = info.name,
					icon = info.icon
				})
			end
		end

		return {
			talents = talents
		}
	end
}

Addon:RegisterProvider(Provider)
