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