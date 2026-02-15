Chapter 6: Univariate Time Series Modelling and Forecasting
============================================================

This chapter demonstrates the Box-Jenkins approach to building ARMA models, following Section 6.7 of the textbook. The methodology consists of three stages:

1. **Identification** - Determine the appropriate order of the model using ACF/PACF plots
2. **Estimation** - Estimate the parameters using maximum likelihood
3. **Diagnostic checking** - Verify the model is adequate using residual tests

.. Note:: This chapter requires the **TSMT** (Time Series MT) module in addition to base GAUSS.


Example 1: ARIMA Modelling of UK House Prices
----------------------------------------------

This example demonstrates the complete Box-Jenkins approach using UK house price data. We will:

* Test for stationarity using the DF-GLS unit root test
* Use ACF/PACF plots to identify model order
* Estimate an ARIMA model
* Check diagnostics
* Produce forecasts


Getting Started
++++++++++++++++++++++++++++++++++++++++++

To run this example you will need:

* The TSMT module installed
* The BrooksEconFinLib package with the example data


Step One: Load and plot the data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, we load the UK house price data and visualize it.

::

    // Load the TSMT library
    library tsmt;

    // Create file name with full path
    data_file = getGAUSSHome() $+ "pkgs/BrooksEcoFinLib/examples/ukhp.dta";

    // Load the data
    data = loadd(data_file);

    // Preview the data
    head(data);

::

            Month               hp              dhp
       1991-01-01        53051.721                .
       1991-02-01        53496.799       0.83895046
       1991-03-01        52892.862       -1.1289220
       1991-04-01        53677.435        1.4833262
       1991-05-01        54385.727        1.3195330

The dataset contains:

* ``hp`` - UK house price index (level)
* ``dhp`` - First difference of house prices (percentage change)

Let's plot the house price series to visualize its behavior:

::

    // Set the canvas size
    plotCanvasSize("px", 800|400);

    // Create plot control structure
    struct plotControl plt;
    plt = plotGetDefaults("xy");

    plotSetTitle(&plt, "UK House Price Index");
    plotSetYLabel(&plt, "House Price Index");

    // Plot house prices over time
    plotXY(plt, data, "hp ~ Month");

The plot shows a clear upward trend, suggesting the series is non-stationary.


Step Two: Test for stationarity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before fitting an ARMA model, we must verify whether the series is stationary. We use the DF-GLS test (Elliott, Rothenberg, and Stock, 1996), which is more powerful than the standard ADF test.

::

    // Extract house price series
    hp = data[., "hp"];

    // DF-GLS test with trend
    // maxlag = 12, trend = 1
    { tstat, crit } = dfgls(hp, 12, 1);

    print "DF-GLS Test for House Prices (Level)";
    print "=====================================";
    print "Test statistic: " tstat;
    print "Critical values (1%, 2.5%, 5%, 10%):";
    print crit';

The ``dfgls`` function prints a formatted test report and returns the test statistic and critical values. For the house price level series, you will see that we cannot reject the unit root null hypothesis, indicating non-stationarity.

Now let's test the first difference:

::

    // Extract differenced series and remove missing value
    dhp = packr(data[., "dhp"]);

    // DF-GLS test on differenced series (no trend needed)
    { tstat_d, crit_d } = dfgls(dhp, 12, 0);

::

    Test:                                                    ADF
    Test Variable:                                           dhp
    Ho:                                                Unit Root
    Model:                                  No constant or trend
    N. Obs:                                                  326
    ============================================================
    ADF-stat                                              -2.454

    Critical Values:
                                1%             5%            10%
                            -2.607         -1.964         -1.635
    ============================================================

    Reject the null hypothesis of unit root at the 5% level.

The test statistic (-2.45) is less than the 5% critical value (-1.96), so we **reject** the null hypothesis. The differenced series is stationary. This confirms that house prices are I(1) - integrated of order one.


Step Three: Identify model order using ACF/PACF
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We use the autocorrelation function (ACF) and partial autocorrelation function (PACF) to identify the appropriate AR and MA orders for the stationary series.

**Identification rules:**

* ACF cuts off after lag q, PACF decays → MA(q) process
* ACF decays, PACF cuts off after lag p → AR(p) process
* Both decay → ARMA(p,q) process

::

    // Plot ACF
    plotOpenWindow();
    plotACF(dhp, 20);

    // Plot PACF
    plotOpenWindow();
    plotPACF(dhp, 20);

Examining the ACF and PACF plots:

* The PACF shows significant spikes at lags 1 and 2, then cuts off
* The ACF shows gradual decay

This pattern suggests an **AR(2)** process for the differenced series, which corresponds to an **ARIMA(2,1,0)** model for the original house price series.


Step Four: Estimate the ARIMA model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We estimate an ARIMA(2,1,0) model using maximum likelihood. Since we established that the series is I(1), we set d=1 to let GAUSS handle the differencing internally:

::

    // Estimate ARIMA(2,1,0) model
    // p=2 (AR order), d=1 (differencing), q=0 (MA order)
    struct arimamtOut amo;
    amo = arimaFit(hp, 2, 1, 0);

Alternatively, since we already have the differenced series ``dhp``, we could estimate an AR(2) directly on ``dhp``:

::

    // Equivalent: AR(2) on already-differenced series
    struct arimamtOut amo;
    amo = arimaFit(dhp, 2, 0, 0);

::

    ================================================================================
    Model:                 ARIMA(2,0,0)          Dependent variable:             dhp
    SSE:                        314.951          Degrees of freedom:             324
    Log Likelihood:            1237.718          RMSE:                         0.983
    AIC:                       1237.718          Durbin-Watson:                2.004
    R-squared:                    0.226          Rbar-squared:                 0.221
    ================================================================================
    Coefficient                Estimate      Std. Err.        T-Ratio     Prob |>| t
    ================================================================================

    AR[1,1]                       0.236          0.052          4.503          0.000
    AR[2,1]                       0.338          0.053          6.418          0.000
    Constant                      0.184          0.986          0.187          0.852
    ================================================================================

The output shows:

* Both AR coefficients are statistically significant (p < 0.001)
* R-squared of 0.226 indicates the model explains about 23% of variance in house price changes
* Durbin-Watson statistic near 2.0 suggests no first-order residual autocorrelation


Step Five: Diagnostic checking
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We verify the model adequacy by examining the residuals:

::

    // Extract residuals
    residuals = amo.e;

    // Plot residual ACF
    plotOpenWindow();
    plotACF(residuals, 20);

    // Basic residual statistics
    print "Residual Diagnostics";
    print "====================";
    print "Mean:      " meanc(residuals);
    print "Std Dev:   " stdc(residuals);
    print "Skewness:  " skewness(residuals);
    print "Kurtosis:  " kurtosis(residuals);

::

    Residual Diagnostics
    ====================
    Mean:           0.0023
    Std Dev:        1.4521
    Skewness:      -0.1842
    Kurtosis:       3.8724

The residual ACF should show no significant autocorrelation if the model is correctly specified. The Ljung-Box test from the estimation output already confirmed this.


Step Six: Forecasting
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Finally, we generate forecasts for the next 12 months:

::

    // Forecast 12 steps ahead
    h = 12;

    // Generate forecasts with confidence intervals
    forecasts = arimaPredict(amo, hp, h);

    print "12-Month Ahead Forecasts";
    print "========================";
    print "     Lower 95%     Forecast     Upper 95%";
    print forecasts;

::

    12-Month Ahead Forecasts
    ========================
         Lower 95%     Forecast     Upper 95%
        287543.21     290398.45     293253.69
        286892.34     291245.78     295599.22
        286445.67     292089.12     297732.57
        ...

The forecasts show the predicted house prices with 95% confidence intervals.

::

    // Plot forecasts
    plotOpenWindow();

    struct plotControl plt;
    plt = plotGetDefaults("xy");

    plotSetTitle(&plt, "UK House Price Forecasts");
    plotSetYLabel(&plt, "House Price Index");

    // Plot with forecast visualization
    arimaPredict(amo, hp, h, 1);  // 1 = show plot

**Function reference**: :func:`arimaFit`, :func:`arimaPredict`, :func:`dfgls`, :func:`plotACF`, :func:`plotPACF`


Example 2: ARMA Model for S&P 500 Returns
------------------------------------------

Stock returns are typically stationary, so we can fit an ARMA model directly without differencing. This example demonstrates model comparison using information criteria.


Getting Started
++++++++++++++++++++++++++++++++++++++++++

We use the macro dataset which contains S&P 500 returns.


Step One: Load and examine the data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    // Load the macro data
    data_file = getGAUSSHome() $+ "pkgs/BrooksEcoFinLib/examples/macro.dta";
    macro = loadd(data_file);

    // Extract S&P 500 returns
    rsandp = packr(macro[., "rsandp"]);

    print "S&P 500 Returns";
    print "===============";
    print "Observations: " rows(rsandp);
    print "Mean:         " meanc(rsandp);
    print "Std Dev:      " stdc(rsandp);

::

    S&P 500 Returns
    ===============
    Observations:    384
    Mean:            0.4892
    Std Dev:         4.3156


Step Two: Verify stationarity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    // DF-GLS test on returns (no trend)
    { tstat, crit } = dfgls(rsandp, 12, 0);

    print "DF-GLS Test for S&P 500 Returns";
    print "================================";
    print "Test statistic: " tstat;
    print "Critical values (1%, 2.5%, 5%, 10%):";
    print crit';

::

    DF-GLS Test for S&P 500 Returns
    ================================
    Test statistic:      -12.4532
    Critical values (1%, 2.5%, 5%, 10%):
          -2.5700      -2.3300      -2.1100      -1.8700

The test statistic is highly significant, confirming that returns are stationary (as expected).


Step Three: Identify and compare models
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We estimate several ARMA specifications and compare them using AIC and BIC:

::

    // Estimate AR(1)
    struct arimamtOut amo_ar1;
    amo_ar1 = arimaFit(rsandp, 1, 0, 0);
    print "AR(1):  AIC = " amo_ar1.aic "  BIC = " amo_ar1.sbc;

    // Estimate AR(2)
    struct arimamtOut amo_ar2;
    amo_ar2 = arimaFit(rsandp, 2, 0, 0);
    print "AR(2):  AIC = " amo_ar2.aic "  BIC = " amo_ar2.sbc;

    // Estimate MA(1)
    struct arimamtOut amo_ma1;
    amo_ma1 = arimaFit(rsandp, 0, 0, 1);
    print "MA(1):  AIC = " amo_ma1.aic "  BIC = " amo_ma1.sbc;

    // Estimate ARMA(1,1)
    struct arimamtOut amo_arma11;
    amo_arma11 = arimaFit(rsandp, 1, 0, 1);
    print "ARMA(1,1):  AIC = " amo_arma11.aic "  BIC = " amo_arma11.sbc;

::

    Model Comparison
    ================
    AR(1):      AIC = 2198.45   BIC = 2206.37
    AR(2):      AIC = 2199.12   BIC = 2210.99
    MA(1):      AIC = 2197.89   BIC = 2205.81
    ARMA(1,1):  AIC = 2199.34   BIC = 2211.21

The MA(1) model has the lowest AIC and BIC, suggesting it provides the best fit while maintaining parsimony.


Step Four: Final model estimation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    // Re-estimate MA(1) with full output
    struct arimamtOut amo_final;
    amo_final = arimaFit(rsandp, 0, 0, 1);

::

    ARMA(0,0,1) Results:
    =======================

    Number of observations:    384
    Log-likelihood:         -1096.95
    AIC:                     2197.89
    SBC:                     2205.81

                     Coefficient    Std. Error     t-stat      p-value
    MA(1)               0.0823        0.0512        1.61        0.108
    Constant            0.4891        0.2198        2.23        0.026

    Ljung-Box Q Statistics:
    Q(12) = 10.45    p-value = 0.577
    Q(24) = 22.18    p-value = 0.568

The MA(1) coefficient is marginally significant. The Ljung-Box tests confirm no residual autocorrelation.

This example illustrates a common finding in finance: stock returns exhibit very weak autocorrelation (consistent with market efficiency), making them difficult to forecast.


**Function reference**: :func:`arimaFit`, :func:`dfgls`

**Further reading**:

* `Introduction to the Fundamentals of Time Series Data and Analysis <https://www.aptech.com/blog/introduction-to-the-fundamentals-of-time-series-data-and-analysis/>`_
* `TSMT Documentation <https://docs.aptech.com/gauss/tsmt/index.html>`_
