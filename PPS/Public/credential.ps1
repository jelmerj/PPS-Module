function Get-PPSCredential {
    <#
        .SYNOPSIS
        Retrieves all properties of a credential entry

        .DESCRIPTION
        Retrieves all properties of a credential entry

        .PARAMETER CredentialID
        Specifies the guid of the credential entry to retrieve

        .PARAMETER Connection
        Optional parameter to specify the connection to use

        .EXAMPLE
        Get-PPSCredential -Credential b2743ec0-b5f2-4afe-8236-6a8d1971b0a5
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$CredentialID,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultPPSConnection
    )
    
    $uri = "/api/v4/rest/credential/" + $CredentialID + "/password"

    Invoke-PPSRestAPI -uri $uri -method GET -connection $connection
}

function Add-PPSCredential {

    <#
        .SYNOPSIS
        Add a credential entry

        .DESCRIPTION
        Add a credential entry

        .PARAMETER Name
        The name of the credential entry

        .PARAMETER Username
        The username

        .PARAMETER Password
        The password in cleartext

        .PARAMETER Url
        The URL field

        .PARAMETER KeePassIconId
        When using KeePass to work with Pleasant Password Server you can specify an icon for entries. This is the number you see in the KeePass GUI

        .PARAMETER Connection
        Optional parameter to specify the connection to use

        .EXAMPLE
        Add-PPSCredential -Name "Domain Administrator" -GroupID "6f042645-660d-4f76-94c1-107a91f05a2d" -Username "Administrator" -Password "VeryS3cret"
    #>
    
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$GroupID,
        [Parameter(Mandatory = $false)]
        [string]$username,
        [Parameter(Mandatory = $false)]
        [string]$password,
        [Parameter(Mandatory = $false)]
        [string]$Url,
        [Parameter(Mandatory = $false)]
        [string]$Notes,
        [Parameter(Mandatory = $false)]
        [int]$KeePassIconId,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultPPSConnection
    )

    $uri = "/api/v4/rest/credential"

    $credential = New-Object -TypeName PSObject
    $credential | add-member -name "name" -membertype NoteProperty -Value $name
    $credential | add-member -name "GroupID" -membertype NoteProperty -Value $GroupID
    $credential | add-member -name "Url" -membertype NoteProperty -Value $Url
    $credential | add-member -name "Notes" -membertype NoteProperty -Value $Notes
    $credential | add-member -name "Username" -membertype NoteProperty -Value $username
    $credential | add-member -name "Password" -membertype NoteProperty -Value $password

    $customapplicationfields = New-Object -TypeName PSObject

    If ($KeePassIconId) {
        $customapplicationfields | add-member -Name "IconId" -MemberType NoteProperty -Value $KeePassIconId
    }

    $credential | add-member -name "CustomApplicationFields" -membertype NoteProperty -Value $customapplicationfields

    $results = Invoke-PPSRestAPI -uri $uri -body $credential -method POST -connection $Connection

    $results
   
}