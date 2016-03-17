output_x = [-651, 980];
output_y = [-51, 460];

output_width = output_x(2) - output_x(1) + 1;
output_height = output_y(2) - output_y(1) + 1;

input_x = [1, 480];
input_y = [1, 360];

input_width = input_x(2) - input_x(1) + 1;
input_height = input_y(2) - input_y(1) + 1;

load('./video1/homographies/panorama.mat');

frame_450 = im2double(imread('./video1/frames/f0450.jpg'));
frame_270 = im2double(imread('./video1/frames/f0270.jpg'));
M = ones(input_height, input_width);


T = maketform('projective', master_trans(:, :, 3)');
mask_450 = imtransform(M, T, 'XData', output_x, 'YData', output_y);
trans_450 = imtransform(frame_450, T, 'XData', output_x, 'YData', output_y);
mask_450 = round(mask_450(:, :, 1));

T = maketform('projective', master_trans(:, :, 2)');
mask_270 = imtransform(M, T, 'XData', output_x, 'YData', output_y);
trans_270 = imtransform(frame_270, T, 'XData', output_x, 'YData', output_y);
mask_270 = round(mask_270(:, :, 1));

combined = mask_270 & mask_450;
corners = corner(combined, 'MinimumEigenvalue', 4);

disp(corners);

upper_midpoint = (corners(3, :) + corners(4, :)) / 2;
lower_midpoint = (corners(1, :) + corners(2, :)) / 2;

left_points = [0, upper_midpoint(1), upper_midpoint(1), lower_midpoint(1), lower_midpoint(1), 0;
                0, 0, upper_midpoint(2), lower_midpoint(2), output_height, output_height];
            
right_points = [output_width, upper_midpoint(1), upper_midpoint(1), lower_midpoint(1), lower_midpoint(1), output_width;
               0, 0, upper_midpoint(2), lower_midpoint(2), output_height, output_height];
    
left_mask = combined & poly2mask(left_points(1, :), left_points(2, :), output_height, output_width);
right_mask = combined & poly2mask(right_points(1, :), right_points(2, :), output_height, output_width);

left_mask = mask_270 - combined + left_mask;
right_mask = mask_450 - combined + right_mask;

blended = pyramidBlend(trans_450, right_mask, trans_270);
imshow(blended);

imwrite(left_mask, './video1/left_mask.jpg');
imwrite(right_mask, './video1/right_mask.jpg');
imwrite(blended, './video1/pyramid_blend.jpg');

