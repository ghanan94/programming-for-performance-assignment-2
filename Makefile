RM = rm -f

SS_CC = /opt/oracle/solarisstudio12.3/bin/cc
SS_CFLAGS = -lm
SS_OPTFLAGS = -fast
SS_AUTOPARFLAGS = -xautopar -xloopinfo -xreduction -xbuiltin
SS_AUTOOMPFLAGS = -xopenmp -xloopinfo
SS_OMPFLAGS = -xopenmp

CC = gcc
CFLAGS = -O2 -std=c99 -D_GNU_SOURCE
OMPFLAGS = -fopenmp -Wall

all: part1 part2 part3

part1: bin bin/raytrace bin/raytrace_opt bin/raytrace_auto

part2: bin bin/raytrace_omp

part3: bin bin/nqueens bin/nqueens_omp

bin:
	mkdir -p bin

bin/raytrace: q1/raytrace_simple.c
	@printf "Compiling Part 1 Sequential unoptimized\n"
	$(SS_CC) $(SS_CFLAGS) -lm $< -o $@

bin/raytrace_opt: q1/raytrace_simple.c
	@printf "Compiling Part 1 Sequential optimized\n"
	$(SS_CC) $(SS_CFLAGS) $(SS_OPTFLAGS) -lm $< -o $@

bin/raytrace_auto: q1/raytrace_auto.c
	@printf "Compiling Part 1 Automatic Parallelization\n"
	$(SS_CC) $(SS_CFLAGS) $(SS_OPTFLAGS) $(SS_AUTOPARFLAGS) $< -o $@

bin/raytrace_omp: q2/raytrace.c q2/3dsloader.c q2/colour.c q2/fileformat.c q2/noise.c q2/sphere.c q2/tokenizer.c q2/triangle.c q2/vectors.c
	@printf "Compiling Part 2 OpenMP\n"
	$(SS_CC) $(SS_CFLAGS) $(SS_OPTFLAGS) $(SS_OMPFLAGS) -o $@ q2/raytrace.c q2/3dsloader.c q2/colour.c q2/fileformat.c q2/noise.c q2/sphere.c q2/tokenizer.c q2/triangle.c q2/vectors.c

bin/nqueens: q3/nqueens.c
	@printf "Compiling Part 3 Sequential\n"
	$(CC) $< $(CFLAGS) -o $@

bin/nqueens_omp: q3/nqueens_omp.c
	@printf "Compiling Part 3 OpenMP\n"
	$(CC) $< $(CFLAGS) $(OMPFLAGS) -o $@

report: report.pdf

report.pdf: report/report.tex
	cd report && pdflatex report.tex && pdflatex report.tex
	mv report/report.pdf report.pdf

clean:
	$(RM) -r bin
	$(RM) report/*.aux report/*.log

.PHONY: all part1 part2 part3 report clean
