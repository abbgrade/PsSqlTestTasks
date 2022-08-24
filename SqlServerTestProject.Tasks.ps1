
#region SqlServerTestProject

[System.IO.DirectoryInfo] $Script:RepositoryRoot = Join-Path $PSScriptRoot .. ..
[System.IO.DirectoryInfo] $Script:SqlServerTestProjectDirectory = Join-Path $Script:RepositoryRoot test sql-server-test-project
[string] $Script:SqlServerTestProjectRepository = 'https://github.com/abbgrade/sql-server-test-project.git'

task PsSqlTestTasks.SqlServerTestProject.Clean -If { $Script:SqlServerTestProjectDirectory.Exists } -Jobs {
    Remove-Item $Script:SqlServerTestProjectDirectory -Recurse -Force
}

task PsSqlTestTasks.SqlServerTestProject.PrepareDirectory -If { -Not $Script:SqlServerTestProjectDirectory.Exists } -Jobs {
    New-Item $Script:SqlServerTestProjectDirectory -ItemType Directory -ErrorAction Continue
}

task PsSqlTestTasks.SqlServerTestProject.InitRepository -If { -Not ( Test-Path "$Script:SqlServerTestProjectDirectory\.git" ) } -Jobs PsSqlTestTasks.SqlServerTestProject.PrepareDirectory, {
    # register remote repository
    Push-Location $Script:SqlServerTestProjectDirectory
    exec { git init }
    exec { git remote add origin -f $Script:SqlServerTestProjectRepository }
    Pop-Location
}

task PsSqlTestTasks.SqlServerTestProject.AddSubmodule -If ( -Not ( ( Get-Content -Path ( Join-Path $Script:RepositoryRoot .gitmodules ) ) -contains '[submodule "test/sql-server-test-project"]' ) ) -Jobs {
    # register submodule
    Push-Location $Script:SqlServerTestProjectDirectory.Parent
    exec { git submodule add $Script:SqlServerTestProjectRepository --force }
    Pop-Location
}

#endregion
