/* 
** This follows example 2.6 on page 21 
** of Greene, Econometric Analysis
*/

// Load Data Table F4.1
data = loadd(__FILE_DIR $+ "TableF4-1.csv");

// Compute aspect ratio
aspect = data[., "WIDTH"]./data[., "HEIGHT"];

// Compute size
size = data[., "WIDTH"].*data[., "HEIGHT"];

// Matrix of independent variables
X = size~aspect~data[., "HEIGHT"];

// Check the rank
call olsmt("", data[., "PRICE"], X);
