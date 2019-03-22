function new-vote
{

    <#
        .SYNOPSIS
            Create a new vote
            
        .DESCRIPTION
            Detailed Description
            
        .PARAMETER param1
            What is it, why do you want it
            
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

        $channelId = $global:PoshBotContext.OriginalMessage.channel
        if(!$channelId)
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
                $keys = $voteData."$channel".getEnumerator()
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

        $voteDetails = @{
            title = $title
            closeAfter = $closeAfter
            isActive = $true
            votes = @{}
            options = [array]$options
        }
        write-verbose 'Getting voteId'
        $voteId = $voteData."$channel".count
        write-verbose "Got Id of $voteId - Adding data"
        $voteData."$channel"."$voteId" = $voteDetails


        write-verbose 'Saving data'
        save-voteData $voteData
    }
    
}