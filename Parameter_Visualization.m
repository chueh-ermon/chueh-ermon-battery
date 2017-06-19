function [ is_allowed ] = Parameter_Visualization( CC_1, CC_2, Q_1 )
%UNTITLED4 Summary of this function goes here
%   Quick Visualization
    Q=linspace(0,.8,100);
    CC1=linspace(1,10,100);
    CC2=linspace(1,5,100);
    
    for i=1:length(Q)
        for j=1:length(CC1)
            for k=1:length(CC2)
                time(i,j,k)=(60*Q(i)/CC1(j))+(60*(.8-Q(i))/CC2(k));
                if time(i,j,k) <= 12
                    scatter(Q(i),CC1(j),CC2(k))
                    hold on
            end 
        end 
    end 

end

