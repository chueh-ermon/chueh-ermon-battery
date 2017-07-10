function [PCALoadings,PCAScores,mean_X] = PCA_All_Battery(cyclematrix1,Q, xVoltage)
%% Partial Least Squares Regression and Principal Components Regression

%% Fitting the Data with Two Components
% Use the |plsregress| function to fit a PLSR model with ten PLS components
% and one response.
%Change to ICA analysis 
X = transpose(cyclematrix1);
% Make Capacity
y = Q;
[n,p] = size(X);
[Xloadings,Yloadings,Xscores,Yscores,betaPLS10,PLSPctVar] = plsregress(...
	X,y,10);
[Xloadings,Yloadings,Xscores,Yscores,betaPLS] = plsregress(X,y,8);
yfitPLS = [ones(n,1) X]*betaPLS;
%%
% Ten components may be more than will be needed to adequately fit the
% data, but diagnostics from this fit can be used to make a choice of a
% simpler model with fewer components. For example, one quick way to choose
% the number of components is to plot the percent of variance explained in
% the response variable as a function of the number of components.
figure
plot(1:10,cumsum(100*PLSPctVar(2,:)),'-bo');
xlabel('Number of PLS components');
ylabel('Percent Variance Explained in Y');
%%
% Next, fit a PCR model with two principal components.  The first step is
% to perform Principal Components Analysis on |X|, using the |pca|
% function, and retaining two principal components. PCR is then just a
% linear regression of the response variable on those two components.  It
% often makes sense to normalize each variable first by its standard
% deviation when the variables have very different amounts of variability,
% however, that is not done here.
[PCALoadings,PCAScores,PCAVar] = pca(X,'Economy',false);
betaPCR = regress(y-mean(y), PCAScores(:,1:5));
%%
% To make the PCR results easier to interpret in terms of the original
% spectral data, transform to regression coefficients for the original,
% uncentered variables.
betaPCR = PCALoadings(:,1:5)*betaPCR;
betaPCR = [mean(y) - mean(X)*betaPCR; betaPCR];
yfitPCR = [ones(n,1) X]*betaPCR;

%%
% Plot fitted vs. observed response for the PLSR and PCR fits.
figure
plot(y,yfitPLS,'bo',y,yfitPCR,'r^');
xlabel('Observed Response');
ylabel('Fitted Response');
legend({'PLSR with 2 Components' 'PCR with 2 Components'},  ...
	'location','NW');
%%
% In a sense, the comparison in the plot above is not a fair one -- the
% number of components (two) was chosen by looking at how well a
% two-component PLSR model predicted the response, and there's no reason
% why the PCR model should be restricted to that same number of components.
% With the same number of components, however, PLSR does a much better job
% at fitting |y|.  In fact, looking at the horizontal scatter of fitted
% values in the plot above, PCR with two components is hardly better than
% using a constant model.  The r-squared values from the two regressions
% confirm that.

TSS = sum((y-mean(y)).^2);
RSS_PLS = sum((y-yfitPLS).^2);
rsquaredPLS = 1 - RSS_PLS/TSS;
%%
RSS_PCR = sum((y-yfitPCR).^2);
rsquaredPCR = 1 - RSS_PCR/TSS;



% %%
% % Notice that while the two PLS components are much better predictors of
% % the observed |y|, the following figure shows that they explain
% % somewhat less variance in the observed |X| than the first two principal
% % components used in the PCR.
% figure
% plot(cumsum(PCAVar)/sum(PCAVar))
% hold on
% %plot(1:10, cumsum(PCAVar(1:10))./sum(PCAVar),'r-^');
% xlabel('Number of Principal Components');
% ylabel('Fraction Variance Explained in X');
% legend('PCA');
%%
% The fact that the PCR curve is uniformly higher suggests why PCR with two
% components does such a poor job, relative to PLSR, in fitting |y|.  PCR
% constructs components to best explain |X|, and as a result, those first
% two components ignore the information in the data that is important in
% fitting the observed |y|.


%% Fitting with More Components
% As more components are added in PCR, it will necessarily do a better job
% of fitting the original data |y|, simply because at some point most of the
% important predictive information in |X| will be present in the principal
% components.  For example, the following figure shows that the
% difference in residuals for the two methods is much less dramatic when
% using ten components than it was for two components.
yfitPLS10 = [ones(n,1) X]*betaPLS10;
betaPCR10 = regress(y-mean(y), PCAScores(:,1:10));
betaPCR10 = PCALoadings(:,1:10)*betaPCR10;
betaPCR10 = [mean(y) - mean(X)*betaPCR10; betaPCR10];
yfitPCR10 = [ones(n,1) X]*betaPCR10;
figure
plot(y,yfitPLS10,'bo',y,yfitPCR10,'r^');
xlabel('Observed Response');
ylabel('Fitted Response');
legend({'PLSR with 10 components' 'PCR with 10 Components'},  ...
	'location','NW');



%% Choosing the Number of Components with Cross-Validation
% It's often useful to choose the number of components to minimize the
% expected error when predicting the response from future observations on
% the predictor variables.  Simply using a large number of components will
% do a good job in fitting the current observed data, but is a strategy
% that leads to overfitting.  Fitting the current data too well results in
% a model that does not generalize well to other data, and gives an
% overly-optimistic estimate of the expected error.
%
% Cross-validation is a more statistically sound method for choosing the
% number of components in either PLSR or PCR.  It avoids overfitting data
% by not reusing the same data to both fit a model and to estimate
% prediction error. Thus, the estimate of prediction error is not
% optimistically biased downwards.
%
% |plsregress| has an option to estimate the mean squared prediction error
% (MSEP) by cross-validation, in this case using 10-fold C-V.
[Xl,Yl,Xs,Ys,beta,pctVar,PLSmsep] = plsregress(X,y,10,'CV',10);
%%
% For PCR, |crossval| combined with a simple function to compute the sum of
% squared errors for PCR, can estimate the MSEP, again using 10-fold
% cross-validation.
PCRmsep = sum(crossval(@pcrsse,X,y,'KFold',10),1) / n;

%%
% The MSEP curve for PLSR indicates that two or three components does about
% as good a job as possible.  On the other hand, PCR needs four components
% to get the same prediction accuracy.
figure
plot(0:10,PLSmsep(2,:),'b-o',0:10,PCRmsep,'r-^');
xlabel('Number of components');
ylabel('Estimated Mean Squared Prediction Error');
legend({'PLSR' 'PCR'},'location','NE');
%%
% In fact, the second component in PCR _increases_ the prediction error
% of the model, suggesting that the combination of predictor variables
% contained in that component is not strongly correlated with |y|.  Again,
% that's because PCR constructs components to explain variation in |X|, not
% |y|.


%% Model Parsimony
% So if PCR requires four components to get the same prediction accuracy as
% PLSR with three components, is the PLSR model more parsimonious?  That
% depends on what aspect of the model you consider.
%
% The PLS weights are the linear combinations of the original variables
% that define the PLS components, i.e., they describe how strongly each
% component in the PLSR depends on the original variables, and in what
% direction.
    [Xl,Yl,Xs,Ys,beta,pctVar,mse,stats] = plsregress(X,y,4);
    plot(xVoltage,stats.W,'-');
    xlabel('Variable');
    ylabel('PLS Weight');
    legend({'1st Component' '2nd Component' '3rd Component','4th Component'},  ...
        'location','NW');
%
for k=1:4
    plot(smooth(Xs(:,k),10))
    hold on
end 
% Similarly, the PCA loadings describe how strongly each component in the PCR
% depends on the original variables.
figure
PCALoading_squared=PCALoadings.^2;
for j=1:length(PCALoadings(:,1))
    PCALoadingTotal(j)=PCALoading_squared(j,1)+PCALoading_squared(j,2)+...
        PCALoading_squared(j,3)+PCALoading_squared(j,4)+PCALoading_squared(j,5)...
        +PCALoading_squared(j,6);
end

figure
plot(xVoltage,PCALoadings(:,1:4),'-');
hold on
plot(xVoltage,mean(X)./30,'-'); 
xlabel('Voltage');
ylabel('PCA Loading');
legend({'1st Component' '2nd Component' '3rd Component' '4th Component'},'location','NW');

figure
plot(xVoltage,PCALoadingTotal,'-'); 
xlabel('Voltage');
ylabel('Fraction Variance Explained (Voltage)');

figure
for k=1:4
    plot(smooth(PCAScores(:,k),10))
    hold on
end 
mean_X=mean(X);

% legend({'1st Component' '2nd Component' '3rd Component' '4th Component'});
% figure(12)
% plot(xVoltage,PCAScores(10,1:4)*transpose(PCALoadings(:,1:4))+mean(X))
% hold on
% plot(xVoltage,cyclematrix1(:,10))
% hold on
% plot(xVoltage,PCAScores(90,1:4)*transpose(PCALoadings(:,1:4))+mean(X))
% hold on
% plot(xVoltage,cyclematrix1(:,90))
% xlabel('Voltage')
% ylabel('dQ/dV (Ah/V)')
% figure(13)
% plot(xVoltage,PCAScores(1210,1:4)*transpose(PCALoadings(:,1:4))+mean(X))
% hold on
% plot(xVoltage,cyclematrix1(:,1210))
% hold on
% plot(xVoltage,PCAScores(1290,1:4)*transpose(PCALoadings(:,1:4))+mean(X))
% hold on
% plot(xVoltage,cyclematrix1(:,1290))
% xlabel('Voltage')
% ylabel('dQ/dV (Ah/V)')
% figure(14)
% plot(xVoltage,PCAScores(1410,1:4)*transpose(PCALoadings(:,1:4))+mean(X))
% hold on
% plot(xVoltage,cyclematrix1(:,1410))
% hold on
% plot(xVoltage,PCAScores(1490,1:4)*transpose(PCALoadings(:,1:4))+mean(X))
% hold on
% plot(xVoltage,cyclematrix1(:,1490))
% xlabel('Voltage')
% ylabel('dQ/dV (Ah/V)')


%%
% For either PLSR or PCR, it may be that each component can be given a
% physically meaningful interpretation by inspecting which variables it
% weights most heavily.  For instance, with these spectral data it may be
% possible to interpret intensity peaks in terms of compounds present in
% the gasoline, and then to observe that weights for a particular component
% pick out a small number of those compounds.  From that perspective, fewer
% components are simpler to interpret, and because PLSR often requires
% fewer components to predict the response adequately, it leads to more
% parsimonious models.
% 
% On the other hand, both PLSR and PCR result in one regression coefficient
% for each of the original predictor variables, plus an intercept.  In that
% sense, neither is more parsimonious, because regardless of how many
% components are used, both models depend on all predictors.  More
% concretely, for these data, both models need 401 spectral intensity
% values in order to make a prediction.
%
% However, the ultimate goal may to reduce the original set of variables to
% a smaller subset still able to predict the response accurately.  For
% example, it may be possible to use the PLS weights or the PCA loadings to
% select only those variables that contribute most to each component.  As
% shown earlier, some components from a PCR model fit may serve
% primarily to describe the variation in the predictor variables, and may
% include large weights for variables that are not strongly correlated with
% the response. Thus, PCR can lead to retaining variables that are
% unnecessary for prediction.
%
% For the data used in this example, the difference in the number of
% components needed by PLSR and PCR for accurate prediction is not great,
% and the PLS weights and PCA loadings seem to pick out the same variables.
% That may not be true for other data.

end

