﻿
function Migrate-INDocumentLibrary
{
	<#.EXTERNALHELP innovasharepointonline.psm1-Help.xml#>
	
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
		$sharepointURL = "https://ultraplating.sharepoint.com/test"
		
		$query = "<view><RowLimit>5000</RowLimit></View>"
		
		$files = get-pnplistitem -list $folder -query $query
#		$targetSiteUri = [System.Uri]$sharepointURL
#		
#		$context = (Get-pnpWeb).Context
#		$credentials = $context.Credentials
#		$authenticationCookies = $credentials.GetAuthenticationCookie($targetSiteUri, $true)
#		
#		$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
#		$webSession.Cookies.SetCookies($targetSiteUri, $authenticationCookies)
#		$webSession.Headers.Add("Accept", "application/json;odata=verbose")
#		
#		$sourcelibrary = "SharedDocuments"
#		$apiUrl = "$sharepointURL" + "/_api/web/lists/getByTitle('$sourceLibrary')/Files?`$top=5000"
#		
#		$webRequest = Invoke-WebRequest -Uri $apiUrl -Method Get -WebSession $webSession
#		
#		# Consume the JSON result
#		$jsonLibrary = $webRequest.Content | ConvertFrom-Json
#		
#		$files = $jsonLibrary.d.results
		
		Write-Host "There are $($files.count) in the Files var now"
		
		#$files = get-pnpfolderitem -foldersiterelativeurl $folder -itemtype File
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
	
<#	function split-array
	{
		[CmdletBinding()]
		param (
			[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
			$Collection,
			[Parameter(Mandatory = $true)]
			[ValidateRange(1, 247483647)]
			[int]$Count)
		begin
		{
			$Ctr = 0
			$Array = @()
			$TempArray = @()
		}
		process
		{
			foreach ($e in $Collection)
			{
				if (++$Ctr -eq $Count)
				{
					$Ctr = 0
					$Array += , @($TempArray + $e)
					$TempArray = @()
					continue
				}
				$TempArray += $e
			}
		}
		end
		{
			if ($TempArray) { $Array += , $TempArray }
			$Array
		}
	}
	
#>	#$filechunks = split-array -collection $files -count 100
	
	if (!$count)
	{
		if ($($files.count) -eq 0)
		{
			Write-verbose "No files in the source library - $folder - check the path and try again."
			Write-LogInfo -LogPath $fulllogpath -Message "[$(time-now)] Count Parameter not used - No files to move from $folder"
		}
		else
		{
		<#	
		foreach ($i in $filechunks.count)
			{
				foreach ($file in $filechunks[$i])
				{
					$source = $folder + "/" + $file.name
					$targetpath = $target + "/" + $file.name
					
					move-pnpfile -siterelativeurl $source -targeturl $targetpath -force
					
					Write-Host "$source headed to $targetpath - inside loop" 
					
				}
				#>
				
				Write-LogInfo -LogPath $fulllogpath -Message "[$(time-now)] Count Parameter Not Specified - Moved file: $source to $targetpath"
			#}
			$counter = 1
			foreach ($file in $files)
			{
				$source = $folder + "/" + $file
				$targetpath = $target + "/" + $file
				
				Write-Host "$($source.title) will be moved to $($targetpath.title) - file count is $counter"
				
				
				
					
				move-pnpfile -siterelativeurl $source -targeturl $targetpath -force
				
				#$sharepointURL = "https://ultraplating.sharepoint.com/test"
				#$targetSiteUri = [System.Uri]$sharepointURL
#				
#				$postcontext = (Get-pnpWeb).Context
#				$postcredentials = $postcontext.Credentials
#				$postauthenticationCookies = $postcredentials.GetAuthenticationCookie($targetSiteUri, $true)
#				
#				$webSession2 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
#				$webSession2.Cookies.SetCookies($targetSiteUri, $postauthenticationCookies)
#				$webSession2.Headers.Add("Accept", "application/json;odata=verbose")
#				
#				#$sourcelibrary = "SharedDocuments"
#				$postapiUrl = "$sharepointURL" + "/_api/web/lists/getByTitle('$targetlibrary')/"
#				
#				$postwebRequest = Invoke-WebRequest -Uri $postapiUrl -Method Post -WebSession $webSession2
#				
#				# Consume the JSON result
#				#$jsonLibrary2 = $postwebRequest.Content | ConvertFrom-Json
#				
#				#$files = $jsonLibrary.d.results
				$counter++
			}
			
			Write-verbose "$($files.count) files have been moved from $folder to $target"
			Write-LogInfo -LogPath $fulllogpath -Message "[$(time-now)] Count Parameter Not Specified -  Moved $($files.count) from $folder to $target"
			
		}
		
	}
	else
	{
		Write-verbose "$($files.count) will be moved from $folder to $target. Re-run this command without -count to proceed."
		Write-LogInfo -LogPath $fulllogpath -Message "[$(time-now)] Count Parameter Specified - $($files.count) will be moved from $folder to $target. Re-run this command without the -count parameter to complete the move."
	}
	
	Stop-Log -LogPath $fulllogpath -NoExit
	$ErrorActionPreference = 'Continue'
}

function Add-INDocuments
{
	<#.EXTERNALHELP Add-INDocuments-Help.xml#>
	
	param ([parameter(Mandatory)]
		[string]$path,
		[string]$library,
		[switch]$progress
	)
	
	$uploads = Get-ChildItem -Path $path
	
	$pnpSite = (get-pnpsite).url
	$pnpweb = (get-pnpweb).serverrelativeurl
	
	Write-Host "Current SharePoint Online Environment: $pnpSite"
	Write-Host "Current Site within SharePoint Online Environment: $pnpweb"
	
	if ($progress)
	{
		$x = 0
		foreach ($file in $uploads)
		{
			$x++
			
			Write-Progress -Activity "Uploading Files" -Status "Percent Complete: " -PercentComplete (($x / $uploads.count) * 100)
			add-pnpfile -path $file -folder $library
		}
	}
	else
	{
		#$x = 0
		foreach ($file in $uploads)
		{
			#$x++
			
			#Write-Progress -Activity "Uploading Files" -Status "Percent Complete: " -PercentComplete (($x / $uploads.count) * 100)
			add-pnpfile -path $file -folder $library
		}
	}
	
}

function New-INTestFiles
{
	param ([string]$path,
		[int]$maxfiles,
		[int]$startwith = 0,
		[switch]$progress
	)
	
	if ($progress)
	{
		for ($i = $startwith; $i -lt ($startwith + $maxfiles); $i++)
		{
			Write-Progress -Activity "Creating asdf Files" -Status "Percent Complete: " -PercentComplete (($i / ($startswith + $maxfiles).count) / 100)
			$filepath = $path + "\asdf$i.txt"
			Add-Content -Path $filepath -Value "asdf" | out-null
		}
	}
	else
	{
		for ($i = $startwith; $i -lt ($startwith + $maxfiles); $i++)
		{
			#Write-Progress -Activity "Creating asdf Files" -Status "Percent Complete: " -PercentComplete (($i / ($startswith + $maxfiles).count) * 100)
			$filepath = $path + "\asdf$i.txt"
			Add-Content -Path $filepath -Value "asdf" | out-null
		}
	}
	
}