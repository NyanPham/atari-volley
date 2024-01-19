    processor 6502 
    include "vcs.h"
    include "macro.h"

    seg.u Variables     
    org $80

Plyr0YPos byte 
Plyr0XPos byte 
Plyr0Jump byte 
Plyr0JumpVel byte 

Plyr1YPos byte
Plyr1XPos byte 
Plyr1Jump byte 

PlayerHeight equ 8 
JumpHeight equ 30
GroundHeight equ 12


Counter byte 

    seg Code 
    org $f000
Start:
    CLEAN_START 

    lda #$f8 
    sta COLUBK 

    lda #GroundHeight
    sta Plyr0YPos

    lda #1
    sta Plyr0JumpVel 

    lda #0
    sta Plyr0Jump
    sta Plyr1Jump   

    lda #35
    sta Plyr0XPos 
    ldx #0
    jsr SetHorizonPos

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

    lda Plyr0XPos
    ldx #0
    jsr SetHorizonPos

    sta WSYNC
    sta HMOVE 

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
    sta WSYNC 
.AreWeInsidePlayer0:
    lda Counter 
    sec 
    sbc Plyr0YPos 
    cmp PlayerHeight
    bcc .DrawPlayer0 
    lda #0 
.DrawPlayer0:
    tay 
    lda PlayerSprite,y
    ldx ColorSprite,y 
    sta WSYNC 
    sta GRP0
    sta COLUP0 

    dec Counter 
    bne VisibleScanline 

    lda #0
    sta GRP0 

    lda #2 
    sta VBLANK 
    lda #28
    sta Counter 
Overscan:
    sta WSYNC
    dec Counter 
    bne Overscan 
    jsr JoystickMovement 
    jsr ComputeJump

    jmp NextFrame 

ComputeJump subroutine
    lda Plyr0Jump 
    beq .NotJump
    lda Plyr0JumpVel
    bpl .MovingUp
.MovingDown:
    lda Plyr0YPos
    cmp #GroundHeight
    bcs .AtGround 
    clc 
    adc Plyr0JumpVel
    sta Plyr0YPos
    jmp .NotJump
.AtGround:
    lda #0
    sta Plyr0JumpVel
    sta Plyr0Jump
    jmp .NotJump
.MovingUp: 
    lda Plyr0YPos 
    cmp #GroundHeight+JumpHeight 
    bpl .AtPeak 
    clc     
    adc Plyr0JumpVel
    sta Plyr0YPos
    jmp .NotJump
.AtPeak:
    lda #$ff 
    sta Plyr0JumpVel
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

JoystickMovement subroutine
    lda #%01000000 
    bit SWCHA   
    bne SkipMoveLeft
    lda Plyr0XPos 
    cmp #8
    bmi SkipMoveLeft
    dec Plyr0XPos   
SkipMoveLeft:
    lda #%10000000  
    bit SWCHA   
    bne SkipMoveRight
    lda Plyr0XPos 
    cmp #135
    bpl SkipMoveRight
    inc Plyr0XPos  
SkipMoveRight:
; Check if player jumps 
    lda INPT4 
    bmi .NotPressedJump
    lda Plyr0Jump 
    bne .NotPressedJump
    ldx #1  
    stx Plyr0Jump 
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
    .byte #%00000000 
    .byte #%11110111
    .byte #%11111011
    .byte #%11111111
    .byte #%10011111
    .byte #%11010111
    .byte #%11111111
    .byte #%01110111
    .byte #%10110001
    .byte #%10101011


    org $fffc 
    .word Start
    .word Start 