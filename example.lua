include("mysql.lua");

mysql:Connect("localhost", "example", "password", "example", 3306);

hook.Add("DatabaseConnected", "example.DatabaseConnected", function()

	--[[ Create the "example" table if it does not exist. --]]
	local queryObj = mysql:Create("example");
		queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT");
		queryObj:Create("name", "VARCHAR(255) NOT NULL");
		queryObj:Create("steam_id", "VARCHAR(25) NOT NULL");
		queryObj:PrimaryKey("id");
	queryObj:Execute();

end);

hook.Add("PlayerInitialSpawn", "example.PlayerInitialSpawn", function(player)

	--[[ Select the player's database entry by their steam id. --]]
	local queryObj = mysql:Select("example");
		queryObj:Where("steam_id", player:SteamID());
		queryObj:Callback(function(result, status, lastID)
			if (type(result) == "table" and #result > 0) then

				--[[ Update the player's name in the database if it exists. --]]
				local updateObj = mysql:Update("example");
					updateObj:Update("name", player:Name());
					updateObj:Where("steam_id", player:SteamID());
				updateObj:Execute();

			else

				--[[ Insert the player's information into the example table. --]]
				local insertObj = mysql:Insert("example");
					insertObj:Insert("name", player:Name());
					insertObj:Insert("steam_id", player:SteamID());
					insertObj:Callback(function(result, status, lastID)
						print(string.format("Added \"%\" to the example table", player:Name()));
					end);
				insertObj:Execute();

			end;
		end);
	queryObj:Execute();

end);

timer.Create("example.SaveData", 60, 0, function()
	for k, v in pairs(player.GetAll()) do

		--[[ Queue and update to the player's name in the database (would usually be for data saving). --]]
		local updateObj = mysql:Update("example");
			updateObj:Update("name", v:Name());
			updateObj:Where("steam_id", v:SteamID());
		updateObj:Execute(true);
		--[[ Passing true to Execute will queue the query. ]]--

	end;
end);

--[[ This will poll the database queue every second and process any queued queries. --]]
timer.Create("example.Think", 1, 0, function()
	mysql:Think();
end);
