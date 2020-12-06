# Usage: sm-update.psc2 name-of-configuration-file.json > output.txt

echo ("Parsing " + $args[0])
$json = Get-Content -Path $args[0] | ConvertFrom-Json

# Quick JSON sanity check.
if (!$json.ServerName) {
  echo "Detected invalid JSON entries. Check your JSON or file a bug report! :)"
  Return
}

# Make the server and mod directories if not in existence
echo ('Updating "' + $json.ServerName + '" at ' + $json.ServerDir)
if (!(Test-Path -Path $json.ServerDir)) {mkdir $json.ServerDir}
if (!(Test-Path -Path $json.ServerModDir)) {$json.ServerModDir}

# If the keys directory exists, back it up to keysbackup and clean it
$keys = ($json.ServerDir + "/keys")
$keysbackup = ($json.ServerDir + "/keysbackup")
if (Test-Path -Path $keys) {

  # Make the backup directory. Clean it if it exists.
  if (!(Test-Path -Path $keysbackup)) {mkdir $keysbackup} else {rm ($keysbackup + "/*")}

  mv ($keys + "/*") ($keysbackup)

} else {mkdir $keys}

# Copy all of the mods.
$modparam = '"-mod=' # Mod line for the parameters.
foreach($mod in $json.Mods.PsObject.properties) {
  if (Test-Path -Path ($json.SteamModDir + "/" + $mod.name)) {
    echo ("Copying " + $mod.name + " to " + $json.ServerModDir + "/" + $mod.value)
    $modparam += ($json.ServerModDir + "/" + $mod.value + ";") # Build parameter entry

    # Clean dir if it exists, then copy and rename the entry from the steam folder
    if (Test-Path -Path ($json.ServerModDir + "/" + $mod.value)) {rm -r ($json.ServerModDir + "/" + $mod.value)}
    cp -r ($json.SteamModDir + "/" + $mod.name) ($json.ServerModDir)
    if (!($mod.name -eq $mod.value)) # Only copy if name and abbreviation not equal
      {Rename-Item ($json.ServerModDir + "/" + $mod.name) ($mod.value)}

    # Finally, copy all of the keys.
    cp ($json.ServerModDir + "/" + $mod.value + "/keys/*") ($keys)
    cp ($json.ServerModDir + "/" + $mod.value + "/Keys/*") ($keys)
  } else {
    Write-Error ("UNABLE TO FIND MOD " + $mod.name + " IN DIRECTORY " + $json.SteamModDir)
  }
}
$modparam += '"' # Closing quotation
echo ("Mod Parameter: " + $modparam)

# Copy all of the servermods.
$servermodparam = '"-servermod=' # Mod line for the parameters.
foreach($mod in $json.ServerMods.PsObject.properties) {
  if (Test-Path -Path ($json.SteamModDir + "/" + $mod.name)) {
    echo ("Copying " + $mod.name + " to " + $json.ServerModDir + "/" + $mod.value)
    $servermodparam += ($json.ServerModDir + "/" + $mod.value + ";") # Build parameter entry

    # Clean dir if it exists, then copy and rename the entry from the steam folder
    if (Test-Path -Path ($json.ServerModDir + "/" + $mod.value)) {rm -r ($json.ServerModDir + "/" + $mod.value)}
    cp -r ($json.SteamModDir + "/" + $mod.name) ($json.ServerModDir)
    if (!($mod.name -eq $mod.value)) # Only copy if name and abbreviation not equal
      {Rename-Item ($json.ServerModDir + "/" + $mod.name) ($mod.value)}

    # Obviously, do not copy the keys for the server mods.
  } else {
    Write-Error ("UNABLE TO FIND SERVER MOD " + $mod.name + " IN DIRECTORY " + $json.SteamModDir)
  }
}
$servermodparam += '" ' # Closing quotation
echo ("Server Mod Parameter: " + $servermodparam)

# Copy all of the keys for client side mods.
foreach($mod in $json.AllowedKeys.PsObject.properties) {
  if (Test-Path -Path ($json.SteamModDir + "/" + $mod.name)) {
    echo ("Copying " + $mod.name + " to " + $json.ServerModDir + "/" + $mod.value)

    # Clean dir if it exists, then copy and rename the entry from the steam folder
    if (Test-Path -Path ($json.ServerModDir + "/" + $mod.value)) {rm -r ($json.ServerModDir + "/" + $mod.value)}
    cp -r ($json.SteamModDir + "/" + $mod.name) ($json.ServerModDir)
    if (!($mod.name -eq $mod.value)) # Only copy if name and abbreviation not equal
      {Rename-Item ($json.ServerModDir + "/" + $mod.name) ($mod.value)}

    # Copy all of the keys.
    cp ($json.ServerModDir + "/" + $mod.value + "/keys/*") ($keys)
    cp ($json.ServerModDir + "/" + $mod.value + "/Keys/*") ($keys)
  } else {
    Write-Error ("UNABLE TO FIND CLIENT MOD " + $mod.name + " IN DIRECTORY " + $json.SteamModDir)
  }
}

$port = $json.ServerPort
$config = "server.cfg"
$cfg = "A3.cfg"
$param = "./arma3server_x64.exe -port=$port -config=$config -cfg=$cfg -loadMissionToMemory -bandwidthAlg=2 -filePatching -profiles=./profiles " + $servermodparam + $modparam
echo "Start Parameter: " + $param

Out-File -FilePath ($json.ServerDir + "/start.bat") -InputObject $param
