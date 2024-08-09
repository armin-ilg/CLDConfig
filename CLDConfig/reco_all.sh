nEvents=1000

# thetas=(80 60) # 80 70 60 50 40 30 20 10)
thetas=(89 80 70 60 50 40 30 20 10)
# thetas=(10)
# momenta=(100)
momenta=(1 10 100)
particle="mu"

detectors=($K4GEO/FCCee/CLD_IDEAvertex/compact/CLD_o2_v05_IDEAvertex/CLD_o2_v05_IDEAvertex.xml)
detectorNames=(CLD_o2_v05_IDEAvertex)

dataFolder=/disk/gfs_data/CMS/arilg/FCC_Simulation/o1_v03_key4hep20240412/

maxJobs=10
iJob=0
for iDetector in "${!detectors[@]}"; do
	for momentum in "${momenta[@]}"; do
		for theta in "${thetas[@]}"; do
            runningJobs=$(jobs | wc -l | xargs)     # Get the number of jobs already started
            while [ "$runningJobs" -ge "$maxJobs" ]; do
                runningJobs=$(jobs | wc -l | xargs)     # Get the number of jobs already started
                sleep 1
            done
			iJob=$((iJob+1))

            echo Job number $iJob out of ${#run_list[@]} running now



            inputFile=${dataFolder}${detectorNames[${iDetector}]}/SIM/SIM_${detectorNames[${iDetector}]}_${particle}_${theta}_deg_${momentum}_GeV_${nEvents}_evts_edm4hep.root
			outputFolder=${dataFolder}${detectorNames[${iDetector}]}/REC/
            mkdir ${outputFolder}
            outputFile=${outputFolder}REC_${detectorNames[${iDetector}]}_${particle}_${theta}_deg_${momentum}_GeV_${nEvents}_evts

            # IDEA
            if [[ ${detectorNames[${iDetector}]} == *"IDEAvertex"* ]]; then
                echo "Running CLD reconstruction with IDEA vertex"
                k4run CLD_IDEAvertexReconstruction2.py --inputFiles ${inputFile} \
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