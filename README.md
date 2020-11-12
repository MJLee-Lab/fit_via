# fit_via
A function for performing curve fitting on relative viability or fractional viability drug dose-response data

# Data Preparation

•	This function fits relative viability (RV) or fractional viability (FV) data to a 4 parameter logistic (i.e. sigmoidal) model and returns pharmacological information related to potency and efficacy

•	Make sure the ‘fit_via.m’ function is in the current file path

•	FV can be calculated by dividing the living number of cells by the total number of cells (live + dead) in treatment wells FV values can be normalized to the vehicle control if basal cell death is high (this is not necessary for low basal cell death)

•	RV can be calculated by dividing living number of cells in treated conditions by the living number of cells in control conditions. 

•	Replicate doses do not need to be averaged and can be included as another row in the vector.  

•	Doses do not need to be in sequential order.



# fit_via structure

    fit_via(data)

data – 2 column matrix that contains 

column 1: linear scale concentrations 
column 2: corresponding FV or RV values. 
 
# Running fit_via

•	Generate ‘data variable as described in fit_via structure.

•	To run the supplied example data (README-fit_via_Ex.mat):

    load README-fit_via_Ex.mat;

•	FV or RV data can be modeled to a sigmoid function using fit_via to quantify efficacy and potency:

    [fitresult, header] = fit_via(data)

•	Fit_via requires a 2 column matrix that contains concentrations (linear scale) in the first column and FV (or RV) data in the 2nd column.  FV (or RV) values should be on a scale between 0 and 1. 

•	The function returns the fitting result (fitresult) and a vector containing the description of each column in fitresult (header)

•	The output of fit_via will include

xy_fit – model predictions from sigmoidal fits.  First column contains log(concentrations), second column contains predicted FV(RV) values, and third column contains log normalized concentrations

xy_scatter – contains original data sent to fit_via and a third column with log normalized concentrations

AOC – area over the curve

EC50 – half maximal response concentration (model parameter)

Emax – Maximal response (model parameter)

Hill – hill slope (model parameter)

Top - Minimum response (model parameter)

IC50 – the dose that results in 50% live and dead (for FV) or a 50% reduction in population size (for RV)

