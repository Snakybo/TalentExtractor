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

--- @return table<integer,TalentNode[]>
local function GetTalents()
	--- @type TalentNode[]
	local result = {}

	local activeConfigId = C_ClassTalents.GetActiveConfigID()
	local config = C_Traits.GetConfigInfo(activeConfigId)

	if #config.treeIDs > 1 then
		error("More than 1 tree ID is not supported")
	end

	for _, treeId in ipairs(config.treeIDs) do
		local nodes = C_Traits.GetTreeNodes(treeId)

		for index, nodeId in ipairs(nodes) do
			local node = C_Traits.GetNodeInfo(activeConfigId, nodeId)

			if node.ID ~= 0 then
				--- @type TalentNode
				local nodeData = {
					nodeID = nodeId,
					posX = node.posX,
					posY = node.posY,
					type = node.type,
					visibleEdges = {},
					entryIDs = {}
				}

				for _, visibleEdge in ipairs(node.visibleEdges) do
					table.insert(nodeData.visibleEdges, {
						type = visibleEdge.type,
						visualStyle = visibleEdge.visualStyle,
						targetNode = visibleEdge.targetNode
					})
				end

				for _, entryId in ipairs(node.entryIDs) do
					local entry = C_Traits.GetEntryInfo(activeConfigId, entryId)
					local definition = C_Traits.GetDefinitionInfo(entry.definitionID)

					-- Hopefully temporary check, some NYI talents do not have a spellID but instead have overrideName and overrideIcon.
					if definition.spellID ~= nil then
						table.insert(nodeData.entryIDs, {
							entryID = entryId,
							type = entry.type,
							definitionID = entry.definitionID,
							spellID = definition.spellID,
							name = GetSpellInfo(definition.spellID)
						})
					end
				end

				if #nodeData.entryIDs > 0 then
					table.insert(result, nodeData)
				end
			end
		end
	end

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
