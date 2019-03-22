function Save-vote
{

    <#
        .SYNOPSIS
            Save a users vote
            
        .DESCRIPTION
           Save a users vote
            
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
        CommandName = 'vote'
    )]

    PARAM(
        [Parameter(Mandatory=$true,Position=0)]
        [int]$option
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

        $channelId = $global:PoshBotContext.OriginalMessage.channel
        $userId = $global:PoshBotContext.FromName


        if(!$channelId)
        {
            new-poshbotCardResponse -type Error -text 'Invalid channel response'
            return
        }

        if(!$userId)
        {
            new-poshbotCardResponse -type Error -text 'Invalid user'
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
                new-poshbotCardResponse -type Warning -text 'This channel has no votes' -Title 'No votes available'
                return
            }else{
                $keys = $voteData."$channel".getEnumerator()
                foreach($key in $keys)
                {
                    if($votedata."$channel"."$key".isActive -eq $true)
                    {
                        $activeVote = $votedata."$channel"."$key"
                        $voteId = $key
                    }
                    
                }
            }

        }else{
            new-poshbotCardResponse -type Warning -text 'This channel has no votes' -Title 'No votes available'
            return
        }

        if(!$activeVote)
        {
            new-poshbotCardResponse -type Warning -text 'This channel has no active votes' -Title 'No active votes'
            return
        }
        if($activeVote.isActive -ne $true)
        {
            new-poshbotTextResponse -DM -Text 'It seems voting is already closed'
            return
        }

        write-verbose 'Check the vote was valid'
        $optionRed = $option -1
        $optionSelect = $activeVote.options[$optionRed]
        if($optionSelect)
        {
            write-verbose 'Vote looks ok'
        }else{
            new-poshbotTextResponse -DM -Text "Option $option is invalid"
            return
        }


        write-verbose 'Checking if user has already voted'
        {
            if($activeVote.votes."$userId")
            {
                write-verbose 'Active vote for user in play'
                
                $activeVote.votes."$userId" = $option
                new-poshbotTextResponse -DM -Text "Vote changed to $($option): $($activeVote.options[$optionRed])"

            }else{
                $activeVote.votes."$userId" = $option
                new-poshbotTextResponse -DM -Text "Initial vote set to $($option): $($activeVote.options[$optionRed])`n`nCast again to change"
            }
        }
        

        #Check whether we should close voting
        $close = get-voteCloseStatus $activeVote
        if($close -eq 'shouldClose')
        {
            write-verbose 'We should close the vote'
            $activeVote.isActive = $false
            #get the results
            get-voteresults $activeVote
        }



        write-verbose 'Saving data'
        save-voteData $voteData


    }
    
}