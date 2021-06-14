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
fname = "data/TableF3-1-mod.csv";

// Load data
invest_data = loadd(fname, "date(Year, %Y) + Real Investment + Constant + Trend + Real GDP + Interest Rate + Inflation Rate + RealGNP");

// View data table
invest_data;

// Calculate means
y_bar = meanc(invest_data[., "Real Investment"]);
t_bar = meanc(invest_data[., "Trend"]);
g_bar = meanc(invest_data[., "RealGNP"]);


// Calculate deviations from the mean
y = invest_data[., "Real Investment"]- y_bar;
t = invest_data[., "Trend"]- t_bar;
g = invest_data[., "RealGNP"]- g_bar;

// Calculate b2
b2 = ((t'*y)*(g'*g) - (g'*y)*(t'*g))/((t'*t)*(g'*g) - (g'*t)^2);
Print "b2 :";
b2;

// Calculate b3
b3 = ((g'*y)*(t'*t) - (t'*y)*(t'*g))/((t'*t)*(g'*g) - (g'*t)^2);
Print "b3 :";
b3;

// Calculate b1
b1 =y_bar - b2*t_bar - b3*g_bar;
Print "b1 :";
b1;

// Full Model
// Estimate the model
print;
//call olsmt("", invest_data[., "Real Investment"], invest_data[., "Trend" "RealGNP" "Interest Rate" "Inflation Rate"]);
call olsmt(fname, "Real Investment ~ Trend + RealGNP + Interest Rate + Inflation Rate");
