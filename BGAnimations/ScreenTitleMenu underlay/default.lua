local TextColor = Color.White

local SongStats = SONGMAN:GetNumSongs() .. " songs in "
SongStats = SongStats .. SONGMAN:GetNumSongGroups() .. " groups, "
SongStats = SongStats .. #SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses")) .. " courses"

-- - - - - - - - - - - - - - - - - - - - -

local game = GAMESTATE:GetCurrentGame():GetName();
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

-- - - - - - - - - - - - - - - - - - - - -
local sm_version = ""
local sl_version = GetThemeVersion()

if ProductVersion():find("git") then
	local date = VersionDate()
	local year = date:sub(1,4)
	local month = date:sub(5,6)
	if month:sub(1,1) == "0" then month = month:gsub("0", "") end
	month = THEME:GetString("Months", "Month"..month)
	local day = date:sub(7,8)

	sm_version = ProductID() .. ", Built " .. month .. " " .. day .. ", " .. year
else
	sm_version = ProductID() .. sm_version
end
-- - - - - - - - - - - - - - - - - - - - -

local af = Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL_Initialize.lua
		InitializeSimplyLove()

		self:Center()
	end,
	OffCommand=cmd(linear,0.5; diffusealpha, 0),

	Def.ActorFrame{
		InitCommand=function(self) self:zoom(1):y(-220):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(0.2):linear(0.4):diffusealpha(1) end,

		Def.BitmapText{
			Font="_miso",
			Text=sm_version,
			InitCommand=function(self) self:x(-265):diffuse(TextColor) end,
		},
		Def.BitmapText{
			Font="_miso",
			Text=sl_version and ("Theme v"..sl_version) or "",
			InitCommand=function(self) self:x(-267):y(20):diffuse(TextColor) end,
		},
		Def.BitmapText{
			Font="_miso",
			Text=SongStats,
			InitCommand=function(self) self:y(10):diffuse(TextColor) end,
		}
	},
}

return af