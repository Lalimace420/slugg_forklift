local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("slugg:forklift:givereweard", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for _,item in ipairs(Config.RewardItems) do
        Player.Functions.AddItem(item.name, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add", item.ammount)
    end

end)

RegisterNetEvent("takecash", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem('cash', Config.Feeforlift)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cash'], "remove", Config.Feeforlift)

end)

RegisterNetEvent("givecashback", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

        Player.Functions.AddItem('cash', Config.Feeforlift)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cash'], "add", Config.Feeforlift)
end)