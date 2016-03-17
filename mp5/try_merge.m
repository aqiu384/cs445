THRESHOLD = 0.3;
figure();

for i = 1:NUM_FRAMES
    disp(i);

    background = im2double(imread(sprintf('./objects/f%04d.jpg', i)));
    foreground = im2double(imread(sprintf('./foreground/f%04d.jpg', i)));
    foremask = im2double(imread(sprintf('./foremask/f%04d.jpg', i)));

    merged = background .* (1 - foremask) + foreground .* foremask;
    
    %imwrite(background, sprintf('./merged/f%04d.jpg', i));
    imshow(merged);
end