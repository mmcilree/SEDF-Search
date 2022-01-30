import os
import subprocess

GAP_DIR = os.getenv("GAP_DIR")
GAP = GAP_DIR + "/bin/gap.sh"
def run_gap(gap_input):
    inputfile = open("./gap/temp_input.g", "w+")
    inputfile.write(gap_input)
    inputfile.close()

    wd = os.getcwd()
    subprocess.run([GAP, "./temp_input.g", "-q", "--nointeract"], cwd=wd+"/gap")

run_gap('Read("param_test.g");\ntest_output();')