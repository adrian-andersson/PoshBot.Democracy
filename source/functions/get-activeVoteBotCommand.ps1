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