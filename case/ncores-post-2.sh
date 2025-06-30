#!/bin/bash -l
#SBATCH --job-name=phrPost2   # Job name
#SBATCH --output=phrPost2.o%j # Name of stdout output file
#SBATCH --error=phrPost2.e%j  # Name of stderr error file

#SBATCH --partition=standard # ju-standard  # Partition (queue) name (@LUMI-C: debug, small [more memory], standard)
#SBATCH --nodes=1               # Total number of nodes
#SBATCH --ntasks-per-node=64
# SBATCH --mem=0    # when sharing node resources (@LUMI-C: 1750)
# SBATCH --cpus-per-task=64     # Number of cores (threads)

#SBATCH --time=01:00:00         # Run time (hh:mm:ss)
#SBATCH --account=project_465001878  # Project for billing

# ENVIROMENT:  source settings file or set enviroment modules/variables 
export machineNAME="lumi"  # lumi, vesuvio
source machineSettings

module load LUMI/24.03  partition/C
module load EasyBuild-user
eb singularity-bindings-24.03.eb -r
module load singularity-bindings

# Print Run info
echo "Date              = $(date)"
echo "Hostname          = $(hostname -s)"
echo "Working Directory = $(pwd)"
echo ""
echo "Number of Nodes Allocated      = $SLURM_JOB_NUM_NODES"
echo "Number of Tasks Allocated      = $SLURM_NTASKS"
echo "Number of Cores/Task Allocated = $SLURM_CPUS_PER_TASK"

./Allrun.post-2 


