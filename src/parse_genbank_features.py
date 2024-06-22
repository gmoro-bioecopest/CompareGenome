from Bio import SeqIO
import os
import sys
import fnmatch


def create_directory(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)


def write_text_to_file(file_path, text):
    with open(file_path, "w") as file:
        for line in text:
            file.write(line)


def process_feature(rec, feature, output_dir, feature_type):

    fold_no = str(len(fnmatch.filter(os.listdir(output_dir), '*')))
    folder_name = "sequence_{}".format(fold_no)
    folder_path = os.path.join(output_dir, folder_name)
    create_directory(folder_path)

    write_text_to_file(os.path.join(folder_path,
                                    "{}_NumberID.txt".format(feature_type.upper())),
                       fold_no)

    for qualifier_name in ["gene", "protein_id", "product", "db_xref", "translation", "note", "locus_tag"]:
        try:
            qualifiers = feature.qualifiers[qualifier_name]
            text = str(qualifiers).replace("[", "").replace("]", "").replace("'", "").strip('"')
            file_name = ''

            if feature_type.upper() == "CDS" and qualifier_name in ["product", "CDS_product"]:
                file_name = "CDS_product.txt"

            if feature_type.upper() == "CDS" and qualifier_name == "translation":
                file_name = "CDS_aa_seq.txt"

            if qualifier_name == "gene":
                file_name = "{}_{}ID.txt".format(feature_type.upper(), qualifier_name)

            if qualifier_name in ['protein_id', 'product', 'db_xref', 'locus_tag']:
                file_name = "{}_{}.txt".format(feature_type.upper(), qualifier_name)

            if qualifier_name == "note" and feature_type.upper() == "CDS":
                file_name = "{}_{}.txt".format(feature_type.upper(), qualifier_name)

            if qualifier_name == "note" and feature_type.upper() == "GENE":
                file_name = "{}_{}_{}.txt".format(feature_type.upper(), qualifier_name, feature_type)

            write_text_to_file(os.path.join(folder_path, file_name), text)
        except KeyError:
            pass

    if feature_type.upper() == "CDS":
        try:
            text = str(feature).replace("[", "").replace("]", "").replace("'", "").strip('"')
            file_name = os.path.join(folder_path, "All_cds_features.csv")
            write_text_to_file(file_name, text)
        except Exception as e:
            pass

    if feature_type.upper() == "GENE":
        try:
            text = feature.location.extract(rec).seq
            file_name = os.path.join(folder_path, "GENE_geneseq.txt")
            write_text_to_file(file_name, text)
        except Exception as e:
            pass


def process_record(record, output_dirs):
    for feature in record.features:
        if feature.type in ["CDS", "gene"]:

            process_feature(record,
                            feature,
                            output_dirs.get("{}_dir".format(feature.type.lower())),
                            feature.type)


def main():
    infile = sys.argv[1]
    outdir = sys.argv[2]

    dirs = dict(
        cds_dir=os.path.join(outdir, "CDS"),
        gene_dir=os.path.join(outdir, "gene")
    )

    create_directory(dirs.get('cds_dir'))
    create_directory(dirs.get('gene_dir'))

    for record in SeqIO.parse(infile, "gb"):
        process_record(record, dirs)


if __name__ == "__main__":
    main()
