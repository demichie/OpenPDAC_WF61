#!/bin/bash -l
#SBATCH --job-name=phreatic   # Job name
#SBATCH --output=phreatic.o%j # Name of stdout output file
#SBATCH --error=phreatic.e%j  # Name of stderr error file

#SBATCH --partition=standard # ju-standard  # Partition (queue) name (@LUMI-C: debug, small [more memory], standard)
#SBATCH --nodes=4           # Total number of nodes
#SBATCH --ntasks-per-node=128
#SBATCH --mem=200G   # Allocate all the memory on each node

# SBATCH --mem=0   # Allocate all the memory on each node
# SBATCH --mem-per-cpu=1750    # when sharing node resources (@LUMI-C: 1750)
# SBATCH --cpus-per-task=128     # Number of cores (threads)

#SBATCH --time=00:20:00         # Run time (hh:mm:ss)
#SBATCH --account=project_465001219  # Project for billing


# ENVIROMENT:  source settings file or set enviroment modules/variables 
export machineNAME="lumi"  # lumi, vesuvio
source machineSettings

module load libunwind/1.6.2-cpeGNU-24.03
module load libbfd				
module load craype-x86-milan
module load cray-python

# export mpiRUN=''
# export pythonCMD=''
# export PYTHON_ENV_PATH=""
# export OPENPDAC_BASHRC=""
# module load openFOAM-11
# source $FOAM_BASHRC

# Profiling with preload mechanism
export MPIP="-c -d"
# TRACE="LD_PRELOAD=/users/brogifed/mpiP/mpiP-3.5/build_gnu/libmpiP.so"
TRACE="env LD_PRELOAD=/$HOME/mpiP/mpiP-3.5/build_gnu/libmpiP.so"

# Print Run info
echo "Date              = $(date)"
echo "Hostname          = $(hostname -s)"
echo "Working Directory = $(pwd)"
echo ""
echo "Number of Nodes Allocated      = $SLURM_JOB_NUM_NODES"
echo "Number of Tasks Allocated      = $SLURM_NTASKS"
echo "Number of Cores/Task Allocated = $SLURM_CPUS_PER_TASK"
echo "TRACE: $TRACE"

# clean run dir
# ./Allclean  # comment to execute pre-processing separately with ncores-pre.sh 

# pre-processing
# export FOAM_IORANKS='(0 128 256 512)'
# source set_foam_ioranks.sh $SLURM_NTASKS 128  # 128
# ./Allrun.pre-2  # full pre-processing to be used to run  pre- and processing in one single job
# ./Allrun.pre-2 -c # pre-processing with collated IO 

# processing
logFile="log.foamRun-0"
[ -f $logFile ] && echo "error:  logfile $logfile exist already, change name and rerun" >&2
[ -f $logFile ] && exit 1
# argCollated=''
argCollated='-fileHandler collated'
# export FOAM_IORANKS='(0 128 256 512)'
# source set_foam_ioranks.sh $SLURM_NTASKS 16 # 128
cp system/controlDict.run-iter system/controlDict # to make just few iterations 
# $mpiRUN foamRun -parallel $argCollated > $logFile
srun ${TRACE} foamRun -parallel $argCollated > $logFile

# post-processing
# ./Allrun.post
