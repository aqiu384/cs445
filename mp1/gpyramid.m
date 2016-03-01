function gpyramid(imgfile)
    ZOOM = 5;
    SIGMA = 2;
    
    img = double(rgb2gray(imread(imgfile)));
    kernel = fspecial('gaussian', SIGMA * 4 + 1, SIGMA);

    for scale = 1:ZOOM
       gauss = imfilter(img, kernel, 'replicate');
       laplace = img - gauss;
       
       subplot(2, ZOOM, scale);
       imshow(mat2gray(gauss));
       subplot(2, ZOOM, ZOOM + scale);
       imshow(mat2gray(laplace));
       
       img = gauss(1:2:end, 1:2:end);
    end
end
