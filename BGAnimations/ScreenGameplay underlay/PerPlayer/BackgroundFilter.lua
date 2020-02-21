local player = ...
local mods = SL[ ToEnumShortString(player) ].ActiveModifiers

-- if no BackgroundFilter is necessary, it's safe to bail now
if mods.BackgroundFilter == "Off" then return end

local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

local filter = Def.ActorFrame{
	InitCommand=function(self) self:xy(GetNotefieldX(player), _screen.cy ) end,
	OffCommand=function(self) self:queuecommand("ComboFlash") end,
}

filter[#filter+1] = Def.Quad{
	InitCommand=function(self)
		self:diffuse(Color.Black)
			:diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
			:zoomto( GetNotefieldWidth(), _screen.h )
	end,
	ComboFlashCommand=function(self)
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		local FlashColor = nil

		local WorstAcceptableFC = { Casual=3, Competitive=3, ECFA=4, StomperZ=4 }

		for i=1,WorstAcceptableFC[SL.Global.GameMode] do
			if pss:FullComboOfScore("TapNoteScore_W"..i) then
				FlashColor = SL.JudgmentColors[SL.Global.GameMode][i]
				break
			end
		end

		if (FlashColor ~= nil) then
			self:accelerate(0.25):diffuse( FlashColor )
				:accelerate(0.5):faderight(1):fadeleft(1)
				:accelerate(0.15):diffusealpha(0)
		end
	end
}


return filter
