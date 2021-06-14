Application 3.2.2 An Investment Equation
====================================================
This example demonstrates how to manually compute least squares estimates from the multivariate macroeconomic linear equation:

.. math:: \text{Real Investment} = b_1 + b_2t + b_3\text{Real GNP}

Getting Started
---------------------------------------------------
To run this example on your own you will need:

* The "Table 3.1-mod.csv" dataset
* The "least-squares-regression-investment.e" program file

How to
---------------------------------------------------

Step One: Loading data
++++++++++++++++++++++++++
To start, load the relevant variables from the dataset using :func:`loadd` and a `formula string <https://www.aptech.com/resources/tutorials/loading-variables-from-a-file/>`_.

To replicate Table 3.1 and compute the regression coefficients manually we will load the following variables:

* Constant
* Trend
* Real Investment
* Interest Rate
* Inflation Rate
* RealGNP


::

  // Load the relevant data
  // Filename
  fname = "data/TableF3-1-mod.csv";

  // Load data
  invest_data = loadd(fname,
  "date(Year, %Y) + Real Investment + Constant + Trend + Real GDP + Interest Rate + Inflation Rate + RealGNP");

  // View data table
  invest_data;


::

             Year         Real      Constant  Trend      Real      Interest    Inflation      Real
                       Investment                        GDP         Rate        Rate         GNP
             1999        2.484        1        1         87.1        9.23        3.40         87.1
             2000        2.311        1        2         88.0        6.91        1.60         88.0
             2001        2.265        1        3         89.5        4.67        2.40         89.5
             2002        2.339        1        4         92.0        4.12        1.90         92.0
             2003        2.556        1        5         95.5        4.34        3.30         95.5
             2004        2.750        1        6         98.7        6.19        3.40         98.7
             2005        2.828        1        7        101.4        7.96        2.50        101.4
             2006        2.717        1        8        103.2        8.05        4.10        103.2
             2007        2.445        1        9        102.9        5.09        0.10        102.9
             2008        1.878        1        10       100.0        3.25        2.70        100.0
             2009        2.076        1        11       102.5        3.25        1.50        102.5
             2010        2.168        1        12       104.2        3.25        3.00        104.2
             2011        2.356        1        13       106.5        3.25        1.70        105.6
             2012        2.482        1        14       108.1        3.25        1.50        109.0
             2013        2.637        1        15       110.7        3.25        0.80        111.6


Step Two: Transforming data
++++++++++++++++++++++++++++++
The computations of multivariate coefficients require that we first compute the deviations of our variables from their means. This can be done in GAUSS using the :func:`meanc` procedure.

::

  // Calculate means
  y_bar = meanc(invest_data[., "Real Investment"]);
  t_bar = meanc(invest_data[., "Trend"]);
  g_bar =  meanc(invest_data[., "RealGNP"];


  // Calculate deviations from the mean
  y = invest_data[., "Real Investment"]- y_bar;
  t = invest_data[., "Trend"]- t_bar;
  g = invest_data[., "RealGNP"]- g_bar);

The results *y*, *t*, and *g* correspond to the in-text variables :math:`y` , :math:`t`, and :math:`g`, respectively.

Step Three: Computing coefficients
+++++++++++++++++++++++++++++++++++
The coefficients :math:`b_2`, and :math:`b_3` are computed following Eq. 3-8:

.. math:: b_2 = \frac{\sum_i t_i y_i \sum_i g_i^2 - \sum_i g_i y_i \sum_i t_i g_i}{\sum_i t_i^2 \sum_i g_i^2 - (\sum_i g_i t_i)^2}

.. math:: b_3 = \frac{\sum_i g_i y_i \sum_i t_i^2 - \sum_i t_i y_i \sum_i t_i g_i}{\sum_i t_i^2 \sum_i g_i^2 - (\sum_i g_i t_i)^2}

::

  // Calculate b2
  b2 = ((t'*y)*(g'*g) - (g'*y)*(t'*g))/((t'*t)*(g'*g) - (g'*t)^2);
  Print "b2 :"; b2;

  // Calculate b3
  b3 = ((g'*y)*(t'*t) - (t'*y)*(t*g))/((t'*t)*(g'*g) - (g'*t)^2);
  Print "b3 :"; b3;


Once :math:`b_2`, and :math:`b_3` are calculated, when can compute :math:`b_1` following Eq. 3-7:

.. math:: b_1 = \bar{Y} - b_2 \bar{T} - b_3 \bar{G}

::

  // Calculate b1
  b1 =y_bar - b2*t_bar - b3*g_bar;
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
It is worth noting that though we just computed the coefficients manually, GAUSS has built-in procedures for least squares regression. For example, we will use :func:`olsmt` to compute the full model:

.. math:: \text{Real Investment} = b_1 + b_2t + b_3\text{Real GNP} + b_4\text{Interest Rate} + b_5\text{Inflation Rate}

::

  call olsmt(fname, "Real Investment ~ Trend + RealGNP + Interest Rate + Inflation Rate");

::


                                   Standard                     Prob     Standardized     Cor with
  Variable             Estimate      Error        t-value       >|t|       Estimate        Dep Var
  -------------------------------------------------------------------------------------------------
  CONSTANT            -6.21967      1.93045      -3.22188      0.009         ---              ---
  Trend              -0.160885    0.0472355      -3.40603      0.007       -2.7478        -0.103635
  RealGNP            0.0990842     0.024132       4.10592      0.002       2.84769          0.14879
  Interest Rate      0.0201716    0.0336915      0.598714      0.563      0.160339         0.553021
  Inflation Rate    -0.0116592    0.0397682     -0.293179      0.775    -0.0486547         0.191923

Using internal GAUSS procedures, like :func:`olsmt` greatly reduces time and effort for estimation.

.. note:: When calling :func:`olsmt` we don't need to include the *Constant* variable. A constant is automatically included in the regression unless otherwise specified.


Exercise 3.1 Partial Correlations
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
To start, load the relevant variables from the dataset using :func:`loadd` and a `formula string <https://www.aptech.com/resources/tutorials/loading-variables-from-a-file/>`_.

To replicate the results in Table 3.2 we will load the following variables:

* Constant
* Trend
* Real Investment
* Interest Rate
* Inflation Rate
* RealGNP

::

  // Filename
  fname = "data\\TableF3-1-mod.csv";

  // Load data
  invest_data = loadd(fname, "date(Year, %Y) + Real Investment + Constant + Trend + Real GDP + Interest Rate + Inflation Rate + RealGNP");


Step Two: Estimate least squares regression
+++++++++++++++++++++++++++++++++++++++++++
Next, we estimate the OLS and store the results using :func:`olsmt`. We will use the stored coefficients and standard errors for computing the partial correlations.

.. math:: \text{Real Investment} = b_1 + b_2 t + b_3 \text{Real GNP} + b_4 \text{Interest Rate} + b_5 \text{Inflation Rate}

::

    // Estimate linear model using
    // least squares and store
    // results
    struct olsmtOut o_Out;
    o_Out = olsmt(fname, "Real Investment ~ Trend + RealGNP + Interest Rate + Inflation Rate");

::


                                     Standard                     Prob     Standardized     Cor with
    Variable             Estimate      Error        t-value       >|t|       Estimate        Dep Var
    -------------------------------------------------------------------------------------------------
    CONSTANT            -6.21967      1.93045      -3.22188      0.009         ---              ---
    Trend              -0.160885    0.0472355      -3.40603      0.007       -2.7478        -0.103635
    RealGNP            0.0990842     0.024132       4.10592      0.002       2.84769          0.14879
    Interest Rate      0.0201716    0.0336915      0.598714      0.563      0.160339         0.553021
    Inflation Rate    -0.0116592    0.0397682     -0.293179      0.775    -0.0486547         0.191923

Step Three: Extract the simple correlations
++++++++++++++++++++++++++++++++++++++++++++++
Note that the printed output table includes the correlations between the independent variables and the dependent variables. These are stored in the *olsmtOut* structure in the *oOut.cx* member. Let's extract these to include in our comparison table:

::

    /*
    ** The simple correlations
    ** between the dependent and
    ** independent variables are
    ** computed and stored when
    ** olsmt is called
    */
    simple_cor = o_oOut.cx[1:4, cols(oOut.cx)];


Step Four: Compute the partial correlations
++++++++++++++++++++++++++++++++++++++++++++++
To compute the partial correlations we need to :

*  Compute the t ratios for the variables using the stored estimates and standard errors.
*  Calculate the partial correlations using Eq. 3-22
*  Setting the signs of the partial correlations to be the same as the estimates.

::

    /*
    ** Calculate the partial
    ** correlations using equation 3-22
    */

    // Find t ratio using olsmt results
    t_stats = o_Out.b./o_Out.stderr;

    // Calculate partial correlations using equation 3-22
    df = 10;
    p_cor = sqrt((t_stats.^2)./(t_stats.^2 + df));


::


                                  Coeff.              t ratio         Simple Corr.        Partial Corr.

             Trend             -0.16089                -3.41             -0.10363            -0.73284
           RealGDP              0.09908                 4.11              0.14879             0.79226
          Interest              0.02017                 0.60              0.55302             0.18603
         Inflation             -0.01166                -0.29              0.19192            -0.09232
