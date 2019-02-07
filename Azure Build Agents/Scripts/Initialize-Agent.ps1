[Reflection.Assembly]::LoadWithPartialName("System.Web") >$null 2>&1

#mandatory parameters
$AccountUrl=$env:ACCOUNT_URL
$AgentToken=$env:AGENT_TOKEN

if(!$AccountUrl) {
    throw "ACCOUNT_URL must be set"
}

if(!$AgentToken) {
    throw "AGENT_TOKEN must be set"
}

#optional parameters
$AgentPool=$env:AGENT_POOL
$AgentUser=$env:AGENT_USER
$AgentName=$env:AGENT_NAME

if(!$AgentPool) {
    $AgentPool="Default"
}

if(!$AgentUser) {
    $AgentUser="build_agent"
}

if(!$AgentName) {
    $AgentName=$env:COMPUTERNAME
}

$User=Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True' and Name='$AgentUser'"

if($User) {
    "Agent is already configured, skipping..."
} else {
    "Configuring agent $AgentName..."
    $Password=[System.Web.Security.Membership]::GeneratePassword(20, 4) | ConvertTo-SecureString -AsPlainText -Force

    NET USER $AgentUser $Password /ADD /Y >$null 2>&1
    NET LOCALGROUP Administrators $AgentUser /ADD >$null 2>&1

    C:\agent\config.cmd --unattended --url $AccountUrl --auth pat --token $AgentToken --pool $AgentPool --agent $AgentName --replace --runAsService --windowsLogonAccount $AgentUser --windowsLogonPassword $Password --acceptTeeEula --noRestart
}

$Provider="VstsAgentService"

$event=Get-WinEvent -Provider $Provider -MaxEvents 1

Write-Output $event

$lastEventId=$event.RecordId

while($true) {
    $event=Get-WinEvent -Provider $Provider -MaxEvents 1

    if($event.RecordId -eq $lastEventId) {
        Start-Sleep -Seconds 1
    }
    else {
        (Write-Output $event | Format-Table -HideTableHeaders | Out-String).Trim().Trim("ProviderName: $Provider").Trim()
        $lastEventId=$event.RecordId
    }
}


