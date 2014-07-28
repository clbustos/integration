all: cl.so

CC=gcc
CL_HEADERS_PATH=
LIBOPENCL_PATH=


UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
# do something Linux-y
OPENCL_LIBRARY_CALL=-lOpenCL
endif
ifeq ($(UNAME), Solaris)
# do something Solaris-y
OPENCL_LIBRARY_CALL=-framework OpenCL
endif



cl.so: integration_host.o
	$(CC) -shared -o cl.so integration_host.o -I $(CL_HEADERS_PATH) -L $(LIBOPENCL_PATH) $(OPENCL_LIBRARY_CALL)


integration_host.o: integration_host.c
	$(CC) -fpic -c integration_host.c

clean:
	rm cl.so integration_host.o

