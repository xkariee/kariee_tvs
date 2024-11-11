if GetCurrentResourceName() ~= 'kariee_tvs' then print('[kariee_tvs]: NIE ZALECANE JEST ZMIENIANIE NAZWY PLIKU!') return end

ESX = ESX
ActiveTVs = {}
CurrentTV = {}
PlayerData = {}
local Anim = {}
local InteractingWith = 0




GetCoordsInFrontOfCam = function(...)
	local unpack = table.unpack
	local coords,direction = GetGameplayCamCoord(), RotationToDirection()
	local inTable  = {...}
	local retTable = {}
	if (#inTable == 0) or (inTable[1] < 0.000001) then
		inTable[1] = 0.000001
	end
	for k,distance in pairs(inTable) do
		if (type(distance) == "number") then
			if (distance == 0) then
				retTable[k] = coords
			else
				retTable[k] = vector3(coords.x + (distance * direction.x), coords.y + (distance * direction.y), coords.z + (distance * direction.z))  
			end
		end
	end
	return unpack(retTable)
end

RotationToDirection = function(rot)
	rot = rot or GetGameplayCamRot(2)
	local rotZ = rot.z  * ( 3.141593 / 180.0 )
	local rotX = rot.x  * ( 3.141593 / 180.0 )
	local c = math.cos(rotX)
	local multXY = math.abs(c)   
	local res = vector3((math.sin(rotZ) * -1) * multXY, math.cos(rotZ) * multXY, math.sin(rotX)) 
	return res 
end

function DrawSelectedArea(PointA, PointB, minZ, maxZ, r, g, b, a)
	DrawPoly(PointB.x, PointB.y, minZ, PointB.x, PointB.y, maxZ, PointA.x, PointA.y, maxZ, r, g, b, a)
	DrawPoly(PointB.x, PointB.y, minZ, PointA.x, PointA.y, maxZ, PointA.x, PointA.y, minZ, r, g, b, a)
end

function DrawImageOnArea(PointA, PointB, minZ, maxZ, r, g, b, a, texture, dict)
	DrawSpritePoly(PointB.x, PointB.y, minZ, PointB.x, PointB.y, maxZ, PointA.x, PointA.y, maxZ, r, g, b, a, texture, dict, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0)
	DrawSpritePoly(PointA.x, PointA.y, maxZ, PointA.x, PointA.y, minZ, PointB.x, PointB.y, minZ, r, g, b, a, texture, dict, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0)
end








RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    LoadData()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent('kariee_tvs:loadPictures')
        LoadData()
    end
end)

function LoadData()
    PlayerData = ESX.GetPlayerData()
	local images = lib.callback.await("kariee_tvs:getImages", false)
    for k,v in ipairs(images) do
        if v.url ~= '' then
            v.duiObj = CreateDui(string.format("https://cfx-nui-%s/web/build/index.html", GetCurrentResourceName()), v.width, v.height)
            v.duiHandle = GetDuiHandle(v.duiObj)
            v.txd = CreateRuntimeTxd(v.textureid)
            v.texture = CreateRuntimeTextureFromDuiHandle(v.txd, v.txn, v.duiHandle)
            
            Citizen.Wait(1000)
    
            SendDuiMessage(v.duiObj, json.encode({
                action = "setDUIVariables",
                imageSrc = v.url,
                width = v.width,
                height = v.height,
            }))

            Citizen.Wait(1000)

            SendDuiMessage(v.duiObj, json.encode({
                action = "setDUIVolume",
                volume = v.volume
            }))
        end
        ActiveTVs[#ActiveTVs+1] = v
    end
end

RegisterNetEvent("kariee_tvs:addTV", function(data)
    ActiveTVs[#ActiveTVs+1] = data
end)

RegisterNetEvent("kariee_tvs:updateTV", function(data, id)
    ActiveTVs[id] = data
end)

RegisterNetEvent("kariee_tvs:deleteClientTV", function(id)
    for k,v in pairs(ActiveTVs) do
        if v.id == id then
            if v.duiObj then
                DestroyDui(v.duiObj)
            end
            table.remove(ActiveTVs, k)
            break
        end
    end
end)

RegisterNetEvent("kariee_tvs:sendAddedImage", function(newImage, id)
    newImage.duiObj = CreateDui(string.format("https://cfx-nui-%s/web/build/index.html", GetCurrentResourceName()), newImage.width, newImage.height)
    newImage.duiHandle = GetDuiHandle(newImage.duiObj)
    newImage.txd = CreateRuntimeTxd(newImage.textureid)
    newImage.texture = CreateRuntimeTextureFromDuiHandle(newImage.txd, newImage.txn, newImage.duiHandle)

    Citizen.Wait(1000)

    SendDuiMessage(newImage.duiObj, json.encode({
        action = "setDUIVariables",
        imageSrc = newImage.url,
        width = newImage.width,
        height = newImage.height,
    }))

    Citizen.Wait(1000)

    SendDuiMessage(newImage.duiObj, json.encode({
        action = "setDUIVolume",
        volume = newImage.volume
    }))

    ActiveTVs[id] = newImage
end)

function PlaceTV()
    local editing = true
    local point1
    local point2
    CurrentTV = {}
    lib.showTextUI("[E] Select Start Point", {
        icon = 'fas fa-hand-pointer',
        position = 'left-center',
    })
    while editing do
        DisableControlAction(0, 38, true)
        DisableControlAction(0, 200, true)

        if IsDisabledControlJustReleased(0, 200) then
            if point1 then
                point1 = nil
            else
                editing = false
                goto skipp
            end
        end

        local start,fin = GetCoordsInFrontOfCam(0, 5000)
        local ray = StartShapeTestRay(start.x, start.y, start.z, fin.x, fin.y, fin.z, 4294967295, cache.ped, 5000)
        local _ray,hit,pos,norm,ent = GetShapeTestResult(ray)
        if hit then
            DrawSphere(pos.x, pos.y, pos.z, 0.01, 52, 0, 116, 0.5)
            if not point1 then
                if IsDisabledControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    point1 = pos
                    point2 = pos
                    Wait(100)
                    lib.showTextUI("[E] Select End Point ", {
                        icon = 'fas fa-hand-pointer',
                        position = 'left-center',
                    })
                end
            end
            if point2 then
                point2 = pos
                if IsDisabledControlJustReleased(0, 38) then
                    editing = false
                end
            end
        end
        if point1 then
            DrawSelectedArea(point1, point2, point2.z, point1.z, 31, 0, 69, 80)
        end
        Wait(0)
    end
    if #(point1 - point2) < 50.0 then
        CurrentTV.pointA = point1
        CurrentTV.pointB = point2
        CurrentTV.url = ''
        CurrentTV.id = #ActiveTVs + 1
        TriggerServerEvent("kariee_tvs:addNewTV", CurrentTV)
        SendNotification("TV created succesffuly!")
    else
        SendNotification("TV size is to large!")
    end

    ::skipp::
    lib.hideTextUI()
end

function DeleteTV()
    local deleting = true
    lib.showTextUI("[E] Select Image Area", {
        icon = 'fas fa-hand-pointer',
        position = 'left-center',
    })
    while deleting do
        DisableControlAction(0, 38, true)
        local start,fin = GetCoordsInFrontOfCam(0, 5000)
        local ray = StartShapeTestRay(start.x, start.y, start.z, fin.x, fin.y, fin.z, 4294967295, cache.ped, 5000)
        local _ray,hit,pos,norm,ent = GetShapeTestResult(ray)
        if hit then
            DrawSphere(pos.x, pos.y, pos.z, 0.01, 52, 0, 116, 0.5)
            if IsDisabledControlJustReleased(0, 38) then
                deleting = false
                lib.hideTextUI()
                local closestDist, currentKey = 999.9, 1
                local CurrentTV = nil
                for k,v in pairs(ActiveTVs) do
                    if #(vec3(pos.x, pos.y, pos.z) - vec3(v.pointA.x, v.pointA.y, v.pointA.z)) < closestDist then
                        closestDist = #(vec3(pos.x, pos.y, pos.z) - vec3(v.pointA.x, v.pointA.y, v.pointA.z))
                        currentKey = v.id
                    end
                    if #(vec3(pos.x, pos.y, pos.z) - vec3(v.pointB.x, v.pointB.y, v.pointB.z)) < closestDist then
                        closestDist = #(vec3(pos.x, pos.y, pos.z) - vec3(v.pointB.x, v.pointB.y, v.pointB.z))
                        currentKey = v.id
                    end
                end
                if closestDist < 10 then
                    TriggerServerEvent("kariee_tvs:deleteImage", currentKey)
                else
                    SendNotification("Could not find a TV close enough to delete. Please try again")
                end
            end
        end
        Wait(0)
    end
end

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false
    })
    TriggerScreenblurFadeOut(500)
    InteractingWith = 0
end)

RegisterNUICallback("kariee_tvs:handleUrl", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false
    })

    CurrentTV = ActiveTVs[InteractingWith]
    if CurrentTV.url ~= '' then
        DestroyDui(CurrentTV.duiObj)
    end

    TriggerScreenblurFadeOut(500)
    CurrentTV.volume = data.volume
    CurrentTV.url = data.url
    CurrentTV.width = data.width
    CurrentTV.height = data.height
    CurrentTV.id = InteractingWith
    CurrentTV.cid = PlayerData.identifier
    CurrentTV.textureid = "newtexture"..InteractingWith
    CurrentTV.txn = "newtexture"..InteractingWith
    InteractingWith = 0

    TriggerServerEvent("kariee_tvs:changeURL", CurrentTV)
    cb('ok')
end)

RegisterNUICallback("kariee_tvs:handleVolume", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false
    })
    TriggerScreenblurFadeOut(500)
    
    
    CurrentTV = ActiveTVs[InteractingWith]
    CurrentTV.volume = data.volume
    InteractingWith = 0
    SendDuiMessage(CurrentTV.duiObj, json.encode({
        action = "setDUIVolume",
        volume = data.volume
    }))

    cb('ok')
end)



CreateThread(function()
    while true do
        local sleep = 1500
        for k,v in pairs(ActiveTVs) do
            local coords = GetEntityCoords(cache.ped)
            if (#(vec3(coords.x, coords.y, coords.z) - vec3(v.pointA.x, v.pointA.y, v.pointA.z)) < Config.RenderDistance or #(vec3(coords.x, coords.y, coords.z) - vec3(v.pointB.x, v.pointB.y, v.pointB.z)) < Config.RenderDistance) and v.url ~= '' then
                sleep = 0
                DrawImageOnArea(v.pointA, v.pointB, v.pointB.z, v.pointA.z, 255, 255, 255, 255, v.textureid, v.txn)

                if v.url ~= '' then
                    if v.duiObj then
                        local maxVolume = v.volume
                        local minVolume = 0.01
    
                        local distanceA = #(vec3(coords.x, coords.y, coords.z) - vec3(v.pointA.x, v.pointA.y, v.pointA.z))
    
                        local volume = maxVolume - (distanceA / Config.RenderDistance) * (maxVolume - minVolume)
                        volume = math.max(volume, minVolume)

                        SendDuiMessage(v.duiObj, json.encode({
                            action = "setDUIVolume",
                            volume = volume
                        }))
    
                        if v.duiObj and v.beforeVolume and v.beforeVolume ~= 0 then
                            v.volume = v.beforeVolume
                            SendDuiMessage(v.duiObj, json.encode({
                                action = "setDUIVolume",
                                volume = v.beforeVolume
                            }))
                            v.beforeVolume = 0
                        end
                    end
                end
            elseif (#(vec3(coords.x, coords.y, coords.z) - vec3(v.pointA.x, v.pointA.y, v.pointA.z)) > Config.RenderDistance or #(vec3(coords.x, coords.y, coords.z) - vec3(v.pointB.x, v.pointB.y, v.pointB.z)) > Config.RenderDistance) and v.volume ~= 0 and v.duiObj then
                if v.duiObj then
                    v.beforeVolume = v.volume
                    v.volume = 0
                    SendDuiMessage(v.duiObj, json.encode({
                        action = "setDUIVolume",
                        volume = 0.01
                    }))
                end
            end

            if (#(vec3(coords.x, coords.y, coords.z) - vec3(v.pointA.x, v.pointA.y, v.pointA.z)) < 2.0 or #(vec3(coords.x, coords.y, coords.z) - vec3(v.pointB.x, v.pointB.y, v.pointB.z)) < 2.0) and InteractingWith == 0 then
                sleep = 0
                SendHelpNotification('Press ~INPUT_PICKUP~ to change URL or Volume\nPress ~INPUT_VEH_HEADLIGHT~ to stop playing')

                if IsControlPressed(0, 38) then
                    TriggerScreenblurFadeIn(500)
                    SendNUIMessage({ action = "setVisible", data = true })
                    SetNuiFocus(true, true)
                    InteractingWith = v.id
                end

                if IsControlJustReleased(0, 74) then
                    sleep = 1000
                    if v.duiObj then
                        DestroyDui(v.duiObj)
                    end

                    local new_data = {
                        pointA = v.pointA,
                        pointB = v.pointB,
                        id = v.id,
                        url = ''
                    }

                    v = new_data
                    TriggerServerEvent("kariee_tvs:resetTV", new_data)
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("kariee_tvs:placeTV", function()
    PlaceTV()
end)

RegisterNetEvent("kariee_tvs:removeTV", function()
	DeleteTV()
end)

