import argparse
import json
import math
from os import listdir, system

PARAM_PATH = "./gap/allrwedfs"
CONJURE_OUTPUT_PATH = "./conjure-output"
JSON_FILE_OUTPUT = "./known_osedfs.json"
ESSENCE_FILE = "essence/edfimagefromimage.essence"

def lcm(a):
  lcm = a[0]
  for i in range(1,len(a)):
    lcm = lcm*a[i]//math.gcd(lcm, a[i])
  return lcm

def all_models():
    files = listdir(PARAM_PATH)
    for f in files:
        if f.endswith(".param"):
            system(
                "timeout 30s conjure solve {0} {1}/{2} --output-format=json --number-of-solutions=1 --smart-filenames ".format(
                    ESSENCE_FILE, PARAM_PATH, f
                )
            )

def one_model(modelpath):
    system(
        "conjure solve {0} {1} --output-format=json --number-of-solutions=1 --smart-filenames ".format(
            ESSENCE_FILE, modelpath
        )
    )

def clean_output(path, rwedf):
    """
    Read all of the conjure json output files, extract the important bits
    and store in a single file
    """
    files = listdir(CONJURE_OUTPUT_PATH)
    outputfile = open(path, "w+")
    output = []
    for filepath in files:
        if filepath.endswith(".json"):
            metadata = filepath.split("_")
            f = open(CONJURE_OUTPUT_PATH + "/" + filepath, "r")
            data = json.load(f)
            f.close()
            
            if rwedf:
                rwedf = [[x for x in s.values()] for s in data["edf"].values()]
                group = [int(metadata[1]), int(metadata[2])]
                numsets = int(metadata[3])
                setsizes = json.loads(metadata[4])
                dups = int(metadata[5].split("-")[0])/lcm(setsizes + [group[1]])
                record = {
                    "rwedf": rwedf,
                    "group": group,
                    "setsize": setsizes,
                    "numsets": numsets,
                    "dups": dups,
                }
                output.append(record)
            else:
                osedf = [[x for x in s.values()] for s in data["edf"].values()]
                overgroup = [int(metadata[1]), int(metadata[2])]
                subgroup = [int(metadata[3]), int(metadata[4])]
                numsets = int(metadata[5])
                setsize = int(metadata[6])
                
                dups = int(metadata[7].split("-")[0])
                record = {
                    "osedf": osedf,
                    "overgroup": overgroup,
                    "subgroup": subgroup,
                    "setsize": setsize,
                    "numsets": numsets,
                    "dups": dups,
                }
                output.append(record)
    if len(outputfile.readlines()) == 0:
        outputfile.write("[")
    else:
        outputfile.seek(-1, os.SEEK_END)
        outputfile.truncate()

    for i, r in enumerate(output):
        outputfile.write(
            json.dumps(r, sort_keys=True)
            + ("," if i != len(output) - 1 else "")
            + "\n\n"
        )
    outputfile.write("]")


parser = argparse.ArgumentParser(
    description="Automate the running of conjure on lots of models"
)

parser.add_argument("--allmodels", action="store_true")
parser.add_argument("--fromimage", action="store_true")
parser.add_argument("--makeimage", action="store_true")
parser.add_argument("--rwedf", action="store_true")

parser.add_argument("--onemodel")
parser.add_argument("--cleanoutput")

args = parser.parse_args()

if args.fromimage:
    ESSENCE_FILE = "essence/edffromimage.essence"
elif args.makeimage:
    ESSENCE_FILE = "essence/edfimage.essence"
elif args.rwedf:
    ESSENCE_FILE = "essence/wedf.essence"

if args.allmodels:
    all_models()
elif args.onemodel is not None:
    one_model(args.onemodel)

if args.cleanoutput is not None:
    clean_output(args.cleanoutput, args.rwedf)
