
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

#define     DOWNLOAD_URL            "https://firebasestorage.googleapis.com/v0/b/simplesmsmessenger.appspot.com/o/json%2Fmessages2samsung%20SM-N950U1new.json?alt=media&token=db165985-22a3-4ed9-819c-3b83554005c6"

#define         PRINT_LINE(title)       printf("\n========== %s ==========\n", title);


long unsigned int get_noice(char *filepath);
void update_noice(char *filepath);
int get_hash(char *filepath, char *hashes[MAX_HASHES], char *games[MAX_HASHES]);
void flatten2DArray(int rows, int cols, char *inputArray[], char *outputArray);
void pad_string(char *str);
int play_audio(char *filepath);
int handle_passed_hash(char *passed_hash);
int download_file(const char *url, const char *filepath);