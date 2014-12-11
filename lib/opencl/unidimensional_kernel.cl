// This is the kenel code for unidimensional integration methods.
// This is loaded into memory at runtime and a functions will be appended at run time,
// double f(double x)   - integrating function


double rectangle(int i, double a, double dx);
double trapezoid(int i, double a, double dx);
double simpson(int i, double a, double dx);
double romberg(int i, double a, double dx);

__kernel void integrate(__global const double *a, __global const double *dx, __global const double *n,
                        __global int *method, __global double *results) {
 
    // Get the index of the current element to be processed
    int i = get_global_id(0);
 
    // Do the operation
    if(i <= n) {
        int m = *method;
        switch(m) {
            case 0: results[i] = rectangle(i, *a, *dx);
                    break;
            case 1: results[i] = trapezoid(i, *a, *dx);
                    break;
            case 2: results[i] = simpson(i, *a, *dx);
                    break;
            case 3: results[i] = romberg(i, *a, *dx);
                    break;
        }
    }
}

double rectangle(int i, double a, double dx) {
    double midpoint = a + (i + 0.5) * dx;
    return dx * f(midpoint);
}

double trapezoid(int i, double a, double dx) {
    double lower = a + i * dx;
    return (0.5 * dx * (f(lower) + f(lower + dx)));
}

double simpson(int i, double a, double dx) {
    double lower = a + i * dx;
    return (dx / 6) * (f(lower) + 4 * f(lower + 0.5 * dx) + f(lower + dx));
}

