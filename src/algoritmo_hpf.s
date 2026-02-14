.section .data  
    numero_righe: .int 0
    indice: .int 0
    indice_secondo_livello: .int 0

    priorita_attuale: .int 0
    priorita_prossima: .int 0

.section .text
    .global algoritmo_hpf
    .type algoritmo_hpf, @function

algoritmo_hpf:
    popl %esi

    movb $4, %dl
    divb %dl
    movb %al, numero_righe

    movl $0, priorita_attuale
    movl $16, priorita_prossima                 # 0 + 16

    movl $-1, indice                            # Settiamo l'indice


for_primo_livello:
    incl indice
    movl indice, %eax

    cmpl %eax, numero_righe
    je fine_for_primo_livello                   # Controlliamo di non essere alla fine del primo for

    movl indice, %ebx
    movl %ebx, indice_secondo_livello

for_secondo_livello:
    incl indice_secondo_livello
    movl indice_secondo_livello, %ebx

    cmpl %ebx, numero_righe
    je fine_for_secondo_livello

if_primo:                                       # Confrontiamo la scandenza attuale con quella successiva 
    movl priorita_attuale, %eax
    movl priorita_prossima, %ebx

    movl (%esp, %eax), %ecx                     # valore scadenza attuale
    movl (%esp, %ebx), %edx                     # valore scadenza prossima

    cmpl %ecx, %edx
    jg scambia_valori

    cmpl %ecx, %edx
    je check_scadenza

    jmp if_primo_fine


if_primo_fine: 
    addl $16, priorita_prossima
    jmp for_secondo_livello



check_scadenza: 
    movl priorita_attuale, %eax
    addl $4, %eax                               # Vado a prendere la scandenza 
    movl priorita_prossima, %ebx
    addl $4, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx

    cmpl %ecx, %edx
    jl scambia_valori
    
    jmp if_primo_fine


scambia_valori: 
    movl priorita_attuale, %eax
    movl priorita_prossima, %ebx

    # Scambia priorità
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    movl %edx, (%esp, %eax)
    movl %ecx, (%esp, %ebx)

    # Scambia scadenza
    addl $4, %eax
    addl $4, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    movl %edx, (%esp, %eax)
    movl %ecx, (%esp, %ebx)

    # Scambia durata
    addl $4, %eax
    addl $4, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    movl %edx, (%esp, %eax)
    movl %ecx, (%esp, %ebx)

    # Scambia ID
    addl $4, %eax
    addl $4, %ebx
    movl (%esp, %eax), %ecx
    movl (%esp, %ebx), %edx
    movl %edx, (%esp, %eax)
    movl %ecx, (%esp, %ebx)
    
    addl $16, priorita_prossima

    jmp for_secondo_livello


fine_for_secondo_livello:
    addl $16, priorita_attuale
    movl priorita_attuale, %eax
    addl $16, %eax
    movl %eax, priorita_prossima

    jmp for_primo_livello

fine_for_primo_livello:
    push %esi                                   # repusha indirizzo prox operazione nello stack
    ret
