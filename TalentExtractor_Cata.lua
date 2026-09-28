-- Talent Extractor, a World of Warcraft addon to extract in-game data.
-- Copyright (C) 2026  Kevin Krol
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

--- @type TalentExtractorInternal
local Addon = select(2, ...)

--- @type TalentProvider
local Provider = {
	minInterfaceVersion = 40400,
	maxInterfaceVersion = 50000,

	events = {
		"PLAYER_ENTERING_WORLD",
		"PLAYER_TALENT_UPDATE"
	},

	GetSize = function()
		return GetNumTalentTabs()
	end,

	GetKey = function(index)
		local id = GetTalentTabInfo(index)
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
		local id, name, _, icon = GetTalentTabInfo(index)

		return {
			specIndex = index,
			specId = id,
			specName = name,
			specIcon = icon
		}
	end,

	GetTalentInfo = function(index)
		--- @type Talent[]
		local talents = {}

		--- @type TalentInfoQuery
		local query = {
			specializationIndex = index
		}

        for i = 1, GetNumTalents(index) do
			query.talentIndex = i

			local talent  = C_SpecializationInfo.GetTalentInfo(query)
			local id = (index - 1) * MAX_NUM_TALENTS + i

			if talent ~= nil then
				table.insert(talents, {
					id = id,
					name = talent.name,
					icon = talent.icon
                })
            else
				TalentExtractor:LogWarning("Failed to get talent info for {tab}-{index}", index, i)
			end
		end

		return {
			talents = talents
		}
	end
}

Addon:RegisterProvider(Provider)
