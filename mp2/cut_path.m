function output = cut_path(bndcost, display_path)
    [overlap, patchsize] = size(bndcost);

    for col = 1:patchsize - 1
        sum_col = zeros(overlap, 1);
        
        for row = 2:overlap - 1
            sum_col(row) = min(bndcost(row - 1:row + 1, col));
        end
        
        sum_col(1) = min(bndcost(1:2, col));
        sum_col(end) = min(bndcost(end-1:end, col));
        
        bndcost(:, col + 1) = bndcost(:, col + 1) + sum_col;
    end
    
    bndcost = transpose(bndcost);
    x_ers = 1:patchsize;
    
    output = ones(patchsize, patchsize);
    [~, min_index] = min(bndcost(patchsize, :));

    for row = patchsize:-1:1
        if min_index == 1
            [~, min_index] = min(bndcost(row, 1:2));
        elseif min_index == overlap
            [~, temp_index] = min(bndcost(row, end-1:end));
            min_index = overlap - 2 + temp_index;
        else
            [~, temp_index] = min(bndcost(row, min_index - 1:min_index + 1));
            min_index = min_index + temp_index - 2;
        end
        
        if display_path
            x_ers(row) = min_index;
        else
            output(row, 1:min_index) = 0;
        end
    end
    
    if display_path
        figure(1);
        imagesc(bndcost);
        axis equal;
        
        figure(2);
        imagesc(bndcost);
        hold on;
        plot(x_ers, 1:patchsize, 'r');
        hold off;
        axis equal;
    end
end

