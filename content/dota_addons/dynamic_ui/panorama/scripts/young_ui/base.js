"use strict";

// This is a function callback called by the registered event: GameEvents.Subscribe( "young_ui_create_panel", CreatePanel);
// Its used to create a new Panel of every type via lua!
function CreatePanel(msg)
{
	$.Msg(msg);
	var panel_parent_name = (msg.parent != null ? msg.parent : "root");
	var panel_type = (msg.type != null ? msg.type : "Panel");
	var panel_id = msg.id;
	
	var parent_panel = $.GetContextPanel();
	
	if (parent_panel!= "root")
	{
		var pp = $("#"+panel_parent_name);
		if (pp != null)
		{
			parent_panel = pp;
		}
	}
	var a = $.CreatePanel( panel_type, parent_panel, panel_id);
}

// This is a function callback called by the registered event: GameEvents.Subscribe( "young_ui_delete_panel", DeletePanel); 
// Its used to delete a Panel.
function DeletePanel(msg)
{
	if (msg.id != null)
	{
		var panel_id = msg.id;
		var pp = $(panel_id);
		if (pp != null)
		{
			pp.RemoveAndDeleteChildren();
		}
	}
}

// This is a function callback called by the registered event: GameEvents.Subscribe( "young_ui_set_panel_class", SetPanelClass); 
// Its used to set the given class of the panel to true.
function SetPanelClass(msg)
{
	if (msg.id != null && msg.class_name != null)
	{
		var panel_id = msg.id;
		var pp = $("#"+panel_id);
		if (pp != null)
		{
			pp.SetHasClass(msg.class_name,true);
		}
	}
}

// This is a function callback called by the registered event: GameEvents.Subscribe( "young_ui_remove_panel_class", RemovePanelClass); 
// Its used to set the given class of the panel to false.
function RemovePanelClass(msg)
{
	if (msg.id != null && msg.class_name != null)
	{
		var panel_id = msg.id;
		var pp = $("#"+panel_id);
		if (pp != null)
		{
			pp.SetHasClass(msg.class_name,false);
		}
	}
}

// This is a function callback called by the registered event: GameEvents.Subscribe( "young_ui_set_style_attribute", SetPanelStyleAttribute);
// Its used to modify the Panel's style attribute.
function SetPanelStyleAttribute(msg)
{
	// msg.attribute_value can be null (nil in lua) to delete the attribute
	if (msg.id != null && msg.attribute_name != null) // && msg.attribute_value != null
	{
		var panel_id = msg.id;
		var pp = $("#"+panel_id);
		if (pp != null)
		{
			pp.style[msg.attribute_name] = msg.attribute_value;
		}
	}
}

// This is a function callback called by the registered event: GameEvents.Subscribe( "young_ui_set_attribute", SetPanelAttribute); 
// Its used to modify the Panel's attributes.
function SetPanelAttribute(msg)
{
	// msg.attribute_value can be null (nil in lua) to delete the attribute
	if (msg.id != null && msg.attribute_name != null) // && msg.attribute_value != null
	{
		var panel_id = msg.id;
		var pp = $("#"+panel_id);
		if (pp != null)
		{
			// Auto Localization of strings
			if (typeof(msg.attribute_value) == "string")
			{
				pp[msg.attribute_name] = $.Localize(msg.attribute_value);
			} else {
				pp[msg.attribute_name] = msg.attribute_value;
			}
		}
	}
}

// This is a function callback called by the registered event: GameEvents.Subscribe( "young_ui_register_event", SetPanelEvent); 
// Its used to delete register a panorama event and callbacks it clientside (locally) to lua.
function SetPanelEvent(msg)
{
	// msg.event_name must match a valid Panorama event name.
	/*
	onload
	onactivate
	onmouseactivate
	oncontextmenu
	onfocus
	ondescendantfocus
	onblur
	ondescendantblur
	oncancel
	onmouseover
	onmouseout
	ondblclick
	onmoveup
	onmovedown
	onmoveleft
	onmoveright
	ontabforward
	ontabbackward
	onselect
	ondeselect
	onscrolledtobottom
	onscrolledtorightedge
	*/
	
	// msg.manager_event_name is the EventManager event name.
	if (msg.id != null && msg.event_name != null && msg.manager_event_name)
	{
		var panel_id = msg.id;
		var pp = $("#"+panel_id);
		if (pp != null)
		{
			pp.SetPanelEvent(
				msg.event_name,
				function(){
					GameEvents.SendCustomGameEventToServer(msg.manager_event_name,{});
				}
			)
		}
	}
}

function TEST(msg)
{
	$.Msg(msg);
}

// Add Events https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Panorama/Events#Event_Routing
// GameEvents.SendEventClientSide( cstring pEventName, js_object jsObject )

(function(){
	GameEvents.Subscribe( "young_ui_create_panel", CreatePanel); 
	GameEvents.Subscribe( "young_ui_delete_panel", DeletePanel); 
	GameEvents.Subscribe( "young_ui_set_panel_class", SetPanelClass); 
	GameEvents.Subscribe( "young_ui_remove_panel_class", RemovePanelClass); 
	GameEvents.Subscribe( "young_ui_set_style_attribute", SetPanelStyleAttribute); 
	GameEvents.Subscribe( "young_ui_set_attribute", SetPanelAttribute); 
	GameEvents.Subscribe( "young_ui_register_event", SetPanelEvent); 
	GameEvents.Subscribe( "test_event", TEST); 
	
	// Send just 1 Time an event to the server to say him the player just loaded the HUD UI.
	var playerId =  Players.GetLocalPlayer()
	//GameEvents.SendCustomGameEventToServer("young_ui_hud_loaded", {player_id: playerId})
	GameEvents.SendCustomGameEventToServer("young_ui_hud_loaded", {player_id: playerId})
	$.Msg("Young-UI Panorama Script successfully loaded");
})()
