-- This script needs to be loaded before other scripts that use it.

local PlayerDefaults = {
	__index = {
		initialize = function(self)
			self.ActiveModifiers = {
				JudgmentGraphic = "Ice",
				Mini = "0%",
				BackgroundFilter = "Off",
				SpeedModType = "C",
				SpeedMod = 400,
				Vocalization = "None",
				NoteSkin = nil,
				HideTargets = false,
				HideSongBG = false,
				HideCombo = false,
				HideLifebar = false,
				HideScore = false,
				HideDanger = false,
				ColumnFlashOnMiss = false,
				SubtractiveScoring = false,
				MeasureCounterPosition = "Left",
				MeasureCounter = "None",
				TargetStatus="Disabled",
				TargetBar=11,
				TargetScore=false,
				LifeMeterType="Standard",
				DensityGraph="Disabled",
			}
			self.Streams = {
				SongDir = nil,
				StepsType = nil,
				Difficulty = nil,
				Measures = nil,
			}
			self.HighScores = {
				EnteringName = false,
				Name = ""
			}
			self.Stages = {
				Stats = {}
			}
			self.CurrentPlayerOptions = {
				String = nil
			}
		end
	}
}

local GlobalDefaults = {
	__index = {

		-- since the initialize() function is called every game cycle, the idea
		-- is to define variables we want to reset every game cycle inside
		initialize = function(self)
			self.ActiveModifiers = {
				MusicRate = 1.0,
				MusicRateEdit = 1.0,
				DecentsWayOffs = "On",
			}
			self.Stages = {
				PlayedThisGame = 0,
				Remaining = PREFSMAN:GetPreference("SongsPerPlay"),
				Stats = {}
			}
			self.ScreenAfter = {
				PlayAgain = "ScreenEvaluationSummary",
				PlayerOptions = "ScreenGameplay",
				PlayerOptions2 = "ScreenGameplay"
			}
			self.Gamestate = {
				Style = "single"
			}
			self.GameMode = "Competitive"
			self.ScreenshotTexture = nil
			self.MenuTimer = {
				ScreenSelectMusic = ThemePrefs.Get("ScreenSelectMusicMenuTimer"),
				ScreenPlayerOptions = ThemePrefs.Get("ScreenPlayerOptionsMenuTimer"),
				ScreenEvaluation = ThemePrefs.Get("ScreenEvaluationMenuTimer"),
				ScreenEvaluationSummary = ThemePrefs.Get("ScreenEvaluationSummaryMenuTimer"),
				ScreenNameEntry = ThemePrefs.Get("ScreenNameEntryMenuTimer"),
			}
			self.TimeAtSessionStart = nil
		end,

		-- These values outside initialize() won't be reset each game cycle,
		-- but are rather manipulated as needed by the theme.
		ActiveColorIndex = ThemePrefs.Get("SimplyLoveColor") or 1,
	}
}

-- "SL" is a general-purpose table that can be accessed from anywhere
-- within the theme and stores info that needs to be passed between screens
SL = {
	P1 = setmetatable( {}, PlayerDefaults),
	P2 = setmetatable( {}, PlayerDefaults),
	Global = setmetatable( {}, GlobalDefaults),
	
	Colors = {
		"#FF3C23",
		"#FF003C",
		"#C1006F",
		"#8200A1",
		"#413AD0",
		"#0073FF",
		"#00ADC0",
		"#5CE087",
		"#AEFA44",
		"#FFFF00",
		"#FFBE00",
		"#FF7D00"
	},
	JudgmentColors = {
		Competitive = {
			color("#21CCE8"),	-- blue
			color("#e29c18"),	-- gold
			color("#66c955"),	-- green
			color("#5b2b8e"),	-- purple
			color("#c9855e"),	-- peach?
			color("#ff0000")	-- red
		}
	},
	Preferences = {
		Competitive = {
			TimingWindowAdd=ThemePrefs.Get("TimingWindowAdd"),
			RegenComboAfterMiss=5,
			MaxRegenComboAfterMiss=10,
			MinTNSToHideNotes="TapNoteScore_W3",
			HarshHotLifePenalty=1,

			TimingWindowSecondsW1=0.021500,
			TimingWindowSecondsW2=0.043000,
			TimingWindowSecondsW3=0.102000,
			TimingWindowSecondsW4=0.135000,
			TimingWindowSecondsW5=0.180000,
			TimingWindowSecondsHold=0.320000,
			TimingWindowSecondsMine=0.070000,
			TimingWindowSecondsRoll=0.350000,
		},
	},
	Metrics = {
		Competitive = {
			PercentScoreWeightW1=5,
			PercentScoreWeightW2=4,
			PercentScoreWeightW3=2,
			PercentScoreWeightW4=0,
			PercentScoreWeightW5=-6,
			PercentScoreWeightMiss=-12,
			PercentScoreWeightLetGo=0,
			PercentScoreWeightHeld=5,
			PercentScoreWeightHitMine=-6,

			GradeWeightW1=5,
			GradeWeightW2=4,
			GradeWeightW3=2,
			GradeWeightW4=0,
			GradeWeightW5=-6,
			GradeWeightMiss=-12,
			GradeWeightLetGo=0,
			GradeWeightHeld=5,
			GradeWeightHitMine=-6,

			LifePercentChangeW1=0.008,
			LifePercentChangeW2=0.008,
			LifePercentChangeW3=0.004,
			LifePercentChangeW4=0.000,
			LifePercentChangeW5=-0.050,
			LifePercentChangeMiss=-0.100,
			LifePercentChangeLetGo=IsGame("pump") and 0.000 or -0.080,
			LifePercentChangeHeld=IsGame("pump") and 0.000 or 0.008,
			LifePercentChangeHitMine=-0.050,
		},
	}
}


-- Initialize preferences by calling this method.
--  We typically do this from ./BGAnimations/ScreenTitleMenu underlay.lua
--  so that preferences reset between each game cycle.

function InitializeSimplyLove()
	SL.P1:initialize()
	SL.P2:initialize()
	SL.Global:initialize()
end

-- TODO: remove this; it's for debugging purposes (Control+F2 to reload scripts) only
InitializeSimplyLove()
