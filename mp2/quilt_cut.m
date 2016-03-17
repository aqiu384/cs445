function output = quilt_cut(sample, outsize, patchsize, overlap, tol)
    rng(0, 'twister');
    
    OFFSET = 1000; %overlap^2 * 1000000;
    
    sample = double(sample);
    sample_square = sample .^ 2;
    
    [iheight, iwidth, channels] = size(sample);
    
    oheight = outsize(1);
    owidth = outsize(2);
    tsize = patchsize - overlap;
        
    pradius = floor(patchsize / 2);
    pyrange = [pradius + 1, iheight - pradius - 1];
    pxrange = [pradius + 1, iwidth - pradius - 1];
        
    function patch = rand_patch()
        ycenter = randi(pyrange);
        xcenter = randi(pxrange);
        patch = sample(ycenter - pradius:ycenter + pradius, xcenter - pradius:xcenter + pradius, :);
    end

    function diff = ssd_patch(squares, template)
        diff = sum(squares - 2 * imfilter(sample, template), 3);
        diff = (diff - min(diff(:)) + 1000000000) / 100000;
        diff = diff(pyrange(1):pyrange(2), pxrange(1):pxrange(2));
    end
    
    function patch = choose_sample(diff)
        min_cost = min(diff(:));
        
        [mins_y, mins_x] = find(diff <= min_cost * (1 + tol));
        
        min_index = randi(length(mins_y));
        ycenter = mins_y(min_index) + pradius;
        xcenter = mins_x(min_index) + pradius;
        
        patch = sample(ycenter - pradius:ycenter + pradius, xcenter - pradius:xcenter + pradius, :);
    end
    
    % Upper-left Corner
    output = zeros(oheight, owidth, channels);
    output(1:patchsize, 1:patchsize, :) = rand_patch();
    
    disp('Down Tiles...');
    
    % Down Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(1:overlap, :, :) = 1;
    squared = imfilter(sample_square, mask);
    
    for h = tsize:tsize:oheight - patchsize
        template = output(h + 1:h + patchsize, 1:patchsize, :);
        patch = choose_sample(ssd_patch(squared, template));
        
        bndcost = sum(((template(1:overlap, :, :) - patch(1:overlap, :, :)) .^ 2), 3);
        mask = repmat(transpose(cut_path(bndcost, false)), [1, 1, 3]);
        
        output(h + 1:h + patchsize, 1:patchsize, :) = ...
            output(h + 1:h + patchsize, 1:patchsize, :) .* (1 - mask) + ...
            patch .* mask;
    end
    
    disp('Right Tiles...');
    
    % Right Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(:, 1:overlap, :) = 1;
    squared = imfilter(sample_square, mask);
    
    for w = tsize:tsize:owidth - patchsize
        template = output(1:patchsize, w + 1:w + patchsize, :);
        patch = choose_sample(ssd_patch(squared, template));
        
        bndcost = transpose(sum(((template(:, 1:overlap, :) - patch(:, 1:overlap, :)) .^ 2), 3));
        mask = repmat(cut_path(bndcost, false), [1, 1, 3]);
        
        if w == 1 * tsize
            temp = output(1:patchsize, 1:w + patchsize, :);
            temp(1:patchsize, w + 1:w + patchsize, :) = patch;
            
            xer = transpose(cut_path(bndcost, true));
            xer = xer(1:overlap, 1:patchsize);
            temp_path = repmat(bndcost, [1, 1, 3]);
            temp_red = ones(overlap, patchsize) * 255;
            temp_red(xer == 0) = 0;
            temp_path(:, :, 2) = temp_red;
            temp_path(:, :, 3) = temp_red;
            
            imwrite(uint8(temp), 'output/overlap.jpg');
            imwrite(uint8(repmat(bndcost, [1, 1, 3])), 'output/ssd.jpg');
            imwrite(uint8(temp_path), 'output/min_cut.jpg');
        end
                
        output(1:patchsize, w + 1:w + patchsize, :) = ...
            output(1:patchsize, w + 1:w + patchsize, :) .* (1 - mask) + ...
            patch .* mask;
    end
    
    disp('Remaining Tiles...');
    
    % Remaining Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(1:overlap, :, :) = 1;
    mask(:, 1:overlap, :) = 1;
    squared = imfilter(sample_square, mask);
    
    for h = tsize:tsize:oheight - patchsize
        for w = tsize:tsize:owidth - patchsize
            template = output(h + 1:h + patchsize, w + 1:w + patchsize, :);
            patch = choose_sample(ssd_patch(squared, template));
            
            bndcost = sum(((template(1:overlap, :, :) - patch(1:overlap, :, :)) .^ 2), 3);
            mask = transpose(cut_path(bndcost, false));
            
            bndcost = transpose(sum(((template(:, 1:overlap, :) - patch(:, 1:overlap, :)) .^ 2), 3));
            mask = bitand(cut_path(bndcost, false), mask);
            mask = repmat(mask, [1, 1, 3]);
            
            output(h + 1:h + patchsize, w + 1:w + patchsize, :) = ...
                output(h + 1:h + patchsize, w + 1:w + patchsize, :) .* (1 - mask) + ...
                patch .* mask;
        end
    end

    output = uint8(output);
end

