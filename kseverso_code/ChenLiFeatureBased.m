clear; close all; clc

%Script to apply feature-based regression model to Chen Li ICA dataset

load ChenLiProcessed.mat

numCyc = 100; %number of cycles to be used in analysis
numBat = 24; %total number of batteries in dataset
lenCyc = 1050; %length of each dQdV dataset

endCyc = 400; 

rmse_train_stor = zeros(endCyc,1);
rmse_test_stor = zeros(endCyc,1);
per_train_stor = zeros(endCyc,1);
per_test_stor = zeros(endCyc,1);
num_coeff_stor = zeros(endCyc,1);
coeff_val_stor = {};

for ii = 2:endCyc
    
    %create dataset based on the difference between cycle 1 and cycle 200 dQdV
    DiffData = zeros(numBat,lenCyc);
    for i = 1:numBat
        DiffData(i,:) = master_dQdV{i}(:,1) - master_dQdV{i}(:,ii);
    end
    
    %extract the relative capacity at cycle 550
    bat_label = zeros(numBat,1);
    for j = 1:numBat
        
        bat_label(j) = master_Q{j}(550);
        
    end
    
    max_Q = 0.9;
    min_Q = 0.45;
    colormap('jet')
    CM = colormap('jet');
    
    % hFig=figure();
    % for j = 1:numBat
    %     if j == 1
    %         surf(peaks,colormap('jet'))
    %         cla
    %     end
    %     subplot(1,1,1)
    %     hold on
    %     color_ind = ceil((bat_label(j) - min_Q)./(max_Q - min_Q)*64);
    %     plot(xVoltage{j},DiffData(j,:),'Color',CM(color_ind,:))
    %
    %     %ylim([0,25])
    %     xlim([3.2,4.4])
    %     xlabel('Voltage (V)')
    %     ylabel('Incremental Capacity (mAh/V)')
    %
    % end
    
    %Create candidate features
    feat = zeros(numBat,21);
    %location of first point in curve where the difference curve decreases
    for i = 1:numBat
        feat(i,1) = find(diff(DiffData(i,:)) < 0,1);
    end
    %first valley minimum and location
    [feat(:,2), feat(:,3)] = min(DiffData(:,1:500),[],2);
    %second valley minimum and location
    [feat(:,4), feat(:,5)] = min(DiffData(:,501:1000),[],2);
    %average over voltages 4.16 to 4.32
    feat(:,6) = mean(DiffData(:,868:1030),2);
    %range over full curve
    %feat(:,7) = max(DiffData,[],2) - min(DiffData,[],2);
    % [feat(:,7),feat(:,8)] = max(DiffData(:,1:500),[],2);
    % [feat(:,9),feat(:,10)] = max(DiffData(:,401:end),[],2);
    
    
    %all possible interactions
    counter = 7;
    for i = 1:6
        for j = i+1:6
            feat(:,counter) = feat(:,i).*feat(:,j);
            counter = counter + 1;
        end
    end
    
    % figure()
    % for i = 1:size(feat,2)
    %
    %     for j = 1:numBat
    %         subplot(4,7,i)
    %         hold on
    %         color_ind = ceil((bat_label(j) - min_Q)./(max_Q - min_Q)*64);
    %         plot(j,feat(j,i),'.','Color',CM(color_ind,:),'MarkerSize',15)
    %         xlim([0,25])
    %     end
    %
    % end
    
    % randomly partition data into train and test
    rng('default')
    test_ind = randperm(numBat,6);
    train_ind = 1:numBat;
    train_ind(test_ind) = [];
    
    [B, FitInfo] = lasso(feat(train_ind,:),bat_label(train_ind),'CV',3);
    
    % lassoPlot(B,FitInfo,'PlotType','CV')
    % lassoPlot(B,FitInfo,'PlotType','L1')
    
    %feature 15 is the interaction between 2 and 6
    min_ind = FitInfo.IndexMinMSE;
    feat_ind = find(B(:,min_ind));
    
    %scale data
    [feat_train_scaled,mu,sigma] = zscore(feat(train_ind,feat_ind));
    feat_test_scaled = bsxfun(@minus,feat(test_ind,feat_ind),mu);
    feat_test_scaled = bsxfun(@rdivide,feat_test_scaled,sigma);
    
    %train OLS model using coeffs
    [B1,BINT1,R1,RINT1,STATS1] = regress(bat_label(train_ind),[feat_train_scaled,ones(length(train_ind),1)]);
    
    if isempty(feat_ind)
        
        rmse_train_stor(ii) = NaN;
        rmse_test_stor(ii) = NaN;
        per_train_stor(ii) = NaN;
        per_test_stor(ii) = NaN;
        num_coeff_stor(ii) = 0;
        coeff_val_stor{ii} = 0;
        
    else
        
        ypred_train = feat_train_scaled*B1(1:length(feat_ind)) + B1(end);
        ypred_test = feat_test_scaled*B1(1:length(feat_ind)) + B1(end);
        
        res_train = ypred_train - bat_label(train_ind);
        res_test = ypred_test - bat_label(test_ind);
        
        per_err_train = mean(abs(res_train./bat_label(train_ind)));
        per_err_test = mean(abs(res_test./bat_label(test_ind)));
        
        err_train = sqrt(mean(res_train.^2));
        err_test = sqrt(mean(res_test.^2));
        
        % figure()
        % plot(bat_label(train_ind),ypred_train,'o')
        % hold on
        % plot(bat_label(test_ind),ypred_test,'o')
        % legend('Train','Test','Location','SouthOutside','Orientation','Horizontal')
        % plot(linspace(0.4,1),linspace(0.4,1),'k')
        % xlabel('Observed Relative Capacity')
        % ylabel('Predicted Relative Capacity')
        % set(gca,'fontsize',16)
        %
        % figure()
        % histogram([res_train; res_test],6)
        %
        % figure()
        % plot(bat_label(train_ind),res_train,'o')
        % hold on
        % plot(bat_label(test_ind),res_test,'o')
        % legend('Train','Test','Location','SouthOutside','Orientation','Horizontal')
        % plot(linspace(0.4,0.9),zeros(100,1),'k')
        % xlabel('Relative Capcaity at Cycle 550')
        % ylabel('Residual')
        % set(gca,'fontsize',16)
        
        [B2,BINT2,R2,RINT2,STATS2] = regress(bat_label(train_ind),[res_train,ones(length(train_ind),1)]);
        
        rmse_train_stor(ii) = err_train;
        rmse_test_stor(ii) = err_test;
        per_train_stor(ii) = per_err_train;
        per_test_stor(ii) = per_err_test;
        num_coeff_stor(ii) = length(B1) - 1;
        coeff_val_stor{ii} = feat_ind;
        
    end %end check that model is non-zero
end

figure()
subplot(1,3,1)
plot(2:endCyc,per_train_stor(2:end),'o-')
hold on
plot(2:endCyc,0.05*ones(length(2:endCyc),1),'k')
title('Mean Percent Error Training Data')
ylim([0,0.2])
xlabel('Cycle Number')
ylabel('Mean Percent Error')

subplot(1,3,2)
plot(2:endCyc,per_test_stor(2:end),'o-')
hold on
plot(2:endCyc,0.05*ones(length(2:endCyc),1),'k')
title('Mean Percent Error Testing Data')
ylim([0,0.2])
xlabel('Cycle Number')
ylabel('Mean Percent Error')

subplot(1,3,3)
plot(2:endCyc,num_coeff_stor(2:end),'o-')
hold on
plot(2:endCyc,0.05*ones(length(2:endCyc),1),'k')
title('Number of model coefficients')
xlabel('Cycle Number')
ylabel('Count')

figure()
subplot(1,3,1)
plot(2:endCyc,movmean(per_train_stor(2:end),5),'o-')
title('RMSE Training Data with Moving Average')
ylim([0,0.2])
xlabel('Cycle Number')
ylabel('RMSE')

subplot(1,3,2)
plot(2:endCyc,movmean(per_test_stor(2:end),5),'o-')
title('RMSE Testing Data with Moving Average')
ylim([0,0.2])
xlabel('Cycle Number')
ylabel('RMSE')

subplot(1,3,3)
plot(2:endCyc,num_coeff_stor(2:end),'o-')
title('Number of model coefficients')
xlabel('Cycle Number')
ylabel('Count')

feat_freq = zeros(size(feat,2),1);

for i = 1:endCyc
    
    add_feat = zeros(size(feat,2),1);
    if coeff_val_stor{i} == 0
        %do nothing
    else
        add_feat(coeff_val_stor{i}) = 1;
        feat_freq = feat_freq + add_feat;
    end
    
end

figure()
bar(feat_freq./(endCyc-1))
title('Frequency of each feature over 400 cycles')

feat_freq = zeros(size(feat,2),1);

for i = 101:endCyc
    
    add_feat = zeros(size(feat,2),1);
    if coeff_val_stor{i} == 0
        %do nothing
    else
        add_feat(coeff_val_stor{i}) = 1;
        feat_freq = feat_freq + add_feat;
    end
    
end

figure()
bar(feat_freq./(endCyc-101))
title('Frequency of each feature over last 300 cycles')

feat_freq = zeros(size(feat,2),1);

for i = 201:endCyc
    
    add_feat = zeros(size(feat,2),1);
    if coeff_val_stor{i} == 0
        %do nothing
    else
        add_feat(coeff_val_stor{i}) = 1;
        feat_freq = feat_freq + add_feat;
    end
    
end

figure()
bar(feat_freq./(endCyc-201))
title('Frequency of each feature over last 200 cycles')


feat_freq = zeros(size(feat,2),1);

for i = 2:100
    
    add_feat = zeros(size(feat,2),1);
    if coeff_val_stor{i} == 0
        %do nothing
    else
        add_feat(coeff_val_stor{i}) = 1;
        feat_freq = feat_freq + add_feat;
    end
    
end

figure()
bar(feat_freq./(99))
title('Frequency of each feature over last 200 cycles')

