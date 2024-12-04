

% This function will plot model output data stored in the table 'rf_out'

function [f] = plot_model_output(rf_out)

    f = figure; 
    f.Position = [50 50 1000 300];

    % MAP OF LIDAR SD
    subplot(1,3,1) 

    geoscatter(rf_out.lat,rf_out.lon,5,rf_out.lidar_SD)
    clim([0 3])
    title('Lidar snow depth')
    c = colorbar;
    c.Label.String = 'SD (m)';
    % add mean SD text
    text(0.01, 0.97, ['Mean SD: ' num2str(mean(rf_out.lidar_SD,'omitnan'),2) ' m'], 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

    
    % MAP OF MODELED SD
    subplot(1,3,2) 

    geoscatter(rf_out.lat,rf_out.lon,5,rf_out.pred_SD)
    clim([0 3])
    title('Modeled snow depth')
    c = colorbar;
    c.Label.String = 'SD (m)';
    % add mean SD text
    text(0.01, 0.97, ['Mean SD: ' num2str(mean(rf_out.pred_SD,'omitnan'),2) ' m'], 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');


    % DENSITY PLOT 
    subplot(1,3,3)

    a = rf_out.lidar_SD;
    b = rf_out.pred_SD;

    [rmse1, ~, ~, rbias] = calc_ml_stats(a,b);
  
    % Define the number of bins
    numBins = [80, 80];
    
    % Manually define bin edges to ensure the range is covered
    xEdges = linspace(0, 4, numBins(1) + 1);
    yEdges = linspace(0, 4, numBins(2) + 1);
    
    % Create 2D histogram with specified bin edges
    [counts, centers] = hist3([a, b], 'Edges', {xEdges, yEdges});
    
    % Apply log transformation, adding a small value to avoid log(0)
    lcounts = min(log(counts), 7.5);
    
    % Plot the histogram
    imagesc(centers{1}, centers{2}, lcounts');
    axis xy; % Correct the axis orientation
    xlabel('Lidar 50 m SD (m)', 'fontsize', 13);
    ylabel('Modeled 50 m SD (m)', 'fontsize', 13);
    title('Lidar vs modeled SD');    

    % Ensure the x and y axis range is [0, 4]
    xlim([0 4]);
    ylim([0 4]);
    yl = ylim;
    
    % Hold and plot the 1:1 line
    hold on;
    plot([0 4], [0 4], 'color', [0.5 0.5 0.5], 'LineWidth', 1);

    % Add error statistics as text 
    text(0.1, yl(2)*0.95, ['RMSE_5_0 = ' num2str(rmse1) ' m'], 'fontsize', 12, 'color', 'w');
    text(0.1, yl(2)*0.88, ['Bias = ' num2str(rbias) ' m'], 'fontsize', 12, 'color', 'w');

    %%% PLOT TITLE 

    % get the basin string
    basin_string = char(rf_out.basin(1));

    % get the date string 
    date_string = datestr(double(rf_out.date(1)),'dd mmmm, yyyy');
    % aggregate the complete file name
    sgtitle([basin_string ' ' date_string])



end