nEvents=10000

thetas=(89 80 70 60 50 40 30 20 10)
# thetas=(40 30)
# momenta=(1 10 100)
momenta=(1 10 100)
particle="mu"
charge="-"

detectors=($K4GEO/FCCee/CLD/compact/CLD_o2_v05/CLD_o2_v05.xml)
detectorNames=(CLD_o2_v05)

# detectors=(/home/hep/arilg/VertexingPerformance/lcgeo/FCCee/CLD_IDEAvertex/compact/CLD_o2_v05_IDEAvertex/CLD_o2_v05_IDEAvertex.xml)
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

			mkdir /home/hep/arilg/VertexingPerformance/CLDConfig/CLDConfig/${detectorNames[${iDetector}]}
			outputDir=/home/hep/arilg/VertexingPerformance/CLDConfig/CLDConfig/${detectorNames[${iDetector}]}/SIM/
			mkdir ${outputDir}
			outputFileName=SIM_${detectorNames[${iDetector}]}_${particle}_${theta}_deg_${momentum}_GeV_${nEvents}_evts_edm4hep

			ddsim --compactFile ${detectors[${iDetector}]} \
			--outputFile ${outputDir}${outputFileName}.root \
			--steeringFile cld_steer.py --random.seed 0123456789 \
			--enableGun --gun.particle ${particle}${charge} --gun.energy "${momentum}*GeV" \
			--gun.distribution uniform --gun.thetaMin "${theta}*deg" --gun.thetaMax "${theta}*deg" \
			--crossingAngleBoost 0 --numberOfEvents ${nEvents} \
			> ${outputDir}${outputFileName}.log 2>&1 &
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