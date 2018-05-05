%close all windows and clear console
close all; clear;

%import libraries
pkg load image;
pkg load dicom;

SHOWGRAPHICS = false; %Show Processed Images
HAT_TYPE = "Bottom"; %Top or Bottom
SE_SIZE = 7;  %Structing Element Size
SRC_FOLDER = ".\\DICOM\\"; %Source Folder
DST_FOLDER = ".\\news\\"; %Destination Folder

%plot configuration
M=2;
N=2;

%get all DICOM files from Source Folder
files = glob([SRC_FOLDER , "*.dcm"]);

disp(["Total of ",mat2str(size(files,1))," DICOM files."]);

for var = 1:size(files,1)
    
    if (SHOWGRAPHICS)
        pause(1);
        close all; %close previous windows
    endif

    %load DICOM image
    dicom = dicomread(files{var});
    dicomInfo = dicominfo(files{var});

    %TODO: fix this fields
    %Octave craches when try to save a dicom file when this fields exists
    %fields = fieldnames(dicomInfo);
    %crashFields = [32,33,34,50,259];
    %for i=1:length(crashFields)
    %    dicomInfo = rmfield(dicomInfo,fields{crashFields(i)});
    %endfor

    Q1 = dicom;

    if (SHOWGRAPHICS)
        figure
        subplot(M,N,1)
        imshow(ToImage(Q1));
        title("Original");
    endif

    %structing element
    se = strel("disk",SE_SIZE,0);

    %TopHat / BottomHat operation
    hatFilter = [];
    if (strcmp(HAT_TYPE,"Top"))
        hatFilter = imtophat (Q1, se);
    else
        hatFilter = imbothat (Q1, se);
    endif
    
    if (SHOWGRAPHICS)
        subplot(M,N,2)
        imshow(ToImage(hatFilter));
        title("TopHat Filtered");
    endif
    
    %TopHat / BottomHat intensity
    maxD = max(max(hatFilter));
    FNorm = double(hatFilter)./double(maxD);
    FNorm = 1-FNorm;

    G = Q1 .*(FNorm);    %new dicom image

    if (SHOWGRAPHICS)
        H = (abs(Q1-G))*255; %difference (Debug only)

        subplot(M,N,3)
        imshow(ToImage(G));
        title("New Image");

        subplot(M,N,4);
        imshow(ToImage(H));
        title("Different Pixels");
    endif

    %imwrite(ToImage(Q1),"Q1.png"); %print new Dicom image in PNG
    
    %save DICOM file
    newDicomName = substr(files{var},length(SRC_FOLDER)+1,length(files{var})-length(SRC_FOLDER));
    info.("InstanceNumber") = dicomInfo.("InstanceNumber"); %index of the slice
    dicomwrite(G, [DST_FOLDER, newDicomName],info);
    
    %display conversion progress
    disp([mat2str(int16(100*var/size(files,1))),"% (",mat2str(var),"/",mat2str(size(files,1)),")."]);

endfor