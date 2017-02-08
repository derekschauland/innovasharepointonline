function Move-DocLibFiles
{
	<#.EXTERNALHELP c:\Users\dschauland\Documents\SAPIEN\PowerShell Studio\Files\SPO\move-doclibfiles.ps1-Help.xml#>
	[cmdletbinding()]
	param (
		[string]$sharepointURL,
		[string]$sourcelibrary,
		[string]$targetlibrary,
		

		[switch]$count
	)
	$ErrorActionPreference = 'SilentlyContinue'
	if (!(Get-Module pslogging))
	{
		#Start-Process "$PSHOME\powershell.exe" -verb runas -ArgumentList '-command "Find-Module pslogging | install-module"'
		Find-Module pslogging | Install-Module
	}
	else
	{
		
	}
	
	if (!(Get-Module SharePoint*))
	{
		Find-Module SharePointPnPPowerShellOnline | Install-Module -Scope currentuser
	}
	else
	{
		
	}
	
	
	$folder = $sourcelibrary
	$target = $targetlibrary
	
	$test = get-pnpfolderitem -foldersiterelativeurl $folder -itemtype File -erroraction SilentlyContinue
	
	if (!$test)
	{
		connect-pnponline -url $sharepointURL -credentials (Get-Credential -Message "Enter SharePoint Logon")
	}
	else
	{
		$files = get-pnpfolderitem -foldersiterelativeurl $folder -itemtype File
	}
	
	
	
	
	
	
	function time-now
	{
		$(Get-Date -Format "yyyy-MM-dd-hh-mm-ss")
	}
	
	$logfilepath = "c:$env:HOMEPATH\documents\logs\"
	
	if (!(Test-Path -Path $logfilepath))
	{
		$null = New-Item -Path $logfilepath -ItemType Directory
	}
	
	$logname = "Sharepoint-Document-Library-Migration-$(time-now).log"
	
	$fulllogpath = $logfilepath + $logname
	
	Start-Log -LogPath $logfilepath -LogName "$logname" -ScriptVersion "1.0.0" | Out-Null
	
	
	if (!$count)
	{
		if ($($files.count) -eq 0)
		{
			Write-verbose "No files in the source library - $folder - check the path and try again."
			Write-LogInfo -LogPath $fulllogpath -Message "[$(time-now)] Count Parameter not used - No files to move from $folder"
		}
		else
		{
			foreach ($file in $files)
			{
				$path = $folder + $file.name
				$targetpath = $target + $file.name
				
				move-pnpfile -siterelativeurl $path -targeturl $targetpath -force
				
				Write-LogInfo -LogPath $fulllogpath -Message "[$(time-now)] Count Parameter Not Specified - Moved file: $path to $targetpath"
			}
			
			Write-verbose "$($files.count) files have been moved from $folder to $target"
			Write-LogInfo -LogPath $fulllogpath -Message "[$(time-now)] Count Parameter Not Specified -  Moved $($files.count) from $folder to $target"
			
		}
		
	}
	else
	{
	<#		foreach ($file in $files)
			{
				$path = $folder + $file.name
				$targetpath = $target + $file.name
				
				move-pnpfile -siterelativeurl $path -targeturl $targetpath -confirm:$false
			}#>
		
		Write-verbose "$($files.count) will be moved from $folder to $target. Re-run this command without -count to proceed."
		Write-LogInfo -LogPath $fulllogpath -Message "[$(time-now)] Count Parameter Specified - $($files.count) will be moved from $folder to $target. Re-run this command without the -count parameter to complete the move."
	}
	
	Stop-Log -LogPath $fulllogpath -NoExit
	$ErrorActionPreference = 'Continue'
}