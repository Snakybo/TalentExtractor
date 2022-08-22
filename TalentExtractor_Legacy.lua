--- @type TalentExtractor
TalentExtractor = LibStub("AceAddon-3.0"):NewAddon("TalentExtractor", "AceEvent-3.0")
TalentExtractor.VERSION = GetAddOnMetadata("TalentExtractor", "Version")

--- @return TalentContainer[]
local function GetTalents()
	local result = {}

	for tab = 1, GetNumTalentTabs() do
		for index = 1, GetNumTalents(tab) do
			local name  = GetTalentInfo(tab, index)
			local talentID = (tab - 1) * MAX_NUM_TALENTS + index

			table.insert(result, {
				talentID = talentID,
				name = name
			})
		end
	end

	return result
end

local function PLAYER_ENTERING_WORLD()
	TalentExtractor:ParseTalents()
end

function TalentExtractor:OnInitialize()
	if TalentExtractorData == nil then
		TalentExtractorData = {}
	end
end

function TalentExtractor:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)
end

function TalentExtractor:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function TalentExtractor:ParseTalents()
	local className, classFileName = UnitClass("player")
	local _, build = GetBuildInfo()

	if TalentExtractorData[classFileName] and TalentExtractorData[classFileName].lastUpdateBuild == build then
		return
	end

	local talents = GetTalents()

	TalentExtractorData[classFileName] = {
		lastUpdateBuild = build,
		className = className,
		classFileName = classFileName,
		talents = talents
	}

	print("TalentExtractor: Updated talent data for " .. className)
end
