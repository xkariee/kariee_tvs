if GetCurrentResourceName() ~= 'kariee_tvs' then print('[kariee_tvs]: NIE ZALECANE JEST ZMIENIANIE NAZWY PLIKU!') return end

local json = require("json")
RegTV = {}
RegisterCommand('createTV', function(source)
    TriggerClientEvent("kariee_tvs:placeTV", source)
end, true)

RegisterCommand("removeTV", function(source, args, raw)
    TriggerClientEvent("kariee_tvs:removeTV", source)
end, true)

local function saveGraf(data)
    local resourceName = GetCurrentResourceName()
    local resourcePath = GetResourcePath(resourceName)
    local filePath = resourcePath .. "/lua/data/tv.json"
    local file = io.open(filePath, "r")

    if file then
        local file_data = file:read("*all")
        local new_table = json.encode(file_data) == '""' and {} or json.decode(file_data)
        table.insert(new_table, data)

        file:close()

        local save_file = io.open(filePath, "w")

        if save_file then
            save_file:write(json.encode(new_table))
            save_file:close()
        end
    else
        print('\n\n^6[kariee_tvs]: ^1FILE NOT FOUND [lua > data > tv.json]\n\n')
    end
end

local function replaceGraf(data)
    local resourceName = GetCurrentResourceName()
    local resourcePath = GetResourcePath(resourceName)
    local filePath = resourcePath .. "/lua/data/tv.json"
    local save_file = io.open(filePath, "w")
    if save_file then
        save_file:write(json.encode(data))
        save_file:close()
    else
        print('\n\n^6[kariee_tvs]: ^1FILE NOT FOUND [lua > data > tv.json]\n\n')
    end
end

RegisterNetEvent("kariee_tvs:addNewTV", function(data)
    saveGraf(data)
    RegTV[#RegTV + 1] = data
    TriggerClientEvent("kariee_tvs:addTV", -1, data)
end)

RegisterNetEvent("kariee_tvs:changeURL", function(data)
    local this_id = 0
    for k, v in pairs(RegTV) do
        print(data.id, v.id)
        if v.id == data.id then
            this_id = k
            break
        end
    end

    RegTV[this_id] = data

    replaceGraf(RegTV)
    TriggerClientEvent("kariee_tvs:sendAddedImage", -1, data, this_id)
end)

RegisterNetEvent("kariee_tvs:resetTV", function(data)
    local this_id = 0
    for k, v in pairs(RegTV) do
        if v.id == data.id then
            this_id = k
            break
        end
    end

    RegTV[this_id] = data

    replaceGraf(RegTV)
    TriggerClientEvent("kariee_tvs:updateTV", -1, data, this_id)
end)

lib.callback.register('kariee_tvs:getImages', function(source)
    return RegTV
end)

RegisterNetEvent("kariee_tvs:deleteImage", function(id)
    for k, v in pairs(RegTV) do
        if v.id == id then
            table.remove(RegTV, k)
            TriggerClientEvent("kariee_tvs:deleteClientTV", -1, id)
            break
        end
    end

    local resourceName = GetCurrentResourceName()
    local resourcePath = GetResourcePath(resourceName)
    local filePath = resourcePath .. "/lua/data/tv.json"
    local save_file = io.open(filePath, "w")

    if save_file then
        save_file:write(json.encode(RegTV))
        save_file:close()
    else
        print('\n\n^6[kariee_tvs]: ^1FILE NOT FOUND [lua > data > tv.json]\n\n')
    end
end)


RegisterServerEvent('kariee_tvs:loadPictures', function()
    local resourceName = GetCurrentResourceName()
    local resourcePath = GetResourcePath(resourceName)

    local filePath = resourcePath .. "/lua/data/tv.json"

    local file = io.open(filePath, "r")
    if file then
        local data = file:read("*all")
        file:close()

        local jsonData = json.decode(data)
        RegTV = json.encode(data) == '""' and {} or json.encode(jsonData) == 'null' and {} or jsonData
    else
        print('\n\n^6[kariee_tvs]: ^1FILE NOT FOUND [lua > data > tv.json]\n\n')
    end
end)
