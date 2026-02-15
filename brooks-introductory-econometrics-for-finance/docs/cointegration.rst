Chapter 8: Modelling Long-Run Relationships in Finance
=======================================================

This chapter demonstrates cointegration analysis following Chapter 8 of the textbook. Cointegration captures long-run equilibrium relationships between non-stationary time series - a key concept for analysing asset prices, interest rates, and other financial variables.

.. Note:: This chapter requires the **TSMT** (Time Series MT) module in addition to base GAUSS.


Example 1: Cointegration of Interest Rates
-------------------------------------------

This example tests for cointegration between short-term and long-term interest rates (the term structure). We demonstrate:

* Unit root testing of individual series
* Engle-Granger two-step cointegration test
* Johansen cointegration test
* VAR model estimation with cointegration diagnostics


Getting Started
++++++++++++++++++++++++++++++++++++++++++

To run this example you will need:

* The TSMT module installed
* The BrooksEconFinLib package with the example data


Step One: Load and examine the data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We use U.S. Treasury yields: the 3-month T-Bill rate and 10-year Treasury bond rate.

::

    // Load the TSMT library
    library tsmt;

    // Create file name with full path
    data_file = getGAUSSHome() $+ "pkgs/BrooksEcoFinLib/examples/macro.dta";

    // Load the data
    macro = loadd(data_file);

    // Extract interest rate series
    ustb3m = packr(macro[., "USTB3M"]);
    ustb10y = packr(macro[., "USTB10Y"]);

    print "Interest Rate Data";
    print "==================";
    print "3-Month T-Bill mean:  " meanc(ustb3m);
    print "10-Year T-Bond mean:  " meanc(ustb10y);
    print "Observations:         " rows(ustb3m);

::

    Interest Rate Data
    ==================
    3-Month T-Bill mean:      3.2969
    10-Year T-Bond mean:      5.0754
    Observations:               385


Step Two: Test for unit roots
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before testing for cointegration, we must verify that each series is I(1) - integrated of order one. We use the ADF test.

::

    // DF-GLS test on 3-month rate
    print "DF-GLS Test for 3-Month T-Bill";
    print "==============================";
    { tstat3m, crit3m } = dfgls(ustb3m, 12, 0);

    // DF-GLS test on 10-year rate
    print "";
    print "DF-GLS Test for 10-Year T-Bond";
    print "==============================";
    { tstat10y, crit10y } = dfgls(ustb10y, 12, 0);

Both series should fail to reject the unit root null, indicating they are non-stationary in levels. However, their first differences should be stationary.


Step Three: Engle-Granger cointegration test
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Engle-Granger two-step method:

1. Estimate the cointegrating regression: :math:`y_t = \alpha + \beta x_t + u_t`
2. Test the residuals for stationarity using ADF

If the residuals are stationary, the series are cointegrated.

::

    // Engle-Granger cointegration test
    // vmcadfmt(y, x, p, l)
    // y = dependent variable (10-year rate)
    // x = explanatory variable (3-month rate)
    // p = 0 (include constant)
    // l = 4 (number of lagged differences)

    print "Engle-Granger Cointegration Test";
    print "=================================";

    { alpha, tstat, crit } = vmcadfmt(ustb10y, ustb3m, 0, 4);

    print "";
    print "ADF test on cointegrating residuals";
    print "Alpha (autoregressive parameter): " alpha;
    print "t-statistic:                      " tstat;
    print "";
    print "Critical values (1%, 5%, 10%):";
    print crit[1:3]';

::

    Engle-Granger Cointegration Test
    =================================

    ADF test on cointegrating residuals
    Alpha (autoregressive parameter):    0.9638
    t-statistic:                        -3.0084

    Critical values (1%, 5%, 10%):
          -3.9024       -3.3271       -3.0372

The t-statistic (-3.01) is compared to special critical values for cointegrating regressions (not standard ADF critical values). Here, the test is marginally significant at the 10% level.


Step Four: Johansen cointegration test
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Johansen procedure uses a VAR framework to test for multiple cointegrating relationships simultaneously.

::

    // Combine series into matrix
    y = ustb3m ~ ustb10y;

    // Johansen test
    // vmsjmt(x, p, k, nodet)
    // x = data matrix
    // p = 0 (constant in cointegrating equation)
    // k = 2 (number of lags)
    // nodet = 0 (include constant)

    print "Johansen Cointegration Test";
    print "===========================";

    { ev, evec, lr1, lr2 } = vmsjmt(y, 0, 2, 0);

    print "";
    print "Eigenvalues:";
    print ev';
    print "";
    print "Trace Statistics:";
    print "H0: r=0  " lr1[1];
    print "H0: r<=1 " lr1[2];
    print "";
    print "Maximum Eigenvalue Statistics:";
    print "H0: r=0  " lr2[1];
    print "H0: r<=1 " lr2[2];

::

    Johansen Cointegration Test
    ===========================

    Eigenvalues:
         0.02429        0.00476

    Trace Statistics:
    H0: r=0     11.2150
    H0: r<=1     1.8221

    Maximum Eigenvalue Statistics:
    H0: r=0      9.3929
    H0: r<=1     1.8221

The trace statistic tests the null hypothesis of at most r cointegrating vectors. Compare to critical values to determine the cointegration rank.


Step Five: VAR model with cointegration diagnostics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``varmaFit`` function provides comprehensive cointegration testing as part of VAR estimation:

::

    // Estimate VAR(2) model
    struct varmamtOut vmo;
    vmo = varmaFit(y, 2);

This produces extensive output including:

* VAR coefficient estimates
* ADF and Phillips-Perron unit root tests
* ADF cointegration test
* Johansen trace and maximum eigenvalue statistics
* Characteristic roots for stationarity checking
* Multivariate ACF and goodness-of-fit tests

::

    ================================================================================
    Model:                VARIMA(2,0,0)            Number of Eqs.:                 2
    Time Span:                  Unknown            Valid cases:                  385
    Log Likelihood:            -162.921            AIC:                     -347.842
                                                   SBC:                     -260.356
    ================================================================================

    Johansen's Trace and Maximum Eigenvalue Statistics
                                   r    Trace    Max. Eig
       Intercept                   0   11.2150    9.3929
                                   1    1.8221    1.8221


Interpreting Results
+++++++++++++++++++++

**Cointegration evidence:**

The Engle-Granger and Johansen tests provide marginal evidence for cointegration between the two interest rates. This is consistent with economic theory - the term structure suggests long-term and short-term rates should move together in the long run, with deviations representing the term premium.

**Economic interpretation:**

If rates are cointegrated, short-run deviations from the long-run relationship are temporary and the spread between rates is mean-reverting. This has implications for:

* Fixed income portfolio management
* Interest rate forecasting
* Monetary policy transmission


Example 2: Error Correction Model
----------------------------------

When series are cointegrated, we can estimate an Error Correction Model (ECM) that captures both short-run dynamics and long-run equilibrium adjustment.

The ECM specification:

:math:`\Delta y_t = \alpha(y_{t-1} - \beta x_{t-1}) + \gamma \Delta x_t + \epsilon_t`

where :math:`(y_{t-1} - \beta x_{t-1})` is the error correction term representing deviation from long-run equilibrium.

::

    // VAR in differences with error correction
    // First, get the cointegrating residuals
    b = ustb3m / ustb10y;  // OLS coefficient
    ecm_term = ustb10y - b .* ustb3m;  // Error correction term

    // The error correction term should be stationary
    print "Testing stationarity of error correction term:";
    { tstat_ecm, crit_ecm } = dfgls(ecm_term, 12, 0);


Summary of Cointegration Functions
-----------------------------------

TSMT provides the following cointegration-related functions:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Function
     - Description
   * - :func:`vmsjmt`
     - Johansen trace and maximum eigenvalue tests
   * - :func:`vmcadfmt`
     - Engle-Granger ADF test on cointegrating residuals
   * - :func:`vmppmt`
     - Phillips-Perron unit root test
   * - :func:`varmaFit`
     - VAR/VARMA estimation with cointegration diagnostics
   * - :func:`vmc_sjtmt`
     - Johansen trace statistic critical values
   * - :func:`vmc_sjamt`
     - Johansen max eigenvalue critical values


**Function reference**: :func:`vmsjmt`, :func:`vmcadfmt`, :func:`varmaFit`, :func:`dfgls`

**Further reading**:

* `Cointegration Analysis in GAUSS <https://www.aptech.com/blog/introduction-to-cointegration-analysis/>`_
* `TSMT Documentation <https://docs.aptech.com/gauss/tsmt/index.html>`_
