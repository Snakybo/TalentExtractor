--- @type TalentExtractor
TalentExtractor = LibStub("AceAddon-3.0"):NewAddon("TalentExtractor", "AceEvent-3.0")
TalentExtractor.VERSION = GetAddOnMetadata("TalentExtractor", "Version")

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
	DEMONHUNTER = 1456
}

--- @return TalentContainer[]
local function GetTalents()
	local result = {}

	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local talentID, name = GetTalentInfo(tier, column, 1)

			table.insert(result, {
				talentID = talentID,
				name = name
			})
		end
	end;

	return result
end

--- @return TalentContainer[][]
local function GetPvPTalents()
	local result = {}

	for slotIndex = 1, 3 do
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slotIndex)
		local availableTalentIDs = slotInfo.availableTalentIDs;

		result[slotIndex] = {}

		for i = 1, #availableTalentIDs do
			local talentID, name = GetPvpTalentInfoByID(availableTalentIDs[i])

			table.insert(result[slotIndex], {
				talentID = talentID,
				name = name
			})
		end
	end

	return result
end

local function PLAYER_ENTERING_WORLD()
	TalentExtractor:ParseInitialSpec()
	TalentExtractor:ParseTalents()
end

local function PLAYER_TALENT_UPDATE()
	TalentExtractor:ParseTalents()
end

function TalentExtractor:OnInitialize()
	if TalentExtractorData == nil then
		TalentExtractorData = {}
	end
end

function TalentExtractor:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", PLAYER_TALENT_UPDATE)
end

function TalentExtractor:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_TALENT_UPDATE")
end

function TalentExtractor:ParseInitialSpec()
	local className, classFileName = UnitClass("player")
	local specID, specName = initialSpecs[classFileName], "Initial"
	local _, build = GetBuildInfo()

	TalentExtractorData[specID] = {
		lastUpdateBuild = build,
		specID = specID,
		specIndex = 5,
		specName = specName,
		className = className,
		classFileName = classFileName,
		talents = {},
		pvpTalents = {{}, {}, {}}
	}
end

function TalentExtractor:ParseTalents()
	local specIndex = GetSpecialization()
	local specID, specName = GetSpecializationInfo(specIndex)
	local className, classFileName = UnitClass("player")
	local _, build = GetBuildInfo()

	if TalentExtractorData[specID] and TalentExtractorData[specID].lastUpdateBuild == build then
		return
	end

	local talents = GetTalents()
	local pvpTalents = GetPvPTalents()

	TalentExtractorData[specID] = {
		lastUpdateBuild = build,
		specID = specID,
		specIndex = specIndex,
		specName = specName,
		className = className,
		classFileName = classFileName,
		talents = talents,
		pvpTalents = pvpTalents
	}

	print("TalentExtractor: Updated talent and PvP talent data for " .. specName .. " " .. className .. " [" .. tostring(specID) .. "]")
end
