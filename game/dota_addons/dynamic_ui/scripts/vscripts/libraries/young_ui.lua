--FireGameEventLocal

require 'libraries.class'

--[[
This library gives you the possibility to create the HUD UI 100% in lua.
You dont have to care about networking and so on since its handled 100% by this library it self.
To manage stylesheets you have to modify the young_ui_hud.xml in the /content/panorama/custom_game/ path.
]]

if YoungUi == nil then
	YoungUi = class:new()
end

YoungUi.Id = "root"
YoungUi.Parent = nil
YoungUi.Type = "Panel"
YoungUi.Childs = {} -- Tables are references so we need to reapply this in the init() function!

-- Used for local attributes, if you change the values in this table the Panorama does NOT get updated!
YoungUi.Attributes = {}

-- Advanced UI settings.
-- The code uses the booleans in the specific sequence like below
YoungUi.ChildIsAll = true -- if this is true, no checks happen if its for a team or not 
YoungUi.ChildIsTeam = false -- if this is true, no checks happen if its for a specific player or not 
YoungUi.ChildIsPlayer = false
YoungUi.ChildTarget = nil -- If the target is not for all then this carries the target for the Event!

-- Own target stuff, DO NOT CHANGE THIS IF YOU ARE NOT KNOWING WHAT YOU'RE DOING :D
YoungUi._SelfIsAll = true
YoungUi._SelfIsTeam = false
YoungUi._SelfIsPlayer = false
YoungUi._SelfTarget = nil

function YoungUi:init(id, parent)
	self.Id = id
	self.Parent = parent
	self.Childs = {}
	self.Attributes = {}
end

-- Target handling. This is used to target a specific Team, User or even target All players (this is default)
-- If the target changed, its only creating childs for the given targets! Means, the UI stays active for a user even if he would not be the target anymore.
-- Also, can only set the Target if its valid (If the parent is a higher target then the child) (TargetAll > TargetTeam > TargetPlayer)
-- Kinda wasted function but hey, just to get it completed :D
function YoungUi:SetTargetAll()
	if self._SelfIsAll then
		self.ChildIsAll = true
		self.ChildIsTeam = false
		self.ChildIsPlayer = false
		self.ChildTarget = nil
	end
	return self
end

function YoungUi:SetTargetTeam(TeamNumber)

	if not self._SelfIsPlayer then
		self.ChildIsAll = false
		self.ChildIsTeam = true
		self.ChildIsPlayer = false
		self.ChildTarget = TeamNumber
	end
	return self
end

-- This works always :D
function YoungUi:SetTargetPlayer(PlayerHandle)
	self.ChildIsAll = false
	self.ChildIsTeam = false
	self.ChildIsPlayer = true
	self.ChildTarget = TeamNumber
	return self
end

-- This function is called internally and should not get touched elsewhere. It just handles the event sendings for the new child with the respect of the targets.
function YoungUi:MasterSend_Child(EventName, TableValues)
	if self.ChildIsAll then
		CustomGameEventManager:Send_ServerToAllClients(EventName,TableValues)
	elseif self.ChildIsTeam then
		CustomGameEventManager:Send_ServerToTeam(self.ChildTarget,EventName,TableValues)
	elseif self.ChildIsPlayer then
		CustomGameEventManager:Send_ServerToPlayer(self.ChildTarget,EventName,TableValues)
	else
		print("[YoungUI]: Cant send (Child-)Event, no targets!")
	end
	return self
end
function YoungUi:MasterSend_Self(EventName, TableValues)
	if self._SelfIsAll then
		CustomGameEventManager:Send_ServerToAllClients(EventName,TableValues)
	elseif self._SelfIsTeam then
		CustomGameEventManager:Send_ServerToTeam(self._SelfTarget,EventName,TableValues)
	elseif self._SelfIsPlayer then
		CustomGameEventManager:Send_ServerToPlayer(self._SelfTarget,EventName,TableValues)
	else
		print("[YoungUI]: Cant send (Self-)Event, no targets!")
	end
	return self
end

-- End of the targetings


-- Creating and Deletion stuff

function YoungUi:Create(...)
	return self:CreatePanel(...)
end

function YoungUi:CreatePanel(Type, ID)
	Type = Type or "Panel"
	local usedId = ID or DoUniqueString(Type)

	self:MasterSend_Child("young_ui_create_panel",
	{
		type = Type,
		parent = self.Id,
		id = usedId
	})

	local newObject = YoungUi:new(usedId, self)
	newObject._SelfIsAll = self.ChildIsAll
	newObject._SelfIsTeam = self.ChildIsTeam
	newObject._SelfIsPlayer = self.ChildIsPlayer
	newObject._SelfTarget = self.Target
	newObject.Type = Type

	table.insert(self.Childs, newObject)
	return newObject
end

-- Deleting the current Panel. Call this function parameterless!
function YoungUi:_Delete(__LuaDelete)
	if #self.Childs > 0 then
		for i = 1, #self.Childs do
			self.Childs[i]:Delete(true)
		end
	end
	if self.Parent then
		MasterSend_Self("young_ui_delete_panel",
			{
				id = self.Id
			})

		self = nil
	end
	return self or self.Parent
end

-- For the users which think the _Delete is the original delte and they call it with a parameter.
function YoungUi:Delete()
	return self:_Delete()
end

-- End of Creating and Deletion stuff

-- Attribute Stuff

function YoungUi:SetAttribute(AttributeName, AttributeValue)
	self:MasterSend_Self("young_ui_set_attribute",
	{
		id = self.Id,
		attribute_name = AttributeName,
		attribute_value = AttributeValue -- if this is nil, the attribute is getting deleted
	})

	self.Attributes[AttributeName] = AttributeValue
	return self
end

-- Sets the specific style Attribute to the given value
-- For example: object:SetStyleAttribute("width", "32px")
function YoungUi:SetStyleAttribute(AttributeName, AttributeValue)
	self:MasterSend_Self("young_ui_set_style_attribute",
	{
		id = self.Id,
		attribute_name = AttributeName,
		attribute_value = AttributeValue -- if this is nil, the attribute is getting deleted
	})

	self.Attributes["style"] = self.Attributes["style"] or {} 

	self.Attributes["style"][AttributeName] = AttributeValue
	return self
end

-- This function resends ALL local stored attributes to the panorama, this function can slow down the server and the targets if it is called repeatedly (use it wisely)
-- This function is not able to updated locally deleted attributes! You must delete them directly with YoungUi:SetAttribute(AttributeName, AttributeValue)
-- As long as the user is not creating useless tables it works like a charme but its still a recursive function :/
function YoungUi:UpdateAllAttributes()
	local function Update(t)
		for k,v in pairs(t) do
			if type(v) ~= "table" then
				self:SetAttribute(k,v)
			else
				Update(v)
			end
		end
	end

	Update(self.Attributes)
	
	return self
end

-- Little helper function because the text is often used.
function YoungUi:SetText(text)
	self:SetAttribute("text",text)
	return self
end

function YoungUi:SetPosition(x,y)
	self:SetStyleAttribute("position", x.."px "..y.."px 1px")
	return self
end

-- End of Attribute stuff

-- CSS Class stuff
-- Note: If you need to apply (include) a custom css include it within the <styles> tag in the file "/content/dota_addons/[ADDON_NAME]/panorama/layout/custom_game/young_ui_hud.xml"

function YoungUi:ApplyClass(ClassName)
	self:MasterSend_Self("young_ui_set_panel_class",{
		id = self.Id,
		class_name = ClassName or "ERROR_NO_CLASS_NAME"
	})
	return self
end

function YoungUi:RemoveClass(ClassName)
	self:MasterSend_Self("young_ui_remove_panel_class",{
		id = self.Id,
		class_name = ClassName or "ERROR_NO_CLASS_NAME"
	})
	return self
end
-- End style sheets

-- Event stuff
-- Sadly Javascript does not allow us the delete the events. We need to keep a track on that.
function YoungUi:ListenToEvent(PanoramaEvent, CallbackFunction)
	self:MasterSend_Self("young_ui_register_event",{
		id = self.Id,
		event_name = PanoramaEvent,
		manager_event_name = self.Id -- Hope that this name is not exceeding 32 chars in the length :/
	})

	CustomGameEventManager:RegisterListener(self.Id, function(msg)
		-- print(self.Id .. " - Event: ".. PanoramaEvent)
		if CallbackFunction then CallbackFunction(self) end -- to keep the self variable alive.
	end)
	return self
end

return YoungUi:new("root")