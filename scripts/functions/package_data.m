


% this function packages  data stored in the 'training data' tables for
% random forest model training


function [X, Y] = package_data(td)
    % deltaSD - the target variable
    Y = td.lidar_SD - td.snotel_SD;
    
    % grab the physiographic variables: fractional vegetation, elevation,
    % southness, latitude, longitude, distance from snotel and TPI
    physio_subset = [td.fveg, td.elev, td.northness, td.lat, td.lon, td.dist, td.TPI_100];

    % gran the dynamic variables: day of water year, days to snotel meltout
    % difference from median SWE, MODIS fSCA
    time_subset = [td.dowy, td.day_to_melt, td.snotel_SWE - td.med_swe, td.fSCA];

    % get the snotel specific variables: snotel SD, relative elev, relative
    % fveg, relative TPI, relative southness
    snotel = [td.snotel_SD, td.elev - td.snotel_ELEV, td.fveg - td.snotel_FVEG, ...
        td.TPI_100 - td.snotel_TPI, td.northness - td.snotel_northness];
    
    % Aggregate the predictor variables into one X variable
    X = [physio_subset, time_subset, snotel];
end
