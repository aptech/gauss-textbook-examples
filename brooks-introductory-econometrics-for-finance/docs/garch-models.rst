Chapter 9: Modelling Volatility and Correlation
================================================

This chapter demonstrates GARCH modelling for financial time series, following Section 9.4-9.8 of the textbook. GARCH models capture the time-varying volatility (heteroskedasticity) commonly observed in financial returns.

.. Note:: This chapter requires the **TSMT** (Time Series MT) module in addition to base GAUSS.


Example 1: GARCH Modelling of S&P 500 Returns
----------------------------------------------

This example demonstrates volatility modelling using S&P 500 returns. We will:

* Examine return characteristics and volatility clustering
* Estimate a standard GARCH(1,1) model
* Test for asymmetric effects with GJR-GARCH
* Compare model specifications


Getting Started
++++++++++++++++++++++++++++++++++++++++++

To run this example you will need:

* The TSMT module installed
* The BrooksEconFinLib package with the example data


Step One: Load and examine the data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, we load the S&P 500 returns and examine their properties.

::

    // Load the TSMT library
    library tsmt;

    // Create file name with full path
    data_file = getGAUSSHome() $+ "pkgs/BrooksEcoFinLib/examples/macro.dta";

    // Load the data
    macro = loadd(data_file);

    // Extract S&P 500 returns
    rsandp = packr(macro[., "rsandp"]);

    print "S&P 500 Returns";
    print "===============";
    print "Observations: " rows(rsandp);
    print "Mean:         " meanc(rsandp);
    print "Std Dev:      " stdc(rsandp);
    print "Skewness:     " skewness(rsandp);
    print "Kurtosis:     " kurtosis(rsandp);

::

    S&P 500 Returns
    ===============
    Observations:    384
    Mean:            0.4892
    Std Dev:         4.3156
    Skewness:       -0.5234
    Kurtosis:        5.1247

The negative skewness and excess kurtosis (>3) are typical of financial returns and suggest the need for GARCH modelling.


Step Two: Visualize volatility clustering
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    // Plot returns to observe volatility clustering
    plotCanvasSize("px", 800|400);

    struct plotControl plt;
    plt = plotGetDefaults("xy");

    plotSetTitle(&plt, "S&P 500 Monthly Returns");
    plotSetYLabel(&plt, "Return (%)");

    plotXY(plt, seqa(1, 1, rows(rsandp)), rsandp);

The plot reveals **volatility clustering** - periods of high volatility tend to be followed by high volatility, and calm periods follow calm periods. This is the stylized fact that GARCH models are designed to capture.


Step Three: Estimate GARCH(1,1) model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The standard GARCH(1,1) model specifies:

* Mean equation: :math:`r_t = \mu + \epsilon_t`
* Variance equation: :math:`\sigma_t^2 = \omega + \alpha \epsilon_{t-1}^2 + \beta \sigma_{t-1}^2`

::

    // Estimate GARCH(1,1) model
    struct garchEstimation gOut;
    gOut = garchFit(rsandp, 1, 1);

::

    ================================================================================
    Model:                   GARCH(1,1)          Dependent variable:          rsandp
    Time Span:                  Unknown          Valid cases:                    384
    ================================================================================
                                 Coefficient            Upper CI            Lower CI

              beta0[1,1]             0.17179                   .                   .
              garch[1,1]             0.47948                   .                   .
               arch[1,1]             0.52052                   .                   .
              omega[1,1]             0.38387                   .                   .
    ================================================================================

                    AIC:                                                 -2268.72278
                    LRS:                                                 -2276.72278

The output shows:

* ``beta0`` - Mean return (constant in mean equation): 0.172%
* ``omega`` - Variance constant: 0.384
* ``arch`` - ARCH coefficient (α): 0.521 - impact of past shocks
* ``garch`` - GARCH coefficient (β): 0.479 - persistence of volatility

The sum α + β = 1.0 indicates high volatility persistence, close to an integrated GARCH (IGARCH) process.

::

    // Print model fit statistics
    print "Model Fit Statistics";
    print "====================";
    print "AIC: " gOut.aic;
    print "BIC: " gOut.bic;

::

    Model Fit Statistics
    ====================
    AIC:       -2268.7228
    BIC:       -2252.9306


Step Four: Test for asymmetric effects (GJR-GARCH)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Financial returns often exhibit **leverage effects** - negative shocks increase volatility more than positive shocks of equal magnitude. The GJR-GARCH model captures this asymmetry:

:math:`\sigma_t^2 = \omega + \alpha \epsilon_{t-1}^2 + \gamma \epsilon_{t-1}^2 I_{t-1} + \beta \sigma_{t-1}^2`

where :math:`I_{t-1} = 1` if :math:`\epsilon_{t-1} < 0`.

::

    // Estimate GJR-GARCH(1,1) model
    struct garchEstimation gOut_gjr;
    gOut_gjr = garchGJRFit(rsandp, 1, 1);

::

    ================================================================================
    Model:               GJR-GARCH(1,1)          Dependent variable:          rsandp
    Time Span:                  Unknown          Valid cases:                    384
    ================================================================================
                                 Coefficient            Upper CI            Lower CI

              beta0[1,1]             0.17545                   .                   .
              garch[1,1]             0.51382                   .                   .
               arch[1,1]             0.48618                   .                   .
                tau[1,1]             0.23224                   .                   .
              omega[1,1]             0.39008                   .                   .
    ================================================================================

                    AIC:                                                 -2222.98611
                    LRS:                                                 -2232.98611

The ``tau`` coefficient (0.232) represents the asymmetry effect. A positive tau confirms the leverage effect: negative returns lead to higher future volatility.


Step Five: Compare models
^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    // Model comparison
    print "Model Comparison";
    print "================";
    print "                      AIC           BIC";
    print "GARCH(1,1):     " gOut.aic "  " gOut.bic;
    print "GJR-GARCH(1,1): " gOut_gjr.aic "  " gOut_gjr.bic;

::

    Model Comparison
    ================
                          AIC           BIC
    GARCH(1,1):     -2268.7228    -2252.9306
    GJR-GARCH(1,1): -2222.9861    -2203.2459

Lower (more negative) AIC/BIC values indicate better fit. In this case, the standard GARCH(1,1) has slightly better information criteria, though the GJR model captures the economically meaningful leverage effect.


Example 2: GARCH-in-Mean for Risk Premium
------------------------------------------

The GARCH-M (GARCH-in-Mean) model includes conditional volatility in the mean equation, allowing us to test whether higher risk leads to higher expected returns:

:math:`r_t = \mu + \delta \sigma_t + \epsilon_t`

::

    // Estimate GARCH-M(1,1) model
    struct garchEstimation gOut_m;
    gOut_m = garchMFit(rsandp, 1, 1);

The ``delta`` parameter measures the risk-return tradeoff. A positive delta indicates that investors require higher returns for bearing more risk.


Example 3: Alternative Error Distributions
-------------------------------------------

Financial returns often have fat tails. TSMT supports Student's t distribution for more flexible tail behavior:

::

    // Create control structure for t-distribution
    struct garchControl gctl;
    gctl = garchControlCreate();

    // Set density = 1 for Student's t distribution
    gctl.density = 1;

    // Estimate GARCH(1,1) with t-distribution
    struct garchEstimation gOut_t;
    gOut_t = garchFit(rsandp, 1, 1, gctl);

The t-distribution adds a degrees of freedom parameter that captures excess kurtosis in the data.


Summary of GARCH Functions
---------------------------

TSMT provides the following GARCH estimation functions:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Function
     - Description
   * - :func:`garchFit`
     - Standard GARCH(p,q) model
   * - :func:`garchGJRFit`
     - GJR-GARCH with asymmetric effects
   * - :func:`garchMFit`
     - GARCH-in-Mean (volatility in mean equation)
   * - :func:`igarchFit`
     - Integrated GARCH (unit root in variance)
   * - :func:`garchControlCreate`
     - Create control structure for options


**Function reference**: :func:`garchFit`, :func:`garchGJRFit`, :func:`garchMFit`, :func:`igarchFit`

**Further reading**:

* `Modeling Volatility with GARCH in GAUSS <https://www.aptech.com/blog/modeling-volatility-with-garch/>`_
* `TSMT Documentation <https://docs.aptech.com/gauss/tsmt/index.html>`_
