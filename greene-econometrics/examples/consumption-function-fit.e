/*
** This follows example 3.2 on page 44
** of Greene, Econometric Analysis
**
** Note per footnote on Table 3.1
** solutions are slightly different than
** those printed based on raw data
*/

/*
**  Loading the data
*/
// Load the relevant data
// Filename
load_dir = getGAUSSHome $+ "pkgs/greeneLib/examples/";
fname = load_dir $+ "TableF2-1.csv";

// Load data
consumption_data = loadd(fname, "date($YEAR, '%Y') + X + C + W");

// View data table
consumption_data;

/*
** Estimating the model with full data
*/

// Find means of variables
y_bar = meanc(consumption_data[., "C"]);
x_bar = meanc(consumption_data[., "X"]);

print "y_bar"; y_bar;
print "x_bar"; x_bar;

// Find Syy
S_yy = (consumption_data[., "C"] - y_bar)'(consumption_data[., "C"] - y_bar);
print "S_yy"; S_yy;

SST = S_yy;
// Find Sxx
S_xx = (consumption_data[., "X"] - X_bar)'(consumption_data[., "X"] - X_bar);
print "S_xx"; S_xx;

// Find Sxy
S_xy = (consumption_data[., "X"] - X_bar)'(consumption_data[., "C"] - y_bar);
print "S_xy"; S_xy;

// Find coefficient 
b = S_xy/S_xx;
print "b"; b;

// Find sum of squared residuals
SSR = b^2*S_xx;
SSR;

// Find SSE
SSE = SST - SSR;
SSE;

// Find R-squared
Rsq = SSR/SST;
Rsq;

