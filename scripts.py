import argparse
import json
from os import listdir, system

PARAM_PATH = "./gap/groups"
OUTPUT_PATH = "./essence/conjure-output"
def all_models():
    files = listdir(PARAM_PATH)
    for f in files:
        if f.endswith(".param"):
            system("conjure solve essence/edfimage.essence {0}/{1} --output-format=json --number-of-solutions=all --smart-filenames ".format(PARAM_PATH, f))

def one_model(modelpath):
    system("conjure solve essence/edfimage.essence {0} --output-format=json --number-of-solutions=all --smart-filenames ".format(modelpath))
def clean_output():
    files = listdir(PARAM_PATH)
    json.load()
    
parser = argparse.ArgumentParser(description='Automate the running of conjure on lots of models')
parser.add_argument('--allmodels', action='store_true')
parser.add_argument('--onemodel')
parser.add_argument('--cleanoutput', action='store_true')
args = parser.parse_args()

if args.allmodels:
    all_models()
elif args.onemodel is not None:
    one_model(args.onemodel)

if args.cleanoutput:
    clean_output()



