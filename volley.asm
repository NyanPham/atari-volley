    processor 6502 
    include "vcs.h"
    include "macro.h"
    
    seg.u Variables     
    org $80 
    
Plyr0YPos byte 
Plyr1YPos byte

Plyr0XPos byte 
Plyr1XPos byte 

Plyr0Jump byte 
Plyr1Jump byte 

Plyr0JumpVel byte 
Plyr1JumpVel byte 

YBall byte 
XBall byte 
YBallVel byte 
XBallVel byte 
Score0 byte 
Score1 byte 
FontBuf ds 10 
Temp byte 
TempP0 byte
TempP1 byte
TempBall byte 
Random byte     
Colup0 byte


SoundOn byte    

PlayerHeight equ 20
JumpHeight equ 40
GroundHeight equ 15
NetHeight equ 35
ScoreboardHeight equ 10 
ScoreboardPadding equ 5
MainKernelHeight equ 162
NetStart equ 90 
BasePlayerYPos equ #0-#MainKernelHeight+#PlayerHeight

    seg Code 
    org $f000
Start:
    CLEAN_START 

    lda #0  
    sta Score0
    sta Score1  

    lda #%11010100
    sta Random              
Restart:
    lda #BasePlayerYPos
    sta Plyr0YPos
    sta Plyr1YPos 

    lda #1  
    sta Plyr0JumpVel 
    sta Plyr1JumpVel 

    lda #0
    sta Plyr0Jump
    sta Plyr1Jump   

    lda #35
    sta Plyr0XPos 
    ldx #0
    jsr SetHorizonPos

    lda #125
    sta Plyr1XPos 
    ldx #1
    jsr SetHorizonPos

    jsr GetRandom 
    adc #50
    sta YBall 

    jsr GetRandom 
    adc #50
    sta XBall 
    ldx #4 
    jsr SetHorizonPos 

    ldx #1  
    jsr GetRandom
    cmp #30
    bpl .setYBallVel
    ldx #$ff   
.setYBallVel:
    stx YBallVel 

    ldx #1 
    jsr GetRandom 
    cmp #30
    bpl .setXBallVel
    ldx #$ff
.setXBallVel:
    stx XBallVel

    sta WSYNC 
    sta HMOVE 
    sta CXCLR   
NextFrame:
    lda #2 
    sta VBLANK 
    sta VSYNC   

    REPEAT 3
        sta WSYNC 
    REPEND

    lda #0
    sta VSYNC 

    sta PF0 
    sta PF1
    sta PF2
    lda #%00010010
    sta CTRLPF 
    sta HMBL

    sta WSYNC
    sta HMCLR   

    lda Plyr0XPos
    ldx #0
    jsr SetHorizonPos

    lda Plyr1XPos
    ldx #1
    jsr SetHorizonPos

    lda XBall
    ldx #4 
    jsr SetHorizonPos 

    sta WSYNC 
    sta HMOVE 

    lda #%00010001
    sta CTRLPF   

    lda #$00 
    sta COLUPF 

    lda #0    
    sta VDELP0

    lda Score0 
    ldx #0
    jsr GetBCDBitmap
    lda Score1 
    ldx #5 
    jsr GetBCDBitmap 

    jsr ProcessSound

    lda Plyr0YPos
    sta TempP0
    lda Plyr1YPos
    sta TempP1
    lda YBall
    sta TempBall

    lda #00
    sta COLUBK 
    
    ldx #30
Underscan:
    sta WSYNC 
    dex 
    bne Underscan 
    lda #0
    sta VBLANK 

; First kernel drawing the scoreboard 
; Drawscorboard kernel
    ldy #0
    lda #%00010010
    sta CTRLPF 
    lda #$a3
    sta COLUP0 
    lda #$30
    sta COLUP1 
 
DrawScoreboard:
    lda #00
    sta COLUBK 
    sta WSYNC 
    tya 
    lsr             
    tax     
    lda FontBuf+0,x 
    sta PF1
    SLEEP 28
    lda FontBuf+5,x 
    sta PF1 
    iny
    cpy #ScoreboardHeight
    bne DrawScoreboard

    lda #0
    sta WSYNC 
    sta PF1 
    lda #%00010100
    sta CTRLPF  

    ldy #ScoreboardPadding     
WaitEndDrawBoard:
    sta WSYNC 
    dey 
    bne WaitEndDrawBoard
    lda #0
    sta WSYNC 
    sta PF1 
    lda #%00010100
    sta CTRLPF 
    lda #$f8 
    sta COLUBK
    
    lda #0
    sta PF0
    sta PF1   
    sta PF2 
    lda #%00010001
    sta CTRLPF
    lda #$00    
    sta COLUPF 

    ldx #MainKernelHeight
ActiveKernelLoop:
; Check ball Y position
    lda #%00000000
    cpx YBall 
    bne .noball 
    lda #%00000010
.noball:
    sta ENABL 

.AreWeInNet:
    cpx #NetHeight
    bcs .NoNet 
    lda #%10000000
    sta PF2     
.NoNet:

.ShouldDrawPlayer0:
    lda #PlayerHeight 
    sec
    isb TempP0 
    bcs .DrawP0
    lda #0
.DrawP0:
    tay 
    lda PlayerSprite,y 
    sta GRP0
    
.ShouldDrawPlayer1:
    lda #PlayerHeight 
    sec
    isb TempP1
    bcs .DrawP1
    lda #0
.DrawP1:
    tay     
    lda PlayerSprite,y 
    sta WSYNC 
    sta GRP1

    dex 
    bne ActiveKernelLoop 

    lda #0
    sta GRP0
    sta GRP1

    ldx #GroundHeight
DrawLand:
    sta WSYNC 
    lda #$ca 
    sta COLUPF 
    lda #%00010001
    sta CTRLPF 
    lda #%11111111 
    sta PF0
    sta PF1 
    sta PF2 
    dex 
    bne DrawLand 

    lda #2 
    sta VBLANK 
    ldx #26
Overscan:
    sta WSYNC
    dex 
    bne Overscan     

    sta WSYNC 
    jsr CheckCollisions
    sta WSYNC 
    sta CXCLR 

    sta WSYNC   
    jsr BallMovement

    jsr JoystickMovement0
    jsr JoystickMovement1

    ldx #0 
    jsr ComputeJump
    inx 
    jsr ComputeJump

    jmp NextFrame 

CheckCollisions subroutine
    ldx #0                  ; index for player collision
    lda #%01000000
    bit CXP0FB  
    bne .Player0Collision
    bit CXP1FB 
    bne .Player1Collision
    lda #%10000000
    bit CXBLPF  
    bne .PlayfieldCollision
    beq .NoCollisions
        
.Player1Collision:
    ldx #1 
.Player0Collision:  
    ldy #1 
    lda Plyr0YPos,x 
    sec  
    sbc #PlayerHeight
    clc 
    adc #MainKernelHeight 
    sta Temp 
    lda #0
    sec     
    sbc Temp 
    clc     
    adc #PlayerHeight/2 
    cmp YBall 
    bcc .SetYBallVel  
    ldy #$ff 
.SetYBallVel:
    sty YBallVel 
    
    lda Plyr0XPos,x     
    adc #5
    ldy #1 
    cmp XBall 
    bcc .SetXVel 
    ldy #$ff 
.SetXVel:   
    sty XBallVel
    bne CollisionSound

.PlayfieldCollision:
    lda YBall 
    cmp #GroundHeight
    bmi .CountScore
    beq .CountScore
; Not hit the ground, then check hit the net
    cmp #NetHeight
    bpl .BallHitNetTop
; Not hit top of the net, check hit left or right side of net 
    ldx #1
    lda XBall 
    cmp #77 
    bmi .BallHitNetLeft
; Ball hit right side
    bne .StoreXVel
.BallHitNetLeft:    
    ldx #$ff 
    bne .StoreXVel 

.BallHitNetTop:
    lda #1
    sta YBallVel 
    bne CollisionSound 

.CountScore:
    ; Check which player get the score
    ldx #0      ; x for player index
    lda XBall 
    cmp #77 
    bcs .PlayerScore   ; ball falls on the right side, so player 0 scores
    inx                 ; else, player 1 scores

.PlayerScore:
    sed 
    clc 
    lda Score0,x 
    adc #1 
    sta Score0,x 
    cld 

    ; Set random value for the next ball position and velocity
    lda Random
    eor Score0
    eor Score1 
    sta Random 

    ; Set wining sound
    lda #10
    sta AUDC0
    lda #7 
    sta AUDF0 
    sta AUDV0 
    lda #$1 
    sta SoundOn 

    jmp Restart 

.StoreXVel:
    stx XBallVel 
    jmp CollisionSound
.NoCollisions:  
    rts 

CollisionSound subroutine
    lda #$4 
    sta AUDC0 
    sta AUDF0 
    sta AUDV0 
    lda #$1 
    sta SoundOn 
    rts 

BallMovement subroutine
    sta WSYNC 
    lda XBallVel
    bmi .BallMoveLeft
    lda XBall 
    clc 
    adc XBallVel 
    sta XBall
    cmp #156
    bcc .DoneHorizontal
    lda #$ff 
    sta XBallVel 
    jsr CollisionSound
    jmp .DoneHorizontal 
.BallMoveLeft:
    lda XBall 
    clc 
    adc XBallVel
    sta XBall 
    cmp #1
    bcs .DoneHorizontal 
    inc XBall
    lda #1
    sta XBallVel 
    jsr CollisionSound

.DoneHorizontal:    
    ; Check vertical movement of ball
    lda YBall 
    clc     
    adc YBallVel
    sta YBall 
    cmp #MainKernelHeight 
    bcc .DoneMovement 
    dec YBall 
    lda #$ff 
    sta YBallVel 
    jsr CollisionSound

.DoneMovement:
    rts 

; x = # of player   
ComputeJump subroutine
    sta WSYNC
    lda Plyr0Jump,x  
    beq .NotJump
    lda Plyr0JumpVel,x
    bpl .MovingUp
.MovingDown:
    lda Plyr0YPos,x
    cmp #BasePlayerYPos
    bcc .AtGround 
    clc 
    adc Plyr0JumpVel,x 
    sta Plyr0YPos,x 
    jmp .NotJump
.AtGround:  
    lda #0  
    sta Plyr0Jump,x 
    lda #1      
    sta Plyr0JumpVel,x 
    jmp .NotJump
.MovingUp:  
    lda Plyr0YPos,x 
    cmp #BasePlayerYPos+JumpHeight 
    bpl .AtPeak 
    clc     
    adc Plyr0JumpVel,x 
    sta Plyr0YPos,x 
    jmp .NotJump
.AtPeak:
    lda #$ff 
    sta Plyr0JumpVel,x 
.NotJump:
    rts 

SetHorizonPos subroutine
    sta WSYNC 
    sec 
.Divide15Loop:
    sbc #15
    bcs .Divide15Loop 
    eor #7 
    asl 
    asl 
    asl 
    asl 
    sta HMP0,x 
    sta RESP0,x 
    rts

JoystickMovement0 subroutine
    sta WSYNC 
    lda #%01000000 
    bit SWCHA   
    bne .SkipMoveLeft
    lda Plyr0XPos 
    cmp #3
    bmi .SkipMoveLeft
    dec Plyr0XPos   
    lda #0
    sta REFP0
.SkipMoveLeft:
    lda #%10000000  
    bit SWCHA   
    bne .SkipMoveRight
    lda Plyr0XPos 
    cmp #65
    bpl .SkipMoveRight
    inc Plyr0XPos  
    lda #%1000
    sta REFP0
.SkipMoveRight:
; Check if player jumps 
    lda INPT4 
    bmi .NotPressedJump
    lda Plyr0Jump 
    bne .NotPressedJump
    lda #1
    sta Plyr0Jump 
.NotPressedJump:
    rts 

JoystickMovement1 subroutine
    sta WSYNC 
    lda #%00000100
    bit SWCHA   
    bne .SkipMoveLeft
    lda Plyr1XPos 
    cmp #82
    bmi .SkipMoveLeft
    dec Plyr1XPos   
    lda #0
    sta REFP1
.SkipMoveLeft:       
    lda #%00001000
    bit SWCHA   
    bne .SkipMoveRight
    lda Plyr1XPos 
    cmp #145
    bpl .SkipMoveRight
    inc Plyr1XPos  
    lda #%1000
    sta REFP1
.SkipMoveRight:
; Check if player jumps 
    lda INPT5
    bmi .NotPressedJump
    lda Plyr1Jump 
    bne .NotPressedJump
    lda #1
    sta Plyr1Jump 
.NotPressedJump:
    rts 

; Fetches bitmap data for two digits of a 
; BCD-encoded number, storing it in addresses 
; FontBuf+x to FontBuf+4+x 
GetBCDBitmap subroutine
; Fetch first bytes for 1st digit
    sta WSYNC 
    pha 
    and #$0f 
    sta Temp 
    asl 
    asl 
    adc Temp 
    tay 
    lda #5 
    sta Temp 
.Loop1:
    lda DigitsBitmap,y 
    and #$0f 
    sta FontBuf,x 
    iny 
    inx 
    dec Temp 
    bne .Loop1 
; Now do the 2nd digit
    pla 
    lsr 
    lsr 
    lsr 
    lsr 
    sta Temp 
    asl
    asl 
    adc Temp 
    tay 
    txa 
    sec 
    sbc #5 
    tax 
    lda #5 
    sta Temp 
.Loop2:
    lda DigitsBitmap,y 
    and #$f0 
    ora FontBuf,x 
    sta FontBuf,x 
    iny 
    inx 
    dec Temp 
    bne .Loop2 
    rts     
    
GetRandom subroutine
    lda Random
    asl
    eor Random
    asl
    eor Random
    asl
    asl
    eor Random
    asl
    rol Random               ; performs a series of shifts and bit operations
    lsr
    lsr                      ; divide the value by 4 with 2 right shifts
    rts 

ProcessSound subroutine
    lda SoundOn
    beq .sound
    dec SoundOn 
    bne .sound
    lda #0
    sta AUDV0 

.sound:
    rts 

    org $FF00

PlayerSprite:
    .byte #0 
    .byte %00010010
    .byte %00010010
    .byte %00010010
    .byte %00010010
    .byte %00011110
    .byte %00011110
    .byte %01111110
    .byte %01111110
    .byte %11111110
    .byte %11111110
    .byte %11111110
    .byte %11111110
    .byte %10100010
    .byte %10100010
    .byte %11100010
    .byte %11100010
    .byte %00100000
    .byte %00100000
    .byte %00100000
    .byte %00100000

ColorSprite:
    .byte #0                    ; 11 bytes
    .byte #$0E 
    .byte #$0E 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$2A 
    .byte #$0E 
    .byte #$0E 

; Bitmap pattern for digits
DigitsBitmap ;;{w:8,h:5,count:10,brev:1};;
    .byte $EE,$AA,$AA,$AA,$EE
    .byte $22,$22,$22,$22,$22
    .byte $EE,$22,$EE,$88,$EE
    .byte $EE,$22,$66,$22,$EE
    .byte $AA,$AA,$EE,$22,$22
    .byte $EE,$88,$EE,$22,$EE
    .byte $EE,$88,$EE,$AA,$EE
    .byte $EE,$22,$22,$22,$22
    .byte $EE,$AA,$EE,$AA,$EE
    .byte $EE,$AA,$EE,$22,$EE
;;end
    
    org $fffc 
    .word Start
    .word Start 