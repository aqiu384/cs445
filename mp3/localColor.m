function output = localColor(im_s, mask_s, im_background)
    gray_back = color2gray(im_background);

    im_red = mixedSingle(im_s(:, :, 1) * 2, mask_s, gray_back);
    im_green = mixedSingle(im_s(:, :, 2) * 2, mask_s, gray_back);
    im_blue = mixedSingle(im_s(:, :, 3) * 2, mask_s, gray_back);
    
    output = cat(3, im_red, im_green, im_blue);
end

