
rem ** Kick Start Artificial Intelligence Opponent Array Sample.
rem ** Creates an array of up to 8 different onscreen opponents.
rem ** Uses assembly language "RTS Trick" to simulate a case structure
rem ** that directs the program to process the type of opponent.

  set basepath gfx_mygame
  set romsize 32k
  set zoneheight 8
  set doublewide off
  set screenheight 192
  doublebuffer off      
  set pauseroutine on
  set tallsprite on
  set plotvalueonscreen on
  set trackersupport basic
           
  displaymode 160A

  dim opponent_type             =$2300 
  dim opponent_xpos             =$2308
  dim opponent_ypos             =$2310
  dim opponent_xdir             =$2318
  dim opponent_ydir             =$2320    
  dim opponent_dat1             =$2328
  dim opponent_dat2             =$2330  
  dim opponent_sprite           =$2338
  dim opponent_change           =$2340
  dim opponent_palette          =$2348
  dim opponent_index            =$2364
  dim opponent_exit             =$2365
  
  dim tempp_opponent_x          =$2366
  dim tempp_opponent_y          =$2367
  dim tempp_opponent_color      =$2368
  
  
   
Start_New_Level
    gosub Initialize_Level
Game_Loop




    asm
PROCESS_OPPONENTS
    LDX #11
    STX opponent_index
OPPONENT_ARRAY_LOOP    
    LDX opponent_index
    LDA opponent_type,X
    AND #31
    TAY
    LDA opponent_jump_lo,Y
    PHA
    LDA opponent_jump_hi,Y
    PHA    
    RTS 
    ; Push the Low and high address for the opponent type logic onto the 6502 stack
    ; It must be address minus 1 to make it similar to a JSR call.    
    
    ;This is a jump table that can be moved to the bottom of the program to avoid program clutter.
opponent_jump_lo
        .byte >(OPPONENT_TYPE_NULL-1), >(OPPONENT_TYPE_01-1),>(OPPONENT_TYPE_02-1),>(OPPONENT_TYPE_03-1),>(OPPONENT_TYPE_04-1)
        .byte >(OPPONENT_TYPE_05-1),>(OPPONENT_TYPE_06-1),>(OPPONENT_TYPE_07-1),>(OPPONENT_TYPE_08-1),>(OPPONENT_TYPE_09-1)
        .byte >(OPPONENT_TYPE_10-1),>(OPPONENT_TYPE_11-1)      
opponent_jump_hi
        .byte <(OPPONENT_TYPE_NULL-1),<(OPPONENT_TYPE_01-1),<(OPPONENT_TYPE_02-1),<(OPPONENT_TYPE_03-1),<(OPPONENT_TYPE_04-1)
        .byte <(OPPONENT_TYPE_05-1),<(OPPONENT_TYPE_06-1),<(OPPONENT_TYPE_07-1),<(OPPONENT_TYPE_08-1),<(OPPONENT_TYPE_09-1)
        .byte <(OPPONENT_TYPE_10-1),<(OPPONENT_TYPE_11-1)      

    ; You may change the labels to describe the what the opponent is, must change the label plus the labels in the jump table.
OPPONENT_TYPE_01
end
        opponent_xpos[opponent_index] = opponent_xpos[opponent_index] + opponent_xdir[opponent_index] 
        opponent_ypos[opponent_index] = opponent_ypos[opponent_index] + opponent_ydir[opponent_index]
        if opponent_xpos[opponent_index]<2 then opponent_xdir[opponent_index]=1
        if opponent_xpos[opponent_index]>145 then opponent_xdir[opponent_index]=-1
        if opponent_ypos[opponent_index]<2 then opponent_ydir[opponent_index]=1
        if opponent_ypos[opponent_index]>172 then opponent_ydir[opponent_index]=-1  
        plotsprite spritename opponent_palette[opponent_index] opponent_xpos[opponent_index] opponent_ypos[opponent_index]
    asm
    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_02
end
        opponent_xpos[opponent_index] = opponent_xpos[opponent_index] + opponent_xdir[opponent_index] 
        opponent_ypos[opponent_index] = opponent_ypos[opponent_index] + opponent_ydir[opponent_index]
        if opponent_xpos[opponent_index]<2 then opponent_xdir[opponent_index]=1
        if opponent_xpos[opponent_index]>145 then opponent_xdir[opponent_index]=-1
        if opponent_ypos[opponent_index]<2 then opponent_ydir[opponent_index]=1
        if opponent_ypos[opponent_index]>172 then opponent_ydir[opponent_index]=-1  
        plotsprite spritename opponent_palette[opponent_index] opponent_xpos[opponent_index] opponent_ypos[opponent_index]
    asm

    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_03


    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_04


    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_05


    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_06


    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_07


    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_08


    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_09


    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_10


    JMP OPPONENT_ENDPROCESS
OPPONENT_TYPE_11


    JMP OPPONENT_ENDPROCESS
    
    ; You may add additional opponent logic like OPPONENT_TYPE_12....
    ; You must also add the addresses into the jump table.
    
        
OPPONENT_ENDPROCESS
    ;If there is no opponent, set the opponent_type to 0 in the array.
    
OPPONENT_TYPE_NULL
    LDX opponent_index
    DEX
    BMI OPPONENTS_DONE
    ; We countdown from last opponent to first opponent, 
    ; when opponent_index is 255, it trips the 6502 negative flag
    ; and we use it to indicate all the opponents had been processed
    
    JMP OPPONENT_ARRAY_LOOP 

OPPONENT_DONES

end 

    goto Game_Loop
    
Initialize_Level
    
    
    return    

