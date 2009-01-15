--[[
Datastream Module
By Janorkie
]]

include( "Json.lua" );
-- Globalize everything we are going to use so module can access it
local table = table;
local string = string;
local usermessage = usermessage;
local RunConsoleCommand = RunConsoleCommand;
local util = util;
local print = print;
local type = type;
local pairs = pairs;
local PrintTable = PrintTable;
local LocalPlayer = LocalPlayer;
local Json = Json;

local function SplitTransmission( str, d )

	local done = false; // Use this to know when to stop our while loop
	local n = 0; // What character are we at?
	local t = { }; // Table full of data blocks
	local len = string.len( str ); // Length of our transmission
	
	while !done do
			
		n = n + 1;
		
		t[n] = string.sub( str, (n - 1) * d, n * d - 1); // Get a 128-bit block from the string (or shorter if we are at our last split)
		
		if( n * d > len ) then
		
			done = true; // We're done here.
			
		end
		
	end
	
	return t;
	
end

module( "datastream" );

local currdata = nil; // Cached data from current stream
local currhandler = nil; // Current handler that we are receiving data for
local currsenttotal = nil; // How much data in total will we be sending to the server
local handlers = {}; // Table full of handlers (hooks)
local currcallback = nil; // What is the current Send callback

function Send( handler, t, callback )
	
	if currcallback then // We can't run multiple client->server datastreams.
	
		print( "ERROR! Tried to start client->server datastream before last datastream was finished." );
		return;
		
	end
	
	currcallback = callback; // Cache the callback
	
	if !t then // No data to send.
	
		RunConsoleCommand( "dsr_start", handler ); // Tell the server we are starting a datastream transmission, but we do not have any data.

	end
	
	if t then // We have data.
	
		local st = Json.Encode( t ); // Convert the table into a string
		currsenttotal = string.len( st ); // The total amount that we will be sending
		LocalPlayer( ):ConCommand( "dsr_start \1 \"" .. handler .. "\" " .. string.len( st ) .. "\n" ); // Tell the server we are starting a datastream transmission and how much we are sending.
		local c = SplitTransmission( st, 128 ); // Split the transmission into 128 character blocks
		
		for k, v in pairs( c ) do
		
				// These two characters are the only ones that can mess up our transmission
				v = string.gsub( v, "\"", "\2" ); // Replace " with ASCII \2
				v = string.gsub( v, "\n", "\3" ); // Replace \n with ASCII \3
				
				LocalPlayer( ):ConCommand( "dsr \"\1" .. v .. "\"\n" ); // Send the block to the server

		end

	end
	
	// Tell the server we are finished.
	LocalPlayer( ):ConCommand( "dsr_end \1\n" );
	
end

function Hook( name, unique, func, callback ) // Adds a hook/handler.

	local handler = { };
	handler.name = name;
	handler.unique = unique;
	handler.func = func;
	handler.callback = callback;
	
	handlers[unique] = handler;

end

function Load( ) // Call this in your GAMEMODE:Initialize or Init functions! This is NOT umsg.Start( )

	local function DataStreamStart( data ) // We received a datastream start from the server.

		currhandler = data:ReadString( ); // Get the handler
		currdata = ""; // Clear our current data buffer
		currtotal = data:ReadLong( ); // How much are we going to be receiving
		
	end

	local function DataStreamReceive( data ) // We received a datastream block from the server.

		if !currhandler then
		
			print( "Received datastream data but datastream not started!" ); // We haven't even received a DatastreamStart?
			return;
			
		end
		
		local d = data:ReadString( ); // Get the data block
		
		currdata = currdata .. d // Append it to the data buffer
		
		for _, handler in pairs( handlers ) do
		
			if handler.name == currhandler then
			
				if handler.callback then // Check to make sure this handler HAS a callback
				
					handler.callback( string.len( currdata ), currtotal ); // Give it the total downloaded so far
				
				end
				
			end
			
		end
		
	end
	
	local function DataStreamEnd( data ) // Server is finished sending data
	
		for _, handler in pairs( handlers ) do
		
			if handler.name == currhandler then

				handler.func( Json.Decode( string.gsub( string.gsub( currdata, "\2", "\"" ), "\3", "\n" ) ) ); // Call the handler and give it the data buffer
				
			end
			
		end
		
		// Clear our buffers
		currhandler = nil;
		currdata = nil;
		currdownloaded = nil;
		currtotal = nil;
		
	end
	
	local function StreamDataReceived( data ) // Message telling us how much data the server has received from us

		if currcallback then // Do we have a send callback?
		
			local amt = data:ReadLong( ); // Amount total
			currcallback( amt, currsenttotal ); // Give it to the current send callback
			if amt == currsenttotal then // Transmission complete
			
				currcallback = nil; // Clear the send callback
				
			end
		end
		
	end
	
	// Add all the usermessage hooks
	usermessage.Hook( "StreamDataReceived", StreamDataReceived );
	usermessage.Hook( "dsr_start", DataStreamStart );
	usermessage.Hook( "dsr_piece", DataStreamReceive );
	usermessage.Hook( "dsr_end", DataStreamEnd );
	
end