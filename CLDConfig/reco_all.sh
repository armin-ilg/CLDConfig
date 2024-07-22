nEvents=10000

# thetas=(80 60) # 80 70 60 50 40 30 20 10)
thetas=(89 80 70 60 50 40 30 20 10)
# thetas=(40 30)
# momenta=(1 10 100)
momenta=(1 10 100)
particle="mu"

# detectors=("${K4GEO}/FCCee/CLD/compact/CLD_o2_v05/CLD_o2_v05.xml")
# echo $detectors
# detectorNames=(CLD_o2_v05)

detectors=($K4GEO/FCCee/CLD/compact/CLD_o2_v05/CLD_o2_v05.xml)
detectorNames=(CLD_o2_v05)


# detectors=("/home/hep/arilg/VertexingPerformance/lcgeo/FCCee/CLD_IDEAvertex/compact/CLD_o2_v05_IDEAvertex/CLD_o2_v05_IDEAvertex.xml")
# # detectorNames=(CLD_o2_v05_IDEAvertex_separateCollections)
# # detectorNames=(CLD_o2_v05_IDEAvertex_separateCollections_ultraLight)
# detectorNames=(CLD_o2_v05_IDEAvertex)

maxJobs=10
for iDetector in "${!detectors[@]}"; do
	for momentum in "${momenta[@]}"; do
		for theta in "${thetas[@]}"; do
            runningJobs=$(jobs | wc -l | xargs)     # Get the number of jobs already started
            while [ "$runningJobs" -ge "$maxJobs" ]; do
                runningJobs=$(jobs | wc -l | xargs)     # Get the number of jobs already started
                sleep 1
            done
            echo Job number $iJob out of ${#run_list[@]} running now


            inputFile=${detectorNames[${iDetector}]}/SIM/SIM_${detectorNames[${iDetector}]}_${particle}_${theta}_deg_${momentum}_GeV_${nEvents}_evts_edm4hep.root
			outputFolder=${detectorNames[${iDetector}]}/REC/
            mkdir ${outputFolder}
            outputFile=${outputFolder}REC_${detectorNames[${iDetector}]}_${particle}_${theta}_deg_${momentum}_GeV_${nEvents}_evts

            # IDEA
            if [[ ${detectorNames[${iDetector}]} == *"IDEAvertex"* ]]; then
                echo "Running CLD reconstruction with IDEA vertex"
                k4run CLD_IDEAvertexReconstruction_separateCollections2.py --inputFiles ${inputFile} \
                --outputBasename ${outputFile} \
                --GeoSvc.detectors ${detectors[${iDetector}]} \
                --trackingOnly \
                -n ${nEvents} > ${outputFile}.log 2>&1 &
            # CLD
            else
                echo "Running CLD reconstruction"
                k4run CLDReconstruction.py --inputFiles ${inputFile} \
                --outputBasename ${outputFile} \
                --GeoSvc.detectors ${detectors[${iDetector}]} \
                --trackingOnly \
                -n ${nEvents} > ${outputFile}.log 2>&1 &
            fi
		done
	done
done

runningJobs=$(jobs | wc -l | xargs)     # Get the number of jobs already started
while [ "$runningJobs" -gt 1 ]; do
    runningJobs=$(jobs | wc -l | xargs)     # Get the number of jobs already started
    echo "$runningJobs jobs left"
    sleep 10
done
echo "Done!"