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