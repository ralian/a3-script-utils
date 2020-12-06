# Using the server configuration script

This set of scripts and configurations is designed for those running an Arma 3 Dedicated server which needs frequently updated mods or parameter values. The mods might come from a service like Steam; If you use Steam for mods, you know it is notorious for performing version updates forcibly or even deleting your mod files if they are removed from the workshop. This script makes a copy of mods from your steam workshop directory (or other mod directory) for your servers to use.

Each server configuration is decided by the `server.json` file; the powershell script `sm-update.ps1` updates the currently installed mods and keys, then generates a start parameter in a file named `start.bat`.

A few important notes:

- Be *very careful* when copying paths into the configuration file. Powershell does not like backslashes; I tried to escape inputs where I could, but you should format your paths `C:/like/this/`, not `C:\like\this`.
- When adding mods to the list of server mods in JSON, remember to leave trailing commas off of entries (e.g. `[0,1,2,3,4,5,]`). While some JSON parsing libraries are okay with this, it breaks the one built into PS. It will give you an error like “Invalid JSON Primitive: .”

## Installation

1. Decide what directories you want your server(s) to be in. It is recommended to use a path on one of your drives root directories, to keep the path short. In this example we will use `C:/A3Servers/`. Make this directory and install a copy of `sm-update.ps1` here.
2. Decide what to name your first server. A very sensible name is `“Server 1”`. Copy the example .json file into `C:/A3Servers/` and rename it to `“server1.json”`. Your two files should look like this: ![image-20201206071246053](C:\Users\wtb0019\Desktop\a3-script-utils\README.assets\image-20201206071246053.png)
3. Open `server1.json` and set the `ServerName` variable to `“Server 1”`. Set `ServerPort` to 2302 or whatever you want the port to be. Set the `ServerDir` variable to `“C:/A3Servers/Server1”` or similar.
4. Determine what directory you want your mods to be copied into. This is usually something shared between multiple servers, i.e. `“C:/Mods/”` or `“C:/A3Servers/Mods”`. You should try and keep this path short. We will use `“C:/SM/”`. For that directory you can leave the `ServerModDir` variable as-is.
5. Find your mod directory. If using Steam, it is usually in `“C:/SteamLibrary/steamapps/common/Arma 3/!Workshop"`. Find your corresponding directory and copy it to the `SteamModDir` variable in `server1.json`.
6. At this point your file should look like this: ![image-20201206065955918](C:\Users\wtb0019\Desktop\a3-script-utils\README.assets\image-20201206065955918.png)
   Leave the mod list empty and run the script with `.\sm-update.ps1 .\server1.json`. This will generate a folder called `Server1`.

