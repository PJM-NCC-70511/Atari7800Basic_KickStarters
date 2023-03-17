
rem ** Kick Start Procedural Screen Drawin Sample.
rem ** Uses a series of Code Instructions to set up screens for multi-screen games.

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

    const CHR = 1
    const BLK = 2
    const HLN = 3
    const VLN = 4
    const LDL = 5
    const RDL = 6
    const EOS = 255 ;End of screen
    const BytesPerRow         =40
      
  dim game_screendata 		= $2400
  dim DATA_INDEX 			= $2381
  dim DRAW_SCREEN_INDEX     = $2382
  dim VERTICAL_ADD_AMOUNT   = $2383
  dim DRAW_CHARACTER        = $2384
  dim HORIZONTAL_SIZE       = $2385
  dim VERTICAL_SIZE         = $2386
  dim SCREEN_NUMBER 	    = $2387
  
   
Draw_New_Screen
    gosub Draw_Screen
Game_Loop


    goto Game_Loop



    
Draw_Screen
    
    asm
    
	LDY Screen_Number
		
    LDA :Screen_Data_Address_LO_0,Y	
    STA DATA_INDEX + 0
    LDA :Screen_Data_Address_HI_0,Y	
    STA DATA_INDEX + 1
Draw_Screen_Loop
    LDY #0
    LDA (DATA_INDEX),Y            	                   
    INY
    CMP #:EOS
    BNE No_End_Of_Screen
    JMP Screen_Draw_Done
No_End_Of_Screen    

CT_CHR ; ;Put Tile Char [X,Y,DRAW CHARACTER]
      CMP #:CHR ;Put Tile Char
      bne CT_BLK 
      LDA #2
      STA DRAW_SIZE_COUNT
      JSR Get_Screen_Address
      lda (DATA_INDEX),Y	
      LDY #$00
      STA (NDX0),Y
      LDA #4  
      JMP AddRoomInstrNDX
CT_BLK	;BLK ;Draw_Block	
      cmp #:BLK ;Draw_Block [X,Y, DRAW CHARACTER,SIZE CODE]
      bne CT_HLN
      JSR Get_Screen_Positions 
      LDA (DATA_INDEX),Y	
      STA DRAW_CHARACTER
      INY
      LDA (DATA_INDEX),Y	
      JSR Get_Rectangle_Dimensions	
      JSR DRAWBLOCK		    
      LDA #5  
      JMP AddRoomInstrNDX
CT_HLN
      cmp #:HLN ;Draw Horizontal Line [X,Y, DRAW CHARACTER,SIZE CODE]
      bne CT_05
      JSR Get_Screen_Positions 
      LDA (DATA_INDEX),Y	
      STA STA DRAW_CHARACTER
      INY
      LDA (DATA_INDEX),Y
      STA HORIZONTAL_SIZE
      JSR DRAWHOZWALL
      LDA #5  
      JMP AddRoomInstrNDX
CT_VLN
      cmp #:VLN ;Draw Vertical Line [X,Y, DRAW CHARACTER,SIZE CODE]
      bne CT_LDL
      JSR Get_Screen_Positions
      LDA (DATA_INDEX),Y
      STA DRAW_CHARACTER
      INY
      LDA (DATA_INDEX),Y
      STA VERTICAL_SIZE					
      LDA #40
      STA VERTICAL_ADD_AMOUNT
      JSR DRAWVRTWALL
      LDA #5  
      JMP AddRoomInstrNDX
CT_LDL 
      cmp #:CT_LDL ;Draw Left Diagonal Line [X,Y, DRAW CHARACTER,SIZE CODE]
      bne CT_RDL
      JSR Get_Screen_Positions
      LDA (DATA_INDEX),Y     
      STA DRAW_CHARACTER		
      INY
      LDA (DATA_INDEX),Y
      STA VERTICAL_SIZE
      LDA #39
      STA VERTICAL_ADD_AMOUNT
      JSR DRAWVRTWALL
      LDA #5  
      JMP AddRoomInstrNDX
CT_RDL ;Draw Right Diagonal Line [X,Y, DRAW CHARACTER,SIZE CODE]
      cmp #:CT_RDL
      bne No_Incr_Room_Hi
      JSR Get_Screen_Positions
      LDA (DATA_INDEX),Y     
      STA DRAW_CHARACTER
      INY
      LDA (DATA_INDEX),Y
      STA VERTICAL_SIZE
      LDA #41
      STA VERTICAL_ADD_AMOUNT
      JSR DRAWVRTWALL
      LDA #5  
      JMP AddRoomInstrNDX
    
AddRoomInstrNDX
    CLC		
    ADC DATA_INDEX  
    STA DATA_INDEX
    BCC No_Incr_Room_Hi
    INC DATA_INDEX + 1
No_Incr_Room_Hi
    JMP Draw_Screen_Loop	 


Screen_Draw_Done

   
end 
    return    
asm
Get_Screen_Positions
		LDA (DATA_INDEX),Y	
		STA temp9
		INY
		LDA (DATA_INDEX),Y
		TAX		
		INY
		RTS

Get_Rectangle_Dimensions	
        CLC
        PHA			
        AND #$0F
        ADC #$02
        STA HORIZONTAL_SIZE 	
        PLA 		
        LSR  		
        LSR  		
        LSR  			
        LSR   		
        CLC				
        ADC #$02	
        STA VERTICAL_SIZE 		
        RTS				




DRAWHOZWALL  
      JSR GET_SCREEN_ADDRESS
      LDY HORIZONTAL_SIZE
      LDA DRAW_CHARACTER
HOZWALLLOOP
      DEY
      STA (DRAW_SCREEN_INDEX),Y
      BNE HOZWALLLOOP
      RTS
    
DRAWVRTWALL
      JSR GET_SCREEN_ADDRESS
VRTWALLLOOP    
      LDA DRAW_CHARACTER
      STA (DRAW_SCREEN_INDEX),Y
      LDA DRAW_SCREEN_INDEX 
      CLC
      ADC VERTICAL_ADD_AMOUNT
      STA DRAW_SCREEN_INDEX
      BCC NO_VERTICAL_INCREASE_HI_BYTE  	
      INC DRAW_SCREEN_INDEX + 1
NO_VERTICAL_INCREASE_HI_BYTE      
      DEC DRAWVRTWALL
      BPL VRTWALLLOOP
NOVERTHI      
      RTS


DRAWBLOCK
	JSR GET_SCREEN_ADDRESS
NEWBLOCKROW
    LDY HORIZONTAL_SIZE
BLOCKLOOP
    LDA DRAW_CHARACTER
    STA (DRAW_SCREEN_INDEX),Y
    DEY 
    BPL HORIZONTAL_SIZE
    
    LDA DRAW_SCREEN_INDEX
    CLC
    ADC VERTICAL_ADD_AMOUNT
    STA DRAW_SCREEN_INDEX
    BCC NO_BLOCK_INCREASE_HI_BYTE
    INC DRAW_SCREEN_INDEX+1
NO_BLOCK_INCREASE_HI_BYTE
    DEC VERTICAL_SIZE
    BPL NEWBLOCKROW    
    RTS

GET_SCREEN_ADDRESS
    LDA temp9
    CLC 
    ADC :SCREEN_LINE_ADDR_LOW,X
    STA DRAW_SCREEN_INDEX + 0  
    LDA :SCREEN_LINE_ADDR_HIGH,X
    ADC #$00
    STA DRAW_SCREEN_INDEX + 1
    RTS         


R000
		.byte BLK,5,5,$22,68
		.byte HLN,0,10,72,40
		.byte VLN,0,0,70,22
		.byte VLN,39,0,70,22
		.byte EOS
R001
        .byte HLN,0,5,72,40
        .byte HLN,0,10,72,40
        .byte HLN,0,15,72,40		
        .byte VLN,0,0,70,22
        .byte VLN,39,0,70,22
        .byte EOS
R002
		.byte BLK,15,5,$22,68
		.byte BLK,25,5,$22,68
		.byte VLN,19,0,70,22
		.byte VLN,20,0,70,22
		.byte EOS

;;;;
;;;;
;;;;

Screen_Data_Address_LO
    	.byte <R000,<R001,<R002
Screen_Data_Address_HI
    	.byte >R000,>R001,>R002

SCREEN_LINE_ADDR_LOW
    .byte <game_screendata,<(game_screendata+BytesPerRow)
    .byte <(game_screendata+BytesPerRow*2),<(game_screendata+BytesPerRow*3),<(game_screendata+BytesPerRow*4)
    .byte <(game_screendata+BytesPerRow*5),<(game_screendata+BytesPerRow*6),<(game_screendata+BytesPerRow*7)
    .byte <(game_screendata+BytesPerRow*8),<(game_screendata+BytesPerRow*9),<(game_screendata+BytesPerRow*10)
    .byte <(game_screendata+BytesPerRow*11),<(game_screendata+BytesPerRow*12),<(game_screendata+BytesPerRow*13)
    .byte <(game_screendata+BytesPerRow*14),<(game_screendata+BytesPerRow*15),<(game_screendata+BytesPerRow*16)
    .byte <(game_screendata+BytesPerRow*17),<(game_screendata+BytesPerRow*18),<(game_screendata+BytesPerRow*19)
    .byte <(game_screendata+BytesPerRow*20),<(game_screendata+BytesPerRow*21),<(game_screendata+BytesPerRow*22)
    .byte <(game_screendata+BytesPerRow*23)
SCREEN_LINE_ADDR_HIGH
    .byte >game_screendata,>(game_screendata+BytesPerRow)
    .byte >(game_screendata+BytesPerRow*2),>(game_screendata+BytesPerRow*3),>(game_screendata+BytesPerRow*4)
    .byte >(game_screendata+BytesPerRow*5),>(game_screendata+BytesPerRow*6),>(game_screendata+BytesPerRow*7)
    .byte >(game_screendata+BytesPerRow*8),>(game_screendata+BytesPerRow*9),>(game_screendata+BytesPerRow*10)
    .byte >(game_screendata+BytesPerRow*11),>(game_screendata+BytesPerRow*12),>(game_screendata+BytesPerRow*13)
    .byte >(game_screendata+BytesPerRow*14),>(game_screendata+BytesPerRow*15),>(game_screendata+BytesPerRow*16)
    .byte >(game_screendata+BytesPerRow*17),>(game_screendata+BytesPerRow*18),>(game_screendata+BytesPerRow*19)
    .byte >(game_screendata+BytesPerRow*20),>(game_screendata+BytesPerRow*21),>(game_screendata+BytesPerRow*22)
    .byte >(game_screendata+BytesPerRow*23)
    end
