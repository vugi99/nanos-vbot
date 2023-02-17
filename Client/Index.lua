


function VBot.prototype:SetValue(key, value)
    if self:IsValid(true) then
        if (not self.Stored.Values[key] or self.Stored.Values[key] ~= value) then
            self.Stored.Values[key] = value
            VBot.CallEvent("ValueChange", self, key, value)
        end
    end
end

function VBot.prototype:SetVOIPVolume(volume)
    if self:IsValid(true) then
        if type(volume) == "number" then
            self.Stored.VOIPVolume = volume
        end
    end
end

function VBot.prototype:SetVOIPSetting(setting)
    if self:IsValid(true) then
        if type(setting) == "number" then
            self.Stored.VOIPSetting = setting
        end
    end
end

function VBot.prototype:GetCameraLocation()
    if self:IsValid(true) then
        return Vector()
    end
end

function VBot.prototype:GetCameraRotation()
    if self:IsValid(true) then
        return Rotator()
    end
end

function VBot.prototype:GetCameraArmLength()
    if self:IsValid(true) then
        return 100
    end
end

function VBot.prototype:IsHost()
    if self:IsValid(true) then
        return false
    end
end

function VBot.prototype:IsLocalPlayer()
    if self:IsValid(true) then
        return false
    end
end

function CL_VZBot(Bot_id, tbl, from_reload)

    local Bot = setmetatable({}, VBot.prototype)

    Bot.ID = Bot_id

    Bot.Stored = tbl
    Bot.Stored.Values = {}
    Bot.BOT = true
    Bot.Valid = true

    Bot.Stored.Name = "Bot " .. tostring(Bot.ID)

    local l_count = table_last_count(ALL_BOTS)
    ALL_BOTS[l_count + 1] = Bot

    if not from_reload then
        VBot.CallEvent("Spawn", Bot)

        if Bot.Stored.Possessed then
            VBot.CallEvent("Possess", Bot, Bot.Stored.Possessed)
        end

        for k2, v2 in pairs(tbl.SyncedValues) do
            VBot.CallEvent("ValueChange", Bot, k2, v2)
        end
    end

    return ALL_BOTS[l_count + 1]
end
Events.SubscribeRemote("CL_CreateBotInstance", CL_VZBot)

Events.SubscribeRemote("BotLeft", function(Bot_id)
    for k, v in pairs(ALL_BOTS) do
        if v.ID == Bot_id then
            VBot.CallEvent("Destroy", v)
            v.Valid = false
            ALL_BOTS[k] = nil
            break
        end
    end
end)

Events.SubscribeRemote("BotUpdateValue", function(Bot_id, key, value)
    local bot = GetBotFromBotID(Bot_id)
    if (bot and bot.Valid) then
        local address = bot.Stored
        if type(key) == "string" then
            if key == "Possess" then
                if not value then
                    VBot.CallEvent("UnPossess", bot, address[key])
                end
            end
            address = address[key]
            if key == "Possess" then
                if value then
                    VBot.CallEvent("Possess", bot, value)
                end
            end
        elseif type(key) == "table" then
            for i, v in ipairs(key) do
                address = address[key]
            end
            address = value
            if key[1] == "BotUpdateValue" then
                VBot.CallEvent("ValueChange", bot, key[2], value)
            end
        else
            error("What is that type of key ? BotUpdateValue")
        end
    end
end)