function PlayerColor( pn )
	if pn == PLAYER_1 then return color("#7623ba") end
	if pn == PLAYER_2 then return color("#00b5af") end
	return color("1,1,1,1")
end

function GetHexColor( n )
	local clr = ((n - 1) % #SL.Colors) + 1
	if SL.Colors[clr] then
		return color(SL.Colors[clr])
	end
	
	-- if we were passed nil or a non-integer, return white
	return Color.White
end



function GetCurrentColor()
	return GetHexColor( SL.Global.ActiveColorIndex )
end

function DifficultyColor( difficulty )

	if difficulty  == "Difficulty_Edit" then return color("#B4B7BA") end
	if difficulty  == "Difficulty_Challenge" then return color("#0074ff") end
	if difficulty  == "Difficulty_Hard" then return color("#bc1818") end
	if difficulty  == "Difficulty_Medium" then return color("#e0d91d") end
	if difficulty  == "Difficulty_Easy" then return color("#18af34") end
	if difficulty  == "Difficulty_Beginner" then return color("#6d1daa") end
end

function GetYOffsetByDifficulty(difficulty)

	if difficulty == "Difficulty_Edit" then
		return 5
	end
	
	-- Use Enum's reverse lookup functionality to find difficulty by index
	-- note: this is 0 indexed, so Beginner is 0, Challenge is 4, and Edit is 5
	-- for our purposes, increment by one here
	return Difficulty:Reverse()[difficulty] + 1
end

function DifficultyIndexColor( i )
	local clr = SL.Global.ActiveColorIndex + (i-2)
	return GetHexColor(clr)
end

function ColorRGB( n )
	local clr = n + SL.Global.ActiveColorIndex
	return GetHexColor(clr)
end