global _start

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60
STDOUT equ 1
STDIN equ 0

SECTION .data
explanation db "Welcome to TicTacToe!"
newline db 10
explanation_len equ $-explanation
newline_len equ $-newline
move_msg db "What's your move? (1-9) "
move_msg_len equ $ -move_msg
x_won db "X won", 10
x_won_len equ $ - x_won
o_won db "O won", 10
o_won_len equ $ - o_won
draw_msg db "It's a draw", 10
draw_msg_len equ $ - draw_msg
symbol_x db "X"
symbol_x_len equ $-symbol_x
symbol_o db "O"
symbol_o_len equ $-symbol_o
symbol_sp db "-"
symbol_sp_len equ $-symbol_sp
board_x dd 0
board_o dd 0
winning_positions_start:
dw 111000000b
array_width equ $-winning_positions_start
dw 000111000b
dw 000000111b
dw 100100100b
dw 010010010b
dw 001001001b
dw 100010001b
dw 001010100b
winning_positions_end equ $
move_count dw 0
read_buffer db 0, 0



SECTION .text


print_board:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov ecx, 0

_print_board_loop:
    push rcx

    mov rsi, 1
    sal esi, cl
    and esi, [board_x]  
    jne _print_x

    mov rsi, 1
    sal esi, cl
    and rsi, [board_o]
    jne _print_o

    mov rsi, symbol_sp
    mov rdx, symbol_sp_len
    jmp _print_call
_print_o:
    mov rsi, symbol_o
    mov rdx, symbol_o_len
    jmp _print_call
_print_x:
    mov rsi, symbol_x
    mov rdx, symbol_x_len
_print_call:
    syscall
    pop rcx

    inc ecx
    cmp ecx, 3
    je _print_nl
    cmp ecx, 6
    je _print_nl
    cmp ecx, 9
    jne _print_board_loop
    mov rsi, newline
    mov rdx, newline_len
    syscall
    ret
_print_nl:
    push rcx
    mov rsi, newline
    mov rdx, newline_len
    syscall
    pop rcx
    jmp _print_board_loop

; Check if a board has won.
; Set rcx to the board bitmap.
; Sets rax to 1 if the game is won.
; Sets rax to 0 otherwise.
check_win:
    lea rax, [winning_positions_start]
_check_loop:
    mov bx, word [rax]
    and bx, cx
    cmp bx, word [rax]
    je _check_won
    
    add rax, array_width
    cmp rax, winning_positions_end
    jne _check_loop
    mov rax, 0
    ret

_check_won:
    mov rax, 1
    ret

_start:
    ; Print starting prompt
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, explanation
    mov rdx, explanation_len
    syscall


game_loop:
    call print_board
    mov cx, word [board_o]
    mov ax, word [move_count]
    and ax, 1
    cmp ax, 0
    je game_loop_1
    mov cx, word [board_x]
game_loop_1:
    call check_win
    cmp rax, 0
    jne announce_win
    cmp word [move_count], 9
    je announce_draw

    ; Play another move
    mov rsi, move_msg
    mov rdx, move_msg_len
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall

    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, read_buffer
    mov rdx, 2
    syscall
    mov cl, byte [read_buffer]
    sub cl, '1'
    mov rax, 1
    shl rax, cl
    mov bl, byte [read_buffer+1]
    cmp bl, 10
    je input_done
    mov rdi, 1
    jmp exit_with_rdi 

input_done:
    mov bx, word [board_x]
    and bx, ax
    cmp bx, 0
    jne game_loop
    mov bx, word [board_o]
    and bx, ax
    cmp bx, 0
    jne game_loop

    lea rcx, [board_x]
    mov bx, word [move_count]
    and bx, 1
    cmp bx, 0
    je set_value
    lea rcx, [board_o]
set_value:
    mov bx, word [rcx]
    or bx, ax
    mov word [rcx], bx


    inc word [move_count]
    jmp game_loop

announce_win:
    mov rsi, o_won
    mov rdx, o_won_len
    mov rax, move_count
    and rax, 1
    cmp rax, 0
    je _announce_win1
    mov rsi, x_won
    mov rdx, x_won_len
_announce_win1:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall
    jmp exit

announce_draw:
    mov rsi, draw_msg
    mov rdi, STDOUT
    mov rdx, draw_msg_len
    mov rax, SYS_WRITE
    syscall
    jmp exit
exit:
    ; Exit the game
    mov rdi, 0
exit_with_rdi:
    mov rax, SYS_EXIT
    syscall

