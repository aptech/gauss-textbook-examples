/*
** This follows example 5.1 on page 121
** of Greene, Econometric Analysis
*/

/*
** Load data using loadd
*/
load_dir = getGAUSSHome $+ "pkgs/greeneLib/examples/";
fname = load_dir $+ "TableF4-1.csv";
monet_data = loadd(fname, "HEIGHT + ln(Price) + WIDTH");

// Compute aspect ratio
aspect = setcolNames(monet_data[., "WIDTH"]./monet_data[., "HEIGHT"], "Aspect Ratio");

// Compute size
size = setcolNames(monet_data[., "WIDTH"].*monet_data[., "HEIGHT"], "Size");

/*
** Calling olsmt
** Note that the print out includes
** coefficients along with the t-stats
** which test the hypothesis that 
** the coefficients equal zero
*/
struct olsmtOut o_out;
o_out = olsmt("", monet_data[., "ln_Price_"], ln(size)~aspect);

// Test hypothesis that beta_2 =< 1
print;
t_stat_1 = (o_out.b[2] - 1)/o_out.stderr[2];
print "Testing that Beta2 less than or equal to 1: "; t_stat_1;
