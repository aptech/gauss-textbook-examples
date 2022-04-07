Chapter 5: Estimation and Hypothesis Testing of the Capital Asset Pricing Model
==================================================================================


Example 1: Estimate the CAPM Regression Equation
--------------------------------------------------

This example demonstrates how to estimate the model:

.. math:: (R_{Ford} - r_f)_t = \alpha + \beta(R_M - r_f)_t + u_t


Getting Started
++++++++++++++++++++++++++++++++++++++++++
To run this example on your own you will need to install the BrooksEconFinLib package. This package houses all examples and associated data.


How to
++++++++++++++++++++++++++++++++++++++++++

Step One: Loading data
^^^^^^^^^^^^^^^^^^^^^^^^^^^
To start, load the relevant variables from the dataset using :func:`loadd` and a `formula string <https://www.aptech.com/resources/tutorials/loading-variables-from-a-file/>`_.

To replicate this example, we will load the following variables:

* Date - Observation date.
* SandP - S&P 500 index.
* USTB3M - Three month T-bill yields. (Note that our data has already been converted to monthly).
* FORD - Stock prices.
* GE - Stock prices.
* MICROSOFT - Stock prices. 
* ORACLE - Stock prices.

::

    // Create file name with full path
    data_file = getGAUSSHome() $+ "pkgs/BrooksEcoFinLib/examples/capm.csv";

    // Load all variables from the CSV file
    data = loadd(data_file, "date(Date) + FORD + SandP + USTB3M");

    head(data);


::

            Date             FORD            SandP           USTB3M 
      2002-01-01        15.300000        1130.2000       0.14000000 
      2002-02-01        14.880000        1106.7300       0.14666667 
      2002-03-01        16.490000        1147.3900       0.15250000 
      2002-04-01        16.000000        1076.9200       0.14583333 
      2002-05-01        17.650000        1067.1400       0.14666667




Step Two: Transform data
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Our data transformation starts by defining a procedure to compute log returns and using that procedure to compute log returns of the ``SandP`` and ``FORD`` variables.o

Previous versions of our ``lnDiff`` procedure removed the missing observation from the first element of the return value. This time we keep the missing observation, because it is more convenient to assign then entire column than a partial column.

::

    // Create 2 4x1 column vectors
    x = { 1, 2, 3, 4 };
    y = { 1.1, 2.1, 3.1, 4.1 };

    // Copy over the entire column
    x[.,1] = y;

    // Create a 3x1 column vector
    z = { 2.2, 3.2, 4.2 };

    // Write over all but the first observation
    x[2:rows(x)] = z;



::

    // Define procedure to compute log returns
    proc (1) = lnDiff(x);
        local x_diff;
    
        // Compute log returns
        x_diff =  100 * ln(x ./ lagn(x, 1));
    
        retp(x_diff);
    endp;

    // Overwrite variables with their logged differences
    data[.,"SandP" "FORD"] = lnDiff(data[., "SandP" "FORD"]);

    head(data);

::

            Date             FORD            SandP           USTB3M 
      2002-01-01                .                .       0.14000000 
      2002-02-01       -2.7834799       -2.0984861       0.14666667 
      2002-03-01        10.273611        3.6080107       0.15250000 
      2002-04-01       -3.0165414       -6.3384655       0.14583333 
      2002-05-01        9.8147061      -0.91229691       0.14666667

::

    // Subtract 'USTB3M' from 'SandP' and 'FORD'
    er = data[.,"SandP" "FORD"] - data[.,"USTB3M"];

    // Change the names of the variables from 'SandP'
    // and 'FORD' to 'ersandp' and 'erford'
    er = dfname(er, "ersandp" $| "erford");

    // Add the variables in 'er' to the end of
    // 'data' using the horizontal concatenation
    // operator '~'
    data = data ~ er;

    head(data);


