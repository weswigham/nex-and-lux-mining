--[[
Datastream Module
By Janorkie
]]

include( "Json.lua" );
-- Globalize everything we are going to use so module can access it
local table = table;
local string = string;
local umsg = umsg;
local concommand = concommand;
local util = util;
local print = print;
local type = type;
local pairs = pairs;
local tostring = tostring;
local Json = Json;

local function SplitTransmission( str, d )

	local done = false; // Use this to know when to stop our while loop
	local n = 0; // What character are we at?
	local t = { }; // Table full of data blocks
	local len = string.len( str ); // Length of our transmission
	
	while !done do
			
		n = n + 1;
		
		t[n] = string.sub( str, (n - 1) * d, n * d - 1); // Get a 128-bit block from the string or shorter if there are less than 128 characters left.
		
		if( n * d > len ) then
		
			done = true; // We're done here.
			
		end
		
	end
	
	return t;
	
end

module( "datastream" );

local streams = {}; // All of our streams, indexed by the player object
local handlers = {}; // All of our handlers

function Send( pl, handler, t, callback )

	local c = nil; // The transmission buffer
	local sent = 0; // How much has been sent
	local total = 0; // How much has been received
	
	umsg.Start( "dsr_start", pl );
		umsg.String( handler );
		
		if !t then
		
			umsg.Long( 0 );
			
		end
		
		if t then
		
			// Process the table
			local st = Json.Encode( t ); // Convert to a string
			st = string.gsub( st, "\"", "\2" );
			st = string.gsub( st, "\n", "\3" );
			total = string.len( st ); // Get the length
			c = SplitTransmission( st, 128 ); // Split the transmission into 128 character blocks
			umsg.Long( string.len( st ) ); // Send the length
			
		end
		
	umsg.End( ); // Send off our datastream start 

	if t and c then // Do we have data to send?
		
		for k, v in pairs( c ) do
		
				umsg.Start( "dsr_piece", pl );
				
					umsg.String( v ); // Send the 128 char block
				
				umsg.End( );
				
				sent = sent + string.len( v ); // Update the total sent
				
				if callback then
				
					callback( pl, sent, total ); // If we have a callback, tell it how much we have sent so far.
					
				end
		
		end
		
	end
	
	umsg.Start( "dsr_end", pl ); // Tell client we are done here.
	umsg.End( );
	
end

function Hook( name, unique, func, callback ) // Hook/handler add function

	local handler = { };
	handler.name = name;
	handler.unique = unique;
	handler.func = func;
	handler.callback = callback;
	
	handlers[unique] = handler;

end

function Load( )

	local function DataStreamStart( pl, cmd, args )

		local stream = { }; // Create our stream table
		stream.pl = pl;
		
		if args[1] != "\1" then
		
			print( "Datastream hacking attempt by " .. pl:Name( ) );
			return;
			
		end
		
		stream.handler = args[2];
		stream.total = args[3];
		stream.data = "";
		
		streams[ pl ] = stream; // Add the stream to our streams table, indexed by the player.

	end

	local function DataStreamReceive( pl, cmd, args )
			
			if !streams[ pl ] then return end // We didn't get a DatastreamStart!
			
			local dat = table.concat( args, " " );
			if string.sub( dat, 1, 1 ) != "\1" then
			
				print( "Datastream hacking attempt by " .. pl:Name( ) );
				return;
				
			end
			
			dat = string.sub( dat, 2, string.len( dat ) );
			
			streams[ pl ].data = streams[ pl ].data .. dat; // Add the data to the data cache
			// streams[ pl ].downloaded = streams[ pl ].downloaded + string.len( dat ); // Update the downloaded amount
			
			umsg.Start( "StreamDataReceived", pl ); // Tell the client how much we have received
				umsg.Long( string.len( streams[ pl ].data ) );
			umsg.End( );
						
			for _, handler in pairs( handlers ) do
			
				if handler.name == streams[ pl ].handler then
					
					if handler.callback then
						
						handler.callback( pl, string.len( streams[ pl ].data ), streams[ pl ].total ); // Call the callback to tell it how much we have received so far
				
					end
					
				end
				
			end
			
	end

	local function DataStreamEnd( pl, cmd, args )
	
			if !streams[ pl ] then return end // Nothing to end
			if args[1] != "\1" then
			
				print( "Datastream hacking attempt by " .. pl:Name( ) );
				
			end
			for _, handler in pairs( handlers ) do
			
				if handler.name == streams[ pl ].handler then
				
					handler.func( pl, Json.Decode( string.gsub( string.gsub( streams[ pl ].data, "\2", "\"" ), "\3", "\n" ) ) ); // Pass off the data to the handler

				end
				
			end
			
			streams[ pl ] = nil; // Clear the stream buffer

	end
	
	concommand.Add( "dsr_start", DataStreamStart );
	concommand.Add( "dsr", DataStreamReceive );
	concommand.Add( "dsr_end", DataStreamEnd );
	
end