function enhance_contrast(imgfile)
    img = rgb2gray(imread(imgfile));
    
    [hist, ~] = histcounts(img, 0:256);
    cdf = double(cumsum(hist));
    zero_mask = (cdf == 0);
    
    cdf(zero_mask) = NaN;
    cdf = (cdf - min(cdf)) * 255 / (cdf(end) - min(cdf));
    cdf(zero_mask) = 0;
    
    disp(class(img));
    
    lut = uint8(cdf);
    imshow(lut(img));
end

