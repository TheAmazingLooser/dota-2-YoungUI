Root = require "libraries.young_ui"

function LoadedHud(whatever,event_table)
	print(whatever, event_table)
	print("A player is read to render the HUD!")
	Root:Create("Button"):
		Create("Label"):
		SetText("Created with lua ♥").
	Parent:ListenToEvent("onactivate", function(self) self.Childs[1]:SetText("Clicked :D") end):
	ApplyClass("SimpleButton"):
	SetPosition(100,100)
end


CustomGameEventManager:RegisterListener("young_ui_hud_loaded", LoadedHud)