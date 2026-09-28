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

--- @return integer?
local function GetConfigID()
	local specGroup = C_SpecializationInfo.GetActiveSpecGroup()
	return C_SpecializationInfo.GetCombatConfigIDForSpecGroup(specGroup)
end

--- @param configID integer
--- @return integer?
local function GetTreeID(configID)
	local configInfo = C_Traits.GetConfigInfo(configID)
	return configInfo ~= nil and configInfo.treeIDs[1] or nil
end

--- @type TalentProvider
local Provider = {
	minInterfaceVersion = 16000,
	maxInterfaceVersion = 20000,

	events = {
		"PLAYER_ENTERING_WORLD",
		"TRAIT_CONFIG_UPDATED"
	},

	GetSize = function()
		return 1
	end,

	GetKey = function(index)
		local _, fileName = UnitClass("player")
		return fileName
	end,

	GetClassInfo = function()
		local name, fileName = UnitClass("player")

		return {
			className = name,
			classFileName = fileName
		}
	end,

	GetTalentInfo = function()
		--- @type Talent[]
		local talents = {}

		local configID = GetConfigID()
		local treeID = configID ~= nil and GetTreeID(configID) or nil

		if treeID == nil then
			TalentExtractor:LogWarning("No talent tree available")
			return {
				talents = talents
			}
		end

		for _, nodeID in ipairs(C_Traits.GetTreeNodes(treeID) or {}) do
			local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)

			if nodeInfo ~= nil and nodeInfo.isVisible then
				for _, entryID in ipairs(nodeInfo.entryIDs) do
					local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
					local definitionInfo = entryInfo ~= nil and entryInfo.definitionID ~= nil and C_Traits.GetDefinitionInfo(entryInfo.definitionID) or nil

					if definitionInfo ~= nil and definitionInfo.spellID ~= nil then
						table.insert(talents, {
							id = entryID,
							name = definitionInfo.overrideName or C_Spell.GetSpellName(definitionInfo.spellID),
							icon = definitionInfo.overrideIcon or C_Spell.GetSpellTexture(definitionInfo.spellID)
						})
					end
				end
			end
		end

		return {
			talents = talents
		}
	end
}

Addon:RegisterProvider(Provider)
