.section .data

    fd: .int 0                              # File descriptor
    argc: .int 0                            # per salvare il numero di argomenti
    numero_elementi: .int 0
    
    testo_errore: .ascii "Ops! Qualcosa non ha funzionato\n\n"
    testo_errore_lunghezza: .long .- testo_errore
    
    testo_menu: .ascii "\nSeleziona l'algoritmo da utilizzare (EDF: 1, HPF: 2, esci: q): "
    testo_menu_lunghezza: .long .- testo_menu

    testo_selezione_non_valida: .ascii "Selezione non valida\n"
    testo_selezione_non_valida_lunghezza: .long .- testo_selezione_non_valida

    testo_algo_EDF: .ascii "Pianificazione EDF:\n"
    testo_algo_EDF_lunghezza: .long .- testo_algo_EDF

    testo_algo_HPF: .ascii "Pianificazione HPF:\n"
    testo_algo_HPF_lunghezza: .long .- testo_algo_HPF

    testo_terminazione_programma: .ascii "Terminazione programma\n"
    testo_terminazione_programma_lunghezza: .long .- testo_terminazione_programma

    carattere_nuova_linea: .ascii "\n"

    carattere_selettore_algoritmo_EDF: .ascii "1"
    carattere_selettore_algoritmo_HPF: .ascii "2"
    carattere_selettore_esci: .ascii "q"

    input_utente: .ascii "0"

.section .text
    .global _start

.macro PRINT_NEW_LINE
    movl $4, %eax
    movl $1, %ebx
    leal carattere_nuova_linea, %ecx
    movl $1, %edx
    int $0x80
.endm

_start:
    popl %esi

    movl %esi, argc

    cmpb $2, argc                           # Controllo se ci sono due argomenti nel argv ([nome programma], "[nome file]")
    jne errore

    popl %esi                               # Togliamo il primo elemento, cioè il nome del programma ([nome programma])

    popl %esi
    testl %esi, %esi	                    # controlla se ESI e' 0 (NULL)
    jz errore

    # Apriamo il file
    movl $5, %eax
    movl %esi, %ebx
    movl $0, %ecx
    int $0x80   

    # Verifichiamo se il file è stato aperto o no
    cmp $0, %eax
    jl errore

    movl %eax, fd
    call read_file

    cmpl $500, %eax
    je errore

    movb %al, numero_elementi

    # CLose the file
    movl $6, %eax
    movl fd, %ebx
    int $0x80

    jmp menu


errore:
    movl $4, %eax
    movl $2, %ebx # stderr
    leal testo_errore, %ecx
    movl testo_errore_lunghezza, %edx
    int $0x80
    movl numero_elementi, %eax
    jmp scarica_pila

scarica_pila:
    cmpl $0, %eax
    je esci
    popl %ebx
    decl %eax
    jmp scarica_pila 


menu:
    # Stampo il testo del menu
    movl $4, %eax 
    movl $1, %ebx
    leal testo_menu, %ecx
    movl testo_menu_lunghezza, %edx
    int $0x80

    # Scanf dell'input
    xorl %ecx, %ecx
    movl $3, %eax
    movl $0, %ebx
    leal input_utente, %ecx
    movl $2, %edx
    int $0x80

    movb carattere_selettore_algoritmo_EDF, %al
    movb carattere_selettore_algoritmo_HPF, %bl
    movb carattere_selettore_esci, %cl
    movb input_utente, %dl
    
    cmpb %al, %dl
    je algoritmo_EDF

    cmpb %bl, %dl
    je algoritmo_HPF

    cmpb %cl, %dl
    je termina_programma

    # Stampo il testo di errore
    movl $4, %eax
    movl $1, %ebx
    leal testo_selezione_non_valida, %ecx
    movl testo_selezione_non_valida_lunghezza, %edx
    int $0x80

    jmp menu
     
algoritmo_EDF:
    # Stampo il testo dell'algoritmo
    movl $4, %eax
    movl $1, %ebx
    leal testo_algo_EDF, %ecx
    movl testo_algo_EDF_lunghezza, %edx
    int $0x80

    # Passo il numero delgi elementi
    movb numero_elementi, %al
    # Chiamo la funzione di ordinamento EDF
    call algoritmo_edf

    # Passo il numero delgi elementi
    movb numero_elementi, %al
    call programmazione

    # Stampo una nuova linea
    PRINT_NEW_LINE

    jmp menu

algoritmo_HPF:
    # Stampo il testo dell'algoritmo
    movl $4, %eax
    movl $1, %ebx
    leal testo_algo_HPF, %ecx
    movl testo_algo_HPF_lunghezza, %edx
    int $0x80

    # Passo il numero delgi elementi
    movb numero_elementi, %al
    call algoritmo_hpf

    # Passo il numero delgi elementi
    movb numero_elementi, %al
    call programmazione
    
    # Stampo una nuova linea
    PRINT_NEW_LINE

    jmp menu


termina_programma:
    movl $4, %eax
    movl $1, %ebx
    leal testo_terminazione_programma, %ecx
    movl testo_terminazione_programma_lunghezza, %edx
    int $0x80

    # jmp esci

esci:
    # Esci dal programma con successo
    movl $1, %eax
    movl $0, %ebx
    int $0x80
