if not ThemePrefs.Get("WriteOffsetDataToDisk") then return end

local player = ...

-- table to store transient judgment data in as it is broadcast by the engine to the theme
local judgment_data = {}

local columns = {
	pump = { "DownLeft", "UpLeft", "Center", "UpRight", "DownRight" },
	techno = { "DownLeft", "Left", "UpLeft", "Down", "Up", "UpRight", "Right", "DownRight" },
	dance = { "Left", "Down", "Up", "Right" }
}

for i, col_name in ipairs( columns[GAMESTATE:GetCurrentGame():GetName()] ) do
	judgment_data[i] = {}
end


local WriteFileToDisk = function(year, month, day, seconds)

	local year, month, day = Year(), MonthOfYear() + 1, DayOfMonth()
	local hour, minute, second = Hour(), Minute(), Second()
	local seconds = (hour*60*60) + (minute*60) + second

	local song = GAMESTATE:GetCurrentSong()
	local group_name = song:GetGroupName()
	local song_name = song:GetMainTitle()

	local path = THEME:GetCurrentThemeDirectory() .."/OffsetData/"..year.."-"..month.."-"..day.."-"..seconds.."-"..song_name.."-"..ToEnumShortString(player)..".txt"

	local data = ""
	data = data..group_name.."/"..song_name.."\n"
	data = data..year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second.."\n"
	data = data..player.."\n\n"

	for c, col_name in ipairs( columns[GAMESTATE:GetCurrentGame():GetName()] ) do
		data = data.."--- " .. col_name .. " ---\n"

		for i, offset in ipairs(judgment_data[c]) do
			data = data..tostring(offset).."\n"
		end

		data = data.."\n\n\n"
	end

	local f = RageFileUtil.CreateRageFile()

	if f:Open(path, 2) then
		f:Write( data )
	else
		local fError = f:GetError()
		SM("There was some kind of error writing your offset data to disk.  Sorry about this.")
		Trace( "[FileUtils] Error writing to ".. path ..": ".. fError )
		f:ClearError()
	end

	f:destroy()
end


-- ----------------------------------------------------------
-- actually hook into the screen so that we can do things at screen's JudgmentMessageCommand and OffCommand

return Def.Actor{
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end

		-- ignore miss judgments; they are asigned an offset of 0 by the engine, which would be misleading here
		if params.TapNoteOffset and params.TapNoteScore ~= "TapNoteScore_Miss" then
			for k,_ in pairs(params.Notes) do
				table.insert(judgment_data[k], params.TapNoteOffset)
			end
		end
	end,

	OffCommand=function(self)
		WriteFileToDisk()
	end
}