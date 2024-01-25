#include "main.h"
#include <SDL2/SDL.h>
#include <time.h>
#include <curl/curl.h>

long unsigned int get_noice(char *filepath){
    FILE *fp;
    long unsigned int noice;
    fp = fopen(filepath, "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);
    fscanf(fp, "%ld", &noice);
    fclose(fp);
    return noice;
}

void update_noice(char *filepath){
    FILE *fp;
    unsigned int prev_noice = get_noice(filepath);
    fp = fopen(filepath, "w");
    if (fp == NULL)
        exit(EXIT_FAILURE);
    fprintf(fp, "%d", prev_noice + 4101);
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

int play_audio(char *filepath) {
    printf("Playing audio: %s\n", filepath);

    if (SDL_Init(SDL_INIT_AUDIO) < 0)
        return 2;
    Uint8 *wavStart;
    Uint32 wavLength;
    SDL_AudioSpec wavSpec;

    if (SDL_LoadWAV(filepath, &wavSpec, &wavStart, &wavLength) == NULL)
        return 1;

    SDL_AudioDeviceID deviceId = SDL_OpenAudioDevice(NULL, 0, &wavSpec, NULL, 0);

    if (deviceId == 0)
        return 1;

    int success = SDL_QueueAudio(deviceId, wavStart, wavLength);
    SDL_PauseAudioDevice(deviceId, 0);

    SDL_Delay(5000);

    SDL_CloseAudioDevice(deviceId);
    SDL_FreeWAV(wavStart);
    SDL_Quit();
    return 0;
}

int handle_passed_hash(char *passed_hash){
    pid_t pid;
    time_t  now = time(NULL);
    char filename[20];
    sprintf(filename, "%ld", now);
    FILE *fp = fopen(filename, "w");
    if (fp == NULL) {
        printf("Error Opening FIle");
        return 1;
    }

    fprintf(fp, "%s", passed_hash);
    fclose(fp);
    memset(passed_hash, 0, sizeof(char) * 65);
    printf("passed_hash: %s\n", passed_hash);
    play_audio("./beep-17.wav");
    return 0;

}

int download_file(const char *url, const char *path) {
    CURL *curl;
    FILE *file;
    CURLcode res;


    if (system("ping -c 1 8.8.8.8 > /dev/null 2>&1") != 0){
        fprintf(stderr, "No internet connection\n");
        return 1;
    }

    curl = curl_easy_init();
    if (curl) {
        file = fopen(path, "w");
        if (file) {
            curl_easy_setopt(curl, CURLOPT_URL, url);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, NULL);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, file);
            res = curl_easy_perform(curl);
            /* always cleanup */
            curl_easy_cleanup(curl);
            fclose(file);
            if (res != CURLE_OK) {
                fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
                return 1;
            }
        } else {
            fprintf(stderr, "Cannot open file: %s\n", path);
            return 1;
        }
    } else {
        fprintf(stderr, "curl_easy_init() failed\n");
        return 1;
    }
    return 0;
}

