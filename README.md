This repository supports the SALMON (Snow Analysis using Lidar and Machine learning Overlaid with Network data) Snow project. This research was recently submitted to _Water Resources Research_ for peer review:

Abstract: 
Machine learning (ML) has emerged as an effective tool for estimating snow depth and snow water equivalent at unsampled times and locations. Airborne lidar surveys are particularly useful for ML applications: the high-resolution, high-precision snow depth data allow for algorithm training and testing to an extent not previously possible. Here, we train a random forest model to estimate snow depth relative to a nearby Snotel site using physiographic data and other dynamic snowpack information as predictor variables and lidar for the target variable. The model output is daily, 50 m resolution snow depth for basins that have both lidar and Snotel data in Colorado. We evaluated multiple approaches for random forest training: using historic lidar data in a basin (temporal transfer), using lidar data from other basins in a region (spatial transfer), and both together. All scenarios demonstrate success, with RMSE values of 0.38–0.45 m at 50 m resolution, indicating that information from lidar can be transferred to different times and locations within the region. The model scenario which includes both temporally and spatially transferred lidar data is the most robust to the number and timing of lidar surveys used in model training. [JH1] This framework extends the spatial footprint of Snotel and the temporal coverage of lidar by leveraging the strengths of the two datasets, with applications for water resource management and validation of gridded snow products. 


Here, we provide scripts to train and test a random forest model to estimate snow depth in the East River Basin. Due to storage limitations, we only provide complete training data for the East River Basin and subsampled training data from other basins. Complete training data from other Colorado basins can be provided upon request (reach out at jordan.herbert@colorado.edu).

Repository contents: 

- SSReg_basin_tifs: contains basin wide tifs of estimated snow depth at the time/location of each lidar survey used in the investigation. The lidar survey at the date of the prediction was omitted from model training to serve as an independent evaluation
- Summary_plots: contains plots which compare lidar snow depth to snow depth from the three models (site-specific, regional and SS+Reg).
- Scripts: contains a script to train and test the random forest model in the east river basin 
- Data: data required to run the random forest script. 
