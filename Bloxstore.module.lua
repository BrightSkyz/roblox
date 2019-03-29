--[[
	BloxStore module for integrating BloxStore into Roblox games.
	
	Getting started:
	 1. Sign up for a BloxStore account by going to https://bloxstore.whats-in.space
	 2. Create a table
	 3. Add some columns
	 4. Put this script into a ModuleScript and require() it
	 5. Using the API you can integrate your game into BloxStore
	
	Important Notes:
	 - Do NOT interface with BloxStore on the client-side, doing so can leave your table open to exploiters
	 - When running a SQL statement, replace the name of the table with %table% for the statement to work
	
	Created by: CoreDev
	Website: https://bloxstore.whats-in.space
--]]

local BloxStore = {}

local httpService = game:GetService("HttpService")

local defaultTableKey = ""
local debugMode = false

--[[
	@description Encodes the data to be sent in the POST request
	@param data: The table of data
	@resturns string: The data that is encoded for POST requests
--]]
function BloxStore:buildQuery(data)
	local built = ""
	for key, value in pairs(data) do
		if built ~= "" then
			built = built .. "&"
		end
		built = built .. key .. "=" .. value
	end
	return built
end

--[[
	@description Sets the default table key for the runSQL function
	@param tableKey: The table key
--]]
function BloxStore:setTableKey(tableKey)
	defaultTableKey = tableKey
	if debugMode then
		local i = 0
		local censored = ""
		while string.len(tableKey) > i do
			i = i + 1
			if (string.len(tableKey) - 5) < i then
				censored = censored .. string.sub(tableKey, i, i)
			else
				censored = censored .. "*"
			end
		end
		print("BloxStore: Setting default table key to: " .. censored)
	end
end

--[[
	@description Used to set the debug mode which prints out useful information to the console
	@param value: A boolean for wether or not debug should be enable
--]]
function BloxStore:setDebugMode(value)
	if value == true or value == false then
		debugMode = value
		if debugMode then
			print("BloxStore: Enabling debug mode.")
		else
			print("BloxStore: Disabling debug mode.")
		end
	end
end

--[[
	@description Sends a POST request to the BloxStore API
	@param path: The path starting with / with the endpoint
	@param requestData: The encoded post data
	@resturns table: The JSON response from the API decoded
--]]
function BloxStore:sendApiRequest(path, requestData)
	local response = httpService:PostAsync(
	    "https://bloxstore.whats-in.space/api/v1" .. path,
	    BloxStore:buildQuery(requestData),
	    Enum.HttpContentType.ApplicationUrlEncoded
	)
	if debugMode then
		print("BloxStore: Response received from the API: " .. response)
	end
	return httpService:JSONDecode(response)
end

--[[
	@description Runs an SQL statement on the table
	@param tableKey: (Optional) The table key for the table to run the statement on
	@param query: The SQL statement to run on the API
	@resturns table: The JSON response from the API decoded
--]]
function BloxStore:runSQL(...)
	local args = {...}
	if #args == 1 then
		local query = args[1]
		if debugMode then
			print("BloxStore: Running \"" .. query .. "\" on the table.")
		end
		return BloxStore:sendApiRequest("/sql", {
			tablekey = defaultTableKey,
			query = query
		})
	elseif #args == 2 then
		local tableKey = args[1]
		local query = args[2]
		if debugMode then
			print("BloxStore: Running \"" .. query .. "\" on the table.")
		end
		return BloxStore:sendApiRequest("/sql", {
			tablekey = tableKey,
			query = query
		})
	end
end

--[[
	@description Runs an SQL prepared statement on the table
	@param tableKey: (Optional) The table key for the table to run the statement on
	@param query: The SQL statement to run on the API
	@param values: The values in a table for the prepared statement
	@resturns table: The JSON response from the API decoded
--]]
function BloxStore:runPreparedSQL(...)
	local args = {...}
	if #args == 2 then
		local query = args[1]
		local values = args[2]
		if debugMode then
			print("BloxStore: Running \"" .. query .. "\" on the table with values: " .. httpService:JSONEncode(values))
		end
		return BloxStore:sendApiRequest("/sql", {
			tablekey = defaultTableKey,
			query = query,
			values = httpService:JSONEncode(values)
		})
	elseif #args == 3 then
		local tableKey = args[1]
		local query = args[2]
		local values = args[3]
		if debugMode then
			print("BloxStore: Running \"" .. query .. "\" on the table with values: " .. httpService:JSONEncode(values))
		end
		return BloxStore:sendApiRequest("/sql", {
			tablekey = tableKey,
			query = query,
			values = httpService:JSONEncode(values)
		})
	end
end

return BloxStore
