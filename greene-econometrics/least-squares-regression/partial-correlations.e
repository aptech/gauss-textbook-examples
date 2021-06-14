/* 
** This follows example 3.6 on page 41 
** of Greene, Econometric Analysis
**
** Note per footnote on Table 3.1 
** solutions are slightly different than
** those printed based on raw data
*/
new;

// Load the relevant data
// Filename
fname = "data/TableF3-1-mod.csv";

// Load data
invest_data = loadd(fname, "date(Year, %Y) + Real Investment + Constant + Trend + Real GDP + Interest Rate + Inflation Rate + RealGNP");

// Estimate linear model using
// least squares and store
// results
struct olsmtOut o_Out;
o_Out = olsmt(fname, "Real Investment ~ Trend + RealGNP + Interest Rate + Inflation Rate");

// The simple correlations
// between the dependent and 
// independent variables are 
// computed and stored when
// olsmt is called
simple_cor = o_Out.cx[1:4, cols(o_Out.cx)];

/*
** Now we will calculate the partial 
** correlations using equation 3-22
*/

// Find t-stat using olsmt results
t_stats = o_Out.b./o_Out.stderr;

// Calculate partial correlations using equation 3-22
df = 10;
p_cor = sqrt((t_stats.^2)./(t_stats.^2 + df));

// Set the sign to be the same as the 
// sign of the coefficient
sign_p = o_Out.b./abs(o_Out.b);
p_cor = sign_p .* p_cor;

// Print table
n_var = rows(o_Out.b);
vars = "Trend"$|"RealGDP"$|"Interest"$|"Inflation";
stats = ""$|"Coeff."$|"t ratio"$|"Simple Corr."$|"Partial Corr.";

print;
sprintf("%21s", stats');
sprintf("%20s %20.5f %20.2f %20.5f", vars, o_Out.b[2:n_var], t_stats[2:n_var], simple_cor~p_cor[2:n_var]);
