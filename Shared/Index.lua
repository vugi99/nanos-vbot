


function table_count(ta)
    local count = 0
    for k, v in pairs(ta) do count = count + 1 end
    return count
end

function table_last_count(ta)
    local count = 0
    for i, v in ipairs(ta) do
        if v then
            count = count + 1
        end
    end
    return count
end


Bots_ID = 0

VBot = {}
VBot.__index = VBot
VBot.prototype = {}
VBot.prototype.__index = VBot.prototype
VBot.prototype.constructor = VBot

ALL_BOTS = {}

Sub_Callbacks = {}

function VBot.Subscribe(event_name, callback)
    if not Sub_Callbacks[event_name] then
        Sub_Callbacks[event_name] = {}
    end
    Sub_Callbacks[event_name][callback] = true
    --print(NanosUtils.Dump(Sub_Callbacks))
    return callback
end

function VBot.Unsubscribe(event_name, callback)
    if callback then
        if Sub_Callbacks[event_name] then
            if Sub_Callbacks[event_name][callback] then
                Sub_Callbacks[event_name][callback] = nil
                return true
            end
        end
    else
        Sub_Callbacks[event_name] = nil
        return true
    end
    return false
end

function VBot.CallEvent(event_name, ...)
    if Sub_Callbacks[event_name] then
        for k, v in pairs(Sub_Callbacks[event_name]) do
            k(...)
        end
    end
end

function VBot.GetPairs()
    return ALL_BOTS
end

function VBot.GetAll()
    local tbl = {}
    for k, v in pairs(ALL_BOTS) do
        if v:IsValid() then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function VBot.prototype:IsValid(is_from_self)
    local valid = self.Valid
    if (not valid and is_from_self) then
        Package.Err() -- Throw real error
    end
    return valid
end

function VBot.prototype:GetControlledCharacter()
    if self:IsValid(true) then
        return self.Stored.Possessed
    end
end

function VBot.prototype:GetPing()
    if self:IsValid(true) then
        return 0
    end
end

function VBot.prototype:GetValue(key)
    if self:IsValid(true) then
        if self.Stored.Values[key] then
            return self.Stored.Values[key]
        else
            return self.Stored.SyncedValues[key]
        end
    end
end

function VBot.prototype:__eq(other)
    if other.ID then
        if other.ID == self.ID then
            return true
        end
    end
    return false
end

function VBot.prototype:GetID()
    if self:IsValid(true) then
        return self.Stored.NanosID
    end
end

function VBot.prototype:GetSteamID()
    if self:IsValid(true) then
        return tostring(self.Stored.ID)
    end
end

function VBot.prototype:GetAccountID()
    if self:IsValid(true) then
        return tostring(self.Stored.ID)
    end
end

function VBot.prototype:GetAccountName()
    if self:IsValid(true) then
        return "Bot " .. tostring(self.ID)
    end
end

function VBot.prototype:GetAccountIconURL()
    if self:IsValid(true) then
        return ""
    end
end

function VBot.prototype:GetName()
    if self:IsValid(true) then
        return self.Stored.Name
    end
end

function VBot.prototype:StartCameraFade()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:SetManualCameraFade()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:StopCameraFade()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:SetCameraLocation()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:SetCameraRotation()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:TranslateCameraTo()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:RotateCameraTo()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:SetCameraSocketOffset()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:SetCameraArmLength()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:AttachCameraTo()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:ResetCamera()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:Spectate()
    if self:IsValid(true) then
        return true
    end
end

function VBot.prototype:GetVOIPChannel()
    if self:IsValid(true) then
        return self.Stored.VOIPChannel or 0
    end
end

function VBot.prototype:GetVOIPSetting()
    if self:IsValid(true) then
        return self.Stored.VOIPSetting or 0
    end
end

function Character:GetPlayer()
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            local possessed = v.Stored.Possessed
            if possessed then
                if possessed == self then
                    return v
                end
            end
        end
    end

    return self:Super()
end


local DEFAULT_GETALL = Player.GetAll
local DEFAULT_GETPAIRS = Player.GetPairs
function Player.GetPairs()
    local def = DEFAULT_GETALL() -- Cannot edit GetPairs table
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            table.insert(def, v)
        end
    end

    return def
end

function Player.GetAll()
    local def = DEFAULT_GETALL()
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            table.insert(def, v)
        end
    end

    return def
end

Character.Subscribe("Destroy", function(char)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            if v.Stored.Possessed then
                if v.Stored.Possessed == char then
                    VBot.CallEvent("UnPossess", v, char)
                    v.Stored.Possessed = nil
                end
            end
        end
    end
end)

function GetBotFromBotID(bot_id)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            if v.ID == bot_id then
                return v
            end
        end
    end
end
Package.Export("GetBotFromBotID", GetBotFromBotID)

function GetBotFromNanosBotID(bot_id)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            if v:GetID() == bot_id then
                return v
            end
        end
    end
end
Package.Export("GetBotFromNanosBotID", GetBotFromNanosBotID)

Package.Export("VBot", VBot)