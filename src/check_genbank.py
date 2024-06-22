from Bio import SeqIO
import sys


def is_genbank(filename):
    with open(filename, "r") as handle:
        genbank = SeqIO.parse(handle, "genbank")
        return int(not any(genbank))


if __name__ == "__main__":
    filename = sys.argv[1]
    result = is_genbank(filename)
    sys.exit(result)
