Chapter 2: Simple Linear Regression: Estimation of an Optimial Hedge Portfolio
================================================================================


Example 1: Estimate Univariate Regression of Spot on Futures
--------------------------------------------------------------

This example demonstrates how to compute ordinary least squares (OLS) estimates of the equation:

.. math:: \text{Spot} = \alpha + \beta_1\text{Futures} + \epsilon


Getting Started
++++++++++++++++++++++++++++++++++++++++++
To run this example on your own you will need to install the BrooksEconFinLib package. This package houses all examples and associated data.


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


Example 2: Estimate Univariate Regression Spot and Futures Returns
--------------------------------------------------------------------

This example demonstrates how to transform the variables into logarithmic returns and estimate the equation:

.. math:: \text{Ret_Spot} = \alpha + \beta_1\text{Ret_Futures} + \epsilon


Getting Started
++++++++++++++++++++++++++++++++++++++++++
To run this example on your own you will need to follow the data loading steps from the above example.


How to
++++++++++++++++++++++++++++++++++++++++++

Step One: Compute log returns
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Our first step is to define the procedure we will use to compute the log returns and apply it to our data. Our blog, `The Basics of GAUSS Procedures <https://www.aptech.com/blog/basics-of-gauss-procedures/>`_ explains everything you need to know to understand this procedure.

::

     // Define procedure to compute log returns
     proc (1) = lnDiff(x);
         local x_diff;
    
         // Compute log returns
         x_diff =  100 * ln(x ./ lagn(x, 1));

         // Remove all rows with missing values
         x_diff = packr(x_diff);
    
         retp(x_diff);
     endp;

    // Create new dataframe that contains the log difference of our variables
    ret_data = lnDiff(data[., "Spot" "Futures"]);


Step Two: Change variable names 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We could have combined this with the previous step, but we will do each step separately for clarity. 

::

    // Create a 2x1 string array using the string concatenation operator
    names = "ret_spot" $| "ret_futures"; 

    // Set variable names 
    ret_data = setcolnames(ret_data, names); 



Step Three: Compute descriptive statistics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We can compute descriptive statistics on our new dataframe with the :func:`dstatmt` procedure as shown below.

::

    // Compute descriptive statistics and print them
    call dstatmt(ret_data);

will print the following:

::

    --------------------------------------------------------------------------------------------
    Variable            Mean     Std Dev      Variance     Minimum     Maximum     Valid Missing
    --------------------------------------------------------------------------------------------
    
    ret_spot          0.4168       4.333         18.78      -18.56       10.23       246    0 
    ret_futures        0.414       4.419         19.53      -18.94       10.39       246    0 


Step Four: Estimate linear model on return data 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Finally, we regress ``ret_spot`` on ``ret_futures``.

::

    // Estimate the linear model and print the results
    call olsmt(ret_data, "ret_spot ~ ret_futures");

will print the following:

::

    Valid cases:                   246      Dependent variable:            ret_spot
    Missing cases:                   0      Deletion method:                   None
    Total SS:                 4600.534      Degrees of freedom:                 244
    R-squared:                   0.989      Rbar-squared:                     0.989
    Residual SS:                51.684      Std error of est:                 0.460
    F(1,244):                21474.923      Probability of F:                 0.000
    
                                Standard                 Prob   Standardized  Cor with
    Variable        Estimate      Error      t-value     >|t|     Estimate    Dep Var
    ----------------------------------------------------------------------------------
    
    CONSTANT       0.0130773   0.0294729    0.443707     0.658       ---         ---   
    ret_futures     0.975077  0.00665385     146.543     0.000    0.994367    0.994367 

