local dark = {0,0,0,0.9}
local light = {0.65,0.65,0.65,1}

return Def.ActorFrame{
	Name="Header",

	Def.Quad{
		InitCommand=function(self)
			self:zoomto(_screen.w, 32):vertalign(top):x(_screen.cx)
			self:diffuse(light)
		end,
		ScreenChangedMessageCommand=function(self)
			local topscreen = SCREENMAN:GetTopScreen():GetName()
		end,
	},

	Def.BitmapText{
		Name="HeaderText",
		Font="_edit undo brk",
		Text=ScreenString("HeaderText"),
		InitCommand=cmd(diffusealpha,0; zoom,WideScale(0.6,0.7); horizalign, left; xy, 10, 13 ),
		OnCommand=cmd(sleep, 0.1; decelerate,0.33; diffusealpha,1),
		OffCommand=cmd(accelerate,0.33; diffusealpha,0)
	}
}
