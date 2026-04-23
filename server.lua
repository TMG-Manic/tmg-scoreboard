local TMGCore = exports['tmg-core']:GetCoreObject()

TMGCore.Functions.CreateCallback('tmg-scoreboard:server:GetScoreboardData', function(source, cb)
    local totalPlayers = #GetPlayers()
    local policeCount = 0
    
    policeCount = TMGCore.Functions.GetDutyCount('police')

    local playerList = {}
    for _, v in pairs(TMGCore.Functions.GetPlayers()) do
        local Player = TMGCore.Functions.GetPlayer(v)
        if Player then
            playerList[v] = {
                optin = true -- Or your custom opt-in logic
            }
        end
    end

    cb(totalPlayers, policeCount, playerList)
end)

RegisterNetEvent('tmg-scoreboard:server:SetActivityBusy', function(activity, bool)
    local src = source
    if not Config.IllegalActions[activity] then return end

    Config.IllegalActions[activity].busy = bool

    TriggerClientEvent('tmg-scoreboard:client:SetActivityBusy', -1, activity, bool)
    
    print(string.format("^5[TMG]^7 Scoreboard: Activity [%s] state updated to %s", activity, tostring(bool)))
end)