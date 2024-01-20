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

PlayerHeight equ 8 
JumpHeight equ 30
GroundHeight equ 15
NetHeight equ 30

Counter byte 

    MAC DRAW_BALL
    lda #%00000000
    cpx YBall 
    bne .noball 
    lda #%00000010
.noball:
    sta ENABL 

    ENDM 

    seg Code 
    org $f000
Start:
    CLEAN_START 

    lda #$f8 
    sta COLUBK 

    lda #GroundHeight
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

    lda #50
    sta YBall 
    lda #35
    sta XBall 
    ldx #4 
    jsr SetHorizonPos 

    lda #1 
    sta XBallVel
    sta YBallVel 

    sta WSYNC 
    sta HMOVE 

NextFrame:
    lda #2 
    sta VBLANK 
    sta VSYNC   

    sta WSYNC
    sta WSYNC
    sta WSYNC

    lda #0
    sta VSYNC 

    lda #0
    sta PF0
    sta PF1
    sta PF2 

    lda #$83 
    sta COLUP0

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

    lda #1  
    sta VDELP0

    lda #37 
    sta Counter  
Underscan:
    sta WSYNC 
    dec Counter
    bne Underscan 
    lda #0
    sta VBLANK 
; Done underscan
    lda #96
    sta Counter 
VisibleScanline:
    ldx Counter
    DRAW_BALL   
    sta WSYNC 
.AreWeInsidePlayer0:
    lda Counter 
    pha
    sec 
    sbc Plyr0YPos 
    cmp PlayerHeight
    bcc .DrawPlayer0 
    lda #0 
.DrawPlayer0:
    tay 
    lda PlayerSprite,y
    ldx #$a3 
    sta GRP0
    stx COLUP0
    
.AreWeInsidePlayer1:
    pla 
    sec 
    sbc Plyr1YPos 
    cmp PlayerHeight
    bcc .DrawPlayer1
    lda #0 
.DrawPlayer1:
    tay 
    lda PlayerSprite,y
    ldx #$30 
    sta GRP1
    stx COLUP1

.AreWeInNetLand:
    lda Counter 
    cmp #NetHeight
    bcs .NoLand
    cmp #GroundHeight+1
    bcc .DrawLand
    lda #$00 
    sta COLUPF 
    lda #%10000000
    sta PF2     
    jmp .DoneNetLand
    
.DrawLand
    lda #$ca 
    sta COLUPF 
    lda #%11111111 
    sta PF0
    sta PF1 
    sta PF2     
    jmp .DoneNetLand
.NoLand:    
    lda #0
    sta PF0
    sta PF1
    sta PF2 
.DoneNetLand:
    dec Counter 
    bne VisibleScanline 

    lda #0
    sta GRP0 

    lda #2 
    sta VBLANK 
    lda #26
    sta Counter 
Overscan:
    sta WSYNC
    dec Counter 
    bne Overscan 

    jsr JoystickMovement0
    jsr JoystickMovement1

    ldx #0 
    jsr ComputeJump
    ldx #1 
    jsr ComputeJump
    jsr BallMovement

    jmp NextFrame 

BallMovement subroutine
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

.DoneHorizontal:    
    lda YBallVel 
    bmi .BallMoveDown
    lda YBall 
    clc 
    adc YBallVel
    sta YBall 
    cmp #96
    bcc .DoneMovement 
    dec YBall 
    lda #$ff 
    sta YBallVel 
    jmp .DoneMovement 
.BallMoveDown:
    lda YBall    
    clc 
    adc YBallVel 
    sta YBall 
    cmp #GroundHeight 
    bpl .DoneMovement 
    inc YBall 
    lda #1 
    sta YBallVel 

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
    cmp #GroundHeight
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
    cmp #GroundHeight+JumpHeight 
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
.SkipMoveLeft:
    lda #%10000000  
    bit SWCHA   
    bne .SkipMoveRight
    lda Plyr0XPos 
    cmp #65
    bpl .SkipMoveRight
    inc Plyr0XPos  
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
.SkipMoveLeft:  
    lda #%00001000
    bit SWCHA   
    bne .SkipMoveRight
    lda Plyr1XPos 
    cmp #145
    bpl .SkipMoveRight
    inc Plyr1XPos  
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

PlayerSprite:
    .byte #%00000000 
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111
    .byte #%11111111

ColorSprite:
    .byte #$83 
    .byte #$83 
    .byte #$83 
    .byte #$83 
    .byte #$83 
    .byte #$83 
    .byte #$83 
    .byte #$83 
    .byte #$83 
    .byte #$83 

    org $fffc 
    .word Start
    .word Start 