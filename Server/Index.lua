


function VBot.prototype:Possess(char)
    if self:IsValid(true) then
        if (char and char:IsValid()) then
            self.Stored.Possessed = char
            VBot.CallEvent("Possess", self, char)
            Events.BroadcastRemote("BotUpdateValue", self.ID, "Possessed", char)
        end
    end
end

function VBot.prototype:UnPossess()
    if self:IsValid(true) then
        if self.Stored.Possessed then
            VBot.CallEvent("UnPossess", self, self.Stored.Possessed)
            self.Stored.Possessed = nil
            Events.BroadcastRemote("BotUpdateValue", self.ID, "Possessed", nil)
        end
    end
end

function VBot.prototype:SetName(name)
    if self:IsValid(true) then
        if name then
            if type(name) == "string" then
                self.Stored.Name = name
                Events.BroadcastRemote("BotUpdateValue", self.ID, "Name", name)
            end
        end
    end
end


function VBot.prototype:SetVOIPChannel(channel)
    if self:IsValid(true) then
        if type(channel) == "number" then
            self.Stored.VOIPChannel = channel
            Events.BroadcastRemote("BotUpdateValue", self.ID, "VOIPChannel", channel)
        end
    end
end

function VBot.prototype:SetVOIPVolume(volume)
    if self:IsValid(true) then
        if type(volume) == "number" then
            self.Stored.VOIPVolume = volume
            Events.BroadcastRemote("BotUpdateValue", self.ID, "VOIPVolume", volume)
        end
    end
end

function VBot.prototype:SetVOIPSetting(setting)
    if self:IsValid(true) then
        if type(setting) == "number" then
            self.Stored.VOIPSetting = setting
            Events.BroadcastRemote("BotUpdateValue", self.ID, "VOIPSetting", setting)
        end
    end
end

function VBot.prototype:GetIP()
    if self:IsValid(true) then
        return "127.0.0.1"
    end
end

function VBot.prototype:Kick()
    if self:IsValid(true) then
        self.Valid = false

        for k, v in pairs(ALL_BOTS) do
            if v.ID == self.ID then
                VBot.CallEvent("Destroy", v)
                Events.BroadcastRemote("BotLeft", self.ID)
                ALL_BOTS[k] = nil
                break
            end
        end
    end
end

function VBot.prototype:SetValue(key, value, sync)
    if self:IsValid(true) then
        local keyV = "Values"
        if sync then
            keyV = "SyncedValues"
        end
        if (not self.Stored[keyV][key] or self.Stored[keyV][key] ~= value) then
            self.Stored[keyV][key] = value
            if sync then
                Events.BroadcastRemote("BotUpdateValue", self.ID, {keyV, key}, self.Stored[keyV][key])
            end
            VBot.CallEvent("ValueChange", self, key, value)
        end
    end
end

function VBotJoin(from_reload_data)
    local Bot = setmetatable({}, VBot.prototype)

    local from_reload
    if from_reload_data then
        from_reload = true
    end

    local this_id = Bots_ID
    if not from_reload_data then
        Bots_ID = Bots_ID + 1
        this_id = Bots_ID
        Bot.ID = this_id

        Bot.Stored = {}
        Bot.Stored.Values = {}
        Bot.Stored.SyncedValues = {}
        Bot.Stored.NanosID = 500200 + this_id
        Bot.Stored.Name = "Bot " .. tostring(this_id)
    else
        this_id = from_reload_data[1]
        Bot.ID = this_id
        Bot.Stored = from_reload_data[2]
    end

    Bot.BOT = true
    Bot.Valid = true

    local l_count = table_last_count(ALL_BOTS)
    ALL_BOTS[l_count + 1] = Bot

    Events.BroadcastRemote("CL_CreateBotInstance", Bot.ID, Bot.Stored, from_reload)

    if not from_reload then
        VBot.CallEvent("Spawn", Bot)
    end

    return ALL_BOTS[l_count + 1]
end
Package.Export("VBotJoin", VBotJoin)

DEFAULT_EREMOTE = Events.CallRemote

function Events.CallRemote(event_name, ply, ...)
    if ply.BOT then
        Events.Call("BOT_" .. event_name, ply, ...)
        return true
    end

    return DEFAULT_EREMOTE(event_name, ply, ...)
end

DEFAULT_EBROADCAST = Events.BroadcastRemote

function Events.BroadcastRemote(event_name, ...)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            Events.Call("BOT_" .. event_name, v, ...)
        end
    end

    return DEFAULT_EBROADCAST(event_name, ...)
end

Player.Subscribe("Spawn", function(ply)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            Events.CallRemote("CL_CreateBotInstance", ply, v.ID, v.Stored)
        end
    end
end)

--[[Package.Subscribe("Unload", function()
    local tbl_bots_data = {}
    for k, v in pairs(VBot.GetPairs()) do
        table.insert(tbl_bots_data, {v.ID, v.Stored})
    end
	Server.SetValue("Bots_For_Reload", tbl_bots_data)
end)

Package.Subscribe("Load", function()
	local bots_data = Server.GetValue("Bots_For_Reload") or {}

	if (#bots_data > 0) then
		for k, v in pairs(bots_data) do
			VBotJoin(v)
		end
	end
end)]]--