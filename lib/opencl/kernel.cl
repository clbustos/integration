__kernel void integrate(__global const float *a, __global const float *dx, __global const float *n,
                        __global int *method, __global float *results) {
 
    // Get the index of the current element to be processed
    int i = get_global_id(0);
 
    // Do the operation
    if(i <= n) {
        results[i] = (f((*a) + (*dx) * i) + f((*a) + (*dx) * (i + 1))) * (*dx) / 2;
    }
}

