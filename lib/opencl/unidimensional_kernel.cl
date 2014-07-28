// This is the kenel code for unidimensional integration methods.
// This is loaded into memory at runtime and a functions will be appended at run time,
// float f(float x)   - integrating function


float rectangle(int i, float a, float dx);

__kernel void integrate(__global const float *a, __global const float *dx, __global const float *n,
                        __global int *method, __global float *results) {
 
    // Get the index of the current element to be processed
    int i = get_global_id(0);
 
    // Do the operation
    if(i <= n) {
        //results[i] = (f((*a) + (*dx) * i) + f((*a) + (*dx) * (i + 1))) * (*dx) / 2;

        results[i] = rectangle(i, *a, *dx); 
    }
}

float rectangle(int i, float a, float dx) {
    return dx * f(a + (i + 0.5) * dx);
}


