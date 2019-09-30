#include <stdio.h>
#include <stdlib.h>
#include "combs.h"

void print_mat(int** mat, int num_rows, int num_cols);
void free_mat(int** mat, int num_rows, int num_cols);

int max(int a, int b) {
  return a > b ? a : b;
}

int min(int a, int b) {
  return a < b ? a : b;
}

int num_combs(int n, int k) {
  int combs = 1;
  int i;
  
  for(i = n; i > max(k, n - k); i--) {
    combs *= i;
  }

  for(i = 2; i <= min(k, n - k); i++) {
    combs /= i;
  }
  
  return combs;
}

/*                                  // num_items
int** get_combs(int* items, int k, int len) {
  // Set up
  int* combo = (int*)malloc(k * sizeof(int));
  int** combs = (int**)malloc(num_combs(len, k) * sizeof(int*));
  for (int s = 0; s < num_combs(len, k); s++) {
    combs[s] = (int*)malloc(k * sizeof(int));
  }

  int combs_index = 0;

  comb(items, combo, 0, len-1, 0, k, combs, &combs_index);

  return combs;
}

void comb(int* items, int* combo, int start, int end, int index, int k, int** combs, int* combs_index) {
  if (index == k) {
    for (int j = 0; j < k; ++j) {
      combs[*combs_index][j] = combo[j];
    }

    (*combs_index)++;
    return;
  }

  for (int i = start; (i <= end) && (end-i+1 >= k-index); ++i) {
    combo[index] = items[i];
    comb(items, combo, i+1, end, index+1, k, combs, combs_index);
  }
}*/

void print_mat(int** mat, int num_rows, int num_cols) {
  int i,j;
  
  for(i = 0; i < num_rows; i++) {
    for( j = 0; j < num_cols; j++) {
      printf("%d ", mat[i][j]); 
    }
    printf("\n");
  }
}

void free_mat(int** mat, int num_rows, int num_cols) {
  int i;
  
  for(i = 0; i < num_rows; i++) {
    free(mat[i]);
  }
  free(mat);
}

int main() {
  int num_items;
  int* items; 
  int i,k;
  int** combs;
  printf("How many items do you have: ");
  scanf("%d", &num_items);
  
  items = (int*) malloc(num_items * sizeof(int));
  
  printf("Enter your items: ");
  for(i = 0; i < num_items; i++) {
    scanf("%d", &items[i]);
  } 
  
  printf("Enter k: ");
  scanf("%d", &k);
  
  combs = get_combs(items, k, num_items);
  print_mat(combs,num_combs(num_items, k) ,k);
  free(items);
  free_mat(combs,num_combs(num_items, k), k);
  
  return 0;
}
