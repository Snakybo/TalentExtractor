-- This talent extractor is aimed at the talent system used from 1.0 until 4.X.

--- @class TalentExtractorV1 : TalentExtractor
TalentExtractorV1 = LibStub("AceAddon-3.0"):NewAddon("TalentExtractor", "AceEvent-3.0")
TalentExtractorV1.VERSION = C_AddOns.GetAddOnMetadata("TalentExtractor", "Version")

--- @return TalentContainer[]
local function GetTalents(tab)
	local result = {}

	for index = 1, GetNumTalents(tab) do
		local name, icon  = GetTalentInfo(tab, index)
		local talentID = (tab - 1) * MAX_NUM_TALENTS + index

		if name ~= nil then
			table.insert(result, {
				talentID = talentID,
				name = name,
				icon = icon
			})
		end
	end

	return result
end

local function PLAYER_ENTERING_WORLD()
	TalentExtractorV1:ParseTalents()
end

function TalentExtractorV1:OnInitialize()
	if TalentExtractorData == nil then
		TalentExtractorData = {}
	end
end

function TalentExtractorV1:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)
end

function TalentExtractorV1:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function TalentExtractorV1:ParseTalents()
	local className, classFileName = UnitClass("player")
	local _, build = GetBuildInfo()

	for tab = 1, GetNumTalentTabs() do
		local specID, specName, _, specIcon = GetTalentTabInfo(tab)
		local talents = GetTalents(tab)

		if not TalentExtractorData[specID] or TalentExtractorData[specID].lastUpdateBuild ~= build then
			TalentExtractorData[specID] = {
				lastUpdateBuild = build,
				specID = specID,
				specIndex = tab,
				specIcon = specIcon,
				specName = specName,
				className = className,
				classFileName = classFileName,
				talents = talents
			}

			print("TalentExtractor: Updated talent data for " .. specName .. " " .. className)
		end
	end
end
