if GetCurrentResourceName() ~= 'kariee_tvs' then print('[kariee_tvs]: NIE ZALECANE JEST ZMIENIANIE NAZWY PLIKU!') return end

Config = {}
Config.RenderDistance = 50.0

function SendNotification(msg)
    ESX.ShowNotification(msg)
end

function SendHelpNotification(msg)
    ESX.ShowHelpNotification(msg)
end