#!/bin/bash -l
#SBATCH --job-name=phrPre2   # Job name
#SBATCH --output=phrPre2.o%j # Name of stdout output file
#SBATCH --error=phrPre2.e%j  # Name of stderr error file

#SBATCH --partition=standard # ju-standard  # Partition (queue) name (@LUMI-C: debug, small [more memory], standard)
#SBATCH --nodes=4             # Total number of nodes
#SBATCH --ntasks-per-node=128
# SBATCH --mem-per-cpu=1750    # when sharing node resources (@LUMI-C: 1750)
# SBATCH --cpus-per-task=128     # Number of cores (threads)

#SBATCH --time=01:00:00         # Run time (hh:mm:ss)
#SBATCH --account=project_465001878  # Project for billing


# ENVIROMENT:  source settings file or set enviroment modules/variables 
export machineNAME="lumi"  # lumi, vesuvio
source machineSettings
# export mpiRUN=''
# export pythonCMD=''
# export PYTHON_ENV_PATH=""
# export OPENPDAC_BASHRC=""

# Print Run info
echo "Date              = $(date)"
echo "Hostname          = $(hostname -s)"
echo "Working Directory = $(pwd)"
echo ""
echo "Number of Nodes Allocated      = $SLURM_JOB_NUM_NODES"
echo "Number of Tasks Allocated      = $SLURM_NTASKS"
echo "Number of Cores/Task Allocated = $SLURM_CPUS_PER_TASK"

# pre-processing
# export FOAM_IORANKS='(0 128 256 512)'
# source set_foam_ioranks.sh $SLURM_NTASKS 128  # 128
./Allrun.pre-2 -c  # pre-processing phase 2 parallel (collated)


