#!/bin/bash

if [ $# -lt  2 ]; then
    echo "usage:deeptools.sh <this_file_contains_a_list_of_genese> <this_file_contains_a_bed_file_of_locations>"
    echo "
    <Species>: this defines the species we use "At, Sp, Si, Es"
    <bedfile>: this_file_contains_a_bed_file_of_locations
    all the path should be the full path."
    exit -1; 
fi

Species=$1
bedfile=$2
    
module load SAMtools/1.9
module load Python/3.6.0 
source activate r-3.5.1


basefilename=${bedfile##*/}
bedname=${basefilename%.*}
echo "currently using bedfile: $bedname"

mkdir -p computeMatrix
mkdir -p heatmap
mkdir -p profile

for mergetype in merge simplemerge
	do
    for ABF in ABF1 ABF2 ABF3 ABF4
        do

        computeMatrix scale-regions -S ${mergetype}$Species${ABF}.bw -R $bedfile  --upstream 2000 --downstream 2000 -out ${mergetype}$bedname$Species${ABF} --binSize 5 --sortUsing max --skipZeros -p=max --maxThreshold 100000
        plotHeatmap -m ${mergetype}$bedname$Species${ABF} -out ${mergetype}$bedname$Species${ABF}heatmap --colorList white,blue --sortUsing max --plotTitle ${mergetype}$bedname$Species${ABF}heatmap
        plotProfile -m ${mergetype}$bedname$Species${ABF} -out ${mergetype}$bedname$Species${ABF}kmeansprofile --perGroup --plotType=se --kmeans 6 --plotTitle ${mergetype}$bedname$Species${ABF}kmeansprofile
        plotProfile -m ${mergetype}$bedname$Species${ABF} -out ${mergetype}$bedname$Species${ABF}profile --perGroup --plotType=se --plotTitle ${mergetype}$bedname$Species${ABF}profile
        mv ${mergetype}$bedname$Species${ABF} computeMatrix
        mv ${mergetype}$bedname$Species${ABF}heatmap* heatmap
        mv ${mergetype}$bedname$Species${ABF}profile* profile
        mv ${mergetype}$bedname$Species${ABF}kmeansprofile* profile
    done
done