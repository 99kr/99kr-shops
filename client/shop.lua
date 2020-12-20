--[[ Marker loop ]]--
Citizen.CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        for i=1, #Config.Locations do
            for j=1, #Config.Locations[i]["shelfs"] do
                local pos = Config.Locations[i]["shelfs"][j]
                local dist = GetDistanceBetweenCoords(coords, pos["x"], pos["y"], pos["z"], true)
                if dist <= 5.0 then
                    if dist <= 1.5 then
                        local text = Config.Locales[pos["value"]]
                        if dist <= 1.0 then
                            text = "[E] " .. text
                            if IsControlJustPressed(0, Keys["E"]) then
                                OpenAction(pos, Config.Items[pos["value"]], Config.Locales[pos["value"]])
                        	end
                        end
                        DrawText3D(pos["x"], pos["y"], pos["z"], text)
                    end
                    wait = 5
                    Marker(pos)
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

--[[ Loop for checking if player is too far away, then empty basket ]] --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if payAmount > 0 then
            for shop = 1, #Config.Locations do
                local blip = Config.Locations[shop]["blip"]
                local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), blip["x"], blip["y"], blip["z"], true)
                if dist <= 20.0 then
                    if dist >= 12.0 then
                        ESX.ShowNotification(_U("99kr_shop_left_store"))
                        payAmount = 0
                        Basket = {}
                    end
                end
            end
        end
    end
end)

--[[ Check what to do ]]--
OpenAction = function(action, shelf, text)
    if action["value"] == "checkout" then
        if payAmount > 0 and #Basket then
            CashRegister(text)
        else
            ESX.ShowNotification(_U('99kr_shop_dont_have_anything'))
        end
    else
        ShelfMenu(text, shelf)
    end
end

--[[ Cash register menu ]]--
CashRegister = function(titel)
        local elements = {
            {label = _U('99kr_shop_pay_with_confirm'), value = "yes"},
            {label = _U('99kr_shop_label_amount_to_pay', payAmount)},
        }

        for i=1, #Basket do
            local item = Basket[i]
            table.insert(elements, {
                label = _U('99kr_shop_item_x', item["label"], item["amount"]),
                value = item["value"],
            })
        end

        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'penis',
            {
                title    = _U('99kr_shop_titel', titel),
                align    = 'center',
                elements = elements
            },
            function(data, menu)
            
                if data.current.value == "yes" then
                    menu.close()
                    ESX.UI.Menu.Open(
                        'default', GetCurrentResourceName(), 'penis2',
                        {
                            title    = _U('99kr_shop_payment'),
                            align    = 'center',
                            elements = {
                                {label = _U('99kr_shop_pay_with_cash'), value = "cash"},
                                {label = _U('99kr_shop_pay_with_card'), value = "bank"},
                            },
                        },
                        function(data2, menu2)
                            ESX.TriggerServerCallback('99kr-shops:CheckMoney', function(hasMoney)
                                if hasMoney then
                                    TriggerServerEvent('99kr-shops:Cashier', payAmount, Basket, data2.current["value"])
                                    payAmount = 0
                                    Basket = {}
                                    menu2.close()
                                else
                                    ESX.ShowNotification(_U('99kr_shop_dont_have_money'))
                                end
                            end, payAmount, data2.current["value"])
                        end,
                    function(data2, menu2)
                        menu2.close()
                    end)
                end
            end,
        function(data, menu)
            menu.close()
    end) 
end

--[[ Open shelf menu ]]--
ShelfMenu = function(titel, shelf)
    local elements = {}

    for i=1, #shelf do
        local shelf = shelf[i]
        table.insert(elements, {
            realLabel = shelf["label"],
            label = _U('99kr_shop_price', shelf["label"], shelf["price"]),
            item = shelf["item"],
            price = shelf["price"],
            value = 1, type = 'slider', min = 1, max = 100,
        })
    end
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'penis',
        {
            title    = _U('99kr_shop_titel', titel),
            align    = 'center',
            elements = elements
        },
        function(data, menu)
        
            local alreadyHave, basketItem = CheckBasketItem(data.current.item)
            if alreadyHave then
                basketItem.amount = basketItem["amount"] + data.current.value
            else
                table.insert(Basket, {
                    label = data.current["realLabel"],
                    value = data.current["item"],
                    amount = data.current.value,
                    price = data.current["price"]
                })
            end
            payAmount = payAmount + data.current["price"] * data.current.value
            ESX.ShowNotification(_U('99kr_shop_put_in_basket', data.current.value, data.current["realLabel"]))     
        end,
    function(data, menu)
        menu.close()
    end)
end

--[[ Check if item already in basket ]]--
CheckBasketItem = function(item)
    for i=1, #Basket do
        if item == Basket[i]["value"] then
            return true, Basket[i]
        end
    end
    return false, nil
end

--[[ Checks if key "L" is pressed ]]--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3)
        if IsControlJustPressed(0, Keys["L"]) then
            OpenBasket()
        end
    end
end)

-- [[ Opens basket menu ]]--
OpenBasket = function()
    if payAmount > 0 and #Basket then
        local elements = {
            {label = _U('99kr_shop_label_amount_to_pay', payAmount)},
        }
        for i=1, #Basket do
            local item = Basket[i]
            table.insert(elements, {
                label = _U('99kr_shop_label_amount_x', item["label"], item["amount"], item["price"] * item["amount"]),
                value = "item_menu",
                index = i
            })
        end
        table.insert(elements, {label = _U('99kr_shop_empty_cart'), value = "empty"})

        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'basket',
            {
                title    = _U('99kr_shop_shopping_cart'),
                align    = 'center',
                elements = elements
            },
            function(data, menu)
                if data.current.value == 'empty' then
                    Basket = {}
                    payAmount = 0
                    menu.close()
                    ESX.ShowNotification(_U('99kr_shop_removed_everything'))    
                end
                if data.current.value == "item_menu" then
                    menu.close()
                    local index = data.current.index
                    local shopItem = Basket[index]

                    -- [[ Opens detailed (kinda) menu about item ]] --
                    ESX.UI.Menu.Open(
                        'default', GetCurrentResourceName(), 'basket_detailedmenu',
                        {
                            title    = _U('99kr_shop_shopping_cart_x', shopItem["label"], shopItem["amount"]),
                            align    = 'center',
                            elements = {
                                {label = _U('99kr_shop_label_price', shopItem["label"], shopItem["price"] * shopItem["amount"])},
                                {label = _U('99kr_shop_delete_item'), value = "deleteItem"},
                            },
                        },
                        function(data2, menu2)
                            if data2.current["value"] == "deleteItem" then
                                ESX.ShowNotification(_U('99kr_shop_removed_x', Basket[index]["amount"], Basket[index]["label"]))
                                payAmount = payAmount - (Basket[index]["amount"] * Basket[index]["price"])
                                table.remove(Basket, index)
                                OpenBasket()
                            end
                        end,
                        function(data2, menu2)
                            menu2.close()
                            OpenBasket()
                        end
                    )
                    
                    -- [[ Back to normal basket menu ]] --
                end
            end,
            function(data, menu)
                menu.close()
            end
        )
    else
        ESX.UI.Menu.CloseAll()
    end
end
