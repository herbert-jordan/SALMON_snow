
% Author: Jordan Herbert
% jordan.herbert@colorado.edu
% December 4, 2024
% https://github.com/herbert-jordan/SALMON_snow

%%% BACKGROUND INFORMATION
% this script provides an example of running a random forest model to
% predict snow depth surrounding a Snotel station in Colorado.

% the training data have been pre-packaged for the user and contain all
% data necessary to run and test the model. 

% Due to github storage limits, this script is set up to run exclusively
% for the East River Basin. We include all training data for the East River
% Basin, and subsampled training data for the rest of the basins in
% Colorado (i.e., regional data) in the github repository. Feel free to 
% reach out if you would like the training data for the rest of the basins. 

%%% SCRIPT INFORMATION
% This script will run the Site-specific + Regional model, which uses
% training data from within the test basin (East River Basin) as well as
% from other basins with lidar data in Colorado. 

% to test model performance, we need to withhold lidar data from one date.
% This script will allow you to choose which lidar survey you would like to
% withhold and test. 

% This script subsamples the training data for faster performance.
% Subsampling has limited impact on model performance. These numbers can be
% changed by altering the 'num_pts' variables below. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initial user inputs 

% !! USER add the path to the SALMON_snow repository !!
home_path = '/Users/jordanherbert/github/SALMON_snow';

% num_pts defines the number of points from the ERB to use (max = 26 mil)
num_pts = 50000;

% define the number of regional points to use (max = 900,000)
num_regional_pts = 50000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% LOAD DATA
cd(home_path)
addpath scripts/functions/ % add path to the functions

cd data/
% load the regional training data. (Table = 'td')
load training_data_regional.mat 
% now, load the east river data (Table = 'training_data')
load training_data_EastRiver.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% subsample regional training data
ind = td.basin == 'East River';
td(ind,:) = [];

% randomly subsample the regional data based on the defined number of pts
subsample = randsample(height(td),num_regional_pts);
% sub sample the regional training data
td = td(subsample,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define which survey to withhold/test

% get the unique survey dates 
survey_dates = unique(training_data.date);
% convert serial dates to readable strings
survey_date_strings = datestr(double(survey_dates),'yyyy mm dd');

% display each date in the terminal 
for i = 1:length(survey_date_strings)
    fprintf('%d: %s\n', i, survey_date_strings(i, :));
end

% The user decides which survey to run 
fprintf('\n')
survey_choice = input('Which date would you like to withhold for testing? (1-10): ');

fprintf('\n')
plot_opt = input('Do you want to plot the output data? (1 = yes, 0 = no): ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% East River Basin training data processing 

% get indices of the test dat
survey_ind = training_data.date == survey_dates(survey_choice);
% 'test data' now contains all data from the withheld survey
test_data = training_data(survey_ind,:);
% remove test data from the training set
training_data(survey_ind,:) = [];

% randomly sample percent of points to remove as defined in 'num_pts'
subsample_ind = randsample(height(training_data),num_pts);
% remove the points
training_data = training_data(subsample_ind,:);

% combine the East River Basin training data with the regional training data 
td_combined = [training_data; td];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Train the random forest model 

% the package data function grabs all variables from the training data
% which are necessary for model training/testing (ignoring metadata, etc.)

%%% Package the training data
[X, Y] = package_data(td_combined);
%%% Package the test data
[test_X, ~] = package_data(test_data);

% Train the RF model
fprintf('\n')
disp('...Training the random forest model')
tic
mdl = TreeBagger(100,X,Y,'Method','regression', ...
'OOBPredictorImportance','On', ...
'MinLeafSize',5);

elapsedTime = toc; % Capture the elapsed time
fprintf('\n')
disp(['Model training complete. Time elapsed: ', num2str(elapsedTime), ' seconds.']);

% Use the test data to estimate delta SD
delta_SD = predict(mdl,test_X);
% add snotel SD to each pixel to get absolute snow depth at each point
predicted_SD = delta_SD + test_data.snotel_SD;
% get rid of any negative values (not physically possible)
predicted_SD(predicted_SD < 0) = 0;
disp('Prediction complete')

% organize final data:
rf_out = test_data;
rf_out.pred_SD = predicted_SD; 

% plot the data 
if plot_opt == 1
    f = plot_model_output(rf_out);
end


%% SAVE DATA 
% navigate to model output folder 
cd model_output

% get the basin string
basin_string = char(rf_out.basin(1));
basin_string = strrep(basin_string,' ','');
% get the date string 
date_string = datestr(double(survey_dates(survey_choice)),'yyyymmdd');
% aggregate the complete file name
save_file = [basin_string '_' date_string];

% save the data 
save([save_file '.mat'],'rf_out')

% save the plot 
exportgraphics(f,[save_file '.png'])







