// This file contains the host code of the openCL supported integration
#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdlib.h>
#include <limits.h>       //For PATH_MAX

// import OpenCL headers assuming OS is a linux version or MAC
#ifdef __APPLE__
    #include<OpenCL/opencl.h>
#else
    #include<CL/cl.h>
#endif

#define MAX_SOURCE_SIZE (0x100000) // maximum size allowed for the kernel text

// these are the available integration methods
enum methods{
      rectangle,
      trapezoid,
      simpson,
      adaptive_quadrature,
      gauss,
      romberg,
      monte_carlo
};

float opencl_integration(float lower, float upper, int n, char* f,
                        enum methods method, char* path_to_kerne) {

    char* source_str;
    size_t source_size;
    int i = 0;
    float dx = (upper - lower) / n;
    float *results = (float*) malloc(n * sizeof(float));

    // read the corresponding kernel
    FILE* fp;
    sprintf(path_to_kerne, "%s%s", path_to_kerne, "/unidimensional_kernel.cl");
    fp = fopen(path_to_kerne, "r");

    // if the kernel file doesn't exist, stop the execution
    if(fp == 0) {
        printf("kernel file not found\n");
        exit(0);
    }
    
    char *temp_source;
    // allocate memory for kenel code
    temp_source = (char*) malloc(sizeof(char) * MAX_SOURCE_SIZE);
    source_str  = (char*) malloc(sizeof(char) * MAX_SOURCE_SIZE);

    temp_source[0] = '\0';  // make temp_source a null string
    char line[100];
    // read the text of the kernel into temp_source
    while(!feof(fp)) {
        if (fgets(line, 100, fp)) {
            sprintf(temp_source, "%s%s",temp_source, line);
        }
    }

    // create the complete kernel code appending,
    // f()   - integrating function
    sprintf(source_str, "float f(float x){return (%s);}\n%s", f, temp_source);

    // printf("\nfunction----------------------------\n%s\n--------------------------\n", source_str);
    source_size = strlen(source_str);
    fclose(fp);
    free(temp_source);

    cl_platform_id platform_id = NULL;
    cl_device_id device_id     = NULL;   
    cl_uint ret_num_devices;
    cl_uint ret_num_platforms;
    cl_int ret;
    ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
    // CL_DEVICE_TYPE_CPU is being used currently as the testing value
    ret = clGetDeviceIDs( platform_id, CL_DEVICE_TYPE_CPU, 1, &device_id, &ret_num_devices);

    // create kernel
    cl_context context = clCreateContext( NULL, 1, &device_id, NULL, NULL, &ret);
    // create command queue
    cl_command_queue command_queue = clCreateCommandQueue(context, device_id, 0, &ret);    

    // create memory buffers to share memory with kernel program 
    cl_mem lower_obj  = clCreateBuffer(context, CL_MEM_READ_ONLY,  sizeof(float)     , NULL, &ret);
    cl_mem dx_obj     = clCreateBuffer(context, CL_MEM_READ_ONLY,  sizeof(float)     , NULL, &ret);
    cl_mem n_obj      = clCreateBuffer(context, CL_MEM_READ_ONLY,  sizeof(int)       , NULL, &ret);
    cl_mem method_obj = clCreateBuffer(context, CL_MEM_READ_ONLY,  sizeof(int)       , NULL, &ret);
    cl_mem result_obj = clCreateBuffer(context, CL_MEM_WRITE_ONLY, sizeof(float) * n , NULL, &ret);
    //cl_mem epsilon_obj      = clCreateBuffer(context, CL_MEM_READ_ONLY,  sizeof(float)     , NULL, &ret);
    //cl_mem golden_obj       = clCreateBuffer(context, CL_MEM_READ_ONLY,  sizeof(float)     , NULL, &ret);

    // writes the input values into the allocated memory buffers
    ret = clEnqueueWriteBuffer(command_queue, lower_obj,  CL_TRUE, 0, sizeof(float)    , &lower , 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, dx_obj   ,  CL_TRUE, 0, sizeof(float)    , &dx    , 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, n_obj    ,  CL_TRUE, 0, sizeof(int)      , &n     , 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, method_obj, CL_TRUE, 0, sizeof(int)      , &method, 0, NULL, NULL);
    //ret = clEnqueueWriteBuffer(command_queue, epsilon_obj , CL_TRUE, 0, sizeof(float)    , &epsilon       , 0, NULL, NULL);
    //ret = clEnqueueWriteBuffer(command_queue, golden_obj  , CL_TRUE, 0, sizeof(float)    , &golden        , 0, NULL, NULL);

    // create kernel program
    cl_program program = clCreateProgramWithSource(context, 1, (const char **)&source_str, (const size_t *)&source_size, &ret);
    // build the kernel program. Still the code isn't being executed
    // memory buffers haven't involved. Any error at this stage MAY be a syntax error of kernel code
    ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);
    // this gives error message only if the kernel code includes any syntax error
    if(ret == CL_BUILD_PROGRAM_FAILURE)  printf("\nerror while building kernel: %d\n", ret);
    // create the kernel calling the kernel function 'minimize'
    cl_kernel kernel = clCreateKernel(program, "integrate", &ret);

    // set arguments of kernel function
    ret = clSetKernelArg(kernel, 0 , sizeof(cl_mem)    , (void *)&lower_obj);    
    ret = clSetKernelArg(kernel, 1 , sizeof(cl_mem)    , (void *)&dx_obj);    
    ret = clSetKernelArg(kernel, 2 , sizeof(cl_mem)    , (void *)&n_obj);    
    ret = clSetKernelArg(kernel, 3 , sizeof(cl_mem)    , (void *)&method_obj);    
    ret = clSetKernelArg(kernel, 4 , sizeof(cl_mem) * n, (void *)&result_obj);
    //ret = clSetKernelArg(kernel, 9 , sizeof(cl_mem)    , (void *)&epsilon_obj);
    //ret = clSetKernelArg(kernel, 10, sizeof(cl_mem)    , (void *)&golden_obj);

    size_t global_item_size = n;
    // enqueue the jobs and let them to be solved by kernel program
    ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL, &global_item_size, NULL, 0, NULL, NULL);
    
    // retrieve results from the shared memory buffers
    ret = clEnqueueReadBuffer(command_queue, result_obj, CL_TRUE, 0, sizeof(float) * n, results, 0, NULL, NULL);

    // clear the allocated memory
    ret = clFlush(command_queue);
    ret = clFinish(command_queue);
    ret = clReleaseKernel(kernel);
    ret = clReleaseProgram(program);

    ret = clReleaseMemObject(lower_obj);
    ret = clReleaseMemObject(dx_obj);
    ret = clReleaseMemObject(n_obj);
    ret = clReleaseMemObject(method_obj);
    //ret = clReleaseMemObject(epsilon_obj);
    //ret = clReleaseMemObject(golden_obj);

    ret = clReleaseCommandQueue(command_queue);
    ret = clReleaseContext(context);
    free(source_str);

    float final_result = 0;
    for(i = 0; i < n; ++i) {
        final_result += results[i];
    }

    return final_result;
}
