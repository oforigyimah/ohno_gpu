tests_256: sha256.c sha256.h tests.c test_vectors.h
	gcc -O3 -Wall -Wextra -pedantic tests.c sha256.c -o tests_256

example_sha256: sha256.c sha256.h example.c
	gcc -O3 -Wall -Wextra -pedantic example.c sha256.c -o example_sha256

main: main.c helper-function.c
	gcc -o ohno -D CL_TARGET_OPENCL_VERSION=120 main.c helper-function.c -lOpenCL -lm
	./ohno

debug: main.c
	gcc -o ohno -D CL_TARGET_OPENCL_VERSION=120 main.c -lOpenCL -lm
	gdb ./ohno

win_main: main.c
	x86_64-w64-mingw32-gcc -o ohno -D CL_TARGET_OPENCL_VERSION=120 main.c -lOpenCL -lm

run:
	./ohno

clean:
	rm -f ohno tests_256 example_sha256 *.o *.exe