local player = ...

if SL[ ToEnumShortString(player) ].ActiveModifiers.HideScore then return end

if SL[ToEnumShortString(player)].ActiveModifiers.DensityGraph ~= "Enabled" then return end

		
local dance_points, percent
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local bitmap = Def.BitmapText{
	Font="_wendy monospace numbers",
	Text="0.00",

	Name=ToEnumShortString(player).."Score",
	InitCommand=function(self)
		self:valign(1):halign(1)
		-- TO-DO rewrite code to seperate each player to avoid funky 2 player score move interactions with density graph hide
		self:zoom(0.5):x(14.5):y(-50)
			if player == PLAYER_2 then
				-- TODO not tested
				self:x( _screen.cx - 305 )
			end
	end,
	JudgmentMessageCommand=function(self) self:queuecommand("RedrawScore") end,
	RedrawScoreCommand=function(self)
		dance_points = pss:GetPercentDancePoints()
		percent = FormatPercentScore( dance_points ):sub(1,-2)
		self:settext(percent)
	end
}

local af = Def.ActorFrame{}

af[#af+1] = bitmap
return af
