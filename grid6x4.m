for i = 1:23
    subplot(6,4,i), hold on, box on
    plot(b{1,2*i-1}),  plot(b{1,2*i})
    xlabel('Cycle number'), ylabel('Rel. Q')
    t = c{i};
    t2 = strrep(t, '_' , '.' );
    t2 = strrep(t2, '-' , '(' );
    t2 = strrep(t2, 'per.' , '%)-' );
    title(t2)
    
    %sub_pos = get(gca,'position'); % get subplot axis position
    %set(gca,'position',sub_pos.*[1 1 .9 .9]) % stretch its width and height
end