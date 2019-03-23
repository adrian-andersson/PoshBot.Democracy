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