#include "main.h"
#include <CL/cl.h>


int main() {
    char **hashes;
    char **games;
    hashes = malloc(MAX_HASHES * sizeof(char *));
    games = malloc(MAX_HASHES * sizeof(char *));

    if (hashes == NULL) {
        printf("Failed to allocate memory for hashes.\n");
        exit(1);
    };
    if (games == NULL) {
        printf("Failed to allocate memory for games.\n");
        exit(1);
    };

    for (int i = 0; i < MAX_HASHES; i++) {
        hashes[i] = malloc(65 * sizeof(char));
        memset(hashes[i], '\0', sizeof(char) * 65);
        if (hashes[i] == NULL) {
            printf("Failed to allocate memory for hashes[%d].\n", i);
            exit(1);
        }
    }

    for (int i = 0; i < MAX_HASHES; i++) {
        games[i] = malloc(33 * sizeof(char));
        memset(games[i], '\0', sizeof(char) * 33);
        if (games[i] == NULL) {
            printf("Failed to allocate memory for games[%d].\n", i);
            exit(1);
        }
    }


    char *hash_flatten = (char *)malloc(sizeof(char) * 64 * MAX_HASHES + 1);
    char *game_flatten = (char *)malloc(sizeof(char) * 32 * MAX_HASHES + 1);
    memset(hash_flatten, '\0', sizeof(char) * 64 * MAX_HASHES);
    memset(game_flatten, '\0', sizeof(char) * 32 * MAX_HASHES);
    int len;
    char *passed_hash = (char *)malloc(sizeof(char) * 65 );
    memset(passed_hash, 0, sizeof(char) * 65);
    unsigned int noice = get_noice("./files/noice.txt");
  


    len = get_hash("./files/hash.csv", hashes, games);
    
    flatten2DArray(len, 64, hashes, hash_flatten);
    flatten2DArray(len, 32, games, game_flatten);



    size_t data_size = sizeof(char) * 65 * len;

    /* GPU Mem allocation*/
    cl_mem hashes_buff, games_buff, start_buff, passed_hash_buff;
    hashes_buff = games_buff = start_buff = passed_hash_buff = NULL;

    cl_platform_id platform_id = NULL;
    cl_device_id device_id = NULL;
    cl_context context = NULL;
    cl_kernel kernel = NULL;
    cl_program program = NULL;
    cl_command_queue command_queue = NULL;
    cl_int ret;

    cl_uint ret_num_platforms;
    cl_uint ret_num_devices;

    /* Load the source code containing the kernel */
    FILE *fp;
    char fileName[] = "./kernel.cl";
    char *source_str;
    size_t source_size;

    fp = fopen(fileName, "r");
    if (!fp) {
        
        fprintf(stderr, "Failed to load kernel.\n");
        exit(1);
    }
    source_str = (char*) malloc (MAX_SOURCE_SIZE);
    source_size = fread(source_str, 1, MAX_SOURCE_SIZE, fp);
    fclose(fp);

    /* Platform */
    ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
    if (ret != CL_SUCCESS) {
        printf("Failed to get platform ID.\n");
        goto error;
    }

    /* Device */
    ret = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_GPU, 1, &device_id, NULL);
    if (ret != CL_SUCCESS) {
        printf("Failed to get device ID.\n");
        goto error;
    }

    /* Context */
    context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &ret);
    if (ret != CL_SUCCESS) {
        printf("Failed to create OpenCL context.\n");
        goto error;
    }

    /* Command Queue */
    command_queue = clCreateCommandQueue(context, device_id, 0, &ret);
    if (ret != CL_SUCCESS) {
       printf("Failed to create command queue %d\n", (int) ret);
       goto error;
    }

    /* Memory Buffer */
    hashes_buff = clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(char) * 64 * MAX_HASHES, NULL, &ret);
    games_buff = clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(char) * 32 * MAX_HASHES, NULL, &ret);
    start_buff = clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(cl_uint) + 1, NULL, &ret);
    passed_hash_buff = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(char) * 65, NULL, &ret);
    

    /* Copy input data to memory buffer */
    ret = clEnqueueWriteBuffer(command_queue, hashes_buff, CL_TRUE, 0, sizeof(char) * 64 * MAX_HASHES, hash_flatten, 0, NULL, NULL);
    ret |= clEnqueueWriteBuffer(command_queue, games_buff, CL_TRUE, 0, sizeof(char) * 32 * MAX_HASHES, game_flatten, 0, NULL, NULL);
    ret |= clEnqueueWriteBuffer(command_queue, start_buff, CL_TRUE, 0, sizeof(int) + 1, (int *)&noice, 0, NULL, NULL);

    if (ret != CL_SUCCESS) {
        printf("Failed to copy data to memory buffer.\n");
        goto error;
    }

    /* Create kernel program from source */

    program = clCreateProgramWithSource(context, 1, (const char **)&source_str, (const size_t *)&source_size, &ret);
    if (ret != CL_SUCCESS) {
        printf("Failed to create OpenCL program from source %d\n", (int) ret);
        goto error;
    }

    /* Build kernel program */

    ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);
    char build_log[16348];
    clGetProgramBuildInfo (program, device_id, CL_PROGRAM_BUILD_LOG, sizeof (build_log), build_log, NULL);
    if (ret != CL_SUCCESS) {
        printf("Failed to build program %d\n", (int) ret);
        printf ("Error in kernel: %s\n", build_log);
        goto error;
    } 

    /* Create OpenCL kernel */

    kernel = clCreateKernel(program, "calSha256", &ret);
    if (ret != CL_SUCCESS) {
        printf("Failed to create kernel %d\n", (int) ret);
        goto error; 
    }

    /* Set OpenCL kernel arguments */

    ret  = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *) &hashes_buff);
    ret |= clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *) &games_buff);
    ret |= clSetKernelArg(kernel, 2, sizeof(cl_mem), (void *) &passed_hash_buff);
    ret |= clSetKernelArg(kernel, 3, sizeof(cl_mem), (void *) &start_buff);
    ret |= clSetKernelArg(kernel, 4, sizeof(cl_int), (void *) &len);

    if (ret != CL_SUCCESS) {
        printf("Failed to set kernel arguments %d\n", (int) ret);
        goto error;
    }

    /* Execute OpenCL kernel */

    size_t global_item_size = CL_DEVICE_MAX_WORK_ITEM_SIZES;

    ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, NULL, 0, NULL, NULL);
    if (ret != CL_SUCCESS) {
        printf("Failed to execute kernel %d\n", (int) ret);
        goto error;
    }



    /* Copy results from the memory buffer */
	ret = clEnqueueReadBuffer(command_queue, passed_hash_buff, CL_TRUE, 0, 65, (void *)passed_hash, 0, NULL, NULL);
	if (ret != CL_SUCCESS) {
		printf("Failed to copy data from device to host %d\n", (int) ret);
		goto error;
	}
    printf("copy data from device to host %d\n", (int) ret);
    printf("passed_hash: %s\n", passed_hash);



    /* Finalization */

error:

    /* free device resouces*/
    clFlush(command_queue);
    clFinish(command_queue);
    clReleaseKernel(kernel);
    clReleaseProgram(program);

    clReleaseMemObject(hashes_buff);
    clReleaseMemObject(games_buff);
    clReleaseMemObject(start_buff);

    clReleaseCommandQueue(command_queue);
    clReleaseContext(context);

    /* free host resources */

    for (int i = 0; i < MAX_HASHES; i++) free(hashes[i]);
    for (int i = 0; i < MAX_HASHES; i++) free(games[i]);
    free(hashes);
    free(games);


    free(source_str);
    free(hash_flatten);
    free(game_flatten);
    free(passed_hash);


    return 0 ;

}

