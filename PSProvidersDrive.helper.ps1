function Get-PSDriveProvider
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [String]
        $By,

        [Parameter()]
        [String]
        $Project
    )

    $providerData = Get-Content -Path "$PSScriptRoot\PSProvidersDrive.Data.json" -Raw
    $providerObject = ConvertFrom-Json -InputObject $providerData

    $names = (Get-Member -InputObject $providerObject -MemberType NoteProperty).Name

    $objects = @()
    foreach ($name in $names)
    {
        $hash = New-Object -TypeName PSCustomObject -Property @{
            "GitHubHandle" = $name
            "Projects" = @($providerObject.$name)
        }

        $hash.PSObject.TypeNames.Insert(0,'PSDrive.Provider')
        $objects += $hash
    }

    if ($By)
    {
        if ($Project)
        {
            $projects =  ($objects | Where-Object {($_.GitHubHandle -eq $By)}).Projects
            return $projects | Where-Object {($_.Name -eq $Project)}

        }
        else
        {
            return $objects | Where-Object {$_.GitHubHandle -eq $By}
        }
        
    }
    else
    {
        return $objects
    }
}
