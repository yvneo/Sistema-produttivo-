#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct prodotto
{
  int ID;
  int durata;
  int scadenza;
  int priorita;
} prodotto;

int menu();
void algorith(prodotto *arr, int len, int type);
int penalita(prodotto prodotto, int tempo_inizio);

int main(int argc, char *argv[])
{
  FILE *file = NULL;
  prodotto prodotti[10];
  int i = 0;
  char filename[15] = "";

  if (argc < 1)
  {
    printf("Nome file non specificato\n");
    exit(EXIT_FAILURE);
  }
  strcpy(filename, argv[1]);

  file = fopen(filename, "r");

  // Popoliamo l'array con tutti i campi del file
  while (!feof(file))
  {
    if (i >= 10)
    {
      break;
    }

    fscanf(file, "%d,%d,%d,%d\n", &prodotti[i].ID, &prodotti[i].durata, &prodotti[i].scadenza, &prodotti[i].priorita);
    i++;
  }
  fclose(file);

  // Chiediamo all'utente quale algoritmo vuole usare
  int algoritmo;
  do
  {

    algoritmo = menu();

    // Usiamo l'agoritmo scelto dall'utente
    if (algoritmo == 1 || algoritmo == 2)
    {
      algorith(prodotti, i, algoritmo);
    }

  } while (algoritmo != -1);
}

int menu()
{
  int input_utente = 0;
  printf("\nSelezione un tipo di algoritmo: (-1 per uscire): ");
  scanf("%d", &input_utente);
  return input_utente;
}

/** Lancia il comando di ordinamento. 1=EDF 2=HPF */
void algorith(prodotto *arr, int len, int type)
{
  int scambia = 0;
  char *nomeAlgoritmo = type == 1 ? "EDF" : "HPF";
  prodotto temp;

  // Ordiniamo per scandenza
  for (int i = 0; i < len; i++)
  {
    prodotto prodotto_minore = arr[i];
    for (int i_min = i; i_min < len; i_min++)
    {
      scambia = 0;
      if (
          (type == 1 && arr[i_min].scadenza < prodotto_minore.scadenza) ||
          (type == 2 && arr[i_min].priorita > prodotto_minore.priorita)
      ) {
        scambia = 1;
      }

      if(type == 1 && arr[i_min].scadenza == prodotto_minore.scadenza && arr[i_min].priorita > prodotto_minore.priorita) {
        scambia = 1;
      }

      if(type == 2 && arr[i_min].priorita == prodotto_minore.priorita && arr[i_min].scadenza < prodotto_minore.scadenza) {
        scambia = 1;
      }

      if (scambia == 1)
      {
        temp = arr[i];
        arr[i] = arr[i_min];
        arr[i_min] = temp;
      }
    }
  }

  int fine_ultimo_prodotto = 0;
  int totale_penalita = 0;
  printf("Pianificazione %s:\n", nomeAlgoritmo);
  for (int i = 0; i < len; i++)
  {
    printf("%d:%d\n", arr[i].ID, fine_ultimo_prodotto);
    totale_penalita += penalita(arr[i], fine_ultimo_prodotto);
    fine_ultimo_prodotto += arr[i].durata;
  }

  // Conculusione
  printf("Conclusine: %d\n", fine_ultimo_prodotto);

  // Penalità
  printf("Penalty: %d\n", totale_penalita);
}

int penalita(prodotto prodotto, int tempo_inizio)
{
  int diff = prodotto.durata + tempo_inizio - prodotto.scadenza;

  if (diff <= 0)
  {
    return 0;
  }

  return prodotto.priorita * diff;
}