#!/bin/sh
##
#SBATCH --account=glab                # The account name for the job
#SBATCH --job-name=H_0-9_try2         # The job name
#SBATCH -n 1                          # The number of MPI tasks
#SBATCH --tasks-per-node=1            # The number of tasks per node
#SBATCH --time=04:00:00               # The runtime of this job
#SBATCH --mail-type=END,FAIL          # Type of email notification- BEGIN,END,FAIL,ALL 
#SBATCH --mail-user=scs2229@columbia.edu

#OMP_NUM_THREADS=8
ulimit -s unlimited
source activate ncplot
make clean
make -f Makefile
./entropy_driver

# End of script







