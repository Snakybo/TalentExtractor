--- @class TalentExtractor
--- @field public VERSION string
--- @field public RegisterEvent function
--- @field public UnregisterEvent function

--- @class TalentNode
--- @field public nodeID integer
--- @field public posX integer
--- @field public posY integer
--- @field public type integer
--- @field public visibleEdges TalentEdge[]
--- @field public entryIDs table<integer,TalentEntry>

--- @class TalentEdge
--- @field public type integer
--- @field public visualStyle integer
--- @field public targetNode integer

--- @class TalentEntry
--- @field public entryID integer
--- @field public type integer
--- @field public definitionID integer
--- @field public spellID integer
--- @field public name string

--- @class TalentContainer
--- @field public talentID integer
--- @field public name string
