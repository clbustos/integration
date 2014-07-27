__kernel void integrate(__global const float *a, __global const float *dx, __global const float *n,
                        __global float *results, __global int *method) {
 
    // Get the index of the current element to be processed
    int i = get_global_id(0);
 
    // Do the operation
    if(i <= n) {

    }
}

