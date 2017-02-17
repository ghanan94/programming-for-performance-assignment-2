// from the Cilk manual: http://supertech.csail.mit.edu/cilk/manual-5.4.6.pdf
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TASK_IF_I_LESS_THAN_VAL (4)

int safe(char * config, int i, int j)
{
    int r, s;

    for (r = 0; r < i; r++)
    {
	s = config[r];
	if (j == s || i-r==j-s || i-r==s-j)
	    return 0;
    }
    return 1;
}

int count = 0;

void nqueens(char *config, int n, int i)
{
    char *new_config;
    int j;

    if (i==n)
    {
	//
	// Make sure increment of count is atomic (avoid race conditions)
	//
	#pragma omp atomic
	count++;
    }

    if (i < TASK_IF_I_LESS_THAN_VAL)
    {
	/* try each possible position for queen <i> */
	for (j=0; j<n; j++)
	{
	    /* allocate a temporary array and copy the config into it */
	    #pragma omp task private(new_config) shared(config, n, i) firstprivate(j)
	    {
		new_config = malloc((i+1)*sizeof(char));
		memcpy(new_config, config, i*sizeof(char));
		if (safe(new_config, i, j))
		{
		    new_config[i] = j;
		    nqueens(new_config, n, i+1);
		}
		free(new_config);
	    }
	}

	#pragma omp taskwait
    }
    else
    {
       /* try each possible position for queen <i> */
       for (j=0; j<n; j++)
	{
	/* allocate a temporary array and copy the config into it */
	    new_config = malloc((i+1)*sizeof(char));
	    memcpy(new_config, config, i*sizeof(char));
	    if (safe(new_config, i, j))
	    {
		new_config[i] = j;
		nqueens(new_config, n, i+1);
	    }
	    free(new_config);
	}
    }
}

int main(int argc, char *argv[])
{
    int n;
    char *config;

    if (argc < 2)
    {
	printf("%s: number of queens required\n", argv[0]);
	return 1;
    }

    n = atoi(argv[1]);
    config = malloc(n * sizeof(char));

    printf("running queens %d\n", n);

    //
    // Create a section that will occur in parallel
    //
    #pragma omp parallel shared(config, n)
    {
	//
	// Following block will only be executed by one thread
	//
	#pragma omp single
	{
	    nqueens(config, n, 0);
	}
    }

    printf("# solutions: %d\n", count);

    return 0;
}
