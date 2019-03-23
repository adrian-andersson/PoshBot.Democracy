@{
  ModuleVersion = '1.1.0'
  RootModule = 'Poshbot.Democracy.psm1'
  AliasesToExport = @()
  FunctionsToExport = @('close-vote','get-activeVoteBotCommand','get-voteResultBotCommand','new-vote','Save-vote')
  CmdletsToExport = @()
  PowerShellVersion = '5.0.0.0'
  PrivateData = @{
    moduleRevision = '1.0.21.1'
    builtBy = 'Adrian.Andersson'
    builtOn = '2019-03-23T22:19:06'
    PSData = @{
      LicenseUri = 'https://github.com/adrian-andersson/PoshBot.Democracy/blob/master/LICENSE'
      ProjectUri = 'https://github.com/adrian-andersson/PoshBot.Democracy'
      ReleaseNotes = 'Tested and functional release'
    }
    bartenderCopyright = '2019 Domain Group'
    permissions = @()
    pester = @{
      time = '00:00:01.0856614'
      codecoverage = 0
      passed = '100 %'
    }
    bartenderVersion = '6.1.22'
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
  }
  GUID = '1dac1e0c-0abe-481b-adc9-ece99c109cb1'
  Description = 'A poshbot based slack voting system'
  Copyright = '2019 Adrian.Andersson'
  CompanyName = 'Adrian.Andersson'
  Author = 'Adrian.Andersson'
  ScriptsToProcess = @()
}
