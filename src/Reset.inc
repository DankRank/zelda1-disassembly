.GLOBAL RunGame
IsrReset:
    SEI                         ; Disable interrupts.
    CLD                         ; Clear decimal mode.
    LDA #$00
    STA PpuControl_2000         ; Set the PPU to a base state with no NMI.
    LDX #$FF
    TXS                         ; Set the stack to $01FF.
:
    LDA PpuStatus_2002          ; Wait for one VBLANK.
    AND #$80
    BEQ :-
:
    LDA PpuStatus_2002          ; Wait for another VBLANK.
    AND #$80                    ;   in case the first was left over from a previous run.
    BEQ :-
    ORA #$FF
    STA $8000                   ; Reset all MMC1 shift registers.
    STA $A000
    STA $C000
    STA $E000
    LDA #$0F                    ; Set our normal mirroring and PRG ROM bank mode.
    JSR SetMMC1Control
    LDA #$00                    ; Use CHR RAM bank 0 for PPU address $00000.
    STA $A000
    LSR
    STA $A000
    LSR
    STA $A000
    LSR
    STA $A000
    LSR
    STA $A000
    LDA #$07
    JSR SwitchBank
    JMP RunGame

SetMMC1Control:
    STA $8000
    LSR
    STA $8000
    LSR
    STA $8000
    LSR
    STA $8000
    LSR
    STA $8000
    RTS

SwitchBank:
    STA $E000
    LSR
    STA $E000
    LSR
    STA $E000
    LSR
    STA $E000
    LSR
    STA $E000
    RTS
