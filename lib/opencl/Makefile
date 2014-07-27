all: cl.so

CC=gcc
CL_HEADERS_PATH=
LIBOPENCL_PATH=

cl.so: integration_host.o
	$(CC) -shared -o cl.so integration_host.o -I $(CL_HEADERS_PATH) -L $(LIBOPENCL_PATH) -lOpenCL

integration_host.o: integration_host.c
	$(CC) -fpic -c integration_host.c

clean:
	rm cl.so integration_host.o
