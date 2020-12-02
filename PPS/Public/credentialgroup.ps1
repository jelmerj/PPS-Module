function Get-PPSCredentialGroup {
    <#
        .SYNOPSIS
        Retrieves all properties of a credentialgroup

        .DESCRIPTION
        Retrieves all properties of a credentialgroup

        .PARAMETER CredentialGroupID
        Specifies the guid of the group to retrieve

        .PARAMETER Connection
        Optional parameter to specify the connection to use

        .EXAMPLE
        Get-PPSCredentialGroup -CredentialGroupID b2743ec0-b5f2-4afe-8236-6a8d1971b0a5
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$CredentialGroupID,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultPPSConnection
    )
        
    $uri = "/api/v4/rest/credentialgroup/" + $CredentialGroupID 

    Invoke-PPSRestAPI -uri $uri -method GET -connection $connection
}

function Find-PPSCredentialGroup {

    <#
        .SYNOPSIS
        Find a folder matching the specified name

        .DESCRIPTION
        Find folders where the name contains what you specify with the name parameter

        .PARAMETER Name
        Specifies the name to search for. Folder will be returned where the title contains the specified name

        .PARAMETER ParentID
        Optional parameter to start searching from the credentialgroup specified.

        .PARAMETER Recurselevel
        Optional parameter to specify the recurselevel. Default to 0 (unlimited)

        .EXAMPLE
        Find-PPSCredentialGroup -Name "CustomerX"

        .EXAMPLE
        Find-PPSCredentialGroup -Name "Windows" -ParentID "2637783e-6973-480c-afc4-8d146ef3d410"

    #>

    param (
        [Parameter(Mandatory = $false)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$ParentID,
        [Parameter(Mandatory = $false)]
        [int]$Recurselevel,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultPPSConnection
    )

    $uri = "/api/v4/rest/credentialgroup"

    If ($ParentID) { 
        $uri = $uri + "/$ParentID"
    }

    If ($Recurselevel) {
        $uri = $uri + "?recurselevel=$recurselevel"
    }

    $credentialgroups = Invoke-PPSRestAPI -uri $uri -method GET -connection $Connection

    $results = Invoke-PPSCredentialSearch -credentialgroups $credentialgroups -Name $Name

    $results
}

function Add-PPSCredentialGroup {
    <#
        .SYNOPSIS
        Add a folder

        .DESCRIPTION
        Add a folder to the password database

        .PARAMETER KeePassIconId
        When using KeePass to work with Pleasant Password Server you can specify an icon for entries. This is the number you see in the KeePass GUI

        .PARAMETER Connection
        Optional parameter to specify the connection to use

        .EXAMPLE
        Add-PPSCredentialGroup -Name "Windows servers" -ParentID "6f042645-660d-4f76-94c1-107a91f05a2d"
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$ParentID,
        [Parameter(Mandatory = $false)]
        [int]$KeePassIconId,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultPPSConnection
    )

    $uri = "/api/v4/rest/credentialgroup"

    $credentialgroup = New-Object -TypeName PSObject
    $credentialgroup | add-member -name "name" -membertype NoteProperty -Value $name
    $credentialgroup | add-member -name "ParentID" -membertype NoteProperty -Value $ParentID

    $customapplicationfields = New-Object -TypeName PSObject

    If ($KeePassIconId) {
        $customapplicationfields | add-member -Name "IconId" -MemberType NoteProperty -Value $KeePassIconId
    }

    $credentialgroup | add-member -name "CustomApplicationFields" -membertype NoteProperty -Value $customapplicationfields

    $results = Invoke-PPSRestAPI -uri $uri -body $credentialgroup -method POST -connection $Connection

    $results
   
}
