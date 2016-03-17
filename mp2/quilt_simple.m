function output = quilt_simple(sample, outsize, patchsize, overlap, tol)
    rng(0, 'twister');
    
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
        diff = diff(pyrange(1):pyrange(2), pxrange(1):pxrange(2));
    end
    
    function patch = choose_sample(diff)
        diff = diff - min(diff(:)) + 1000000000;
        min_cost = min(diff(:));
        
        [mins_y, mins_x] = find(diff < min_cost * (1 + tol));
        
        min_index = randi(length(mins_y));
        ycenter = mins_y(min_index) + pradius;
        xcenter = mins_x(min_index) + pradius;
        
        patch = sample(ycenter - pradius:ycenter + pradius, xcenter - pradius:xcenter + pradius, :);
    end
    
    % Upper-left Corner
    output = zeros(oheight, owidth, channels);
    output(1:patchsize, 1:patchsize, :) = rand_patch();
    
    % Down Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(1:overlap, :, :) = 1;
    squared = imfilter(sample_square, mask);

    for h = tsize:tsize:oheight - patchsize
        template = output(h + 1:h + patchsize, 1:patchsize, :);
        output(h + 1:h + patchsize, 1:patchsize, :) = choose_sample(ssd_patch(squared, template));
    end
    
    % Right Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(:, 1:overlap, :) = 1;
    squared = imfilter(sample_square, mask);
    
    for w = tsize:tsize:owidth - patchsize
        template = output(1:patchsize, w + 1:w + patchsize, :);
        output(1:patchsize, w + 1:w + patchsize, :) = choose_sample(ssd_patch(squared, template));
    end
    
    % Remaining Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(1:overlap, :, :) = 1;
    mask(:, 1:overlap, :) = 1;
    squared = imfilter(sample_square, mask);
    
    for h = tsize:tsize:oheight - patchsize
        for w = tsize:tsize:owidth - patchsize
            template = output(h + 1:h + patchsize, w + 1:w + patchsize, :);
            output(h + 1:h + patchsize, w + 1:w + patchsize, :) = choose_sample(ssd_patch(squared, template));
        end
    end

    output = uint8(output);
end
