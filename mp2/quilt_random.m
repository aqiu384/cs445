function output = quilt_random(sample, outsize, patchsize)
    rng(0, 'twister');
    
    sample = double(sample);

    [iheight, iwidth, channels] = size(sample);
    
    oheight = outsize(1);
    owidth = outsize(2);
    
    pradius = floor(patchsize / 2);
    pyrange = [pradius, iheight - pradius];
    pxrange = [pradius, iwidth - pradius];
        
    function patch = rand_patch()
        ycenter = randi(pyrange);
        xcenter = randi(pxrange);
        patch = sample(ycenter - pradius:ycenter + pradius, xcenter - pradius:xcenter + pradius, :);
    end
    
    % Upper-left Corner
    output = zeros(oheight, owidth, channels);
    output(1:patchsize, 1:patchsize, :) = rand_patch();
    
    % Down Tiles
    for h = patchsize:patchsize:oheight - patchsize
        output(h + 1:h + patchsize, 1:patchsize, :) = rand_patch();
    end
    
    % Right Tiles
    for w = patchsize:patchsize:owidth - patchsize
        output(1:patchsize, w + 1:w + patchsize, :) = rand_patch();
    end
    
    % Remaining Tiles
    for h = patchsize:patchsize:oheight - patchsize
        for w = patchsize:patchsize:owidth - patchsize
            output(h + 1:h + patchsize, w + 1:w + patchsize, :) = rand_patch();
        end
    end
    
    output = uint8(output);
end

