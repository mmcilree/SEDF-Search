import argparse
import json
from os import listdir, system

PARAM_PATH = "./gap/params"
CONJURE_OUTPUT_PATH = "./conjure-output"
JSON_FILE_OUTPUT = "./known_osedfs.json"
ESSENCE_FILE = "essence/edf.essence"


def all_models():
    files = listdir(PARAM_PATH)
    for f in files:
        if f.endswith(".param"):
            system(
                "timeout 30m conjure solve {0} {1}/{2} --output-format=json --number-of-solutions=1 --smart-filenames ".format(
                    ESSENCE_FILE, PARAM_PATH, f
                )
            )

def one_model(modelpath):
    system(
        "timeout 30m conjure solve {0} {1} --output-format=json --number-of-solutions=all --smart-filenames ".format(
            ESSENCE_FILE, modelpath
        )
    )

def clean_output():
    """
    Read all of the conjure json output files, extract the important bits
    and store in a single file
    """
    files = listdir(CONJURE_OUTPUT_PATH)
    outputfile = open(JSON_FILE_OUTPUT, "w+")
    output = []
    for filepath in files:
        if filepath.endswith(".json"):
            metadata = filepath.split("_")
            f = open(CONJURE_OUTPUT_PATH + "/" + filepath, "r")
            data = json.load(f)
            f.close()
            osedf = [[x for x in s.values()] for s in data["edf"].values()]
            overgroup = [int(metadata[1]), int(metadata[2])]
            setsize = int(metadata[3])
            numsets = int(metadata[4])
            dups = int(metadata[5].split("-")[0])
            record = {
                "osedf": osedf,
                "overgroup": overgroup,
                "subgroup": [3, 1],  # hardcore this for now
                "setsize": setsize,
                "numsets": numsets,
                "dups": dups,
            }
            output.append(record)

    outputfile.write("[")
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

parser.add_argument("--onemodel")
parser.add_argument("--cleanoutput", action="store_true")

args = parser.parse_args()

if args.fromimage:
    ESSENCE_FILE = "essence/edffromimage.essence"
elif args.makeimage:
    ESSENCE_FILE = "essence/edfimage.essence"

if args.allmodels:
    all_models()
elif args.onemodel is not None:
    one_model(args.onemodel)

if args.cleanoutput:
    clean_output()
