[Reflection.Assembly]::LoadWithPartialName("System.Web") >$null 2>&1

#mandatory parameters
$AccountUrl=$env:ACCOUNT_URL
$AgentToken=$env:AGENT_TOKEN
$AgentName=$env:AGENT_NAME

if(!$AccountUrl) {
    throw "ACCOUNT_URL must be set"
}

if(!$AgentToken) {
    throw "AGENT_TOKEN must be set"
}

if(!$AgentToken) {
    throw "AGENT_NAME must be set"
}

#optional parameters
$AgentPool=$env:AGENT_POOL
$AgentUser=$env:AGENT_USER

if(!$AgentPool) {
    $AgentPool="Default"
}

if(!$AgentUser) {
    $AgentUser="build_agent"
}

$User=Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True' and Name='$AgentUser'"

if($User) {
    "Agent is already configured, skipping..."
} else {
    "Configuring agent $AgentName..."
    $Password=[System.Web.Security.Membership]::GeneratePassword(20, 4) | ConvertTo-SecureString -AsPlainText -Force

    NET USER $AgentUser $Password /ADD /Y >$null 2>&1
    NET LOCALGROUP Administrators $AgentUser /ADD >$null 2>&1

    cmd /c "C:\agent\config.cmd --unattended --url $AccountUrl --auth pat --token $AgentToken --pool $AgentPool --agent $AgentName --replace --runAsService --windowsLogonAccount $BuildAgentUser --windowsLogonPassword $Password --acceptTeeEula --noRestart"
}

if($env:AGENT_TOKEN) {
    Remove-Item env:AGENT_TOKEN
}