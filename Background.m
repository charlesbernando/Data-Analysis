% Loavvd h5 info
folder     = 'C:\Users\charles\Desktop\';%hitfinder_team/'; %Directory of H5 flies

filelist=dir('*.h5');

reartotal = zeros(1024,1044);
fronttotal = zeros(1024,1043);

for q=1:length(filelist(:,1))

run_num= filelist(q,:).name; % Run number

fileName = ([folder run_num]);
disp=['now loading ' fileName];
info = hdf5info(fileName);
num_images = size(filelist,1);


reartotal = reartotal + hdf5read(([folder filelist(q,:).name]),'/data/RearPnCCDLab'); %Rear detector raw data
fronttotal = fronttotal + hdf5read(([folder filelist(q,:).name]),'/data/FrontPnCCDLab'); %Front detector raw data

end

% Display and Save Images
close all

save_figure=1;  %Boolean to automatically save the figure
%You can set this to 0 and then use the matlab export function once the
%figure is porduced if you prefer.  

save_path='C:\Users\charles\Desktop\';

clear dat1
clear dat2

rearavg = reartotal/size(filelist,1);
frontavg = fronttotal/size(filelist,1);

    %Threshold all negative values to zero
    
    %Temp=RearHit{j};
    Temp1=rearavg;
    Temp2=frontavg;
    PlotOut1=0*Temp1;
    PlotOut2=0*Temp2;
    PlotOut1(Temp1>0)=Temp1(Temp1>0);
    PlotOut2(Temp2>0)=Temp2(Temp2>0);
    
    
    %Plot log of image
    dat1=log10(PlotOut1);
    dat2=log10(PlotOut2);
    
    figure(1);
    imagesc(dat1,[1,4]) %The last two numbers define the color range [0.5,4] means 10^0.5 to 10^4
    axis square
    colormap(jet(256))
    figure(2);
    imagesc(dat2,[2,5])
    axis square
    colormap(jet(256))
    %defines color map, during the run we used jet.  see doc colormap

    if (save_figure)
        %save picture, export png
        saveas(figure(1),[save_path,filelist(1,:).name(1:end-23),'-log-','rear-','background','.png'],'png')
        saveas(figure(2),[save_path,filelist(1,:).name(1:end-23),'-log-','front-','background','.png'],'png')

        
        %save data
        dlmwrite([save_path,'dats\',filelist(1,:).name(1:end-23),'-','rear-','background','.dat'], PlotOut1, 'delimiter', '\t', 'precision', 5)
        dlmwrite([save_path,'dats\',filelist(1,:).name(1:end-23),'-','front-','background','.dat'], PlotOut2, 'delimiter', '\t', 'precision', 5)
        %save([save_path,run_num(1:end-3),'-',fout(2:end),'.dat'],'PlotOut','-ascii','-tabs')
    %This saves each figure with the title runnumber-log-timestamp
    end
