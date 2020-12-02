function Invoke-PPSRestAPI {
    param (
        [Parameter(Mandatory = $true)]
        [string]$uri,
        [Parameter(Mandatory = $false)]
        [ValidateSet("GET", "PUT", "POST", "DELETE","PATCH")]
        [string]$method = "GET",
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter(Mandatory = $false)]
        [psobject]$connection
    )

    if ($null -eq $connection ) {
        if ($null -eq $DefaultPPSConnection) {
            Throw "Not Connected. Connect to the Pleasant Password Server with Connect-PPSService"
        }
        $connection = $DefaultPPSConnection
    }   

    $url = "https://" + $connection.server + ":" + $connection.port + $uri

    try {
        if ($body) {

            Write-Verbose -message ($body | ConvertTo-Json)

            $response = Invoke-RestMethod -uri $url -Method $method -body ($body | ConvertTo-Json) -Headers $connection.headers -ContentType "application/json"
        }
        else {
            Write-Verbose -message "PPS Query $url"
            $response = Invoke-RestMethod -uri $url -Method $method -Headers $connection.headers
        }
    }

    catch {
        Show-PPSException $_
        throw "Unable to use PPS API"
    }
    $response
}
function Invoke-PPSCredentialSearch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [psobject]$credentialgroups,
        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    [psobject]$results = @()
    $results += $credentialgroups | Where-Object Name -like "*$Name*"

    foreach ($credentialgroup in $credentialgroups) {
        If ($credentialgroup.Children) {
            $results += Invoke-PPSCredentialSearch -credentialgroups $credentialgroup.Children -name $Name
        } 
    }

    $results
  
}


