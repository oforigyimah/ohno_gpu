
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>

/* gpu */
#include <CL/cl.h>

#define 	MEM_SIZE                (128)
#define 	MAX_SOURCE_SIZE 	(0x100000)
#define         MAX_HASHES              (30)

#define         PRINT_LINE(title)       printf("\n========== %s ==========\n", title);


unsigned int get_noice(char *filepath);
void update_noice(char *filepath);
int get_hash(char *filepath, char *hashes[MAX_HASHES], char *games[MAX_HASHES]);
void flatten2DArray(int rows, int cols, char *inputArray[], char *outputArray);
void pad_string(char *str);