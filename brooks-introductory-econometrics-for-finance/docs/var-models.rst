Chapter 7: Multivariate Models
===============================

This chapter demonstrates Vector Autoregressive (VAR) models following Chapter 7 of the textbook. VAR models capture dynamic interactions between multiple time series, essential for understanding macroeconomic relationships and financial market dynamics.

.. Note:: This chapter requires the **TSMT** (Time Series MT) module in addition to base GAUSS.


Example 1: VAR Model for Macro Variables
-----------------------------------------

This example estimates a VAR model for S&P 500 returns, inflation, and industrial production growth. We demonstrate:

* VAR model estimation
* Interpretation of coefficients
* Model diagnostics
* Forecasting


Getting Started
++++++++++++++++++++++++++++++++++++++++++

To run this example you will need:

* The TSMT module installed
* The BrooksEconFinLib package with the example data


Step One: Load and examine the data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    // Load the TSMT library
    library tsmt;

    // Create file name with full path
    data_file = getGAUSSHome() $+ "pkgs/BrooksEcoFinLib/examples/macro.dta";

    // Load the data
    macro = loadd(data_file);

    // Extract macro variables
    rsandp = packr(macro[., "rsandp"]);      // S&P 500 returns
    inflation = packr(macro[., "inflation"]); // Inflation rate
    dprod = packr(macro[., "dprod"]);         // Industrial production growth

    print "Macro Variables";
    print "===============";
    print "S&P Returns:      " rows(rsandp) " obs, mean = " meanc(rsandp);
    print "Inflation:        " rows(inflation) " obs, mean = " meanc(inflation);
    print "Ind. Production:  " rows(dprod) " obs, mean = " meanc(dprod);

::

    Macro Variables
    ===============
    S&P Returns:          384 obs, mean =     0.6257
    Inflation:            384 obs, mean =     0.2162
    Ind. Production:      384 obs, mean =     0.1302


Step Two: Estimate VAR model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The VAR(p) model for L variables:

:math:`y_t = c + A_1 y_{t-1} + A_2 y_{t-2} + ... + A_p y_{t-p} + \epsilon_t`

where :math:`y_t` is an Lx1 vector and each :math:`A_i` is an LxL coefficient matrix.

::

    // Combine variables into matrix
    y = rsandp ~ inflation ~ dprod;

    // Estimate VAR(2) model
    struct varmamtOut vmo;
    vmo = varmaFit(y, 2);

The ``varmaFit`` function produces detailed output:

::

    ================================================================================
    Model:                VARIMA(2,0,0)            Number of Eqs.:                 3
    Time Span:                  Unknown            Valid cases:                  384
    Log Likelihood:            1424.975            AIC:                     2801.950
                                                   SBC:                     2992.766
    ================================================================================
    Equation                      R-sq          DW           SSE          RMSE

    rsandp                      0.0557       2.0245     6829.6008        4.2173
    inflation                   0.2855       3.5346       28.2156        0.2711
    dprod                       0.1496       3.7455      100.9205        0.5127
    ================================================================================


Step Three: Interpret coefficients
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Each equation in the VAR shows how the variable depends on its own lags and lags of other variables:

::

    Results for equation rsandp
    ====================================================================
    Coefficient                 Estimate      Std. Err.     T-Ratio

    Constant                      0.2760            .            .
    rsandp L(1)                   0.0384        0.0505        0.760
    inflation L(1)                0.0087        0.0033        2.661
    dprod L(1)                    0.0097        0.0062        1.582
    rsandp L(2)                  -0.0736        0.0505       -1.458
    inflation L(2)                0.0001        0.0033        0.022
    dprod L(2)                    0.0200        0.0062        3.231
    ====================================================================

**Key findings:**

* Past inflation significantly affects S&P returns (inflation L(1): t=2.66)
* Industrial production growth predicts returns (dprod L(2): t=3.23)
* Stock returns show weak own-lag dependence

::

    Results for equation dprod
    ====================================================================
    Coefficient                 Estimate      Std. Err.     T-Ratio

    Constant                      0.0110            .            .
    rsandp L(1)                   1.1889        0.3892        3.055
    dprod L(1)                    0.1512        0.0490        3.084
    rsandp L(2)                   1.0502        0.3695        2.842
    ====================================================================

Stock returns strongly predict industrial production, consistent with the idea that financial markets are forward-looking indicators of economic activity.


Step Four: Model diagnostics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``varmaFit`` output includes comprehensive diagnostics:

**Unit root tests** verify stationarity of each variable:

::

    Augmented Dickey-Fuller Unit Root Tests
    ==================================================================
                   Variable      ADF Stat      CV 5%      Conclusion
    ==================================================================
    rsandp (Intercept)            -18.12      -2.86      Reject H0
    inflation (Intercept)          -4.23      -2.86      Reject H0
    dprod (Intercept)              -5.67      -2.86      Reject H0
    ==================================================================

All variables are stationary (reject unit root null).

**Multivariate goodness-of-fit test** (Portmanteau Q):

::

    Multivariate Goodness of Fit Test
    Lag          Qs     P-value
    ----------------------------
    3        43.6176      0.0000
    6        70.9501      0.0000
    12      109.5897      0.0000

Significant Q-statistics indicate some remaining autocorrelation, suggesting a higher lag order or different specification might improve the model.


Step Five: Forecasting
^^^^^^^^^^^^^^^^^^^^^^^^

Generate multi-step ahead forecasts:

::

    // Forecast 12 periods ahead
    // varmaPredict(vmo, y, x, t)
    // x = 0 for no exogenous variables

    fcst = varmaPredict(vmo, y, 0, 12);

    print "12-Period Forecast";
    print "==================";
    print "Period   rsandp   inflation   dprod";
    print fcst;

The forecasts incorporate the dynamic interactions estimated in the VAR.


Example 2: VAR with Two Variables
----------------------------------

A simpler bivariate VAR for interest rates:

::

    // Load data
    ustb3m = packr(macro[., "USTB3M"]);
    ustb10y = packr(macro[., "USTB10Y"]);

    // Combine for VAR
    rates = ustb3m ~ ustb10y;

    print "Bivariate VAR for Interest Rates";
    print "=================================";
    print "";

    // Estimate VAR(2)
    struct varmamtOut vmo2;
    vmo2 = varmaFit(rates, 2);

This produces the VAR estimates along with cointegration tests (covered in Chapter 8).


Lag Order Selection
--------------------

The optimal lag order can be selected using information criteria:

::

    // Estimate VAR with different lag orders
    print "Lag Order Selection";
    print "===================";
    print "Lags     AIC          SBC";

    struct varmamtOut v1, v2, v3, v4;

    v1 = varmaFit(y, 1);
    print "1    " v1.aic "    " v1.sbc;

    v2 = varmaFit(y, 2);
    print "2    " v2.aic "    " v2.sbc;

    v3 = varmaFit(y, 3);
    print "3    " v3.aic "    " v3.sbc;

    v4 = varmaFit(y, 4);
    print "4    " v4.aic "    " v4.sbc;

Select the model with the lowest AIC or SBC (BIC) value.


Summary of VAR Functions
-------------------------

TSMT provides the following VAR/VARMA functions:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Function
     - Description
   * - :func:`varmaFit`
     - Estimate VAR, VARMA, or VARMAX models
   * - :func:`varmaPredict`
     - Generate multi-step forecasts
   * - :func:`ecmFit`
     - Estimate Error Correction Models
   * - :func:`vmsjmt`
     - Johansen cointegration test
   * - :func:`vmrootsmt`
     - Check characteristic roots for stationarity


**Function reference**: :func:`varmaFit`, :func:`varmaPredict`, :func:`ecmFit`

**Further reading**:

* `VAR Models in GAUSS <https://www.aptech.com/blog/introduction-to-var-models/>`_
* `TSMT Documentation <https://docs.aptech.com/gauss/tsmt/index.html>`_
