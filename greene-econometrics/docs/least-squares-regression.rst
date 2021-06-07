Exercise 3.2.2 Application: An Investment Equation
====================================================
This application demonstrates how to apply least squares regression to a multivariate estimation
using macroeconomic data.

This application manually computes the least square estimates for the coefficients in the linear equation:
.. math:: \text{Real Investment} = b_1 + b_2*t + b_3*\text{Real GNP}

Getting Started
---------------------------------------------------
To run this example on your own you will need:
* The "Table 3.1-mod.csv" dataset
* The "least-squares-regression-investment.e" program file

How to
---------------------------------------------------

Step One: Loading data
++++++++++++++++++++++++++
To start, load the relevant variables from the dataset using the [`loadd`](https://docs.aptech.com/gauss/loadd.html) and a [`formula string`](https://www.aptech.com/resources/tutorials/loading-variables-from-a-file/).

To both replicate the Table 3.1 and compute the regression coefficients manually we will load the following variables:
* Constant
* Trend
* Real Investment
* Interest Rate
* Inflation Rate
* RealGNP


::

  // Load the relevant data
  // Filename
  fname = "data\\TableF3-1-mod.csv";

  // Load data
  invest_data = loadd(fname,
  "date(Year, %Y) + Real Investment + Constant + Trend + Real GDP + Interest Rate + Inflation Rate + RealGNP");

  // View data table
  invest_data;


::

  Year  Real Investment         Constant            Trend         Real GDP    Interest Rate   Inflation Rate          RealGNP
             1999        2.4840000        1.0000000        1.0000000        87.100000        9.2300000        3.4000000        87.100000
             2000        2.3110000        1.0000000        2.0000000        88.000000        6.9100000        1.6000000        88.000000
             2001        2.2650000        1.0000000        3.0000000        89.500000        4.6700000        2.4000000        89.500000
             2002        2.3390000        1.0000000        4.0000000        92.000000        4.1200000        1.9000000        92.000000
             2003        2.5560000        1.0000000        5.0000000        95.500000        4.3400000        3.3000000        95.500000
             2004        2.7500000        1.0000000        6.0000000        98.700000        6.1900000        3.4000000        98.700000
             2005        2.8280000        1.0000000        7.0000000        101.40000        7.9600000        2.5000000        101.40000
             2006        2.7170000        1.0000000        8.0000000        103.20000        8.0500000        4.1000000        103.20000
             2007        2.4450000        1.0000000        9.0000000        102.90000        5.0900000       0.10000000        102.90000
             2008        1.8780000        1.0000000        10.000000        100.00000        3.2500000        2.7000000        100.00000
             2009        2.0760000        1.0000000        11.000000        102.50000        3.2500000        1.5000000        102.50000
             2010        2.1680000        1.0000000        12.000000        104.20000        3.2500000        3.0000000        104.20000
             2011        2.3560000        1.0000000        13.000000        106.50000        3.2500000        1.7000000        105.60000
             2012        2.4820000        1.0000000        14.000000        108.10000        3.2500000        1.5000000        109.00000
             2013        2.6370000        1.0000000        15.000000        110.70000        3.2500000       0.80000000        111.60000


Step Two: Transforming data
++++++++++++++++++++++++++++++
The computations of multivariate coefficients require that we first compute the deviations of our variables from their means. This can be done in GAUSS using the [`meanc`](https://docs.aptech.com/gauss/meanc.html) procedure.

::

  // Calculate deviations from the mean
  y_little = invest_data[., "Real Investment"]- meanc(invest_data[., "Real Investment"]);
  t_little = invest_data[., "Trend"]- meanc(invest_data[., "Trend"]);
  g_little = invest_data[., "RealGNP"]- meanc(invest_data[., "RealGNP"]);


The results `y_little`, `t_little`, and `g_little` correspond to the in-text variables :math:y , :math:t, and :math:g, respectively.

Step Three: Computing coefficients
+++++++++++++++++++++++++++++++++++
The coefficients :math:b_2, and :math:b_3 are computed following Eq. 3-8:

.. math :: b_2 = \frac{\sum_i t_i y_i \sum_i g_i^2 - \sum_i g_i t_i \sum_i t_i g_i}{\sum_i t_i^2 \sum_i g_i^2 - (\sim_i g_i t_i)^2}

.. math :: b_3 = \frac{\sum_i g_i y_i \sum_i t_i^2 - \sum_i t_i y_i \sum_i t_i g_i}{\sum_i t_i^2 \sum_i g_i^2 - (\sim_i g_i t_i)^2}

The coefficient :math: b_1 is computed following Eq. 3-7:

.. math :: b_1 = \bar{Y} - b_2\bar{T} - b_3\bar{G}

::

  // Calculate b2
  b2 = ((t_little'*y_little)*(g_little'*g_little) - (g_little'*y_little)*(t_little'*g_little))/((t_little'*t_little)*(g_little'*g_little) - (g_little'*t_little)^2);
  Print "b2 :"; b2;

  // Calculate b3
  b3 = ((g_little'*y_little)*(t_little'*t_little) - (t_little'*y_little)*(t_little'*g_little))/((t_little'*t_little)*(g_little'*g_little) - (g_little'*t_little)^2);
  Print "b3 :"; b3;

  // // Calculate b1
  b1 = meanc(invest_data[., "Real Investment"]) - b2*meanc(invest_data[., "Trend"]) - b3*meanc(invest_data[., "Real GDP"]);
  Print "b1 :"; b1;

This prints the computed coefficients to the **Program Input/Output** window:

::

  b2 :
     -0.18002371
  b3 :
        0.10778411
  b1 :
        -6.8490543

Step Four: Estimating the full model
+++++++++++++++++++++++++++++++++++++
It is worth noting that though we just computed the coefficients manually, GAUSS has built-in procedures for least squares regression. For example, we will use [`olsmt`](https://docs.aptech.com/gauss/olsmt.html) to compute the full model:

.. math:: \text{Real Investment} = b_1 + \b_2*t + b_3*\text{Real GNP} + b_4 \text{Interest Rate} + b_5 \text{Inflation Rate}

::

  call olsmt(fname, "Real Investment ~ Trend + RealGNP + Interest Rate + Inflation Rate");

::


  Standard             Prob     Standardized    Cor with
  Variable           Estimate      Error        t-value     >|t|     Estimate    Dep Var
  -------------------------------------------------------------------------------------

  CONSTANT           -6.21967     1.93045    -3.22188     0.009       ---         ---
  Trend             -0.160885   0.0472355    -3.40603     0.007     -2.7478   -0.103635
  RealGNP           0.0990842    0.024132     4.10592     0.002     2.84769     0.14879
  Interest Rate     0.0201716   0.0336915    0.598714     0.563    0.160339    0.553021
  Inflation Rate   -0.0116592   0.0397682   -0.293179     0.775  -0.0486547    0.191923

Using internal GAUSS procedures, like `olsmt` greatly reduces time and effort for estimation.

.. note:: When calling `olsmt` we don't need to include the `Constant` variable. A constant is automatically included in the regression unless otherwise specified.


Exercise 31 Partial Correlations
===================================================
This example compares the least squares coefficients estimates with simple correlation and partial correlation.

Getting Started
---------------------------------------------------
To run this example on your own you will need:
* The "Table 3.1-mod.csv" dataset
* The "partial-correlations.e" program file

How to
---------------------------------------------------

Step One: Loading data
++++++++++++++++++++++++++
To start, load the relevant variables from the dataset using the [`loadd`](https://docs.aptech.com/gauss/loadd.html) and a [`formula string`](https://www.aptech.com/resources/tutorials/loading-variables-from-a-file/).

To both replicate the results in Table 3.2 we will load the following variables:
* Constant
* Trend
* Real Investment
* Interest Rate
* Inflation Rate
* RealGNP

Filter based on partial string match
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.
