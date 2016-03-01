function shift_color(img_file)
    RED_INCREASE = 30;
    YELLOW_DECREASE = 30;

    img = imread(img_file);
    lab_img = rgb2lab(img);
    
    lab_red = lab_img;
    lab_red(:, :, 2) = lab_red(:, :, 2) + RED_INCREASE;
    
    lab_yellow = lab_img;
    lab_yellow(:, :, 3) = lab_yellow(:, :, 3) - YELLOW_DECREASE;
    
    red_up = lab2rgb(lab_red);
    yellow_down = lab2rgb(lab_yellow);
    
    subplot(1, 3, 1);
    imshow(img);
    subplot(1, 3, 2);
    imshow(red_up);
    subplot(1, 3, 3);
    imshow(yellow_down);
end

