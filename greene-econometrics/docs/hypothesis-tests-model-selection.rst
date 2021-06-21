Chapter 5: Hypothesis Tests and Model Selection
================================================
Example 5.1 An Investment Equation
-------------------------------------------
This example considers a linear regression model of painting auction prices such that:

.. math:: ln \text{Price} = \beta_1 + \beta_2 ln \text{Size} + \beta_3 \text{AspectRatio} + \epsilon

In particular, it considers whether *Size* is a statistically significant determinant of *Price*. This is done by testing the hypothesis:

.. math:: H_0: \beta_2 = 0
.. math:: H_1: \beta_2 \neq 0

If *Size* is a statistically significant determinant of *Price* than the null hypothesis that :math: `\beta_2 \eq 0` should be rejected.

Getting Started
++++++++++++++++++++++++++++++++
To run this example on your own you will need to install the GreeneLib package. This package houses all examples and associated data.

How to
++++++++++++++++++++++++++++++++

Step One: Loading data
^^^^^^^^^^^^^^^^^^^^^^^^^
To start, load the relevant variables from *Table 4.7* using :func:`loadd` and a `formula string <https://www.aptech.com/resources/tutorials/loading-variables-from-a-file/>`_.

::

  //Load data using loadd
  fname = getGAUSShome() $+ "pkgs/GreeneLib/examples/TableF4-1.csv";
  monet_data = loadd(fname, "HEIGHT+ ln(Price) + WIDTH");

The code above:
1.  Tranforms the raw data variable, *Price* into our dependent variable *ln(Price)*.
2.  The raw data variables *Height* and *Width* are loaded so we can create our dependent variables, *Aspect Ratio* and the *Size*.

Step Two: Create dependent variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Our dependent variables are created according to:

.. math::  \text{Aspect Ratio} = \frac{Width}{Height}
.. math:: \text{Size} = Width \times Height

In addition, we will use the function :func:`setColNames` to give our variables the correct names:

::

  // Compute aspect ratio
  aspect = setcolNames(monet_data[., "WIDTH"]./monet_data[., "HEIGHT"], "Aspect Ratio");

  // Compute size
  size = setcolNames(monet_data[., "WIDTH"].*monet_data[., "HEIGHT"], "Size");

Step Three: Estimate our linear model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Finally, we call :func:`olsmt` to run ordinary least squares estimation and store our results for later hypothesis testing.

::

  // Estimate ordinary least squares
  struct olsmtOut o_out;
  o_out = olsmt("", monet_data[., "ln_Price_"], ln(size)~aspect);


When we call :func:`olsmt` a complete set of results are printed to screen including:

*  Coefficient estimates.
*  The t-statistics testing the null hypothesis that the coefficient are equal to zero.
*  The p-values associated with the t-statistics.

::

                              Standard                 Prob   Standardized  Cor with
  Variable         Estimate      Error      t-value     >|t|     Estimate    Dep Var
  -----------------------------------------------------------------------------------
  CONSTANT         -8.34236    0.678203    -12.3007     0.000       ---         ---
  Size              1.31638   0.0920493     14.3009     0.000    0.573347    0.577572
  Aspect Ratio   -0.0962332     0.15784   -0.609689     0.542  -0.0244435   -0.123553

These results confirm that:

* The *Size* variable is statistically significant with a t-statistic equal to 14.3009.
* The *Aspect Ratio* variable is not statistically significant with a t-statistic equal to -0.61.  

Step Four: Additional testing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Following Greene, let's also test

.. math:: H_0: \beta_2 \leq 1
.. math:: H_1: \beta_2 > 0

::

  // Test hypothesis that beta_2 =< 1
  t_stat_1 = (o_out.b[2] - 1)/o_out.stderr[2];

The t-statistic testing that :math:`\beta_2 \leq 1` is 3.437.
