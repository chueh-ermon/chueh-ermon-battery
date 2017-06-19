test=randn(100);
x=1:100;
for i=1:max(x)
    [col, mark]=random_color('y','y');
    scatter(x(i),test(i),[],col,mark)
    hold on
end 