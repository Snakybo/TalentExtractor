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
	DEMONHUNTER = 1456,
	EVOKER = 1465
}

local isUpdating

local function StripColorCodes(str)
	str = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
	str = string.gsub(str, "|c%x%x %x%x%x%x%x", "") -- the trading parts colour has a space instead of a zero for some weird reason
	str = string.gsub(str, "|r", "")

	return str
end

--- @return table<integer,TalentNode[]>?
local function GetTalents()
	--- @type TalentNode[]
	local result = {}

	local configID = C_ClassTalents.GetActiveConfigID()
	local configInfo = C_Traits.GetConfigInfo(configID)
	local treeID = configInfo.treeIDs[1]
	local nodes = C_Traits.GetTreeNodes(treeID)

	for _, nodeID in ipairs(nodes) do
		local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)

		if nodeInfo.ID ~= 0 then
			local node = {
				ID = nodeInfo.ID,
				posX = nodeInfo.posX,
				posY = nodeInfo.posY,
				maxRanks = nodeInfo.maxRanks,
				flags = nodeInfo.flags,
				type = nodeInfo.type,
				entryIDs = nodeInfo.entryIDs,
				entries = {},
				conditionIDs = nodeInfo.conditionIDs,
				conditions = {},
				visibleEdges = {}
			}

			for i = 1, #nodeInfo.entryIDs do
				local entryID = nodeInfo.entryIDs[i]
				local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
				local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)

				if definitionInfo.spellID ~= nil then
					node.entries[entryID] = {
						entryID = entryID,
						type = entryInfo.type,
						maxRanks = entryInfo.maxRanks,
						definition = {
							spellID = definitionInfo.spellID,
							name = StripColorCodes(TalentUtil.GetTalentNameFromInfo(definitionInfo)),
							subtext = TalentUtil.GetTalentSubtextFromInfo(definitionInfo),
							description = TalentUtil.GetTalentDescriptionFromInfo(definitionInfo),
							overrideSpellID = TalentUtil.GetReplacesSpellNameFromInfo(definitionInfo),
							icon = TalentButtonUtil.CalculateIconTexture(definitionInfo)
						}
					}
				else
					table.remove(nodeInfo.entryIDs, i)
				end
			end

			for _, conditionID in ipairs(nodeInfo.conditionIDs) do
				local conditionInfo = C_Traits.GetConditionInfo(configID, conditionID)

				node.conditions[conditionID] = {
					conditionID = conditionID,
					specSetID = conditionInfo.specSetID,
					isGate = conditionInfo.isGate,
					isAlwaysMet = conditionInfo.isAlwaysMet,
					traitCurrencyID = conditionInfo.traitCurrencyID
				}
			end

			for _, edge in ipairs(nodeInfo.visibleEdges) do
				table.insert(node.visibleEdges, {
					visualStyle = edge.visualStyle,
					type = edge.type,
					targetNode = edge.targetNode
				})
			end

			table.insert(result, node)
		end
	end

	return result
end

--- @return TalentContainer[][]
local function GetPvPTalents()
	local result = {}

	local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(1)
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
		TalentExtractor:ParseTalents()
		isUpdating = false
	end)
end

local function PLAYER_ENTERING_WORLD()
	TalentExtractor:ParseInitialSpec()

	DelayParseTalents()
end

local function PLAYER_TALENT_UPDATE()
	DelayParseTalents()
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
		pvpTalents = {}
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
