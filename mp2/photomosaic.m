function output = photomosaic(sample, target, patchsize, overlap, tol, alpha)
    rng(0, 'twister');
    
    function output = find_core(image)
        output = imgaussfilt(rgb2gray(image), 4);
        MIN = min(min(output));
        MAX = max(max(output));
        output = mat2gray(output, [double(MIN), double(MAX)]);
    end
    
    sample_core = find_core(sample);
    target_core = find_core(target);
    
    sample = double(sample);
    sample_square = sample .^ 2;
    
    [iheight, iwidth, channels] = size(sample);
    
    [oheight, owidth, ~] = size(target);
    tsize = patchsize - overlap;
        
    pradius = floor(patchsize / 2);
    pyrange = [pradius + 1, iheight - pradius - 1];
    pxrange = [pradius + 1, iwidth - pradius - 1];
        
    function patch = rand_patch()
        ycenter = randi(pyrange);
        xcenter = randi(pxrange);
        patch = sample(ycenter - pradius:ycenter + pradius, xcenter - pradius:xcenter + pradius, :);
    end

    function diff = ssd_patch(squares, template, target_pixel)
        diff = (sample_core - target_pixel) .^ 2;
        diff = diff(pyrange(1):pyrange(2), pxrange(1):pxrange(2));
        diff = (1 - alpha) * mat2gray(diff);
        
        ssds = sum(squares - 2 * imfilter(sample, template), 3);
        ssds = ssds(pyrange(1):pyrange(2), pxrange(1):pxrange(2));
        ssds = alpha * mat2gray(ssds);
        
        diff = mat2gray(diff + ssds);
    end
    
    function patch = choose_sample(diff)        
        [mins_y, mins_x] = find(diff < tol);
        
        min_index = randi(length(mins_y));
        ycenter = mins_y(min_index) + pradius;
        xcenter = mins_x(min_index) + pradius;
        
        patch = sample(ycenter - pradius:ycenter + pradius, xcenter - pradius:xcenter + pradius, :);
    end
    
    % Upper-left Corner
    output = zeros(oheight, owidth, channels);
    output(1:patchsize, 1:patchsize, :) = rand_patch();
    
    disp('Processing down...');
    
    % Down Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(1:overlap, :, :) = 1;
    squared = imfilter(sample_square, mask);

    for h = tsize:tsize:oheight - patchsize
        template = output(h + 1:h + patchsize, 1:patchsize, :);
        target_pixel = target_core(h + floor(patchsize / 2), floor(patchsize / 2));
        patch = choose_sample(ssd_patch(squared, template, target_pixel));
        
        bndcost = sum(((template(1:overlap, :, :) - patch(1:overlap, :, :)) .^ 2), 3);
        mask = repmat(transpose(cut_path(bndcost)), [1, 1, 3]);
        
        output(h + 1:h + patchsize, 1:patchsize, :) = ...
            output(h + 1:h + patchsize, 1:patchsize, :) .* (1 - mask) + ...
            patch .* mask;
    end
    
    disp('Processing right...');
    
    % Right Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(:, 1:overlap, :) = 1;
    squared = imfilter(sample_square, mask);
    
    for w = tsize:tsize:owidth - patchsize
        template = output(1:patchsize, w + 1:w + patchsize, :);
        target_pixel = target_core(floor(patchsize / 2), w + floor(patchsize / 2));
        patch = choose_sample(ssd_patch(squared, template, target_pixel));
        
        bndcost = transpose(sum(((template(:, 1:overlap, :) - patch(:, 1:overlap, :)) .^ 2), 3));
        mask = repmat(cut_path(bndcost), [1, 1, 3]);
        
        output(1:patchsize, w + 1:w + patchsize, :) = ...
            output(1:patchsize, w + 1:w + patchsize, :) .* (1 - mask) + ...
            patch .* mask;
    end
    
    % Remaining Tiles
    mask = zeros(patchsize, patchsize, channels);
    mask(1:overlap, :, :) = 1;
    mask(:, 1:overlap, :) = 1;
    squared = imfilter(sample_square, mask);
    
    for h = tsize:tsize:oheight - patchsize
        disp('Processing remaining...');
        for w = tsize:tsize:owidth - patchsize
            template = output(h + 1:h + patchsize, w + 1:w + patchsize, :);
            target_pixel = target_core(h + floor(patchsize / 2), w + floor(patchsize / 2));
            patch = choose_sample(ssd_patch(squared, template, target_pixel));
            
            bndcost = sum(((template(1:overlap, :, :) - patch(1:overlap, :, :)) .^ 2), 3);
            mask = transpose(cut_path(bndcost));
            
            bndcost = transpose(sum(((template(:, 1:overlap, :) - patch(:, 1:overlap, :)) .^ 2), 3));
            mask = bitand(cut_path(bndcost), mask);
            mask = repmat(mask, [1, 1, 3]);
            
            output(h + 1:h + patchsize, w + 1:w + patchsize, :) = ...
                output(h + 1:h + patchsize, w + 1:w + patchsize, :) .* (1 - mask) + ...
                patch .* mask;
        end
    end

    output = uint8(output);
end

