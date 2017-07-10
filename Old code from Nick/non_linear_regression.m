function [  ] = non_linear_regression( master_cycle, DQ )
%Regresses Capacity data to Nick's proposed decay
%   Detailed explanation goes here
%% Prepare data for non linear regression
num_batt=length(DQ(1,:));
RegCoeff=zeros(3,num_batt);
y_total=[];
for i=1:num_batt
        x1=transpose(1:master_cycle(i));
        x2=log(x1);
        y1=transpose(log(1-DQ{i}));
        mQ=DQ{i};
        y1=real(y1);
        figure(48)
        plot((1:master_cycle(i)),DQ{i})
        hold on
        X = [ones(size(x1)) x1 x2];
        b = regress(y1,X);
        RegCoeff(:,i)=b;
        y_guess=(100-((100*exp(b(1)))*exp(b(2).*x1).*x1.^b(3)))./(100);
        RMSE(i)=sqrt(sum((y1(:)-y_guess(:)).^2)/master_cycle(i));
        figure(60)
        if mQ(master_cycle(i)) >0.97
            color='g';
            scatter3(b(1),b(2),b(3),[],color)
        elseif mQ(master_cycle(i))>.92
            color='y';
            scatter3(b(1),b(2),b(3),[],color)
        else 
            color='r';
            scatter3(b(1),b(2),b(3),[],color)
        end
        hold on
end
%% Calculate the RMSE of the fit
    figure(52);
    subplot(2,2,1)
    b1=histogram(RegCoeff(1,:));
    b1avg=mean(RegCoeff(1,:));
    xlabel('Coefficient 1')
    ylabel('Count')
    subplot(2,2,2)
    b2=histogram(RegCoeff(2,:));
    b2avg=mean(RegCoeff(2,:));
    xlabel('Coefficient 2')
    ylabel('Count')
    subplot(2,2,3)
    b3=histogram(RegCoeff(3,:));
    b3avg=mean(RegCoeff(3,:));
    xlabel('Coefficient 3')
    ylabel('Count')
    subplot(2,2,4)
    b4=histogram(RMSE);
    xlabel('RMSE')
    ylabel('Count')
    %% Median values for Coefficients from Multi-linear regression
    x=(1:max(master_cycle));
    decay2=(100-((100*exp(b1avg))*exp(b2avg.*x).*x.^b3avg))./(100);
    figure(48)
    plot(x,decay2,'LineWidth',3);
    xlabel('Cycle Index')
    ylabel('Remaining Capacity')
    hold on
end


