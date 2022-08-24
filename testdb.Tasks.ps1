
#region TestDb

[string] $Script:TestDbProjectRelativePath = 'testdb'
[System.IO.DirectoryInfo] $Script:TestDbProjectDirectory = Join-Path $Script:SqlServerTestProjectDirectory $Script:TestDbProjectRelativePath
[System.IO.FileInfo] $Script:TestDbProject = Join-Path $Script:SqlServerTestProjectDirectory $Script:TestDbProjectRelativePath "testdb.sqlproj"
[System.IO.FileInfo] $Script:TestDbDacPac = Join-Path $Script:SqlServerTestProjectDirectory $Script:TestDbProjectRelativePath "bin\Debug\testdb.dacpac"

task PsSqlTestTasks.TestDb.CheckoutDirectory -If { -Not $Script:TestDbProjectDirectory.Exists } -Jobs PsSqlTestTasks.SqlServerTestProject.InitRepository, {
    Push-Location $Script:SqlServerTestProjectDirectory
    # configure sparse checkout
    exec { git config core.sparseCheckout true }
    Set-Content .git/info/sparse-checkout $Script:TestDbProjectRelativePath

    # download content
    exec { git checkout main }
    Pop-Location
}, PsSqlTestTasks.SqlServerTestProject.AddSubmodule

task PsSqlTestTasks.TestDb.DacPac.Create -If { -Not $Script:TestDbDacPac.Exists } -Jobs PsSqlTestTasks.TestDb.CheckoutDirectory, {
    assert $Script:TestDbProject
    Write-Verbose "TestDbProject: $Script:TestDbProject"

    # can be enabled if dotnet core build is public and working
    # exec { dotnet build $Script:TestDbProject /p:NetCoreBuild=true }

    Invoke-MsBuild $Script:TestDbProject

    assert ( Test-Path $Script:TestDbDacPac )
}

#endregion
