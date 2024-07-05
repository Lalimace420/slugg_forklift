local QBCore = exports['qb-core']:GetCoreObject()
local Palettespawn = false

for _, Pedsjobs in ipairs(Config.PedsJobs) do
    npcHash = GetHashKey(Pedsjobs.model)
    RequestModel(npcHash)
    while not HasModelLoaded(npcHash) do
        Wait(1)
    end
    pedjob = CreatePed(1, npcHash, Pedsjobs.coords.x, Pedsjobs.coords.y, Pedsjobs.coords.z - 1, Pedsjobs.coords.w, false, true)
  
    SetBlockingOfNonTemporaryEvents(pedjob, true)
    SetPedDiesWhenInjured(pedjob, false)
    SetPedCanPlayAmbientAnims(pedjob, true)
    SetPedCanRagdollFromPlayerImpact(pedjob, false)
    SetEntityInvincible(pedjob, true)
    FreezeEntityPosition(pedjob, true)
    TaskStartScenarioInPlace(pedjob, Pedsjobs.scenario, 0, true)
    Pedsjobs.ped = pedjob
    exports['qb-target']:AddCircleZone("pedsjobs", vector3(Pedsjobs.coords.x, Pedsjobs.coords.y, Pedsjobs.coords.z), 1.0, { 
    name = "pedsjobs", 
    debugPoly = false, 
    }, {
    options = { 
        {
            num = 1, 
            type = "client", 
            event = "slugg:forklift:openmenu", 
            icon = 'fa-solid fa-angle-right', 
            label = Pedsjobs.label,
        }
    },
        distance = 2.5, 
    })
end

for _, PedsLift in ipairs(Config.PedsLift) do
    npcHash = GetHashKey(PedsLift.model)
    RequestModel(npcHash)
    while not HasModelLoaded(npcHash) do
        Wait(1)
    end
    pedjob = CreatePed(1, npcHash, PedsLift.coords.x, PedsLift.coords.y, PedsLift.coords.z - 1, PedsLift.coords.w, false, true)
  
    SetBlockingOfNonTemporaryEvents(pedjob, true)
    SetPedDiesWhenInjured(pedjob, false)
    SetPedCanPlayAmbientAnims(pedjob, true)
    SetPedCanRagdollFromPlayerImpact(pedjob, false)
    SetEntityInvincible(pedjob, true)
    FreezeEntityPosition(pedjob, true)
    TaskStartScenarioInPlace(pedjob, PedsLift.scenario, 0, true)
    PedsLift.ped = pedjob
    exports['qb-target']:AddCircleZone("PedsLift", vector3(PedsLift.coords.x, PedsLift.coords.y, PedsLift.coords.z), 1.0, { 
    name = "PedsLift", 
    debugPoly = false, 
    }, {
    options = { 
        {
            num = 1, 
            type = "client", 
            event = "slugg:forklift:takelift", 
            icon = 'fa-solid fa-angle-right', 
            label = "Emprunter un lift",
        },
        {
            num = 1, 
            type = "client", 
            event = "slugg:forklift:givelift", 
            icon = 'fa-solid fa-angle-right', 
            label = "Donner le lift",
        }
    },
        distance = 2.5, 
    })
end


RegisterNetEvent('slugg:forklift:takelift', function(vehName)

    local ped = PlayerPedId()
    local hash = GetHashKey(Config.Forklift.model)

    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
  
        forklift = CreateVehicle(hash, Config.Forklift.coords.x, Config.Forklift.coords.y, Config.Forklift.coords.z, Config.Forklift.coords.w, true, false)
        TaskWarpPedIntoVehicle(ped, forklift, -1)
        SetVehicleFuelLevel(forklift, 100.0)
        SetVehicleDirtLevel(forklift, 0.0)
        SetModelAsNoLongerNeeded(hash)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(forklift))
        Wait(5)
        TriggerEvent('qb-admin:client:SaveCar', source)
        TriggerServerEvent("takecash")

end)


RegisterNetEvent('slugg:forklift:givelift', function()
    DeleteVehicle(forklift)
    TriggerServerEvent("givecashback")
end)

RegisterNetEvent("slugg:forklift:openmenu", function()
    if Config.Contextmenu == "ox" then
        lib.registerContext({
            id = 'pedsjobs',
            title = 'Tu veux commencer à travailler?',
            options = {
            {
                title = 'Commencer a travailler',
                event = 'slugg:forklift:spawnpalette',
                arrow = false,
                icon = 'angle-right'
            },
            {
                title = 'Arreter de travailler',
                event = 'slugg:forklift:stopworking',
                arrow = false,
                icon = 'angle-right'
            },
            }
        })

        lib.showContext('pedsjobs')
    end


end)


local function reqMod(model)
    if type(model) ~= 'number' then model = joaat(model) end
    if HasModelLoaded(model) or not model then return end
    RequestModel(model)
    repeat Wait(0) until HasModelLoaded(model)
end


local function createPalletBlip(entity)
    blip = AddBlipForEntity(entity)
    SetBlipSprite(blip, 478)
    SetBlipCategory(blip, 2)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 70)
    SetBlipAsShortRange(blip, true)
    AddTextEntry('Pallet', 'Pallet')
    BeginTextCommandSetBlipName('Pallet')
    EndTextCommandSetBlipName(blip)
    return blip
end

local function createDeliveryBlip(x, y, z)
    deliveryblip = AddBlipForCoord(x, y, z)
    SetBlipSprite(deliveryblip, 478)
    SetBlipCategory(deliveryblip, 2)
    SetBlipDisplay(deliveryblip, 4)
    SetBlipScale(deliveryblip, 0.8)
    SetBlipColour(deliveryblip, 70)
    SetBlipAsShortRange(deliveryblip, true)
    AddTextEntry("Delivery", "Delivery")
    BeginTextCommandSetBlipName("Delivery")
    EndTextCommandSetBlipName(deliveryblip)
    return deliveryblip
end


RegisterNetEvent("slugg:forklift:spawnpalette", function()
    if not Palettespawn then
        local randomIndex = math.random(1, #Config.PalletLocation)
        local palettespawn = Config.PalletLocation[randomIndex]
        local model = Config.PalletModel
        reqMod(model)
        pallet = CreateObject(model, palettespawn.coords.x, palettespawn.coords.y, palettespawn.coords.z - 0.95, true, true, true)
        SetEntityAsMissionEntity(pallet)
        SetEntityCanBeDamaged(pallet, true)
        SetEntityDynamic(pallet, true)
        SetEntityCollision(pallet, true, true)
        PlaceObjectOnGroundProperly(pallet)
        createPalletBlip(pallet)
        TriggerEvent('slugg:forklift:randomloc', palettespawn.coords)
        Palettespawn = true
    else
        QBCore.Functions.Notify("Tu as déjà un travail en cours", "error")
    end
end)



RegisterNetEvent("slugg:forklift:randomloc", function(palletCoords)
    local randomIndex = math.random(1, #Config.Deliveryloc)
    local deliveryloc = Config.Deliveryloc[randomIndex]
    createDeliveryBlip(deliveryloc.coords.x, deliveryloc.coords.y, deliveryloc.coords.z)

    Citizen.CreateThread(function()
        while Palettespawn do
            DrawMarker(1, deliveryloc.coords.x, deliveryloc.coords.y, deliveryloc.coords.z - 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 3.0, 255, 255, 255, 255, false, true, 2, false, nil, nil, false)
            Citizen.Wait(0)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500) 
            local palletPos = GetEntityCoords(pallet)

            local dist = GetDistanceBetweenCoords(deliveryloc.coords.x, deliveryloc.coords.y, deliveryloc.coords.z, palletPos.x, palletPos.y, palletPos.z, true)
            
            if dist <= 2.0 then
                RemoveBlip(blip)
                RemoveBlip(deliveryblip)
                DeleteEntity(pallet)
                TriggerServerEvent("slugg:forklift:givereweard")
                Palettespawn = false
                local confirmed = lib.alertDialog({
                    header = 'Travaill de lift',
                    content = 'Tu veux continuer a travailler?',
                    centered = true,
                    cancel = true
                })
                if confirmed == 'confirm' then
                    TriggerEvent("slugg:forklift:spawnpalette")
                    lib.notify({
                        title = 'Accepter',
                        description = 'Tu continues de travailler',
                        type = 'success'
                    })
                else
                    lib.notify({
                        title = 'Annulé',
                        description = 'Vous avez arreter de travailler',
                        type = 'error'
                    })
                end
                break
            end
        end
    end)
end)



RegisterNetEvent("slugg:forklift:stopworking", function()
    if Palettespawn then
        RemoveBlip(blip)
        RemoveBlip(deliveryblip)
        DeleteEntity(pallet)
        Palettespawn = false
    else
        QBCore.Functions.Notify("Tu dois commencer a travailler pour ca", "error")
    end
end)

