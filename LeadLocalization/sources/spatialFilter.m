function outputImage = spatialFilter( NifTi, method, varargin )

outputImage = NifTi;
switch method
    case 'entropy'
        for k = 1:size(NifTi.img,3)
            outputImage.img(:,:,k) = entropyfilt(NifTi.img(:,:,k));
        end
    case 'diffusion'
        outputImage.img = CoherenceFilter(NifTi.img / NifTi.hdr.dime.glmax, []);
        outputImage.img = (outputImage.img - min(min(min(outputImage.img)))) * NifTi.hdr.dime.glmax;
    case 'laplacian'
        h = fspecial('laplacian', 0.05);
        outputImage.img = NifTi.img - imfilter(NifTi.img,h);
    case 'log'
        h = fspecial('log', [5 5], 0.5);
        outputImage.img = NifTi.img - imfilter(NifTi.img,h);
    case 'prewitt'
        h = fspecial('prewitt');
        outputImage.img = imfilter(NifTi.img,h);
    case 'bilateral'
        if nargin == 3
            for k = 1:size(NifTi.img,3)
                outputImage.img(:,:,k) = imbilatfilt(NifTi.img(:,:,k),varargin{1});
            end
        else
            for k = 1:size(NifTi.img,3)
                outputImage.img(:,:,k) = imbilatfilt(NifTi.img(:,:,k));
            end
        end
    otherwise
        disp('No Filter Used');
end