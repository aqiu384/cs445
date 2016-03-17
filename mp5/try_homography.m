addpath vlfeat-0.9.19/
addpath vlfeat-0.9.19/toolbox/
vl_setup;

REF_PATH = './video1';
REF_FRAME = strcat(REF_PATH, '/frames/f0450.jpg');
NEXT_FRAME = strcat(REF_PATH, '/frames/f0270.jpg');
OVERLAP_PATH = strcat(REF_PATH, '/overlap.jpg');
REF_SQUARE = strcat(REF_PATH, '/s0450.jpg');
NEXT_SQUARE = strcat(REF_PATH, '/s0270.jpg');

frame_ref = imread(REF_FRAME);
frame_270 = imread(NEXT_FRAME);
frame_mask = ones(size(frame_ref));

H = auto_homography(frame_270, frame_ref);

T_i = maketform('projective', eye(3));
T_h = maketform('projective', H');

imt = imtransform(frame_ref, T_i, 'XData',[-651 980],'YData',[-51 460]);
mask = (imtransform(frame_mask, T_i, 'XData',[-651 980],'YData',[-51 460]) == 0);

imt_2 = imtransform(frame_270, T_h, 'XData',[-651 980],'YData',[-51 460]);
mask_2 = (imtransform(frame_mask, T_h, 'XData',[-651 980],'YData',[-51 460]) == 0);

imt(mask) = imt_2(mask);
%imshow(imt);

SX = 250;
SY = 50;
INC = 200;

points = [SX, SX, SX+INC, SX+INC, SX;
          SY, SY+INC, SY+INC, SY, SY;
          ones(1, 5)];
      
points_p = H * points;
points_p = bsxfun(@rdivide, points_p, points_p(3, :));

%subplot(121);
imshow(frame_270);
hold on;
plot(points(1, :), points(2, :), 'red', 'LineWidth', 2);
hold off;
f = getframe(gcf); 
imwrite(f.cdata, REF_SQUARE);

%subplot(122);
imshow(frame_ref);
hold on;
plot(points_p(1, :), points_p(2, :), 'red', 'LineWidth', 2);
hold off;
f = getframe(gcf); 
imwrite(f.cdata, NEXT_SQUARE);

% imwrite(frame_ref, REF_SQUARE);
% imwrite(frame_270, NEXT_SQUARE);
imwrite(imt, OVERLAP_PATH);