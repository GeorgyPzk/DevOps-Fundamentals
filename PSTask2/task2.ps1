param(
    [Parameter(Mandatory)]
    $csv_file_path = "./accounts.csv"
)
begin {
    # Turn all non-terminating errors into terminating ones
    $ErrorActionPreference = "Stop"

    # Suppress breaking changes warnings (https://aka.ms/azps-changewarnings)
    #Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
    #$WarningPreference = 'SilentlyContinue'

    # Init flags for error handling
    $isErrorState = $false

}

process {
    try {
        Write-Host "Processing..." -ForegroundColor DarkGray

        $accounts = Import-Csv $csv_file_path
        
        foreach ($item in $accounts) {
            # Name format all letters to lower, title latters to upper
            $item.name = ( Get-Culture ).TextInfo.ToTitleCase( $item.name.ToLower() )
            # email update
            $nameArr = $item.name.Split(" ") 
            $item.email = "$($namearr[0][0])$($namearr[1])$($item.location_id)@abc.com".ToLower() -replace '\W', ''
        }

        # Generate new file path and export csv object
        $newPath = $csv_file_path.Insert($csv_file_path.Length-4,"_new")
        $accounts | Export-Csv -Path $newPath -NoTypeInformation
        Write-Host "Path of new file: $newPath" -ForegroundColor Green

    } catch {
        $isErrorState = $true
        $catchedError = $_
    }
}
end {
    if ($isErrorState) {
        Write-Host "An error occurred in the script `nDetailed information is provided in the error below:" -ForegroundColor Red
        $catchedError
    }
}