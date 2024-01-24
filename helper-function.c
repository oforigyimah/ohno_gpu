#include "main.h"

unsigned int get_noice(char *filepath){
    FILE *fp;
    unsigned int noice;
    fp = fopen(filepath, "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);
    fscanf(fp, "%d", &noice);
    fclose(fp);
    return noice;
}

void update_noice(char *filepath){
    FILE *fp;
    unsigned int prev_noice = get_noice(filepath);
    fp = fopen(filepath, "w");
    if (fp == NULL)
        exit(EXIT_FAILURE);
    fprintf(fp, "%d", prev_noice + 4100);
    fclose(fp);
}

int get_hash(char *filepath, char *hashes[MAX_HASHES], char *games[MAX_HASHES]){
    FILE *fp_hashes;
    char buffer[1024];
    char *record, *line;
    int len = 0;

    fp_hashes = fopen(filepath,"r");

    if(fp_hashes == NULL) {
        printf("\n file opening failed ");
        return -1 ;
    }
    while((line=fgets(buffer,sizeof(buffer),fp_hashes))!=NULL && len < MAX_HASHES) {
        record = strtok(line,",");
        if(record != NULL) {
            hashes[len] = strdup(record);
            record = strtok(NULL,",");
            if(record != NULL) {
                // Copy only non-null characters from record to games[len]
                strncpy(games[len], record, strlen(record));
            }
            len++;
        }
    }
    fclose(fp_hashes);
    return len;
}

void flatten2DArray(int rows, int cols, char *inputArray[], char *outputArray) {
    int i, j;
    for (i = 0; i < rows; i++) {
        for (j = 0; j < cols; j++) {
            outputArray[i*cols + j] = inputArray[i][j];
        }
    }
}

void pad_string(char *str) {
    int len = strlen(str);
    if (len < 32) {
        memset(str + len, '0', 32 - len);  // Fill the rest of the string with '0'
        str[32] = '\0';  // Null-terminate the string
    }
}