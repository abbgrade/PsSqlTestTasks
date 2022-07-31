
[System.IO.DirectoryInfo] $Script:SqlServerSamplesDirectory = "$PSScriptRoot\..\..\test\sql-server-samples"
[string] $Script:WideWorldImportersSsdtRelativePath = 'samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt'
[System.IO.DirectoryInfo] $Script:WideWorldImportersSsdtDirectory = Join-Path $Script:SqlServerSamplesDirectory $Script:WideWorldImportersSsdtRelativePath
[System.IO.FileInfo] $Script:WideWorldImportersProject = Join-Path $Script:SqlServerSamplesDirectory $Script:WideWorldImportersSsdtRelativePath "WideWorldImporters.sqlproj"
[System.IO.FileInfo] $Script:WideWorldImportersDacPac = Join-Path $Script:SqlServerSamplesDirectory $Script:WideWorldImportersSsdtRelativePath "bin\Debug\WideWorldImporters.dacpac"
[string] $Script:RepoUrl = 'https://github.com/microsoft/sql-server-samples.git'

task PsSqlTestTasks.WideWorldImporters.DacPac.Clean -If { $Script:SqlServerSamplesDirectory.Exists } -Jobs {
    Remove-Item $Script:SqlServerSamplesDirectory -Recurse -Force
}

task PsSqlTestTasks.WideWorldImporters.DacPac.AddSolution -If { -Not $Script:SqlServerSamplesDirectory.Exists } -Jobs {
    New-Item $Script:SqlServerSamplesDirectory -ItemType Directory -ErrorAction Continue
}

task PsSqlTestTasks.WideWorldImporters.DacPac.InitSolution -If { -Not ( Test-Path "$Script:SqlServerSamplesDirectory\.git" ) } -Jobs PsSqlTestTasks.WideWorldImporters.DacPac.AddSolution, {
    # register remote repository
    Push-Location $Script:SqlServerSamplesDirectory
    exec { git init }
    exec { git remote add origin -f $Script:RepoUrl }
    Pop-Location
}

task PsSqlTestTasks.WideWorldImporters.DacPac.CheckoutSolution -If { -Not $Script:WideWorldImportersSsdtDirectory.Exists } -Jobs PsSqlTestTasks.WideWorldImporters.DacPac.InitSolution, {
    Push-Location $Script:SqlServerSamplesDirectory
    # configure sparse checkout
    exec { git config core.sparseCheckout true }
    Set-Content .git/info/sparse-checkout $Script:WideWorldImportersSsdtRelativePath

    # download content
    exec { git checkout master }
    Pop-Location

    # register submodule
    Push-Location $Script:SqlServerSamplesDirectory.Parent
    exec { git submodule add $Script:RepoUrl }
    Pop-Location
}

task PsSqlTestTasks.WideWorldImporters.DacPac.Create -If { -Not $Script:WideWorldImportersDacPac.Exists } -Jobs PsSqlTestTasks.WideWorldImporters.DacPac.CheckoutSolution, {
    # # can be enabled if dotnet core build is public and working
    # exec { dotnet build $Script:WideWorldImportersProject /p:NetCoreBuild=true }

    assert $Script:WideWorldImportersProject
    Write-Verbose "WideWorldImportersProject: $Script:WideWorldImportersProject"

    Invoke-MsBuild $Script:WideWorldImportersProject

    assert ( Test-Path $Script:WideWorldImportersDacPac )
}
