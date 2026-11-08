Chapter 9: Modelling Volatility and Correlation
================================================

This chapter demonstrates GARCH modelling for financial time series, following Section 9.4-9.8 of the textbook. GARCH models capture the time-varying volatility (heteroskedasticity) commonly observed in financial returns.

.. Note:: Examples 1 and 2 use the **GAUSS Time Series** package (``library timeseries``). Example 3, GARCH-in-mean, uses **TSMT 4.1** (``library tsmt``); GARCH-in-mean is planned for a later 27.x release of the Time Series package. Load only one of the two libraries in a program.


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

* The GAUSS Time Series package installed
* The example files for this book: the programs in the ``examples`` folder
  and the data in the ``raw data`` folder next to it


Step One: Load and examine the data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, we load the S&P 500 returns and examine their properties. The program
``garch-models-1.gss`` in the ``examples`` folder loads ``macro.dta`` from the
``raw data`` folder next to it.

::

    // Load the Time Series library
    library timeseries;

    // Create path to data folder
    data_file = __FILE_DIR $+ "../raw data/macro.dta";

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
    Observations:        384.00000
    Mean:               0.62573404
    Std Dev:             4.3456198
    Skewness:           -1.0866108
    Kurtosis:            6.7974146

The negative skewness and the kurtosis above 3 (the value for normal data) are typical of financial returns and suggest the need for GARCH modelling.


Step Two: Visualize volatility clustering
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    // Plot returns to observe volatility clustering
    plotCanvasSize("px", 800|400);

    struct plotControl plt;
    plt = plotGetDefaults("xy");

    plotSetTitle(&plt, "S&P 500 Monthly Returns");
    plotSetYLabel(&plt, "Return (%)");

    plotXY(plt, 1:rows(rsandp), rsandp);

The plot reveals **volatility clustering** - periods of high volatility tend to be followed by high volatility, and calm periods follow calm periods. This is the stylized fact that GARCH models are designed to capture.


Step Three: Estimate GARCH(1,1) model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The standard GARCH(1,1) model specifies:

* Mean equation: :math:`r_t = \mu + \epsilon_t`
* Variance equation: :math:`\sigma_t^2 = \omega + \alpha \epsilon_{t-1}^2 + \beta \sigma_{t-1}^2`

::

    // GARCH(1,1) with a constant mean and normal errors
    struct garchResult fit;
    fit = garchFit(rsandp, garch=1, arch=1);

::

    ================================================================================
    GARCH Family Model Results
    ================================================================================
    Model:        GARCH(1,0,1)
    Mean model:   constant_mean
    Distribution: normal
    Observations: 384
    Log likelihood: -1082.37
    AIC: 2172.73    BIC: 2188.53

    Parameters on the original data scale

           Parameter         Estimate       SE_Hessian        SE_Robust  P_Robust_Normal Lower_95_Robust_ Upper_95_Robust_
                  mu       0.70834295       0.17387220       0.19845631    0.00035798558       0.31937573        1.0973102
               omega       0.43906879       0.25996876       0.32180387       0.17244211      -0.19165521        1.0697928
              alpha1       0.15715141      0.041347879      0.047451099    0.00092677791      0.064148969       0.25015386
               beta1       0.83642249      0.033150573      0.043326295    4.8573259e-83       0.75150452       0.92134047
    Inference: available; Hessian and unadjusted score sandwich; robust normal p-values and limits
    Initialization: sample_variance_presample
    P-values and limits: robust asymptotic normal, level=0.95

    Optimizer: lbfgsb_tight_repolish; projected_gradient_at_or_below_pgtol
    Iterations: 6; function evaluations: 8
    Projected-gradient norm: 5.06925e-05 (requested 0.0001)
    Persistence: 0.993574 (admissible)

The output shows:

* ``mu`` - Mean monthly return (constant in the mean equation): 0.708%
* ``omega`` - Variance constant: 0.439
* ``alpha1`` - ARCH coefficient (α): 0.157 - impact of last month's shock
* ``beta1`` - GARCH coefficient (β): 0.836 - persistence of volatility

The table gives two standard errors for each parameter, from the Hessian and robust; the p-values and the 95% limits use the robust ones. The persistence α + β = 0.994 is close to 1: volatility shocks die out very slowly, close to an integrated GARCH (IGARCH) process.


Step Four: Test for asymmetric effects (GJR-GARCH)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Financial returns often exhibit **leverage effects** - negative shocks increase volatility more than positive shocks of equal magnitude. The GJR-GARCH model captures this asymmetry:

:math:`\sigma_t^2 = \omega + \alpha \epsilon_{t-1}^2 + \gamma \epsilon_{t-1}^2 I_{t-1} + \beta \sigma_{t-1}^2`

where :math:`I_{t-1} = 1` if :math:`\epsilon_{t-1} < 0`.

::

    // GJR-GARCH(1,1): adds a term for negative shocks
    struct garchResult fit_gjr;
    fit_gjr = garchFit(rsandp, garch=1, arch=1, model="gjr");

The parameter table adds ``gamma1``:

::

           Parameter         Estimate       SE_Hessian        SE_Robust  P_Robust_Normal Lower_95_Robust_ Upper_95_Robust_
                  mu       0.71127868       0.18366474       0.17665547    5.6646742e-05       0.36504031        1.0575170
               omega       0.43544210       0.26899633       0.41811062       0.29766586      -0.38403965        1.2549239
              alpha1       0.15919129      0.058660794      0.072105885      0.027262172      0.017866348       0.30051622
              gamma1    -0.0030674072      0.061930889       0.11006744       0.97776708      -0.21879563       0.21266081
               beta1       0.83640457      0.033099893      0.042649342    1.2408223e-85       0.75281339       0.91999574

The ``gamma1`` coefficient (-0.003, robust p-value 0.98) gives no evidence of asymmetry in this sample: no evidence that negative shocks raise next month's volatility more than positive shocks of the same size. A positive and significant ``gamma1`` would indicate a leverage effect.


Step Five: Compare models
^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    // Compare the two fits: a higher log likelihood and a lower AIC or BIC
    // are better
    print "Model Comparison";
    print "================";
    print sprintf("%-16s %14s %12s %12s", "", "Log lik.", "AIC", "BIC");
    print sprintf("%-16s %14.4f %12.4f %12.4f", "GARCH(1,1)", fit.loglik, fit.aic, fit.bic);
    print sprintf("%-16s %14.4f %12.4f %12.4f", "GJR-GARCH(1,1)", fit_gjr.loglik, fit_gjr.aic, fit_gjr.bic);

::

    Model Comparison
    ================
                           Log lik.          AIC          BIC
    GARCH(1,1)           -1082.3653    2172.7306    2188.5332
    GJR-GARCH(1,1)       -1082.3641    2174.7282    2194.4814

Lower AIC and BIC values indicate a better fit. The GJR model raises the log likelihood by only 0.001 for one more parameter, so both criteria prefer the standard GARCH(1,1).


Example 2: Alternative Error Distributions
-------------------------------------------

Financial returns often have fat tails. The Student's *t* distribution adds a degrees-of-freedom parameter that captures excess kurtosis:

::

    // GARCH(1,1) with Student's t errors
    struct garchResult fit_t;
    fit_t = garchFit(rsandp, garch=1, arch=1, dist="t");

The parameter table adds ``df``:

::

           Parameter         Estimate       SE_Hessian        SE_Robust  P_Robust_Normal Lower_95_Robust_ Upper_95_Robust_
                  mu       0.97775192       0.17007049       0.17597858    2.7589289e-08       0.63284024        1.3226636
               omega       0.96880825       0.55663669       0.51720608      0.061046693     -0.044897045        1.9825135
              alpha1       0.18754861      0.066567066      0.064639401     0.0037142866      0.060857713       0.31423951
               beta1       0.77586761      0.065886582      0.062989047    7.2919579e-35       0.65241135       0.89932388
                  df        6.1463237        1.7220896        2.0456973     0.0026600656        2.1368307        10.155817

::

    Normal vs Student's t errors
    ============================
                           Log lik.          AIC          BIC
    Normal               -1082.3653    2172.7306    2188.5332
    Student's t          -1067.8443    2145.6886    2165.4418
    Degrees of freedom of the t fit: 6.15

With 6.1 degrees of freedom the *t* distribution has much fatter tails than the normal, and the log likelihood rises by 14.5 for the one extra parameter; both AIC and BIC prefer the *t* errors. The *df* p-value tests *df* = 0, which is outside the allowed range, so it is not a standard test; the same holds for the p-values of ``omega``, ``alpha1`` and ``beta1``, which test a value on their lower bound of 0. The full program, ``garch-models-2.gss``, prints both summaries and this table.


Example 3: GARCH-in-Mean for Risk Premium (TSMT 4.1)
-----------------------------------------------------

.. Note:: This example uses TSMT 4.1 (``library tsmt``). GARCH-in-mean is not in the GAUSS 27.0 Time Series package; it is planned for a later 27.x release. The output below is from TSMT 4.1.1.

The GARCH-M (GARCH-in-Mean) model includes conditional volatility in the mean equation, allowing us to test whether higher risk leads to higher expected returns:

:math:`r_t = \mu + \delta \sigma_t + \epsilon_t`

::

    library tsmt;

    // Estimate GARCH-M(1,1) model
    struct garchEstimation gOut_m;
    gOut_m = garchMFit(rsandp, 1, 1);

::

    ================================================================================
    Model:                  GARCHM(1,1)          Dependent variable:          rsandp
    Time Span:                  Unknown          Valid cases:                    384
    ================================================================================
                                 Coefficient            Upper CI            Lower CI

              beta0[1,1]             0.17085                   .                   .
              garch[1,1]             0.47232                   .                   .
               arch[1,1]             0.52768                   .                   .
              delta[1,1]             0.11435                   .                   .
              omega[1,1]             0.38680                   .                   .
    ================================================================================

                    AIC:                                                 -2269.59347
                    LRS:                                                 -2279.59347

The ``delta`` parameter measures the risk-return tradeoff. A positive delta indicates that investors require higher returns for bearing more risk. In this fit ``arch`` + ``garch`` = 1.00000, the edge of the stationary region, and no confidence limits are printed.


Summary of GARCH Functions
---------------------------

The GAUSS Time Series package provides:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Function
     - Description
   * - :func:`garchFit`
     - GARCH(p,q) and GJR-GARCH(1,1) with normal or Student's t errors, AR terms and regressors in the mean
   * - :func:`garchForecast`
     - Variance, volatility and mean forecasts
   * - :func:`garchDiagnostics`
     - ARCH-LM and sign-bias tests on the standardized residuals
   * - :func:`garchResults`
     - Print the summary of a fit again
   * - :func:`garchControlCreate`
     - Create a control structure for options

TSMT 4.1 users: see :doc:`/timeseries/garch-from-tsmt`.


**Function reference**: :func:`garchFit`, :func:`garchForecast`, :func:`garchDiagnostics`

**Further reading**:

* `Modeling Volatility with GARCH in GAUSS <https://www.aptech.com/blog/modeling-volatility-with-garch/>`_
