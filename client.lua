local TMGCore = exports['tmg-core']:GetCoreObject()
local scoreboardOpen = false
local playerOptin = {}

local function DrawIDLabel(coords, text)
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 1.2)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline() 
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

local function GetNearbyPlayers(maxDistance)
    local activePlayers = GetActivePlayers()
    local myCoords = GetEntityCoords(PlayerPedId())
    local closePlayers = {}
    local distSq = maxDistance * maxDistance 

    for i = 1, #activePlayers do
        local player = activePlayers[i]
        local targetPed = GetPlayerPed(player)
        
        if DoesEntityExist(targetPed) then
            local targetCoords = GetEntityCoords(targetPed)
            local delta = targetCoords - myCoords
            if (delta.x * delta.x + delta.y * delta.y + delta.z * delta.z) < distSq then
                closePlayers[#closePlayers + 1] = player
            end
        end
    end
    return closePlayers
end





RegisterNetEvent('tmg-scoreboard:client:SetActivityBusy', function(activity, busy)
    Config.IllegalActions[activity].busy = busy
end)



local isRequesting = false 

local function ToggleScoreboard(show)
    if show then
        if isRequesting then return end
        isRequesting = true

        TMGCore.Functions.TriggerCallback('tmg-scoreboard:server:GetScoreboardData', function(players, cops, playerList)
            playerOptin = playerList
            
            SendNUIMessage({
                action = 'open',
                players = players,
                maxPlayers = Config.MaxPlayers,
                requiredCops = Config.IllegalActions, 
                currentCops = cops
            })

            scoreboardOpen = true
            isRequesting = false
        end)
    else
        SendNUIMessage({ action = 'close' })
        scoreboardOpen = false
        isRequesting = false
    end
end

if Config.Toggle then
    RegisterCommand('scoreboard', function()
        ToggleScoreboard(not scoreboardOpen)
    end, false)
RegisterKeyMapping('scoreboard', 'Toggle Scoreboard', 'keyboard', Config.OpenKey or 'DELETE')else
    RegisterCommand('+scoreboard', function() ToggleScoreboard(true) end, false)
    RegisterCommand('-scoreboard', function() ToggleScoreboard(false) end, false)
RegisterKeyMapping('+scoreboard', 'Hold Scoreboard', 'keyboard', Config.OpenKey or 'DELETE')
    
end


RegisterNetEvent('tmg-scoreboard:client:SetActivityBusy', function(activity, busy)
    if Config.IllegalActions[activity] then
        Config.IllegalActions[activity].busy = busy
    end
end)



CreateThread(function()
    Wait(1000)
    local actions = {}
    
    for k, v in pairs(Config.IllegalActions) do
        actions[k] = v.label
    end
    SendNUIMessage({
        action = 'setup',
        items = actions
    })
end)


CreateThread(function()
    Wait(1000)
    local actions = {}
    for k, v in pairs(Config.IllegalActions) do
        actions[k] = v.label
    end
    SendNUIMessage({
        action = 'setup',
        items = actions
    })
end)

CreateThread(function()
    while true do
        local sleep = 1000 
        
        if scoreboardOpen then
            sleep = 100 
            
            local coords = GetEntityCoords(PlayerPedId())
            local nearby = GetPlayersFromCoords(coords, 10.0)
            
            if #nearby > 0 then
                sleep = 0 
                
                for i = 1, #nearby do
                    local player = nearby[i]
                    local serverId = GetPlayerServerId(player)
                    
                    if playerOptin[serverId] then
                        if Config.ShowIDforALL or playerOptin[serverId].optin then
                            local playerPed = GetPlayerPed(player)
                            local playerCoords = GetEntityCoords(playerPed)
                            
                            DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, '[' .. serverId .. ']')
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
