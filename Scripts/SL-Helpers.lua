------------------------------------------------------------------------------
-- call this to draw a Quad with a border
-- width of quad, height of quad, and border width, in pixels

function Border(width, height, bw)
	return Def.ActorFrame {
		Def.Quad {
			InitCommand=cmd(zoomto, width-2*bw, height-2*bw;  MaskSource,true)
		},
		Def.Quad {
			InitCommand=cmd(zoomto,width,height; MaskDest)
		},
		Def.Quad {
			InitCommand=cmd(diffusealpha,0; clearzbuffer,true)
		},
	}
end


------------------------------------------------------------------------------
-- Misc Lua functions that didn't fit anywhere else...

-- helper function used to detmerine which timing_window a given offset belongs to
function DetermineTimingWindow(offset)
	for i=1,5 do
		if math.abs(offset) < SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..i] + SL.Preferences[SL.Global.GameMode]["TimingWindowAdd"] then
			return i
		end
	end
	return 5
end


function GetCredits()
	local coins = GAMESTATE:GetCoins()
	local coinsPerCredit = PREFSMAN:GetPreference('CoinsPerCredit')
	local credits = math.floor(coins/coinsPerCredit)
	local remainder = coins % coinsPerCredit

	local r = {
		Credits=credits,
		Remainder=remainder,
		CoinsPerCredit=coinsPerCredit
	}
	return r
end

-- Used in Metrics.ini for ScreenRankingSingle and ScreenRankingDouble
function GetStepsTypeForThisGame(type)
	local game = GAMESTATE:GetCurrentGame():GetName()
	-- capitalize the first letter
	game = game:gsub("^%l", string.upper)

	return "StepsType_" .. game .. "_" .. type
end


function GetNotefieldX( player )
	local p = ToEnumShortString(player)

	local IsPlayingDanceSolo = (GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo")
	local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player') or IsPlayingDanceSolo
	local NumPlayersEnabled = GAMESTATE:GetNumPlayersEnabled()
	local NumSidesJoined = GAMESTATE:GetNumSidesJoined()

	if IsUsingSoloSingles and NumPlayersEnabled == 1 and NumSidesJoined == 1 then return _screen.cx end
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then return _screen.cx end

	local NumPlayersAndSides = ToEnumShortString( GAMESTATE:GetCurrentStyle():GetStyleType() )
	return THEME:GetMetric("ScreenGameplay","Player".. p .. NumPlayersAndSides .."X")
end

function GetNotefieldWidth()

	-- double
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
		return _screen.w*1.058/GetScreenAspectRatio()

	-- dance solo
	elseif GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo" then
		return _screen.w*0.8/GetScreenAspectRatio()

	-- single
	else
		return _screen.w*0.529/GetScreenAspectRatio()
	end
end

------------------------------------------------------------------------------
-- Define what is necessary to maintain and/or increment your combo, per Gametype.
-- For example, in dance Gametype, TapNoteScore_W3 (window #3) is commonly "Great"
-- so in dance, a "Great" will not only maintain a player's combo, it will also increment it.
--
-- We reference this function in Metrics.ini under the [Gameplay] section.
function GetComboThreshold( MaintainOrContinue )
	local CurrentGame = string.lower( GAMESTATE:GetCurrentGame():GetName() )

	local ComboThresholdTable = {
		dance	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		pump	=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
		techno	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		kb7		=	{ Maintain = "TapNoteScore_W4", Continue = "TapNoteScore_W4" },
		-- these values are chosen to match Deluxe's PARASTAR
		para	=	{ Maintain = "TapNoteScore_W5", Continue = "TapNoteScore_W3" },

		-- I don't know what these values are supposed to actually be...
		popn	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" },
		beat	=	{ Maintain = "TapNoteScore_W3", Continue = "TapNoteScore_W3" }
	}

	return ComboThresholdTable[CurrentGame][MaintainOrContinue]
end


function SetGameModePreferences()
	for key,val in pairs(SL.Preferences[SL.Global.GameMode]) do
		PREFSMAN:SetPreference(key, val)
	end

	-- Now that we've set the SL table for DecentsWayOffs appropriately,
	-- use it to apply DecentsWayOffs as a mod.
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local OptRow = CustomOptionRow( "DecentsWayOffs" )
		OptRow:LoadSelections( OptRow.Choices, player )
	end

	local prefix = {
		Competitive = "",
	}

	if PROFILEMAN:GetStatsPrefix() ~= prefix[SL.Global.GameMode] then
		PROFILEMAN:SetStatsPrefix(prefix[SL.Global.GameMode])
	end
end

function GetOperatorMenuLineNames()
	local lines = "System,KeyConfig,TestInput,Visual,GraphicsSound,Arcade,Input,Theme,MenuTimer,CustomSongs,Advanced,Profiles,Reload"

	-- the TestInput screen only supports dance, pump, and techno; remove it when in other games
	local CurrentGame = GAMESTATE:GetCurrentGame():GetName()
	if not (CurrentGame=="dance" or CurrentGame=="pump" or CurrentGame=="techno") then
		lines = lines:gsub("TestInput,", "")
	end

	-- hide the OptionRow for ClearCredits if we're not in CoinMode_Pay; it doesn't make sense to show for at-home players
	-- note that (EventMode + CoinMode_Pay) will actually place you in CoinMode_Home
	if GAMESTATE:GetCoinMode() ~= "CoinMode_Pay" then
		lines = lines:gsub("ClearCredits,", "")
	end

	-- CustomSongs preferences don't exist in 5.0.x, which many players may still be using
	-- thus, if the preference for CustomSongsEnable isn't found in this version of SM, don't let players
	-- get into the CustomSongs submenu in the OperatorMenu by removing that OptionRow
	if not PREFSMAN:PreferenceExists("CustomSongsEnable") then
		lines = lines:gsub("CustomSongs,", "")
	end
	return lines
end


function GetSimplyLoveOptionsLineNames()
	local lines = "TimingWindowAdd,CustomFailSet,MusicWheelStyle,MusicWheelSpeed,EvalSummary,NameEntry,GameOver,HideStockNoteSksins,DanceSolo,WriteOffsetDataToDisk"
	if Sprite.LoadFromCached ~= nil then
		lines = lines .. ",UseImageCache"
	end
	return lines
end


function GetPlayerOptionsLineNames()
	return "SpeedModType,SpeedMod,Mini,Perspective,NoteSkin2,Judgment,BackgroundFilter,MusicRate,Difficulty,ScreenAfterPlayerOptions"
end

function GetPlayerOptions2LineNames()
	local mods = "Turn,Scroll,10,12,Hide,LifeMeterType,TargetStatus,GameplayExtras,MeasureCounterPosition,MeasureCounter,DensityGraph,ScreenAfterPlayerOptions2"

	-- remove TargetStatus and TargetBar (IIDX pacemaker) if style is double
	if SL.Global.Gamestate.Style == "double" then
		mods = mods:gsub("TargetStatus,TargetBar,ActionOnMissedTarget,", "")
	end

	-- only show if the user is in event mode
	-- no need to have this show up in arcades.
	-- the pref is also checked against EventMode during runtime.
	if not PREFSMAN:GetPreference("EventMode") then
		mods = mods:gsub("ActionOnMissedTarget,", "")
	end

	return mods
end

GetStepsCredit = function(player)
	local t = {}

	if GAMESTATE:IsCourseMode() then
		local course = GAMESTATE:GetCurrentCourse()
		-- scripter
		if course:GetScripter() ~= "" then t[#t+1] = course:GetScripter() end
		-- description
		if course:GetDescription() ~= "" then t[#t+1] = course:GetDescription() end
	else
		local steps = GAMESTATE:GetCurrentSteps(player)
		-- credit
		if steps:GetAuthorCredit() ~= "" then t[#t+1] = steps:GetAuthorCredit() end
		-- description
		if steps:GetDescription() ~= "" then t[#t+1] = steps:GetDescription() end
		-- chart name
		if steps:GetChartName() ~= "" then t[#t+1] = steps:GetChartName() end
	end

	return t
end


GetThemeVersion = function()
	local file = IniFile.ReadFile( THEME:GetCurrentThemeDirectory() .. "ThemeInfo.ini" )
	if file then
		if file.ThemeInfo and file.ThemeInfo.Version then
			return file.ThemeInfo.Version
		end
	end
	return false
end

local function FilenameIsMultiFrameSprite(filename)
	-- look for the "[frames wide] x [frames tall]"
	-- and some sort of all-letters file extension
	-- Lua doesn't support an end-of-string regex marker...
	return string.match(filename, " %d+x%d+") and string.match(filename, "%.[A-Za-z]+")
end

local function StripSpriteHints(filename)
	-- handle common cases here, gory details in /src/RageBitmapTexture.cpp
	return filename:gsub(" %d+x%d+", ""):gsub(" %(doubleres%)", ""):gsub(".png", "")
end

function CleanString(filename)
	-- do a couple text conversions to allow spaces and periods in display strings
	-- without causing so much grief with SM loading
	-- Suppose two images named "A" and "A B" are in the same folder
	-- Attempting to load "A" will throw a nonsensical but harmless error
	local name = filename:gsub("_", " ")
	name = name:gsub("`", ".")

	return name
end

function GetJudgmentGraphics(mode)
	local path = THEME:GetPathG('', '_judgments/' .. mode)
	local files = FILEMAN:GetDirListing(path .. '/')
	local judgment_graphics = {}

	for k,filename in ipairs(files) do

		-- Filter out files that aren't judgment graphics
		-- e.g. hidden system files like .DS_Store
		if FilenameIsMultiFrameSprite(filename) then

			-- use regexp to get only the name of the graphic, stripping out the extension
			local name = StripSpriteHints(filename)

			-- Fill the table, special-casing Love so that it comes first.
			if name == "Love" then
				table.insert(judgment_graphics, 1, name)
			else
				judgment_graphics[#judgment_graphics+1] = name
			end
		end
	end

	-- "None" -> no graphic in Player judgment lua
	judgment_graphics[#judgment_graphics+1] = "None"

	return judgment_graphics
end
