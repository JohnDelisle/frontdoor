[CmdletBinding()]
param (
    # version number, to increment RGs so we don't have wait between runs when destroying/ retrying development
    [Parameter()][int]$version = 10,
    [Parameter()][string]$rgPrefix = "app508-jmdpe"
)

$ErrorActionPreference = "Stop"

# the location against which to submit the Az bicep deployments - not where resources go..
$location = "eastus2"

# sub into which we will create RGs and resources
# RelEng 
$sub = "d7c0f56a-558e-46e3-bbbb-2c733b72f3d8"
# Hosting
# $sub = "4b1a4d38-d517-4e3e-b1e3-41e7ba8818e0"

# the environments, from the /env/ dir
$envs = @((Get-ChildItem -Path ./ -Directory | Where-Object { $_.name -ne "all" -and $_.name -ne "shared" }).name)

# set context
Write-Output "Selecting subscription $sub"
Select-AzSubscription $sub | Out-Null
az account set -s $sub

# provision the infra using the "all" env, which calls the regional envs as modules
Write-Output "Provisioning infra..."
az deployment sub create --location $location -f ./all/frontdoor.bicep --parameters version=$version


# deploy a simple static HTML page to the webApps, so we can see which we're hitting during testing
foreach ($env in $envs) {
    Write-Output "Deploying HTML to $env..."
    $htmlFile = "./$env/index.html"
    Write-Output "$env version $version" | Out-File -FilePath $htmlFile -Encoding ascii

    # Source: https://docs.microsoft.com/en-us/azure/app-service/scripts/powershell-deploy-ftp
    # Get publishing profile for the web app
    $xml = [xml](Get-AzWebAppPublishingProfile -Name "$($rgPrefix)$($version)-web-$($env)-app" -ResourceGroupName "$($rgPrefix)$($version)-web-$($env)" -OutputFile null)

    # Extract connection information from publishing profile
    $username = $xml.SelectNodes("//publishProfile[@publishMethod=`"FTP`"]/@userName").value
    $password = $xml.SelectNodes("//publishProfile[@publishMethod=`"FTP`"]/@userPWD").value
    $url = $xml.SelectNodes("//publishProfile[@publishMethod=`"FTP`"]/@publishUrl").value

    # Upload file 
    $file = Get-Item -Path $htmlFile
    $uri = New-Object System.Uri("$url/$($file.Name)")

    $request = [System.Net.FtpWebRequest]([System.net.WebRequest]::Create($uri))
    $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $request.Credentials = New-Object System.Net.NetworkCredential($username, $password)

    # Enable SSL for FTPS. Should be $false if FTP.
    $request.EnableSsl = $true;

    # Write the file to the request object.
    $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $request.ContentLength = $fileBytes.Length;
    $requestStream = $request.GetRequestStream()

    try {
        $requestStream.Write($fileBytes, 0, $fileBytes.Length)
    }
    finally {
        $requestStream.Dispose()
    }

    Write-Host "Uploading to $($uri.AbsoluteUri)"

    try {
        $response = [System.Net.FtpWebResponse]($request.GetResponse())
        Write-Host "Status: $($response.StatusDescription)"
    }
    finally {
        if ($null -ne $response) {
            $response.Close()
        }
    }
    Write-Output "Done"
}