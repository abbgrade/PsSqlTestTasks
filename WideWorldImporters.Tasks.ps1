
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
