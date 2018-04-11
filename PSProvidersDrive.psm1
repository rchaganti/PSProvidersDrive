using namespace Microsoft.PowerShell.SHiPS

[SHiPSProvider()]
class ProviderRoot : SHiPSDirectory
{    
    # Default constructor
    ProviderRoot([string]$name):base($name)
    {
    }

    [object[]] GetChildItem()
    {
        $obj = @()
        
        . "$PSScriptRoot\PSProvidersDrive.helper.ps1"
        $psProviders = Get-PSDriveProvider

        foreach ($name in $psProviders.GitHubHandle)
        {
            $obj += [GitHubHandle]::new($name, $psProviders)
        }
        return $obj
    }
}

[SHiPSProvider()]
class GitHubHandle : SHiPSDirectory
{
    [int] $ProjectCount
    hidden [Object] $projectData
    
    GitHubHandle([string]$name, [object]$projectData):base($name)
    {
        $this.ProjectData = $projectData
        $count = $ProjectData.Where({$_.GitHubHandle -eq $this.name}).Projects.Count
        if (-not $count)
        {
            $count = 1
        }
        $this.ProjectCount = $count
    }

    [object[]] GetChildItem()
    {
        $obj = @()
        $projects = $this.ProjectData.Where({$_.GitHubHandle -eq $this.name}).Projects
        foreach ($project in $projects)
        {
            $obj += [Project]::new($project.Name, $project)
        }

        return $obj
    }
}

[SHiPSProvider()]
class Project : SHiPSLeaf
{    
    hidden [Object] $projectData
    [string] $Description
    [string] $GitHubRepository
    [string] $GitHubBranch
    [Bool] $IsAvailableInGallery
    [String] $GalleryName
    
    Project([string] $name, [object] $projectData):base($name)
    {
        $this.ProjectData = $ProjectData
        $this.Description = $this.ProjectData.Description
        $this.GitHubRepository = $this.ProjectData.GitHub.Repository
        $this.GitHubBranch = $this.ProjectData.GitHub.Branch
        $this.IsAvailableInGallery = $this.ProjectData.PowerShellGallery.IsAvailableInGallery
        $this.GalleryName = $this.ProjectData.PowerShellGallery.GalleryName
    }
}
