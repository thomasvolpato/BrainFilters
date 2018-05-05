%normalize a matrix to a value from 0 to 255
function A = ToImage(dicom)
    maxD = double(max(max(dicom)));
    minD = min(min(dicom));
    A = uint8((double(dicom)./maxD)*256);
endfunction