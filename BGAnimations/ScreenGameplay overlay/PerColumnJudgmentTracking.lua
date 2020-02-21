local player = ...
local judgments = {}
for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
judgments[#judgments+1] = { W1=0, W2=0, W3=0, W4=0, W5=0, Miss=0 }
end



return Def.Actor{
JudgmentMessageCommand=function(self, params)
	local health_state = GAMESTATE:GetPlayerState(params.Player):GetHealthState()
	if health_state == 'HealthState_Dead' then return end
	if params.Player == player and params.Notes then
		for i,col in pairs(params.Notes) do
			local tns = ToEnumShortString(params.TapNoteScore)
			judgments[i][tns] = judgments[i][tns] + 1
		end
	end
end,
OffCommand=function(self)
	local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
	storage.column_judgments = judgments
end
}