function output = mixedBlend(im_s, mask_s, im_background)
    im_red = mixedSingle(im_s(:, :, 1), mask_s, im_background(:, :, 1));
    im_green = mixedSingle(im_s(:, :, 2), mask_s, im_background(:, :, 2));
    im_blue = mixedSingle(im_s(:, :, 3), mask_s, im_background(:, :, 3));
    
    output = cat(3, im_red, im_green, im_blue);
end

