Chapter 2: Simple Linear Regression: Estimation of an Optimial Hedge Portfolio
================================================================================


Example 1: Estimate Univariate Regression of Spot on Futures
--------------------------------------------------------------

This example demonstrates how to compute ordinary least squares (OLS) estimates of the equation:

.. math:: \text{Spot} = \alpha + \beta_1\text{Futures}


Getting Started
++++++++++++++++++++++++++++++++++++++++++
To run this example on your own you will need to install the brooksecofinLib package. This package houses all examples and associated data.


How to
++++++++++++++++++++++++++++++++++++++++++

Step One: Loading data
^^^^^^^^^^^^^^^^^^^^^^^^^^^
To start, load the relevant variables from the dataset using :func:`loadd` and a `formula string <https://www.aptech.com/resources/tutorials/loading-variables-from-a-file/>`_.

To replicate this example, we will load the following variables:

* Date
* Spot
* Futures

Since we are using a CSV file for this data, the date variable will be in the form of a string. It would be very inefficient for GAUSS to check every string column to see if it is a date. So we surround the name of our date variable in ``date()`` so that GAUSS treats it as a date variable. 

Fortunately the date variable is in a standard date format, so GAUSS figures it out automatically. GAUSS allows you to specify any arbitrary date format in your formula string. You can read more about this in the Programmatic Data Import section of the GAUSS Data Management Guide.


::

    // Create file name with full path
    data_set = getGAUSSHome() $+ "pkgs/BrooksEcoFinLib/examples/Sandphedge.csv";


    // Use formula string to specify the variables to load and to tell
    // GAUSS that Date is a date variable
    data = loadd(data_set, "date(Date) + Spot + Futures");

    // Print the first 5 observations of all columns of our data
    print data[1:5,.];

::

            Date             Spot          Futures 
      1979-09-01        947.28003        954.50000
      1979-10-01        914.62000        924.00000
      1979-11-01        955.40002        955.00000
      1979-12-01        970.42999        979.25000
      1980-01-01        980.28003        987.75000


Step Two: Perform OLS estimation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We pass the dataframe, ``data`` and a formula string to  the :func:`olsmt` procedure to perform the estimation and print an output table. The :keyword:`call` keyword tells GAUSS to not return any data, so it just prints the report.

::

    // Perform OLS estimation and print report
    call olsmt(data, "Spot ~ Futures");


::

    Valid cases:                   247      Dependent variable:                Spot
    Missing cases:                   0      Deletion method:                   None
    Total SS:             47960127.957      Degrees of freedom:                 245
    R-squared:                   1.000      Rbar-squared:                     1.000
    Residual SS:             11692.797      Std error of est:                 6.908
    F(1,245):              1004666.955      Probability of F:                 0.000
    
                             Standard                 Prob   Standardized  Cor with
    Variable     Estimate      Error      t-value     >|t|     Estimate    Dep Var
    -------------------------------------------------------------------------------
    
    CONSTANT     -2.83784     1.48897     -1.9059     0.058       ---         ---   
    Futures       1.00161 0.000999277     1002.33     0.000    0.999878    0.999878 

