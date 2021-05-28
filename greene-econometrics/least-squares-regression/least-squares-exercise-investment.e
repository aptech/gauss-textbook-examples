/* 
** This follows example 3.6 on page 41 
** of Greene, Econometric Analysis
*/

// Load the relevant data
invest_data = loadd(__FILE_DIR $+ "TableF3-1-mod.csv", "date($Year, '%Y') + Real Investment + Constant + Trend + Real GDP + Interest Rate + Inflation Rate + RealGNP");

// View data table
invest_data;

// Calculate deviations from the mean
y_little = invest_data[., "Real Investment"]- meanc(invest_data[., "Real Investment"]);
t_little = invest_data[., "Trend"]- meanc(invest_data[., "Trend"]);
g_little = invest_data[., "RealGNP"]- meanc(invest_data[., "RealGNP"]);

// Calculate b2
b2 = ((t_little'*y_little)*(g_little'*g_little) - (g_little'*y_little)*(t_little'*g_little))/((t_little'*t_little)*(g_little'*g_little) - (g_little'*t_little)^2);
Print "b2 :"; b2;

// Calculate b3
b3 = ((g_little'*y_little)*(t_little'*t_little) - (t_little'*y_little)*(t_little'*g_little))/((t_little'*t_little)*(g_little'*g_little) - (g_little'*t_little)^2);
Print "b3 :"; b3;

// Calculate b1
b1 = meanc(invest_data[., "Real Investment"]) - b2*meanc(invest_data[., "Trend"]) - b3*meanc(invest_data[., "Real GDP"]);
Print "b1 :"; b1;

// Full Model
// Estimate the model
print;
call olsmt("", invest_data[., "Real Investment"], invest_data[., "Trend" "RealGNP" "Interest Rate" "Inflation Rate"]);

