/*
** This file replicates Example 2.1, page 14
** in Greene Econometrics. 
**
** Keynes' Consumption Function
*/

// Load data
data = loadd(__FILE_DIR $+ "TableF2-1.csv");

// Set plot canvas to be 640 by 480 pixels
plotCanvasSize("px", 1200|800);

// Set up plot format
struct plotControl myPlot;
myPlot = plotGetDefaults("scatter");

// Set title
plotSetTitle(&myPlot, "Consumption Data, 1940-1950.", "Arial", 18);

// Set Y-axis title
plotSetYLabel(&myPlot, "C");

// Set X-axis title
plotSetXLabel(&myPlot, "X");

// Set range
plotSetXRange(&myPlot, 225, 375);
plotSetYRange(&myPlot, 200, 350);

// Plot data
plotScatter(myPlot, data[., "X"], data[., "C"]);

//Create string array of text labels
yrs = ntos(data[., "YEAR"], 4);
 
//Add labels to scatter points
plotAddTextbox(yrs, data[., "X"], data[., "C"]);

/*
** In this section we estimate the 
** linear regression lines to 
** fit the data
*/

// Add constant to X data
x_mat = ones(rows(yrs), 1)~data[., "X"];

/*
** First we fit the line to the 
** full data
*/
// Compute OLS estimates, using matrix operations
beta_hat = inv(x_mat'x_mat)*(x_mat'data[., "C"]);

// Forecast y
y_hat = x_mat * beta_hat;

// Sort data
add_y = sortc(data[., "X"]~y_hat, 1);

// Add line
plotAddXY(data[., "X"], y_hat);

/*
** Add dummy variables for war years
*/
d_war = (data[., "YEAR"] .== 1942 .or data[., "YEAR"] .== 1943 .or data[., "YEAR"] .== 1944 .or data[., "YEAR"] .== 1945);

// Create new x_mat
x_mat_war = ones(rows(yrs), 1)~d_war~data[., "X"];

// Compute OLS estimates, using matrix operations
beta_hat = inv(x_mat'x_mat)*(x_mat'data[., "C"]);
