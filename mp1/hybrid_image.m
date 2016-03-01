function hybrid_image(imgfile0, imgfile1, combfile)
    DIVISOR = 20;
    img0 = imread(imgfile0);
    img1 = imread(imgfile1);
    
    assert(isequal(size(img0), size(img1)));
    [width, height, channels] = size(img0);
    
    assert(width == height && width > DIVISOR && floor(log2(width)) == log2(width));
    radius = round(min(width, height) / DIVISOR);
    
    fft0 = fftshift(fft2(double(img0)));
    fft1 = fftshift(fft2(double(img1)));
    fftc = zeros(size(img0));
    
    kernel = fspecial('gaussian', [width, height], radius);
    l_kernel = kernel ./ max(kernel(:));
    h_kernel = 1 - l_kernel;
    
    for channel = 1:channels
        fftc(:, :, channel) = fft0(:, :, channel) .* h_kernel + fft1(:, :, channel) .* l_kernel;
    end
        
    imwrite(mat2gray(log(abs(fft0) + 1)), 'fourier0.jpg');
    imwrite(mat2gray(log(abs(fft1) + 1)), 'fourier1.jpg');
    imwrite(mat2gray(log(abs(fftc) + 1)), 'fourierc.jpg');
        
    imgc = uint8(real(ifft2(ifftshift(fftc))));
    imwrite(imgc, combfile);
end
