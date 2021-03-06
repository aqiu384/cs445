% starter script for project 3
DO_TOY = false;
DO_BLEND = false;
DO_MIXED  = false;
DO_PYRAMID = false;
DO_LOCAL_COLOR = true;
DO_COLOR2GRAY = false;

if DO_TOY 
    toyim = im2double(imread('./samples/toy_problem.png')); 
    im_out = toy_reconstruct(toyim);
    disp(['Error: ' num2str(sqrt(sum((toyim(:)-im_out(:)).^2)))])
end

if DO_BLEND
    % do a small one first, while debugging
    im_background = imresize(im2double(imread('./samples/im2.jpg')), 0.25, 'bilinear');
    im_object = imresize(im2double(imread('./samples/penguin-chick.jpeg')), 0.25, 'bilinear');

    % get source region mask from the user
    objmask = getMask(im_object);
    % align im_s and mask_s with im_background
    [im_s, mask_s] = alignSource(im_object, objmask, im_background);

    % blend
    im_blend = poissonBlend(im_s, mask_s, im_background);
    figure(3), hold off, imshow(im_blend)
end

if DO_MIXED
    % do a small one first, while debugging
    im_background = imresize(im2double(imread('./samples/im2.jpg')), 0.25, 'bilinear');
    im_object = imresize(im2double(imread('./samples/penguin-chick.jpeg')), 0.25, 'bilinear');

    % get source region mask from the user
    objmask = getMask(im_object);
    % align im_s and mask_s with im_background
    [im_s, mask_s] = alignSource(im_object, objmask, im_background);

    % blend
    im_blend = mixedBlend(im_s, mask_s, im_background);
    figure(3), hold off, imshow(im_blend);
end

if DO_PYRAMID
    % do a small one first, while debugging
    im_background = imresize(im2double(imread('./samples/im2.jpg')), 0.25, 'bilinear');
    im_object = imresize(im2double(imread('./samples/penguin-chick.jpeg')), 0.25, 'bilinear');

    % get source region mask from the user
    objmask = getMask(im_object);
    % align im_s and mask_s with im_background
    [im_s, mask_s] = alignSource(im_object, objmask, im_background);

    % blend
    im_blend = pyramidBlend(im_s, mask_s, im_background);
    figure(3), hold off, imshow(im_blend);
end

if DO_LOCAL_COLOR
    % do a small one first, while debugging
    im_background = imresize(im2double(imread('./samples/sunflower.jpg')), 0.25, 'bilinear');
    im_object = imresize(im2double(imread('./samples/sunflower.jpg')), 0.25, 'bilinear');

    % get source region mask from the user
    objmask = getMask(im_object);
    % align im_s and mask_s with im_background
    % [im_s, mask_s] = alignSource(im_object, objmask, im_background);

    % blend
    im_blend = localColor(im_background, objmask > 0, im_background);
    figure(3), hold off, imshow(im_blend);
end

if DO_COLOR2GRAY
    % also feel welcome to try this on some natural images and compare to rgb2gray
    im_rgb = im2double(imread('./samples/colorBlind4.png'));
    im_gr = color2gray(im_rgb);
    figure(4), hold off, imagesc(im_gr), axis image, colormap gray
end
