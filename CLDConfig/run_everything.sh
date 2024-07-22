sh sim_all.sh
sh reco_all.sh
fccanalysis run ../../FullSim/TrackingPerformance/Plotting/analysis_tracking.py
k4run ../../FullSim/TrackingPerformance/Plotting/plots_tracking.py

# or do overlay multiple canvases
python3 ../../FullSim/TrackingPerformance/Plotting/SuperimposedCanvas.py