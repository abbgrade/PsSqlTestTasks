
#region SqlServerSamples

[System.IO.DirectoryInfo] $Script:RepositoryRoot = Join-Path $PSScriptRoot .. ..
[System.IO.DirectoryInfo] $Script:SqlServerSamplesDirectory = Join-Path $Script:RepositoryRoot test sql-server-samples
[string] $Script:SqlServerSamplesRepository = 'https://github.com/microsoft/sql-server-samples.git'

task PsSqlTestTasks.SqlServerSamples.Clean -If { $Script:SqlServerSamplesDirectory.Exists } -Jobs {
    Remove-Item $Script:SqlServerSamplesDirectory -Recurse -Force
}

task PsSqlTestTasks.SqlServerSamples.PrepareDirectory -If { -Not $Script:SqlServerSamplesDirectory.Exists } -Jobs {
    New-Item $Script:SqlServerSamplesDirectory -ItemType Directory -ErrorAction Continue
}

task PsSqlTestTasks.SqlServerSamples.InitRepository -If { -Not ( Test-Path "$Script:SqlServerSamplesDirectory\.git" ) } -Jobs PsSqlTestTasks.SqlServerSamples.PrepareDirectory, {
    # register remote repository
    Push-Location $Script:SqlServerSamplesDirectory
    exec { git init }
    exec { git remote add origin -f $Script:SqlServerSamplesRepository }
    Pop-Location
}

task PsSqlTestTasks.SqlServerSamples.AddSubmodule -If ( -Not ( ( Get-Content -Path ( Join-Path $Script:RepositoryRoot .gitmodules ) ) -contains '[submodule "test/sql-server-samples"]' ) ) -Jobs {
    # register submodule
    Push-Location $Script:SqlServerSamplesDirectory.Parent
    exec { git submodule add $Script:SqlServerSamplesRepository --force }
    Pop-Location
}

#endregion
#region WideWorldImporters

[string] $Script:WideWorldImportersSsdtRelativePath = 'samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt'
[System.IO.DirectoryInfo] $Script:WideWorldImportersSsdtDirectory = Join-Path $Script:SqlServerSamplesDirectory $Script:WideWorldImportersSsdtRelativePath
[System.IO.FileInfo] $Script:WideWorldImportersProject = Join-Path $Script:SqlServerSamplesDirectory $Script:WideWorldImportersSsdtRelativePath "WideWorldImporters.sqlproj"
[System.IO.FileInfo] $Script:WideWorldImportersDacPac = Join-Path $Script:SqlServerSamplesDirectory $Script:WideWorldImportersSsdtRelativePath "bin\Debug\WideWorldImporters.dacpac"

task PsSqlTestTasks.WideWorldImporters.CheckoutDirectory -If { -Not $Script:WideWorldImportersSsdtDirectory.Exists } -Jobs PsSqlTestTasks.SqlServerSamples.InitRepository, {
    Push-Location $Script:SqlServerSamplesDirectory
    # configure sparse checkout
    exec { git config core.sparseCheckout true }
    Set-Content .git/info/sparse-checkout $Script:WideWorldImportersSsdtRelativePath

    # download content
    exec { git checkout master }
    Pop-Location
}, PsSqlTestTasks.SqlServerSamples.AddSubmodule

task PsSqlTestTasks.WideWorldImporters.DacPac.Create -If { -Not $Script:WideWorldImportersDacPac.Exists } -Jobs PsSqlTestTasks.WideWorldImporters.CheckoutDirectory, {
    # # can be enabled if dotnet core build is public and working
    # exec { dotnet build $Script:WideWorldImportersProject /p:NetCoreBuild=true }

    assert $Script:WideWorldImportersProject
    Write-Verbose "WideWorldImportersProject: $Script:WideWorldImportersProject"

    Invoke-MsBuild $Script:WideWorldImportersProject

    assert ( Test-Path $Script:WideWorldImportersDacPac )
}

#endregion
