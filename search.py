import os
import subprocess

GAP_DIR = os.getenv("GAP_DIR")
GAP = GAP_DIR + "/bin/gap.sh"

def run_gap(gap_input):
    """
        Runs gap input (mostly just for calling functions with arbitrary arguments).
    """
    inputfile = open("./gap/temp_input.g", "w+")
    inputfile.write(gap_input)
    inputfile.close()
    wd = os.getcwd()
    subprocess.run([GAP, "./temp_input.g", "-q", "--nointeract"], cwd=wd+"/gap")

def homomorphism_search(group_size, group_id)
    """
        Attempt to find an SEDF by constructing images in smaller groups, using a subnormal
        series to 'hop' up.
    """
    