-- Disable unused self warnings.
self = false

-- Disable line length limits.
max_line_length = false
max_code_line_length = false
max_string_line_length = false
max_comment_line_length = false

-- Add exceptions for external libraries.
std = "lua51"

globals = {
	"TalentExtractor",
	"TalentExtractorData",
}

exclude_files = {
	"**/Libs",
	".luacheckrc",
}

ignore = {
	"542", -- empty if branch
}

read_globals = {
	-- Libraries
	"LibStub",

	-- WoW API globals
	"C_SpecializationInfo",
	"GetAddOnMetadata",
	"GetBuildInfo",
	"GetPvpTalentInfoByID",
	"GetSpecialization",
	"GetSpecializationInfo",
	"GetTalentInfo",
	"GetTime",
	"MAX_TALENT_TIERS",
	"NUM_TALENT_COLUMNS",
	"UnitClass",

	-- Lua globals
	"floor",
	"geterrorhandler",
	"error",
	"ipairs",
	"pairs",
	"print",
	"select",
	"setmetatable",
	"string",
	"table",
	"tonumber",
	"tostring",
	"type",

	-- Global table
	"_G"
}
