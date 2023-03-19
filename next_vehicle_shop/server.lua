VEHICLES = { }
VEHICLES_DATA = { }
VEHICLES_FROM_OWNER = { }
NUMBERS_USED = { }
VEHICLE_SAVE_TIMER = { }

function AddVehicle( conf )
	local self = conf or { }
	if VEHICLES_FROM_OWNER[ self.player.serial ] then
		return self.player:outputChat( "У вас уже имеется автомобиль", 255, 0, 0 )
	end

	NUMBERS_USED[ self.numberplate or "а777аа77" ] = true
	DB:exec( "INSERT INTO `vehicles` ( `model`, `numberplate`, `owner_serial` ) VALUES( ?, ?, ? )", self.model, self.numberplate or "а777аа77", self.player.serial )
	LoadVehicle( self )
end

function _Vehicle( data, waprToVehicle )
	if not isElement( data.player ) then
		-- если игрок вдруг вышел - не создаем машину
		return false
	end

	local x, y, z = getElementPosition( data.player )
	local vehicle = Vehicle( data.model, x + 2, y + 2, z + 1 )

	vehicle.dimension = data.dimension or data.player.dimension
	vehicle.health = math.max( math.min( 350, 1000 ), data.health or 999 )

	VEHICLES[ vehicle ] = vehicle
	VEHICLES_FROM_OWNER[ data.player.serial ] = vehicle

	local _elem_data = data
	VEHICLES_DATA[ vehicle ] = _elem_data

	function OnDestroy( )
		local data = VEHICLES_DATA[ source ]
		if data then
			SaveVehicle( data.player, true )
		end
	end
	addEventHandler( "onElementDestroy", vehicle, OnDestroy )

	if waprToVehicle then
		warpPedIntoVehicle( data.player, vehicle )
	end
	
	VEHICLE_SAVE_TIMER[ vehicle ] = setTimer( SaveVehicle, ( 5 * 600000 ), 0, data.player ) -- автосохранение каждые 5 мин
	return vehicle
end

function LoadVehicle( data )
	if type( data ) == "table" then
		local player = data.player
		if isElement( player ) then
			_Vehicle( data, true )
		end
	elseif isElement( data ) and getElementType( data ) == "player" then
		DB:query( function( query, player ) 
			if isElement( player ) then
				local result = query:poll( -1 )
				if result and result[ 1 ] then
					local _query_data = result[ 1 ]
					_query_data.player = player
					_Vehicle( _query_data )
				end
			end
		end, { data }, "SELECT * FROM `vehicles` WHERE `owner_serial`=? LIMIT 1", data.serial)
	end
end

function LoadNumberPlates( query )
	local result = query:poll( -1 )
	for i, v in pairs( result ) do
		NUMBERS_USED[ v.numberplate ] = true
	end
end

function SaveVehicle( player, bDestroy )
	if not isElement( player ) then return end
	local vehicle = VEHICLES_FROM_OWNER[ player.serial ] or nil
	if not isElement( vehicle ) then
		return false
	end

	local data = VEHICLES_DATA[ vehicle ]
	if data then
		local health = math.floor( getElementHealth( vehicle ) )
		local dimension = getElementDimension( vehicle )
		local numberplate = data.numberplate or ""
		DB:exec( "UPDATE `vehicles` SET `health`=?, `dimension`=?, `numberplate`=? WHERE `owner_serial`=?", health, dimension, numberplate, player.serial )

		if bDestroy then
			VEHICLES[ vehicle ] = nil
			VEHICLES_DATA[ vehicle ] = nil
			if isElement( vehicle ) then destroyElement( vehicle ) end
			VEHICLES_FROM_OWNER[ player.serial ] = nil
			if isTimer( VEHICLE_SAVE_TIMER[ vehicle ] ) then killTimer( VEHICLE_SAVE_TIMER[ vehicle ] ) end
		end
	end
end

function DestroyVehicle( player )
	local vehicle = VEHICLES_FROM_OWNER[ player.serial ] -- идентифицируем с серийником клиента
	if not isElement( vehicle ) then
		return false
	end

	if VEHICLES[ vehicle ] then
		DB:exec( "DELETE FROM `vehicles` WHERE `owner_serial`=?", player.serial )

		-- освобождаем номер
		local numberplate = ( VEHICLES_DATA[ vehicle ] or {} ).numberplate or ""
		if NUMBERS_USED[ numberplate ] then NUMBERS_USED[ numberplate ] = nil end

		VEHICLES[ vehicle ] = nil
		VEHICLES_FROM_OWNER[ player.serial ] = nil
		VEHICLES_DATA[ vehicle ] = nil
		if isElement( vehicle ) then destroyElement( vehicle ) end
		if isTimer( VEHICLE_SAVE_TIMER[ vehicle ] ) then killTimer( VEHICLE_SAVE_TIMER[ vehicle ] ) end
	end
end

addEvent( "PlayerWantBuyVehicle", true )
addEventHandler( "PlayerWantBuyVehicle", resourceRoot, function( index, numberplate ) 
	if VEHICLES_FROM_OWNER[ client.serial ] then
		return client:outputChat( "У вас уже имеется автомобиль" )
	end

	local conf = _VEHICLES_LIST[ index ]
	if conf then
		local numberplate = numberplate or "а777аа77"
		if NUMBERS_USED[ numberplate ] then
			return client:outputChat( "Номер который вы ввели уже занят!", 255, 0, 0 )
		end

		--[[plocal cost = conf.cost
		if client:getMoney( ) - cost < 0 then
			return client:outputChat( "Недостаточно средств", 255, 0, 0 )
		end]]

		AddVehicle( {
			player = client,
			numberplate = numberplate,
			model = conf.id
		} )
		triggerClientEvent( client, "g_PlayerWantQuit", resourceRoot )
	else
		error( "Автомобиль не найден в прописи, индекс: "..index )
	end
end)

addEvent( "PlayerWantBuyVehicleCheck", true )
addEventHandler( "PlayerWantBuyVehicleCheck", resourceRoot, function( index )
	if VEHICLES_FROM_OWNER[ client.serial ] then
		outputChatBox( "У вас уже имеется автомобиль", client, 255, 0, 0 )
		error( "У вас уже имеется автомобиль" )
		return
	end
	triggerClientEvent( client, "CreateNumberSelectWindow", resourceRoot )

	-- TODO
end)

addEvent( "PlayerWantSellVehicle", true )
addEventHandler( "PlayerWantSellVehicle", resourceRoot, function( ) 
	local _client_vehicle = client.vehicle
	if not VEHICLES_FROM_OWNER[ client.serial ] then
		return client:outputChat( "У тебя нету машины", 255, 0, 0 )
	end

	if VEHICLES_FROM_OWNER[ client.serial ] ~= _client_vehicle then
		return client:outputChat( "Это не твоя тачка", 255, 0, 0 )
	end

	local conf = _VEHICLES[ _client_vehicle.model ]
	if conf then
		givePlayerMoney( client, conf.cost / 2 )
		DestroyVehicle( client )
		client:outputChat( "Вы успешно продали свою тачку за "..conf.cost / 2, 0, 255, 0 )
	end
end)

addEvent( "PlayerWantChangeVehicleNumber", true )
addEventHandler( "PlayerWantChangeVehicleNumber", resourceRoot, function( sNumber )
	local _client_vehicle = client.vehicle
	if not VEHICLES_FROM_OWNER[ client.serial ] then
		return client:outputChat( "У тебя нету машины", 255, 0, 0 )
	end

	if VEHICLES_FROM_OWNER[ client.serial ] ~= _client_vehicle then
		return client:outputChat( "Это не твоя тачка", 255, 0, 0 )
	end

	local data = VEHICLES_DATA[ VEHICLES_FROM_OWNER[ client.serial ] ]
	if data then
		if NUMBERS_USED[ sNumber ] then
			return client:outputChat( "Номер уже используется", 255, 0, 0 )
		end

		NUMBERS_USED[ data.numberplate ] = nil
		NUMBERS_USED[ sNumber ] = true
		data.numberplate = sNumber

		client:outputChat( "Вы успешно изменили номер на "..sNumber, 0, 255, 0 )
	end
end)

function OnResourceStop_handler( )
	for i, v in ipairs( getElementsByType( "player" ) ) do
		SaveVehicle( v )
	end
end
addEventHandler( "onResourceStop", resourceRoot, OnResourceStop_handler )

function OnResourceStart_handler( )
	for i, v in ipairs( getElementsByType( "player" ) ) do
		LoadVehicle( v )
	end

	local fn_numbers_load = function( )
		DB:query( LoadNumberPlates, { }, "SELECT * FROM `vehicles`" )
	end
	Timer( fn_numbers_load, 2000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, OnResourceStart_handler )

function OnPlayerJoin_handler( )
	Timer( LoadVehicle, 3500, 1, source )
end
addEventHandler( "onPlayerJoin", root, OnPlayerJoin_handler )

function OnPlayerQuit_handler( )
	SaveVehicle( source, true )
end
addEventHandler( "onPlayerQuit", root, OnPlayerQuit_handler )

addCommandHandler( "addvehicle", function( self, cmd, model ) 
	AddVehicle( {
		player = self,
		model = tonumber( model ) or 429
	} )
end)

addCommandHandler( "delvehicle", function( self ) 
	DestroyVehicle( self )
end)
