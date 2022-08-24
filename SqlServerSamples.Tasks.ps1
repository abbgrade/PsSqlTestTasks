
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