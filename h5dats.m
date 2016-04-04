% Load h5 info
%folder     = '/reg/data/ana03/amo/amo54912/ftc/';%hitfinder_team/'; %Directory of H5 flies
folder = 'C:\Users\charles\Desktop\';
filelist= [
    'run220.h5';
    %'run110.h5';
    %'run112.h5';
    %'run113.h5';
    %'run114.h5';
    %'run115.h5';
    %'run75.h5';
    %'run96.h5';
    %'run98.h5';
    %'run99.h5';
    %'run93.h5';
    %'run92.h5';
    %'run91.h5';
    %'run88.h5';
    %'run87.h5';
    %'run86.h5';
    %'run82.h5';
    %'run77.h5';
    %'run73.h5';
    ];
    

for q=1:length(filelist(:,1))

run_num= filelist(q,:); % Run number


fileName = ([folder run_num]);
disp=['now loading' fileName]
info = hdf5info(fileName);
num_images = size(info.GroupHierarchy.Groups.Groups,2)

% Load Images to Memory
images_to_load=1:num_images;

%Load Data
clear FrontHit
clear ToF
clear ToFaxis
clear Second
clear Nanosecond
clear Fiducial
hit_ind=[];

for i=1:length(images_to_load)
      j=images_to_load(i);
      FrontHit{i}=hdf5read(info.GroupHierarchy.Groups.Groups(1,j).Datasets(1,4)); %Front detector raw data
      Second{i}=hdf5read(info.GroupHierarchy.Groups.Groups(1,j).Datasets(1,6)); %Unix time stamp
      Nanosecond{i}=hdf5read(info.GroupHierarchy.Groups.Groups(1,j).Datasets(1,5)); %The elapsed time in nanosecond from the Unix time stamp
      Fiducial{i}=hdf5read(info.GroupHierarchy.Groups.Groups(1,j).Datasets(1,3)); %Time stamp of the XFEL
      ToF{i}=hdf5read(info.GroupHierarchy.Groups.Groups(1,j).Datasets(1,1)); %Time of flight
      ToFaxis{i}=hdf5read(info.GroupHierarchy.Groups.Groups(1,j).Datasets(1,2)); %Time of flight axis
      hit_ind=[hit_ind,j];     
end

% Display and Save Images
close all

save_figure=1;  %Boolean to automatically save the figure
%You can set this to 0 and then use the matlab export function once the
%figure is porduced if you prefer.  

save_path='C:\Users\charles\Desktop\';

clear dat
clear tof

for j=1:length(hit_ind)
    
    tof(:,1) = ToFaxis{j}(:,1);
    tof(:,2) = ToF{j}(:,1);
    
    figure('visible','off')
    
    Temp=FrontHit{j};
    PlotOut1=0*Temp;
    PlotOut1(Temp>0)=Temp(Temp>0);
    PlotOut2 = plot(tof(:,1),tof(:,2));
    
    %Plot log of image
    dat=log10(PlotOut1);
    
    mycolormap = jet(256);
    %mycolormap(1,:) = [1 1 1];
    
    second=num2str(Second{j});
    nanosecond=num2str(Nanosecond{j});
    fiducial=num2str(Fiducial{j});
    
    k=2:length(ToF{1,j})-1;
    
    figure(1);
    imagesc(dat,[2,3.4]) %The last two numbers define the color range [0.5,4] means 10^0.5 to 10^4
    axis image
    colormap(mycolormap) %defines color map, during the run we used jet.  see doc colormap
    title([run_num(1:end-3),'-',second,'-',nanosecond,'-',fiducial,'-log'])
    figure(2);
    plot(tof(k,1),tof(k,2))
    title([run_num(1:end-3),'-',second,'-',nanosecond,'-',fiducial,'-tof'])
    

    if (save_figure)
        %save picture, export png
        saveas(figure(1),[save_path,'imgs/',run_num(1:end-3),'-',second,'-',nanosecond,'-',fiducial,'-log','.png'],'png')
        saveas(figure(2),[save_path,'imgs/',run_num(1:end-3),'-',second,'-',nanosecond,'-',fiducial,'-tof','.png'],'png')
        
        %save data
        dlmwrite([save_path,'dats/',run_num(1:end-3),'-',second,'-',nanosecond,'-',fiducial,'-img','.dat'], PlotOut1, 'delimiter', '\t', 'precision', 5)
        dlmwrite([save_path,'dats/',run_num(1:end-3),'-',second,'-',nanosecond,'-',fiducial,'-tof','.dat'], tof, 'delimiter', '\t', 'precision', 5)
        %save([save_path,run_num(1:end-3),'-',fout(2:end),'.dat'],'PlotOut','-ascii','-tabs')
    end
    %This saves each figure with the title runnumber-log-timestamp
end

end

%% Filename

