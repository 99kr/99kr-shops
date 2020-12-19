--[[ Gets the ESX library ]]--
ESX = nil 
TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

RegisterNetEvent('99kr-shops:Cashier')
AddEventHandler('99kr-shops:Cashier', function(price, basket, account)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if account == "cash" then
        xPlayer.removeMoney(price)
    else
        xPlayer.removeAccountMoney(account, price)
    end
    
    for i=1, #basket do
        xPlayer.addInventoryItem(basket[i]["value"], basket[i]["amount"])
    end
    
    pNotify(_U('99kr_shop_bought', price), 'success', 3000)

end)

ESX.RegisterServerCallback('99kr-shops:CheckMoney', function(source, cb, price, account)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local money
    if account == "cash" then
        money = xPlayer.getMoney()
    else
        money = xPlayer.getAccount(account)["money"]
    end

    if money >= price then
        cb(true)
    end
    cb(false)
end)

pNotify = function(message, messageType, messageTimeout)
	TriggerClientEvent("pNotify:SendNotification", source, {
		text = message,
		type = messageType,
		queue = "shop_sv",
		timeout = messageTimeout,
		layout = "topRight"
	})
end