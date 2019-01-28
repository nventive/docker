$agentZipPath = '.\vsts-agent.zip';

Invoke-WebRequest https://vstsagentpackage.azureedge.net/agent/2.144.2/vsts-agent-win-x86-2.144.2.zip -OutFile $agentZipPath
Expand-Archive -Path $agentZipPath -DestinationPath C:\agent\
Remove-Item -Path $agentZipPath