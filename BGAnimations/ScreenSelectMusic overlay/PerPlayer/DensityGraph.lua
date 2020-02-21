local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]
local show = false
local nsj = GAMESTATE:GetNumSidesJoined()

local function getInputHandler(actor)
    return (function (event)
	if event.GameButton == "MenuLeft" and event.PlayerNumber == player and GAMESTATE:IsHumanPlayer(event.PlayerNumber) and nsj == 1 then
        if event.type == "InputEventType_FirstPress" then
                show = false
                actor:queuecommand("UpdateGraphState")
		elseif event.type == "InputEventType_Release" or not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
                show = true
                actor:queuecommand("UpdateGraphState")
		end
	end
	if event.GameButton == "MenuRight" and event.PlayerNumber == player and GAMESTATE:IsHumanPlayer(event.PlayerNumber) and nsj == 1 then
        if event.type == "InputEventType_FirstPress" then
                show = false
                actor:queuecommand("UpdateGraphState")
		elseif event.type == "InputEventType_Release" or not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
                show = true
                actor:queuecommand("UpdateGraphState")
		end
	end
	if event.GameButton == "MenuLeft" and nsj == 2 then
        if event.type == "InputEventType_FirstPress" then
                show = false
                actor:queuecommand("UpdateGraphState")
		elseif event.type == "InputEventType_Release" then
                show = true
                actor:queuecommand("UpdateGraphState")
		end
	end
	if event.GameButton == "MenuRight" and nsj == 2 then
        if event.type == "InputEventType_FirstPress" then
                show = false
                actor:queuecommand("UpdateGraphState")
		elseif event.type == "InputEventType_Release" then
                show = true
                actor:queuecommand("UpdateGraphState")
		end
	end

        return false
    end)
end

local bannerWidth = 370
local bannerHeight = 140
local padding = 10

return Def.ActorFrame {
    -- song and course changes
    OnCommand=cmd(queuecommand, "StepsHaveChanged"),
    CurrentSongChangedMessageCommand=cmd(queuecommand, "StepsHaveChanged"),
    CurrentCourseChangedMessageCommand=cmd(queuecommand, "StepsHaveChanged"),

    InitCommand=function(self)
        local zoom, xPos

        if IsUsingWideScreen() then
            zoom = 0.7655
            xPos = 145
        else
            zoom = 0.75
            xPos = 142
        end
        
        self:zoom(zoom)
        self:xy(_screen.cx - xPos - ((bannerWidth / 2 - padding) * zoom), 310 - ((bannerHeight / 2 - padding) * zoom))

        if (player == PLAYER_1 and GAMESTATE:IsHumanPlayer(PLAYER_1)) then
            show = true
        end

        if (player == PLAYER_2 and GAMESTATE:IsHumanPlayer(PLAYER_2)) then
            show = true
            self:addy((bannerHeight / 2 - (padding * 0.5)) * zoom)
        end

        self:diffusealpha(0)
        self:queuecommand("Capture")
    end,

    CaptureCommand=function(self)
        SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self))
    end,
    
    StepsHaveChangedCommand=function(self, params)
        if show then
            self:queuecommand("UpdateGraphState")
        end
    end,

    PlayerJoinedMessageCommand=function(self, params)
        nsj = GAMESTATE:GetNumSidesJoined()
		if params.Player == player then
            self:playcommand("Init")
		end
	end,

    UpdateGraphStateCommand=function(self, params)
        if show and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
            local song = GAMESTATE:GetCurrentSong()
            local steps = GAMESTATE:GetCurrentSteps(player)
            self:playcommand("ChangeSteps", {song=song, steps=steps})
            self:stoptweening()
            self:linear(0.1):diffusealpha(0.9)
        else
            self:stoptweening()
            self:linear(0.1):diffusealpha(0)
        end
    end,

    CreateDensityGraph(bannerWidth - (padding * 2), bannerHeight / 2 - (padding * 1.5)),

    Def.Quad {
        InitCommand=function(self)
            self:zoomto(bannerWidth - (padding * 2), 20)
                :diffuse(color("#000000"))
                :diffusealpha(0.8)
                :align(0, 0)
                :y(bannerHeight / 2 - (padding * 1.5) - 20)
        end,
    },
    
    Def.BitmapText{
        Font="_miso",
        InitCommand=function(self)
            self:diffuse(color("#ffffff"))
                :horizalign("left")
                :y(bannerHeight / 2 - (padding * 1.5) - 20 + 2)
                :x(5)
                :maxwidth(bannerWidth - (padding * 2) - 10)
                :align(0, 0)
                :Stroke(color("#000000"))
        end,

        StepsHaveChangedCommand=function(self, params)
            if show then
                self:queuecommand("UpdateGraphState")
            end
        end,

        UpdateGraphStateCommand=function(self)
            if show and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
                local song_dir = GAMESTATE:GetCurrentSong():GetSongDir()
                local steps = GAMESTATE:GetCurrentSteps(player)
				
				if steps == nil then return end
				
                local steps_type = ToEnumShortString( steps:GetStepsType() ):gsub("_", "-"):lower()
                local difficulty = ToEnumShortString( steps:GetDifficulty() )
                local breakdown = GetStreamBreakdown(song_dir, steps_type, difficulty)
                
                if breakdown == "" or breakdown == nil then
                    self:settext("No streams!")
                else
                    self:settext("Streams: " .. breakdown)
                end
                
                return true
            end
        end
    }
}