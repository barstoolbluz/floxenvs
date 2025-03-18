# ==========================================
# YOU MUST PREPEND 'Set-ExecutionPolicy Bypass -Scope Process -Force;' TO RUN THIS SCRIPT WITH POWERSHELL
# ==========================================

# get the windows cwd in powerShell and convert it to a string
$windowsPath = Get-Location | ForEach-Object { $_.Path }

# convert asinine windows backslashes to correct unix-y forward slashes
$windowsPath = $windowsPath -replace "\\", "/"

# convert asinine windows cwd path to a valid unix-y cwd path in wsl2
$wslPath = wsl.exe wslpath -u "$windowsPath"

# debug output (comment-out if unneeded)
# Write-Host "Windows Path: $windowsPath"
# Write-Host "Converted WSL Path: $wslPath"

$remoteport = bash.exe -c "ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1"
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if ($found) {
    $remoteport = $matches[0];
} else {
    Write-Host "The script exited. Could not find WSL 2 IP address."
    exit
}

# define the ports you want to forward
$ports=@(3000); # add or modify ports in this array if you need to add ports besides 3000

# define the IP address on which windows listens + forwards traffic
$addr='0.0.0.0'; # change to a specific IP address if you want windows to forward traffic only on that interface

# if exists remove firewall rule for next.js forwarding
$firewallRule = Get-NetFireWallRule -DisplayName 'WSL 2 Next.js Port Forwarding' -ErrorAction SilentlyContinue
if ($firewallRule) {
    Remove-NetFireWallRule -DisplayName 'WSL 2 Next.js Port Forwarding'
}

# add new firewall rules
iex "New-NetFireWallRule -DisplayName 'WSL 2 Next.js Port Forwarding' -Direction Outbound -LocalPort 3000 -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL 2 Next.js Port Forwarding' -Direction Inbound -LocalPort 3000 -Action Allow -Protocol TCP";

# set up port forwarding for next.js (windows -> wsl2)
iex "netsh interface portproxy delete v4tov4 listenport=3000 listenaddress=$addr";
iex "netsh interface portproxy add v4tov4 listenport=3000 listenaddress=$addr connectport=3000 connectaddress=$remoteport";

# ==========================================
# run 'flox activate' inside wsl2
# ==========================================

# construct the command to run inside wsl2
$command = "./ollama.service; bash"

# debug output that verifies the construction of this command; uncomment to enable debugging
# Write-Host "Final command: $command"

# run the command inside wsl2
wsl.exe -e bash -c "cd $wslPath && $command"

# NOTE the FIRST: If WSL2 is not already running, Ollama services may take up to a minute to come online.

# NOTE the SECOND: If you close the shell window, the Flox subshell will die and Ollama services will terminate.
