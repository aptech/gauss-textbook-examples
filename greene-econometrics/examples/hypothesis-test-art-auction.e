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

/*
** Create regression variables
*/

// Compute aspect ratio
aspect = monet_data[., "WIDTH"] ./ monet_data[., "HEIGHT"];

// Compute ln(size)
size = monet_data[., "WIDTH"] .* monet_data[., "HEIGHT"];

/*
** Change assigned variable names, `width`, 
** to match variables
*/
aspect = setColNames(aspect, "Aspect Ratio");
size = setColNames(size, "Size");

// Create regression data
reg_data = monet_data[., "ln_Price_"] ~ size ~ aspect;

/*
** Calling olsmt
** Note that the print out includes
** coefficients along with the t-stats
** which test the hypothesis that 
** the coefficients equal zero
*/
struct olsmtOut o_out;
o_out = olsmt(reg_data, "ln_Price_ ~ ln(Size) + Aspect Ratio");

// Test hypothesis that beta_2 =< 1
print;
t_stat_1 = (o_out.b[2] - 1) / o_out.stderr[2];
print "Testing that Beta2 less than or equal to 1: "; t_stat_1;
