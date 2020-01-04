ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('m3:blackmarket:copCount', function(source, cb)
	local xPlayers = ESX.GetPlayers()

	copConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == Config.CopJobName then
			copConnected = copConnected + 1
		end
	end

	cb(copConnected)
end)

ESX.RegisterServerCallback('m3:blackmarket:getWeapons', function(source, cb, type)
	MySQL.Async.fetchAll('SELECT * FROM m3_blackmarket_stock WHERE type = @type', {
		['@type'] = type,
	}, function(result)
		if result[1] ~= nil then
			cb(result)
		else
			cb(nil)
		end
	end)
end)

RegisterServerEvent('m3:blackmarket:removeWeapon')
AddEventHandler('m3:blackmarket:removeWeapon', function(name)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if name ~= nil then
		MySQL.Async.fetchAll('SELECT * FROM m3_blackmarket_stock WHERE name = @name', {['@name'] = name}, function(result)
			if xPlayer.getMoney() >= result[1].price then
				if result[1].count ~= 0 then
					MySQL.Async.execute('INSERT INTO m3_blackmarket_orders (identifier, name, label, time) VALUES (@identifier, @name, @label, @time)',{
						['@identifier'] = xPlayer.identifier, ['@name'] = result[1].name, ['@label'] = result[1].label, ['@time'] = os.time()})

					MySQL.Async.execute("UPDATE m3_blackmarket_stock SET count = @count WHERE name = @name", {['@name'] = name, ['count'] = result[1].count - 1})
					
					xPlayer.removeMoney(result[1].price)
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = _U('success_order')})
				else
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('no_stock')})
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('failed_order')})
			end
		end)
	end
end)

ESX.RegisterServerCallback('m3:blackmarket:getItems', function(source, cb, type)
	MySQL.Async.fetchAll('SELECT * FROM m3_blackmarket_stock WHERE type = @type', {
		['@type'] = type,
	}, function(result)
		if result[1] ~= nil then
			cb(result)
		else
			cb(nil)
		end
	end)
end)

RegisterServerEvent('m3:blackmarket:removeItem')
AddEventHandler('m3:blackmarket:removeItem', function(name)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if name ~= nil then
		MySQL.Async.fetchAll('SELECT * FROM m3_blackmarket_stock WHERE name = @name', {['@name'] = name}, function(result)
			if xPlayer.getMoney() >= result[1].price then
				if result[1].count ~= 0 then
					MySQL.Async.execute('INSERT INTO m3_blackmarket_orders (identifier, name, label, time) VALUES (@identifier, @name, @label, @time)',{
						['@identifier'] = xPlayer.identifier, ['@name'] = result[1].name, ['@label'] = result[1].label, ['@time'] = os.time()})

					MySQL.Async.execute("UPDATE m3_blackmarket_stock SET count = @count WHERE name = @name", {['@name'] = name, ['count'] = result[1].count - 1})
					
					xPlayer.removeMoney(result[1].price)
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = _U('success_order')})
				else
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('no_stock')})
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('failed_order')})
			end
		end)
	end
end)

ESX.RegisterServerCallback('m3:blackmarket:getTime', function(source, cb)
    cb(os.time())
end)

ESX.RegisterServerCallback('m3:blackmarket:getOrders', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM m3_blackmarket_orders WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier,
	}, function(result)
		if result[1] ~= nil then
			cb(result)
		else
			cb(nil)
		end
	end)
end)

RegisterServerEvent('m3:blackmarket:giveItem')
AddEventHandler('m3:blackmarket:giveItem', function(name, time, lost)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if name ~= nil then
		MySQL.Async.fetchAll('DELETE FROM m3_blackmarket_orders WHERE identifier = @identifier AND name = @name AND time = @time',{
			['@identifier'] = xPlayer.identifier,
			['@name'] = name,
			['@time'] = time})
		if not lost then
			xPlayer.addInventoryItem(name, 1)
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = _U('success_take')})
			local xTargets = ESX.GetPlayers()

			for i=1, #xTargets, 1 do
				local xTarget = ESX.GetPlayerFromId(xTargets[i])
				if xTarget.job.name == Config.CopJobName then
					TriggerClientEvent('m3:blackmarket:copNotify', xTarget.source)
				end
			end
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('failed_chance_order')})
			local xTargets = ESX.GetPlayers()

			for i=1, #xTargets, 1 do
				local xTarget = ESX.GetPlayerFromId(xTargets[i])
				if xTarget.job.name == Config.CopJobName then
					TriggerClientEvent('m3:blackmarket:copNotify', xTarget.source)
				end
			end
		end
		dclog(name, xPlayer, lost)
	end
end)

function dclog(name, xPlayer, lost)
	local playerName = Sanitize(xPlayer.getName())

	if lost then
		itemcondition = _U('discorddeliverytake')
	else
		itemcondition = _U('discorddeliverylost')
	end
	
	local discord_webhook = GetConvar('discord_webhook', Config.DiscordWebhook)
	if discord_webhook == '' then
	  return
	end
	local headers = {
	  ['Content-Type'] = 'application/json'
	}
	local data = {
	  ["username"] = Config.WebhookName,
	  ["avatar_url"] = Config.WebhookAvatarUrl,
	  ["embeds"] = {{
		["author"] = {
		  ["name"] = playerName .. ' - ' .. xPlayer.identifier
		},
		["color"] = 1942002,
		["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
	  }}
	}
	data['embeds'][1]['description'] = _U('discorddeliveryitem') .. ': ' .. name .. ' - ' .. _U('discorddelivery') .. ': ' .. itemcondition
	PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

RegisterServerEvent('m3:blackmarket:deliveryConfirmed')
AddEventHandler('m3:blackmarket:deliveryConfirmed', function(receiverPos)
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == Config.CopJobName then
			TriggerClientEvent('m3:blackmarket:blipReceiver', xPlayer.source, receiverPos)
		end
	end
end)


RegisterServerEvent('m3:blackmarket:addToBlackmarket')
AddEventHandler('m3:blackmarket:addToBlackmarket', function(name, count, type, price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if name ~= nil then
		MySQL.Async.fetchAll('SELECT label FROM items WHERE name = @name',{ ['@name'] = name}, function(result)
			local label = result[1].label
			MySQL.Async.fetchAll('SELECT * FROM m3_blackmarket_stock WHERE name = @name',{ ['@name'] = name}, function(result2)
				if result2[1] ~= nil then
					print(count)
					MySQL.Async.execute('UPDATE m3_blackmarket_stock SET price = @price WHERE name = @name',{['@name'] = name, ['@price'] = price})
					MySQL.Async.execute('UPDATE m3_blackmarket_stock SET count = @count  WHERE name = @name',{['@name'] = name, ['@count'] = count })
					print('[m3_blackmarket] update stock')
				else
					MySQL.Async.execute('INSERT INTO m3_blackmarket_stock (type, name, label, count, price) VALUES (@type, @name, @label, @count, @price)',{
						['@type'] = type,
						['@name'] = name,
						['@label'] = label,
						['@count'] = count,
						['@price'] = price})
					print('[m3_blackmarket] insert into stock')
				end
			end)
		end)
	end
end)

TriggerEvent('es:addGroupCommand', 'addbm', 'superadmin', function(source, args, user)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local item    = args[1]
	local count   = args[2]
	local type    = args[3]
	local price   = args[4]

	if count ~= nil then
		if xPlayer.getInventoryItem(item) ~= nil then
			if type == 'weapon' or type == 'item' then
				if price ~= nil then
					TriggerEvent('m3:blackmarket:addToBlackmarket', item, count, type, price)
				else
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'invalid_price'})
				end
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'invalid_type'})
			end
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'invalid_item'})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'invalid_count'})
	end
end,  function(source, args, user)
	TriggerClientEvent('chat:addMessage', _source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end)

function Sanitize(str)
	local replacements = {
		['&' ] = '&amp;',
		['<' ] = '&lt;',
		['>' ] = '&gt;',
		['\n'] = '<br/>'
	}

	return str
		:gsub('[&<>\n]', replacements)
		:gsub(' +', function(s)
			return ' '..('&nbsp;'):rep(#s-1)
		end)
end
