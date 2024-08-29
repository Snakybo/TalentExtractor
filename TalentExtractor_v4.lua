-- This talent extractor is aimed at the talent system used from 4.0 until 9.X.

--- @class TalentExtractorV3 : TalentExtractor
TalentExtractorV3 = LibStub("AceAddon-3.0"):NewAddon("TalentExtractor", "AceEvent-3.0")
TalentExtractorV3.VERSION = C_AddOns.GetAddOnMetadata("TalentExtractor", "Version")

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

local isUpdating

--- @return TalentContainer[][]
local function GetPvPTalents()
	local result = {}

	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(1)
	if  slotInfo == nil then
		return result
	end

	local availableTalentIDs = slotInfo.availableTalentIDs;

	for i = 1, #availableTalentIDs do
		local talentID, name, texture = GetPvpTalentInfoByID(availableTalentIDs[i])

		result[i] = {
			talentID = talentID,
			name = name,
			icon = texture
		}
	end

	return result
end

local function DelayParseTalents()
	if isUpdating then
		return
	end

	isUpdating = true

	C_Timer.After(1, function()
		TalentExtractorV3:ParseTalents()
		isUpdating = false
	end)
end

local function PLAYER_ENTERING_WORLD()
	TalentExtractorV3:ParseInitialSpec()

	DelayParseTalents()
end

local function PLAYER_TALENT_UPDATE()
	DelayParseTalents()
end

function TalentExtractorV3:OnInitialize()
	if TalentExtractorData == nil then
		TalentExtractorData = {}
	end
end

function TalentExtractorV3:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", PLAYER_TALENT_UPDATE)
end

function TalentExtractorV3:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_TALENT_UPDATE")
end

function TalentExtractorV3:ParseInitialSpec()
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
		pvpTalents = {}
	}
end

function TalentExtractorV3:ParseTalents()
	local specIndex = GetSpecialization()
	local specID, specName = GetSpecializationInfo(specIndex)
	local className, classFileName = UnitClass("player")
	local _, build = GetBuildInfo()

	if TalentExtractorData[specID] and TalentExtractorData[specID].lastUpdateBuild == build then
		return
	end

	local pvpTalents = GetPvPTalents()

	TalentExtractorData[specID] = {
		lastUpdateBuild = build,
		specID = specID,
		specIndex = specIndex,
		specName = specName,
		className = className,
		classFileName = classFileName,
		pvpTalents = pvpTalents
	}

	print("TalentExtractor: Updated PvP talent data for " .. specName .. " " .. className .. " [" .. tostring(specID) .. "]")
end
