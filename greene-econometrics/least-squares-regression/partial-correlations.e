/* 
** This follows example 3.6 on page 41 
** of Greene, Econometric Analysis
**
** Note per footnote on Table 3.1 
** solutions are slightly different than
** those printed based on raw data
*/

// Load the relevant data
// Filename
fname = "data\\TableF3-1-mod.csv";

// Load data
invest_data = loadd(fname, "date(Year, %Y) + Real Investment + Constant + Trend + Real GDP + Interest Rate + Inflation Rate + RealGNP");

// Define independent variables
X = invest_data[., "Trend" "RealGNP" "Interest Rate" "Inflation Rate"];

// Define dependent variable
y = invest_data[., "Real Investment"];

// Estimate linear model using
// least squares and store
// results
struct olsmtOut oOut;
oOut = olsmt("", y, X);

// Simple correlations
simple_cor = corrx(Y~X);

/*
** Now we will calculate the partial 
** correlations using equation 3-22
*/

// Find t-stat using olsmt results
t_stats = oOut.b./oOut.stderr;

// Calculate partial correlations using equation 3-22
df = 10;
p_cor = sqrt((t_stats.^2)./(t_stats.^2 + df));

// Set the sign to be the same as the 
// sign of the coefficient
sign_p = oOut.b./abs(oOut.b);
p_cor = sign_p .* p_cor;

// Print table
n_var = rows(oOut.b);
table_vals = oOut.b[2:n_var]~t_stats[2:n_var]~simple_cor[2:n_var, 1]~p_cor[2:n_var];
vars = "Trend"$|"RealGDP"$|"Interest"$|"Inflation";

sprintf("%10s %10.5f %10.2f %10.5f", vars, oOut.b[2:n_var], t_stats[2:n_var], simple_cor[2:n_var, 1]~p_cor[2:n_var]);
