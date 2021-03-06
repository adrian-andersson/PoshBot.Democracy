<#
Module Mixed by BarTender
	A Framework for making PowerShell Modules
	Version: 6.1.22
	Author: Adrian.Andersson
	Copyright: 2019 Domain Group

Module Details:
	Module: Poshbot.Democracy
	Description: A poshbot based slack voting system
	Revision: 1.0.21.1
	Author: Adrian.Andersson
	Company: Adrian.Andersson

Check Manifest for more details
#>

function close-vote
{
    <#
        .SYNOPSIS
            Close the active vote and get the results
            
        .DESCRIPTION
           Close the active vote and get the results
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    [PoshBot.BotCommand(
        CommandName = 'closevote'
    )]
    PARAM(
        
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        #$user = $global:PoshBotContext.CallingUserInfo.FirstName
        $voteData = get-voteData
        
    }
    
    process{
        write-verbose 'Check the channel/user and the votedata exists'
        $channel = $global:PoshBotContext.OriginalMessage.RawMessage.channel
        if(!$channel)
        {
            new-poshbotCardResponse -type Error -text 'Invalid channel response'
            return
        }
        $activeVote = get-activeVote -channel $channel
        if($activeVote)
        {
            new-poshbotTextResponse -text '_closing vote_'
            $results = get-voteresult $activeVote
            if($results)
            {
                new-poshbotCardResponse -type normal -text $results -Title "Results | $($activeVote.title)"
            }
            $activeVote.isActive = $false
            $activeVote.closedDate = get-date
            #Need to save the file again somehow
            if($(save-activeVote $activeVote) -eq $true){
                write-verbose 'succesful save'
                return
            }else{
                write-verbose 'error save'
                new-poshbotCardResponse -type Warning -text 'Error saving vote' -Title 'Error Saving Vote'
            }
        }else{
            new-poshbotCardResponse -type Warning -text 'This channel has no active votes (debug: na)' -Title 'No active votes'
            return
        }
    }
    
}

function get-activeVoteBotCommand
{
    <#
        .SYNOPSIS
            Get the currently active vote for the channel
            
        .DESCRIPTION
            Get the currently active vote for the channel
           
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    [PoshBot.BotCommand(
        CommandName = 'getVote'
    )]
    PARAM(
        
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        #$user = $global:PoshBotContext.CallingUserInfo.FirstName
        
    }
    
    process{
        write-verbose 'Check the channel/user and the votedata exists'
        $channel = $global:PoshBotContext.OriginalMessage.RawMessage.channel
        if(!$channel)
        {
            new-poshbotCardResponse -type Error -text 'Invalid channel response'
            return
        }
        $activeVote = get-activeVote -channel $channel
        if($activeVote)
        {
            $optionCount = $($activeVote.options|measure-object).count
            $i = 0
            $optionRes = while($i -lt $optionCount)
            {
                [psCustomObject] @{
                    id = $i+1
                    option = $activeVote.options[$i]
                }
                $i++
                
            }
            
            new-poshbotCardResponse -type normal -text $($optionRes|format-table|out-string) -Title "$title `nUse `!vote #id` to vote"
            return
        }else{
            new-poshbotCardResponse -type Warning -text 'This channel has no active votes (debug: na)' -Title 'No active votes'
            return
        }
    }
    
}

function get-voteResultBotCommand
{
    <#
        .SYNOPSIS
            Get the vote results without closing via a poshbot command
            
        .DESCRIPTION
           Save a users voteGet the vote results without closing via a poshbot command
           Invokes the get-voteResult function via Poshbot command
            
        .  Will get the active vote for the current channel
        -
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        
    #>
    [CmdletBinding()]
    [PoshBot.BotCommand(
        CommandName = 'voteresult'
    )]
    PARAM(
        
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        #$user = $global:PoshBotContext.CallingUserInfo.FirstName
        
    }
    
    process{
        write-verbose 'Check the channel/user and the votedata exists'
        $channel = $global:PoshBotContext.OriginalMessage.RawMessage.channel
        if(!$channel)
        {
            new-poshbotCardResponse -type Error -text 'Invalid channel response'
            return
        }
        $activeVote = get-activeVote -channel $channel
        if($activeVote)
        {
            $result = get-voteresult $($activeVote)
            if($result)
            {
                new-poshbotCardResponse -type normal -text $result -Title "Results | $($activeVote.title)"
            }else{
                new-poshbotCardResponse -type Error -text 'Unable to get active vote results' -Title "Results | $($activeVote.title)"
            }
            return
        }else{
            new-poshbotCardResponse -type Warning -text 'This channel has no active votes (debug: na)' -Title 'No active votes'
            return
        }
    }
    
}

function new-vote
{
    <#
        .SYNOPSIS
            Create a new vote
            
        .DESCRIPTION
            For the current channel, if there are no active votes then
            Create a new vote for the current channel
            Set it to active
            
        .PARAMETER title
            What are we voting on
        .PARAMETER options
            Need at least two
            What are the voting options
        
        .PARAMETER closeAfter
            After this many votes, close it automatically
            0 means manual close
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    [PoshBot.BotCommand(
        CommandName = 'newvote'
    )]
    PARAM(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$title,
        [Parameter(Mandatory=$true,Position=1)]
        [array]$options,
        [Parameter(Mandatory=$false,Position=2)]
        [int]$closeAfter = 0
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        #$user = $global:PoshBotContext.CallingUserInfo.FirstName
        $voteData = get-voteData
        
    }
    
    process{
        write-verbose 'Check the channel and the votedata exists'
        $channel = $global:PoshBotContext.OriginalMessage.RawMessage.channel
        if(!$channel)
        {
            new-poshbotCardResponse -type Error -text 'Invalid channel response'
            return
        }
        if(!$voteData)
        {
            new-poshbotCardResponse -type Error -text 'Unable to load vote data'
            return
        }
        write-verbose 'Check we dont have active data already for this channel'
        if($votedata."$channel")
        {
            write-verbose 'Channel data found, checking for validity and active vote'
            if($votedata."$channel".getType().Name -ne 'Hashtable')
            {
                write-verbose 'Channel data exists but is not a hashtable, recreating it'
                $votedata."$channel" = @{}
            }else{
                $keys = $voteData."$channel".keys
                foreach($key in $keys)
                {
                    if($votedata."$channel"."$key".isActive -eq $true)
                    {
                        new-poshbotCardResponse -type Error -text "Please close the current active vote`n*$($votedata."$channel"."$key".isActive.title)*" -Title 'Vote already open'
                        return
                    }
                }
            }
        }else{
            write-verbose 'Channel data not found, creating'
            $votedata."$channel" = @{}
        }
        $optionCount = $($options|measure-object).Count
        if($optionCount -le 1)
        {
            new-poshbotCardResponse -type Error -text "Not enough options" -Title 'Options'
            return
        }elseIf($optionCount -gt 9)
        {
            new-poshbotCardResponse -type Error -text "Too many options - currently limited to 9" -Title 'Options'
            return
        }
        $voteId = $voteData."$channel".count
        $voteDetails = @{
            id = $voteId
            channel = $channel
            title = $title
            closeAfter = $closeAfter
            isActive = $true
            votes = @{}
            options = [array]$options
            createdDate = get-date
            closedDate = $null
        }
        write-verbose 'Getting voteId'
        
        write-verbose "Got Id of $voteId - Adding data"
        $voteData."$channel"."$voteId" = $voteDetails
        write-verbose 'Saving data'
        save-voteData $voteData
        $i = 0
        $optionRes = while($i -lt $optionCount)
        {
            [psCustomObject] @{
                id = $i+1
                option = $options[$i]
            }
            $i++
            
        }
        new-poshbotCardResponse -type normal -text $($optionRes|format-table|out-string) -Title "$title `nUse `!vote #id` to vote"
        
    }
    
}

function Save-vote
{
    <#
        .SYNOPSIS
            Allow user to select a vote and save it
            
        .DESCRIPTION
            Allow user to select a vote and save it
            Will select the current active vote for the channel
            Will also get results if we go over the count
            
        .PARAMETER option
            What option they currently selected
            
        ------------
        .EXAMPLE
            verb-noun param1
            
            #### DESCRIPTION
            Line by line of what this example will do
            
            
            #### OUTPUT
            Copy of the output of this line
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    [PoshBot.BotCommand(
        CommandName = 'vote'
    )]
    PARAM(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateRange(1,9)]
        [int]$option
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        #$user = $global:PoshBotContext.CallingUserInfo.FirstName
    }
    
    process{
        write-verbose 'Check the channel/user and the votedata exists'
        $channel = $global:PoshBotContext.OriginalMessage.RawMessage.channel
        $userId = $global:PoshBotContext.FromName
        if(!$channel)
        {
            new-poshbotCardResponse -type Error -text 'Invalid channel response'
            return
        }
        if(!$userId)
        {
            new-poshbotCardResponse -type Error -text 'Invalid user'
            return
        }
        $activeVote = get-activeVote $channel
        if($activeVote)
        {
            $optionAdjust  = $option-1
            $optionSelect = $activeVote.options[$optionAdjust]
            if($optionSelect)
            {
                write-verbose 'Checking if user has already voted'
                if($activeVote.votes."$userId")
                {
                    #'1'
                    write-verbose 'Active vote for user in play'
                    
                    $response = "$($global:PoshBotContext.CallingUserInfo.FirstName) changed their vote to $optionSelect"
                    
                }else{
                    #'2'
                    write-verbose 'New vote for user'
                    $response = "$($global:PoshBotContext.CallingUserInfo.FirstName) voted for $optionSelect"
                    
                }
                $activeVote.votes."$userId" = $optionAdjust
                new-poshbotTextResponse -text $response
                #Check whether we should close voting
                $close = get-voteCloseStatus $activeVote
                #$close
                if($close -eq 'shouldClose')
                {
                    write-verbose 'We should close the vote'
                    new-poshbotTextResponse -text '_That was the last required vote, closing and getting results_'
                    $activeVote.isActive = $false
                    #get the results
                    $results = get-voteresult $activeVote
                    if($results)
                    {
                        new-poshbotCardResponse -type normal -text $results -Title "Results | $($activeVote.title)"
                    }
                }
                if($(save-activeVote $activeVote) -eq $true){
                    write-verbose 'succesful save'
                    return
                }else{
                    write-verbose 'error save'
                    new-poshbotCardResponse -type Warning -text 'Error saving vote' -Title 'Error Saving Vote'
                }
            }else{
                new-poshbotTextResponse -DM -Text "Option $option is invalid"
                return
            }
        }else{
            new-poshbotCardResponse -type Warning -text 'This channel has no active votes (debug: ac)' -Title 'No active votes'
            return
        }
    }
    
}


function get-activeVote
{
    <#
        .SYNOPSIS
            Get the vote data and return the active vote
            
        .DESCRIPTION
            Get the vote data and return the active vote for the channel id provided
        .PARAMETER channelId
            What channel
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [string]$channel
        
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $voteData = get-voteData
        write-verbose 'Channel data found, checking for validity and active vote'
        if($votedata."$channel".getType().Name -ne 'Hashtable')
        {
            write-verbose 'Channel data not a hashtable, probably corrupt, return $null'
            return
        }
        if(($voteData."$channel") -and ($votedata."$channel".getType().Name -eq 'Hashtable'))
        {
            write-verbose 'Channel available and valid'
            $keys = $voteData."$channel".keys
            $activeVotes = foreach($key in $keys)
            {
                if($votedata."$channel"."$key".isActive -eq $true)
                {
                    $votedata."$channel"."$key"
                }
            }
            $activeVotesCount = $($activeVotes|measure-object).count
            if($activeVotesCount -gt 1)
            {
                write-verbose 'We have undesired multiple votes, return the most recent'
                return $($activeVotes|sort-object -property createdDate -Descending|Select-object -First 1)
            }elseIf($activeVotesCount -eq 1)
            {
                write-verbose 'We have the desired active vote'
                return $activeVotes
            }else{
                write-verbose 'No Active votes for this channel'
                return $null
            }
        }else{
            write-verbose 'Either no channel data or data is corrupt'
            return $null
        }
        $activeVotes = if($votedata."$channel")
        {
            else{
                
            }
        }else{
            write-verbose 'No data for channel'
            return
        }
    }
}

function get-voteCloseStatus
{
    <#
        .SYNOPSIS
            Figure out what the close state should be
            I.E. if the closeAfter is set, should we close it
            
        .DESCRIPTION
            Figure out what the close state should be
            I.E. if the closeAfter is set, should we close it
        .PARAMETER ActiveVote
            An active vote hashtable
            
        
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,Position=0)]
        [hashtable]$activeVote
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        write-verbose 'Check we have valid voteData'
        
        if($activeVote)
        {
            if($activeVote.isActive -eq $true)
            {
                write-verbose 'check the number of votes'
                $count = $activeVote.votes.count
                if($count -ge $activeVote.closeAfter -and $activeVote.closeAfter -ne 0)
                {
                    #we should close
                    return 'shouldClose'
                }elseIf($activeVote.closeAfter -eq 0){
                    return 'manualClose'
                }else{
                    return 'active'
                }
            }else{
                return 'closed'
            }
        }else{
            return 'error'
        }
        
    }
}

function get-voteData
{
    <#
        .SYNOPSIS
            Get the vote data
            
        .DESCRIPTION
            Get all the vote data from the vote file
            If there is none, pass back an empty hashtable
            
        .PARAMETER path
            Path to the xml file
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter()]
        [string]$Path = 'c:\poshbot\voteData\voteData.xml'
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $folder = split-path $Path -Parent
        $file = split-path $Path -Leaf
        
        write-verbose 'Checking for directory'
        if(!$(test-path $folder))
        {
            new-item -ItemType Directory -Path $folder -Force
            write-verbose "New directory created at $folder"
        }else{
            write-verbose "Directory exists at $folder"
        }
        write-verbose 'Checking for file'
        if(!$(test-path $Path))
        {
            write-verbose 'File not found, creating hash'
            $voteHash = @{}
            
        }else{
            write-verbose 'File found, importing'
            $voteHash = import-clixml $path
        }
        return $voteHash
    }
    
}

function get-voteResult
{
    <#
        .SYNOPSIS
            Get a preformated response for the active Vote
            
        .DESCRIPTION
            Get a preformated response for the active Vote
            Return a nice vote tally
            As well as a line-by-line of who chose what
            
        .PARAMETER activeVote
            An active vote hashtable
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,Position=0)]
        [hashtable]$activeVote
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        write-verbose 'Check we have valid voteData'
        
        
        if($activeVote)
        {
            $groupedResults = $activeVote.votes.values |group-object|select-object Count,Name
            $totalVotes = $($groupedResults.count|measure-object -Sum).sum
            $i = 0
            $totalOptions = $($activeVote.options|measure-object).count
            $voteSummary = while($i -lt $totalOptions)
            {
                $option = $activeVote.options[$i]
                $votes = $($groupedResults|where-object{$_.name -eq $i}).count
                if(!$votes)
                {
                    $votes = 0
                }
                $voters = $activeVote.votes
                [psCustomObject] @{
                    Option = $option
                    Votes = $votes
                    Percent =  $([math]::round($($votes/$totalVotes)*100,0))
                    voters = $($activevote.votes.GetEnumerator()|where-object{$_.value -eq $i}).name
                }
                $i++
            }
            $top = "$($voteSummary | select-object Option,Votes,Percent|format-table|out-string)"
            $bottom = foreach($v in $voteSummary)
            {
                "*$($v.option)*`n--------------------------`n    $($v.voters -join "`n    ")`n`n`n"
            }
            $result = "$top`n$bottom"
            return $result
            
        }else{
            return $null
        }
        
    }
}

function save-activeVote
{
    <#
        .SYNOPSIS
            Take an active vote, match it to all the vote data, update it, then save it out to the file
            
        .DESCRIPTION
            Take an active vote, match it to all the vote data, update it, then save it out to the file
        .PARAMETER activeVote
            An active vote hashtable
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [hashtable]$activeVote
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $voteData = get-voteData
        $channel = $activeVote.channel
        $voteId = $activeVote.id
        if($voteData."$channel"."$voteid")
        {
            $voteData."$channel"."$voteid" = $activeVote
            save-voteData $voteData
            return $true
        }else{
            return $false
        }
    }
    
}

function save-voteData
{
    <#
        .SYNOPSIS
            Save the vote data
            
        .DESCRIPTION
            Helper function to save all the votedata to file
        .PARAMETER voteData
            Hashtable of the voteData
            
        .PARAMETER path
            Path to the xml file
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter()]
        [string]$Path = 'c:\poshbot\voteData\voteData.xml',
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [hashtable]$voteData
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $folder = split-path $Path -Parent
        
        
        write-verbose 'Checking for directory'
        if(!$(test-path $folder))
        {
            write-warning 'Folder does not exist'
            new-item -ItemType Directory -Path $folder -Force
            write-verbose "New directory created at $folder"
        }else{
            write-verbose "Directory exists at $folder"
        }
        $voteData | Export-Clixml -Path $path -Depth 6
    }
    
}

