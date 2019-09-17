ID_FILE_NAME="KVSFFCKNKEKKCSY.blast-no1.txt"
NR_TXT_FILE="NR_20190502_nrprotaccession.lineage.txt"
OUTPUT_FILE="KVSFFCKNKEKKCSY-no1.output.txt"

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
        parts = split(ln, "\t")
        if (length(parts) > 1)
            if parts[1] in idList
                write(outputFile, ln)
            end
        end
    end
end

close(outputFile)
