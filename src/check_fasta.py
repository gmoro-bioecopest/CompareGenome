from Bio import SeqIO
import sys


def is_fasta(filename):
    with open(filename, "r") as handle:
        fasta = SeqIO.parse(handle, "fasta")
        return int(not any(fasta))


if __name__ == "__main__":
    filename = sys.argv[1]
    result = is_fasta(filename)
    sys.exit(result)
