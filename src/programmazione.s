.section .data
    numero_righe: .int 0
    indice_massimo: .int 0
    indice: .int 0
    durata_totale: .int 0
    penalita_totale: .int 0

    ID_attuale: .int 0

    carattere_nuova_linea: .ascii "\n"
    carattere_due_punti: .ascii ":"

    testo_conclusione: .ascii "Conclusione: "
    testo_conclusione_len: .long .-testo_conclusione
    testo_penalita: .ascii "Penalty: "
    testo_penalita_len: .long .-testo_penalita
    

.section .text
    .global programmazione
    .type programmazione, @function

programmazione:
    popl %esi

    movb $4, %dl
    divb %dl
    movb %al, numero_righe

    # Inizializziamo gli indici
    subb $1, %al                                # Indice massimo e non la lunghezza massima
    movb %al, indice_massimo

    xorl %ecx, %ecx
    movl %ecx, durata_totale                    # Azzeriamo la durata totale
    movl %ecx, penalita_totale                  # Azzeriamo la penalità totale

    movl $12, ID_attuale

    movl $-1, indice                            # Settiamo l'indice

for:
    incl indice
    movl indice, %edx

    cmpl %edx, numero_righe
    je fine_for

    # Stampa ID
    movl ID_attuale, %ebx
    movl (%esp, %ebx), %eax
    call itoa

    # Stampa ":"
    movl $4, %eax
    movl $1, %ebx
    leal carattere_due_punti, %ecx
    movl $1, %edx
    int $0x80	

    # Stampa Inizio		
    movl durata_totale, %eax
    call itoa

    # Stampa "\n"
    movl $4, %eax
    movl $1, %ebx
    leal carattere_nuova_linea, %ecx
    movl $1, %edx
    int $0x80

    # Incrementiamo la durata
    movl ID_attuale, %eax
    subl $4, %eax
    movl (%esp, %eax), %ebx
    movl durata_totale, %eax
    addl %eax, %ebx
    movl %ebx, durata_totale 

    # Calcolo penalità
    movl ID_attuale, %eax
    subl $8, %eax
    movl (%esp, %eax), %ebx # Scadenza
    movl durata_totale, %ecx # Durata totale

    subl %ecx, %ebx # Durata totale - scandenza
    cmpl $0, %ebx 
    jl aggiungi_penalita

    movl ID_attuale, %eax
    addl $16, %eax
    movl %eax, ID_attuale
    jmp for

aggiungi_penalita:
    movl ID_attuale, %ecx
    subl $12, %ecx
    movl (%esp, %ecx), %eax # Priorità

    mull %ebx # %eax * %ebx = %eax

    # Aggiorno il totale del della penalità
    movl penalita_totale, %ebx
    subl %eax, %ebx
    movl %ebx, penalita_totale

    # Incremto indice e etichetta
    movl ID_attuale, %eax
    addl $16, %eax
    movl %eax, ID_attuale
    jmp for

fine_for:
    # Stampo le stats finali
    movl $4, %eax
    movl $1, %ebx
    leal testo_conclusione, %ecx
    movl testo_conclusione_len, %edx
    int $0x80

    # Stampo la durata totale
    movl durata_totale, %eax
    call itoa

    # Stampo "\n"
    movl $4, %eax
    movl $1, %ebx
    leal carattere_nuova_linea, %ecx
    movl $1, %edx
    int $0x80

    # Stampo le penalità
    movl $4, %eax
    movl $1, %ebx
    leal testo_penalita, %ecx
    movl testo_penalita_len, %edx
    int $0x80

    # Stampo la penalità totale
    movl penalita_totale, %eax
    call itoa

    # Stampo "\n"
    movl $4, %eax
    movl $1, %ebx
    leal carattere_nuova_linea, %ecx
    movl $1, %edx

    
    push %esi
    ret

