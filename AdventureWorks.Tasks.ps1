
#region AdventureWorks

[string] $Script:AdventureWorksOltpRelativePath = 'samples/databases/adventure-works/oltp-install-script'
[System.IO.DirectoryInfo] $Script:AdventureWorksOltpDirectory = Join-Path $Script:SqlServerSamplesDirectory $Script:AdventureWorksOltpRelativePath

task PsSqlTestTasks.AdventureWorks.CheckoutDirectory -If { -Not $Script:AdventureWorksOltpDirectory.Exists } -Jobs PsSqlTestTasks.SqlServerSamples.InitRepository, {
    Push-Location $Script:SqlServerSamplesDirectory
    # configure sparse checkout
    exec { git config core.sparseCheckout true }
    Set-Content .git/info/sparse-checkout $Script:AdventureWorksOltpRelativePath

    # download content
    exec { git checkout master }
    Pop-Location
}, PsSqlTestTasks.SqlServerSamples.AddSubmodule

#endregion
