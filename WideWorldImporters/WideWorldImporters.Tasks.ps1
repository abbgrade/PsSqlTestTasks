
[System.IO.DirectoryInfo] $SqlServerSamplesDirectory = "$PSScriptRoot\..\test\sql-server-samples"
[string] $WideWorldImportersSsdtRelativePath = 'samples/databases/wide-world-importers/wwi-ssdt/wwi-ssdt'
[System.IO.DirectoryInfo] $WideWorldImportersSsdtDirectory = Join-Path $SqlServerSamplesDirectory $WideWorldImportersSsdtRelativePath
[System.IO.FileInfo] $WideWorldImportersProject = Join-Path $SqlServerSamplesDirectory $WideWorldImportersSsdtRelativePath "WideWorldImporters.sqlproj"
[System.IO.FileInfo] $WideWorldImportersDacPac = Join-Path $SqlServerSamplesDirectory $WideWorldImportersSsdtRelativePath "bin\Debug\WideWorldImporters.dacpac"

task SqlTest.WideWorldImporters.DacPac.Clean -If { $SqlServerSamplesDirectory.Exists } -Jobs {
    Remove-Item $SqlServerSamplesDirectory -Recurse -Force
}

task SqlTest.WideWorldImporters.DacPac.AddSolution -If { -Not $SqlServerSamplesDirectory.Exists } -Jobs {
    New-Item $SqlServerSamplesDirectory -ItemType Directory -ErrorAction Continue
}

task SqlTest.WideWorldImporters.DacPac.InitSolution -If { -Not ( Test-Path "$SqlServerSamplesDirectory\.git" ) } -Jobs SqlTest.WideWorldImporters.DacPac.AddSolution, {
    Push-Location $SqlServerSamplesDirectory
    exec { git init }
    exec { git remote add origin -f https://github.com/microsoft/sql-server-samples.git }
    Pop-Location
}

task SqlTest.WideWorldImporters.DacPac.CheckoutSolution -If { -Not $WideWorldImportersSsdtDirectory.Exists } -Jobs SqlTest.WideWorldImporters.DacPac.InitSolution, {
    Push-Location $SqlServerSamplesDirectory
    exec { git config core.sparseCheckout true }
    Set-Content .git/info/sparse-checkout $WideWorldImportersSsdtRelativePath
    exec { git checkout master }
    Pop-Location
}

task SqlTest.WideWorldImporters.DacPac.Create -If { -Not $WideWorldImportersDacPac.Exists } -Jobs SqlTest.WideWorldImporters.DacPac.CheckoutSolution, {
    # # can be enabled if dotnet core build is public and working
    # exec { dotnet build "$SqlServerSamplesDirectory\samples\databases\wide-world-importers\wwi-ssdt\wwi-ssdt\WideWorldImporters.sqlproj" /p:NetCoreBuild=true }

    assert $WideWorldImportersProject
    Write-Verbose "WideWorldImportersProject: $WideWorldImportersProject"

    Invoke-MsBuild $WideWorldImportersProject

    assert ( Test-Path $WideWorldImportersDacPac )
}
