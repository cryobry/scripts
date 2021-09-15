// Copyright (c) 2021 Bryan C. Roessler
// 
// This script will probe the WSL2 instance for its randomly assigned IP
// and open the requisite Windows Firewall ports
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

# Get the WSL instance IP address (randomized on init)
$remoteport = bash.exe -c "ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1"

# All the ports you want to forward separated by comma
$ports=@(22);
$ports_a = $ports -join ",";

# Listening address
$addr='0.0.0.0';

# Remove existing rules
iex "Remove-NetFireWallRule -DisplayName 'WSL2 Services' ";

# Add Inbound/Outbound exception rules
iex "New-NetFireWallRule -DisplayName 'WSL Services' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL Services' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP";

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr";
  iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport";
}
