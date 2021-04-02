#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* minimum required number of parameters */
#define MIN_REQUIRED 2

/* display usage */
int help() {
    printf("Usage: ./a.exe NLINES NBIT\n");
    printf("\tNLINES: number of LUT line address, as unsigned\n");
    printf("\tNBIT  : y bit-depth, as C2 balanced\n");
    return 0;
}

/* main */
int main(int argc, char *argv[]){

    if (argc < MIN_REQUIRED) {
        return help();
    }
    
    int NLINES  = atoi(argv[1]);
    int NBIT    = atoi(argv[2]);
    
    printf("\n");
    printf("-- SIN samples for VHDL LUT\n");
    printf("-- LUT lines: %4d\n", NLINES);
    printf("--   number of LUT line address, as unsigned\n");
    printf("-- bit depth: %4d\n", NBIT);
    printf("--   y bit-depth, as C2 balanced\n");
    printf("\n");

    double lsb_yq = 1.0/(pow(2,NBIT-1)-1);  //   balanced
    double f;

    // quantization    
    for (int i=0; i<NLINES; i++){
        f = sin(2.0*M_PI*i/NLINES);
        f = round(f/lsb_yq);
        printf("%4d => %6d ,\n", i, (int)f);
    }
  
  return 0;
}