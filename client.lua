ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if NetworkIsSessionStarted() then
            blackmarketStart()
            return
        end
    end
end)

Citizen.CreateThread(function()

	if Config.EnableBlip then

		local blip = AddBlipForCoord(Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z - 1)
		SetBlipSprite(blip, Config.BlipID)
		SetBlipColour(blip, Config.BlipColor)
		SetBlipScale  (blip, Config.BlipScale)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(_U('blipname'))
		EndTextCommandSetBlipName(blip)
	end
end)

function blackmarketStart()
    local pedhash = GetHashKey(Config.NpcModel)
    RequestModel(pedhash)

    while not HasModelLoaded(pedhash) do
        Citizen.Wait(10)
    end

    RequestAnimDict("mini@strip_club@idles@bouncer@base")

    while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
        Citizen.Wait(10)
    end

    local npcPed =  CreatePed(4, pedhash, Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z - 1, Config.NpcHeading, false, true)

	FreezeEntityPosition(npcPed, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    TaskPlayAnim(npcPed,"mini@strip_club@idles@bouncer@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
end

function blackmarketMenu()
	local elements = {}
	
	PlayerData = ESX.GetPlayerData()

	if Config.CopandDocCantAccess then
		if PlayerData.job.name == Config.DocJobName then
			table.insert(elements, {label = _U('copdoctitle'), value = nil})
		elseif PlayerData.job.name == Config.CopJobName then
			table.insert(elements, {label = _U('copdoctitle'), value = nil})
		else
			table.insert(elements, {label = _U('weapons'), value = 'weapons'})
			table.insert(elements, {label = _U('illegal_items'), value = 'items'})
			table.insert(elements, {label = _U('get_orders_menu'), value = 'orders'})
		end
	else
		table.insert(elements, {label = _U('weapons'), value = 'weapons'})
		table.insert(elements, {label = _U('illegal_items'), value = 'items'})
		table.insert(elements, {label = _U('get_orders_menu'), value = 'orders'})
	end
    
    ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blackmarket', {
		title    = _U('blackmarket'),
		align    = 'right',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'weapons' then
			OpenWeaponMenu()
		elseif data.current.value == 'items' then
			OpenItemMenu()
		elseif data.current.value == 'orders' then
			OpenOrdersMenu()
		end

	end, function(data, menu)
		menu.close()
	end)
end

function OpenWeaponMenu()
	ESX.TriggerServerCallback('m3:blackmarket:getWeapons', function(weapons)
		local elements ={}
		if weapons ~= nil then
			for i=1, #weapons, 1 do
				if weapons[i].count > 0 then
					table.insert(elements, {
						label = weapons[i].label .. ' - ' .. _U('remaining_stock') .. ': ' .. weapons[i].count .. ' ' .. _U('price') .. ': '.. weapons[i].price,
						value = weapons[i].name
					})
				else
					table.insert(elements, { label = weapons[i].label .. ' - ' .. _U('no_stock'), value = nil })
				end
			end
		else
			table.insert(elements, { label = _U('no_stock'), value = nil })
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'get_weapon', {
			title    = _U('get_weapon_menu'),
			align    = 'right',
			elements = elements
		}, function(data, menu)
			menu.close()

			if data.current.value ~= nil then
				TriggerServerEvent('m3:blackmarket:removeWeapon', data.current.value)
				PlaySoundFrontend(-1, "LOOSE_MATCH", "HUD_MINI_GAME_SOUNDSET", 0)
			else
				PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", 0)
			end
		end, function(data, menu)
			menu.close()
		end)
	end,'weapon')
end

function OpenItemMenu()
	ESX.TriggerServerCallback('m3:blackmarket:getItems', function(items)
		local elements ={}
		if items ~= nil then
			for i=1, #items, 1 do
				if items[i].count > 0 then
					table.insert(elements, {
						label = items[i].label .. ' - ' .. _U('remaining_stock') .. ': ' .. items[i].count .. ' ' .. _U('price') .. ': '.. items[i].price,
						value = items[i].name
					})
				else
					table.insert(elements, { label = items[i].label .. ' - ' .. _U('no_stock'), value = nil })
				end
			end
		else
			table.insert(elements, { label = _U('no_stock'), value = nil })
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'get_item', {
			title    = _U('get_item_menu'),
			align    = 'right',
			elements = elements
		}, function(data, menu)
			menu.close()
			if data.current.value ~= nil then
				TriggerServerEvent('m3:blackmarket:removeItem', data.current.value)
				PlaySoundFrontend(-1, "LOOSE_MATCH", "HUD_MINI_GAME_SOUNDSET", 0)
			else
				PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", 0)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, 'item')
end

function OpenOrdersMenu()
	ESX.TriggerServerCallback('m3:blackmarket:getTime', function(time)
		ESX.TriggerServerCallback('m3:blackmarket:getOrders', function(orders)
			local elements ={}
			if orders ~= nil then
				for i=1, #orders, 1 do
					local remainingtime = time - orders[i].time
					if time - orders[i].time <= Config.OrderTime then
						table.insert(elements, {
							label = orders[i].label .. ' - ' .. _U('remaining_time') .. ': ' .. math.floor((Config.OrderTime - remainingtime) / 60) .. ' ' .. _U('minute') ,
							value = nil
						})
					elseif time - orders[i].time >= Config.OrderTime then
						table.insert(elements, {
							label = orders[i].label .. ' - ' .. _U('available'),
							value = orders[i].name,
							valuetime = orders[i].time

						})
					end
				end
			else
				table.insert(elements, { label = _U('no_orders'), value = nil })
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'get_item', {
				title    = _U('get_orders_menu'),
				align    = 'right',
				elements = elements
			}, function(data, menu)
				menu.close()
				if data.current.value ~= nil then
					local chance = math.random(1, 100)
					local blipchance = math.random(1, 100)
					local lost = false

					ESX.TriggerServerCallback('m3:blackmarket:copCount', function(cops)
						print(cops)
						if cops >= Config.MinCop then
							if chance <= Config.ChancetoReceive then
								lost = false
							else
								lost = true
							end
							TriggerServerEvent('m3:blackmarket:giveItem', data.current.value, data.current.valuetime, lost)
							ESX.UI.Menu.CloseAll()
							PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0)

							if blipchance <= Config.BlipChange then
								deliveryconfirmed = true
							else
								deliveryconfirmed = false
							end
						else
							TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('min_cops')})
						end
					end)
				else
					PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", 0)
				end
			end, function(data, menu)
				menu.close()
			end)
		end)
	end)
end


Citizen.CreateThread(function()
	while true do
		local ped = GetPlayerPed(-1)
		local pedCoords = GetEntityCoords(ped)

		Citizen.Wait(Config.BlipIntervalTime * 1000)

		if Config.EnableReceiverBlip then
			if deliveryconfirmed then
				TriggerServerEvent('m3:blackmarket:deliveryConfirmed', pedCoords)
			end
		end
	end
end)

local bliptimer = 5 
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
		if deliveryconfirmed then
			bliptimer = bliptimer - 1
			if bliptimer == 0 then
				deliveryconfirmed = false
				bliptimer = Config.BlipTimer
			end
		end
    end
end)

RegisterNetEvent('m3:blackmarket:copNotify')
AddEventHandler('m3:blackmarket:copNotify', function()
	if Config.UseM3Dispatch then
		-- update later
	else
		PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0)
		TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = _U('cop_notify'), length = 10000})
	end
end)

RegisterNetEvent('m3:blackmarket:blipReceiver')
AddEventHandler('m3:blackmarket:blipReceiver', function(receiverPos)
	PlayerData = ESX.GetPlayerData()
	if PlayerData.job.name == Config.CopJobName then
		local transT = 250
        local Blip = AddBlipForCoord(receiverPos.x, receiverPos.y, receiverPos.z)
        SetBlipSprite(Blip,  162)
        SetBlipColour(Blip,  27)
		SetBlipAlpha(Blip,  transT)
		SetBlipScale(Blip, 1.0)
		SetBlipAsShortRange(Blip,  false)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(_U('receiverblipname'))
		EndTextCommandSetBlipName(blip)
        while transT ~= 0 do
            Wait(4)
            transT = transT - 1
            SetBlipAlpha(Blip,  transT)
            if transT == 0 then
                SetBlipSprite(Blip,  2)
                return
            end
        end
	end
end)

local closeenough = false

Citizen.CreateThread(function()
    while true do
		local ped = GetPlayerPed(-1)
		local pedCoords = GetEntityCoords(ped)
        pedDistance = GetDistanceBetweenCoords(pedCoords, Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z, true)
		Citizen.Wait(30)
        if pedDistance <= 3.0 then
            ESX.ShowHelpNotification(_U('helptext'))
            if IsControlPressed(0, 38) then
				blackmarketMenu()
				closeenough = true
            end
		else
			if closeenough then
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'blackmarket')
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'get_weapon')
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'get_item')
				closeenough = false
			end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		SetNuiFocus(false, false)
		ESX.UI.Menu.CloseAll()
	end
end)
