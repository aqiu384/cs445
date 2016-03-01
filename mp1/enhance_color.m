function enhance_color(img_file)
    LEFT_CLIP = 0.0;
    RIGHT_CLIP = 0.6;

    img = imread(img_file);
    hsv_img = rgb2hsv(img);

    sat = hsv_img(:, :, 2);
    new_sat = (sat - LEFT_CLIP) / (RIGHT_CLIP - LEFT_CLIP);
    new_sat(new_sat < 0) = 0;
    new_sat(new_sat > 1) = 1;
    
    hsv_img(:, :, 2) = new_sat;
    new_img = hsv2rgb(hsv_img);
    
    subplot(1, 2, 1);
    imshow(img);
    subplot(1, 2, 2);
    imshow(new_img);
end

