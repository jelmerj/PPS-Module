function Connect-PPSService {
    param (
        [Parameter(Mandatory = $true)]
        [string]$hostname,
        [Parameter(Mandatory = $true)]
        [pscredential]$cred,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [int]$port = 10001,
        [Parameter(Mandatory = $false)]
        [boolean]$DefaultConnection = $true
    )

    $connection = @{server = ""; port = ""; headers = "" }

    $tokenParams = @{
        grant_type='password';
        username=$Cred.UserName;
        password=$Cred.GetNetworkCredential().password;
    }

    $url = "https://" + $hostname + ":" + $port 

    # Request a security token for the specified user that will be used to authenticate when requesting a password
    $Response = Invoke-WebRequest -Uri "$url/OAuth2/Token" -Method POST -Body $tokenParams -ContentType "application/x-www-form-urlencoded" -SessionVariable PPS -TimeoutSec 5
    # The RESTful API returns a JSON object.  Convert that to a PowerShell object and extract just the access_token
    $Token = (ConvertFrom-Json $Response.Content).access_token

    $headers = @{
        "Accept" = "application/json"
        "Authorization" = "$Token"
    }

    $connection.server = $hostname
    $connection.port = $port
    $connection.headers = $headers

    if ( $DefaultConnection ) {
        set-variable -name DefaultPPSConnection -value $connection -scope Global
    }

    $connection
}
