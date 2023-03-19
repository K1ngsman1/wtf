local _DB_DATA = { -- P.S; Вводите свои данные :)
	dbname = "veh_shop",
	user = "ganzes77",
	pass = "ganzes77_123",
	host = "127.0.0.1",
	port = 3306,
}

local _DB = dbConnect( "mysql", string.format( "dbname=%s;host=%s;port=%s;", _DB_DATA.dbname, _DB_DATA.host, _DB_DATA.port ), _DB_DATA.user, _DB_DATA.pass )
dbExec( _DB, [[CREATE TABLE IF NOT EXISTS vehicles(
	model INT,
	health FLOAT,
	owner_serial VARCHAR(64) NOT NULL,
	dimension FLOAT,
	numberplate TEXT
	)]]
)

DB = _DB
