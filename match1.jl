using ArgParse

s = ArgParseSettings()
@add_arg_table s begin
    "--walltime", "-w"
    help = "Walltime hours"
    arg_type = Int
    default = 10
    "--mem", "-m"
    help = "mem Gb"
    arg_type = Int
    default = 10
    "--threads", "-t"
    help = "threads - refer to clumpify.sh"
    arg_type = Int
    default = 1
    "--input_dir", "-d"
    help = "input directory"
    required = true
    "--input_file", "-i"
    help = "input_file"
    required = true
    "--tax_file", "-r"
    help = "taxonomy reference"
    default = "/srv/scratch/z3527722/autoimmune/B2GPI/NR_20190502_nrprotaccession.lineage.txt"
    "--output_file", "-o"
    help = "outputfile"
    required = true
end
parsed_args = parse_args(ARGS, s)

PBS_TEMPLATE = """#!/bin/bash
#PBS -N {input_file}_match
#PBS -l nodes=1:ppn={threads}
#PBS -l walltime={walltime}:00:00
#PBS -l mem={mem}GB
#PBS -m ae
#PBS -M emily.mcgovern@unsw.edu.au

cd {input_dir}
module load julia/1.1.0

ID_FILE_NAME={input_file}
NR_TAX_FILE={tax_file}
OUTPUT_FILE={output_file}

# Open output filter
outputFile = open(OUTPUT_FILE, "w")

# Read ID file into array
idFile = open(ID_FILE_NAME);
idList = readlines(idFile);
close(idFile)

# Filter out any empty lines
filter!(x->x≠"",idList);

# Open large file and read line
open(NR_TXT_FILE) do file
    for ln in eachline(file)
        parts = split(ln, "\\t")
        if (length(parts) > 1)
            if parts[1] in idList
                write(outputFile, string(ln, "\\n"))
            end
        end
    end
end

close(outputFile)"""

output_pbs = PBS_TEMPLATE
for (key, value) in parsed_args
    global output_pbs
    output_pbs = replace(output_pbs, string("{", key, "}") => string(value))
end

open(string(parsed_args["input_file"], "_out.txt"), "a+") do f
    write(f, output_pbs)
end
