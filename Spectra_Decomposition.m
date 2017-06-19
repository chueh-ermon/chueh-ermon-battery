function [ Predictors,Scores ] = Spectra_Decomposition( master_dDQdV,k )
%Spectra Decomposition: Splits the Discharge Spectra into known Components
%   Use only for Discharge IDCA Curves
    [Predictors, Scores]= nnmf(-master_dDQdV,k);
% Compare to PCA
    [Predictors2, Scores2]=pca(master_dDQdV);
    xVoltage=linspace(3.5,2.001,1000);
    for i=1:k
        figure(8)
        plot(xVoltage,Predictors2(:,i),'r')
        hold on
        plot(xVoltage,Scores(i,:),'b')
        figure(9)
        plot(Scores2(:,i),'r')
        hold on
        plot(Predictors(:,i),'b')
    end
end

