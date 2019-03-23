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