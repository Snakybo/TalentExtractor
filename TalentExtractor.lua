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

--- @class TalentProvider
--- @field public minInterfaceVersion integer
--- @field public maxInterfaceVersion integer
--- @field public events string[]
--- @field public GetSize fun(): integer
--- @field public GetKey fun(index: integer): unknown
--- @field public GetClassInfo fun(): ClassInfoContainer
--- @field public GetSpecInfo? fun(index: integer): SpecInfoContainer
--- @field public GetTalentInfo? fun(index: integer): TalentInfoContainer
--- @field public GetPvpTalentInfo? fun(index: integer): PvpTalentInfoContainer

--- @class Talent
--- @field public id integer
--- @field public name string
--- @field public icon integer

--- @class ClassInfoContainer
--- @field public className string
--- @field public classFileName string

--- @class SpecInfoContainer
--- @field public specIndex integer
--- @field public specId integer
--- @field public specName string
--- @field public specIcon integer

--- @class TalentInfoContainer
--- @field public talents Talent[]

--- @class PvpTalentInfoContainer
--- @field public pvpTalents Talent[]

--- @class Addon
--- @field private frame Frame
local Addon = select(2, ...)

--- @param key unknown
--- @param build integer
--- @return boolean
local function IsUpdateRequired(key, build)
	return TalentExtractorData == nil or
	       TalentExtractorData.data[key] == nil or
		   TalentExtractorData.data[key].lastUpdateBuild < build
end

--- @param source table<string, unknown>
--- @param destination table<string, unknown>
local function CopyTo(source, destination)
	for k, v in pairs(source) do
		destination[k] = v
	end
end

local function OnEvent()
	C_Timer.After(0.5, function()
		Addon:Collect()
	end)
end

function Addon:Collect()
	local _, buildStr = GetBuildInfo()
	local build = tonumber(buildStr) --[[@as integer]]

	for i = 1, self.provider.GetSize() do
		local key = self.provider.GetKey(i)

		if IsUpdateRequired(key, build) then
			local data = {
				lastUpdateBuild = build
			}

			CopyTo(self.provider.GetClassInfo(), data)

			if self.provider.GetSpecInfo ~= nil then
				CopyTo(self.provider.GetSpecInfo(i), data)
			end

			if self.provider.GetTalentInfo ~= nil then
				CopyTo(self.provider.GetTalentInfo(i), data)
			end

			if self.provider.GetPvpTalentInfo ~= nil then
				CopyTo(self.provider.GetPvpTalentInfo(i), data)
			end

			TalentExtractorData = TalentExtractorData or {
				data = {}
			}

			TalentExtractorData.minInterfaceVersion = self.provider.minInterfaceVersion
			TalentExtractorData.maxInterfaceVersion = self.provider.maxInterfaceVersion
			TalentExtractorData.data[key] = data

			print("Updated talent data for", key)
		end
	end
end

--- @param provider TalentProvider
function Addon:RegisterProvider(provider)
	local interfaceVersion = select(4, GetBuildInfo())

	if interfaceVersion >= provider.minInterfaceVersion and interfaceVersion < provider.maxInterfaceVersion then
		if self.provider ~= nil then
			error("Multiple providers registered")
		end

		self.provider = provider

		for _, event in ipairs(provider.events) do
			self.frame:RegisterEvent(event)
		end
	end
end

Addon.frame = CreateFrame("Frame")
Addon.frame:SetScript("OnEvent", OnEvent)
