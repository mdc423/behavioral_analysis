%{
MDC open field analysis

Go through excel sheets in directory and only save relevant information
Should have the option to append to already existing data, or create a new
.mat file

structure:
keep.(bin_type).data
%}

%% read in excel files (RAW output) and save data
% select folder path
path_dir = uigetdir;

% move to directory
cd(path_dir);

% find all files with .xlsx file format in directory

% option to select only certain excel files OR all
[excel_name,excel_path,~] = uigetfile({'*.*'},'select one or more files','MultiSelect','on');

% if only 1 file selected, it will put name into cell to match format if multiple
% are selected. makes things easier later.
if ~iscell(excel_name)
    excel_name = {excel_name};
    excel_path = {excel_path};
end

if isequal(excel_name,0)
   disp('User selected Cancel')
else
   sprintf('User selected %d file(s)', size(excel_name,2))
end


% option to load in existing .mat file to append data
% if yes, will load in data and append so everything will be in one file
% if no, then a new .mat file will be saved
answer = questdlg('load existing .mat file?','mat file question','yes','no','no');
switch answer
    case 'yes'
        [mat_name,mat_path,~] = uigetfile({'*.*'},'select one or more files','MultiSelect','on');
        keep = load(fullfile(mat_path, mat_name));
    case 'no'
        disp('no .mat file selected');
        mat_path = excel_path;
    case 'Cancel'
        disp('no .mat file selected');
end

%% Read excel workbook
% stores output into variable 'keep'

% read and store data
for file_num = 1:size(excel_name,2)
    fprintf('processing file %d...\n',file_num)

    % reads in .txt file from Noldus, keep all raw data and info
    [~,sheets] = xlsfinfo([path_dir,'\',excel_name{file_num}]); %v2018

% what tabs/sheets of the excel file are of importance?
    sheets2analyze = sheets([3,4]); % tabs of interst are 3 and 4
    sheets2analyze2 = replace(sheets2analyze,{' '},{'_'});

    for sheet_num = 1:length(sheets2analyze)
        [num,txt,raw]=xlsread(excel_name{file_num},sheets2analyze{sheet_num}); %v2018
        num = num(3:end,:);

        header={raw{1,3:end}}; % find column titles of first row from column 3 onwards
        % find column index with param names
        header_idx=find(cell2mat(cellfun(@(x) length(ismissing(x))>1,header,'UniformOutput',false)));
        header_name = unique({raw{1,header_idx+2}},'stable'); % add 2 for ignoring time columns
        header_name2 = replace(header_name,{' ','%','-','/','>'},{'_','P','_','_','to'});

        animal_row={raw{2,3:end}}; % find column titles of second row from column 3 onwards
        animal_idx=find(cell2mat(cellfun(@(x) length(ismissing(x))>1,animal_row,'UniformOutput',false)));
        animal_name = unique({raw{2,animal_idx+2}},'stable');
        animal_name2 = strcat('a',animal_name);


        for animal_num = 1:length(animal_name)-2 % fix this; don't count avg + sem            
            for header_num = 1:length(header_name)
                keep.(sheets2analyze2{sheet_num})(animal_num).animal_ID = animal_name2{animal_num};
                keep.(sheets2analyze2{sheet_num})(animal_num).time = num(:,1);
                keep.(sheets2analyze2{sheet_num})(animal_num).bin = num(:,2);
                keep.(sheets2analyze2{sheet_num})(animal_num).(header_name2{header_num}) = ...
                    num(1:end,header_idx(header_num)+2+animal_num-1);                
            end
        end
    end
end

disp('finished')

%% save some pathways
% save data: save filed of keep structure as individual variables
save(strcat('dat_out',datestr(now,'yyyymmdd')),'-struct','keep');

%% Define Variables

% labels **WILL NEED TO CHANGE FOR EACH EXCEL FILE**
name = 'PV-GPe-ChR2 DD';
cell_type_legend = 'PV-GPe-ChR2 DD';
cohort_N = 6; % change with how many total mice
cohort_total = 1:6; % for individual mouse graphs



% stim colors
Arch = [0.4660 0.6740 0.1880]; % green
ChR2 = [0.3010 0.7450 0.9330]; % blue
crimson = [0.8500 0.3250 0.0980]; % orange
orange = [0.9290 0.6940 0.1250]; % orange
black = [0 0 0];

% cell colors
PV = [0.6350 0.0780 0.1840]; % red
PV_2 = [0.8350 0.0780 0.1040]; % red
Lhx6 = [0.3010 0.7450 0.9330]; % blue
NPas = [0.4940 0.1840 0.5560]; % purple
Vglut2 = [0.4660 0.6740 0.1880]; 
ChAT = [0.9290 0.6940 0.1250]; 
Vgat = [0 0.4470 0.7410]; 
D1 = [0 0.4470 0.7410]; % dark blue
D2 = [0.6350 0.0780 0.1840]; % red
colormap hot

% chosen colors - CHANGE AS NEEDED**
stim_color = ChR2;
cell_type = PV;

% stim related times
pre_stim_times = [21:7:84];
stim_times = [22:7:85];
stim_off_times = [26:7:89];
post_stim_times = [23:7:86];

% cohort averages
%velocity
vel_limit = 1.2;

all_vel_1 = [keep.RAW_1_sec_bin.Velocity_Center_point_Mean_cm_s];
avg_vel_1 = nanmean(all_vel_1,2);
vel_true_1 = avg_vel_1;
avg_vel_less_1 = avg_vel_1<vel_limit;
vel_true_1(avg_vel_less_1) = 0;
all_vel_1h_1 = vel_true_1(1:121,:);
vel_true_1 = vel_true_1(1:14400);
all_vel_30 = [keep.RAW_30_sec_bin.Velocity_Center_point_Mean_cm_s];
avg_vel_30 = nanmean(all_vel_30,2);
vel_true_30 = avg_vel_30;
avg_vel_less_30 = avg_vel_30<vel_limit;
vel_true_30(avg_vel_less_30) = 0;
all_vel_1h_30 = vel_true_30(1:121,:);
vel_true_30 = vel_true_30(1:480);

%distance
vel_limit = 1.2;

all_dist_1 = [keep.RAW_1_sec_bin.Distance_Moved_center_point_total_cm];
avg_dist_1 = nanmean(all_dist_1,2);
dist_true_1 = avg_dist_1;
avg_vel_less_1 = avg_vel_1<vel_limit;
avg_vel_greater = avg_vel_1>vel_limit;
dist_true_1(avg_vel_less_1) = 0;
avg_dist_1h_1 = dist_true_1(1:3600,:);
dist_true_1 = dist_true_1(1:14400);
all_dist_30 = [keep.RAW_30_sec_bin.Distance_Moved_center_point_total_cm];
avg_dist_30 = nanmean(all_dist_30,2);
dist_true_30 = avg_dist_30;
avg_vel_less_30 = avg_vel_30<vel_limit;
avg_vel_greater = avg_vel_30>vel_limit;
dist_true_30(avg_vel_less_30) = 0;
avg_dist_1h_30 = dist_true_30(1:121,:);
dist_true_30 = dist_true_30(1:480);

%ambulation
vel_limit = 1.2;

all_amb_1 = [keep.RAW_1_sec_bin.Ambulation];
avg_amb_1 = nanmean(all_amb_1,2);
amb_true_1 = avg_amb_1;
avg_vel_less_1 = avg_vel_1<vel_limit;
avg_vel_greater = avg_vel_1>vel_limit;
amb_true_1(avg_vel_less_1) = 0;
amb_true_1(avg_vel_greater) = 1;
avg_amb_1h_1 = amb_true_1(1:3600,:);
amb_true_1 = amb_true_1(1:14400);

all_amb_30 = [keep.RAW_30_sec_bin.Ambulation];
avg_amb_30 = nanmean(all_amb_30,2);
amb_true_30 = avg_amb_30;
avg_amb_1h_30 = amb_true_30(1:121,:);
amb_true_30 = amb_true_30(1:480);
amb_sem = std(all_amb_30,0,2,'omitnan')/sqrt(cohort_N);
pre_stim1_amb_sem = amb_sem(21);
pre_stim2_amb_sem = amb_sem(28);
pre_stim3_amb_sem = amb_sem(35);
pre_stim4_amb_sem = amb_sem(42);
pre_stim5_amb_sem = amb_sem(49);
pre_stim6_amb_sem = amb_sem(56);
pre_stim7_amb_sem = amb_sem(63);
pre_stim8_amb_sem = amb_sem(70);
pre_stim9_amb_sem = amb_sem(77);
pre_stim10_amb_sem = amb_sem(84);
stim1_amb_sem = amb_sem(22);
stim2_amb_sem = amb_sem(29);
stim3_amb_sem = amb_sem(36);
stim4_amb_sem = amb_sem(43);
stim5_amb_sem = amb_sem(50);
stim6_amb_sem = amb_sem(57);
stim7_amb_sem = amb_sem(64);
stim8_amb_sem = amb_sem(71);
stim9_amb_sem = amb_sem(78);
stim10_amb_sem = amb_sem(85);
post_stim1_amb_sem = amb_sem(23);
post_stim2_amb_sem = amb_sem(30);
post_stim3_amb_sem = amb_sem(37);
post_stim4_amb_sem = amb_sem(44);
post_stim5_amb_sem = amb_sem(51);
post_stim6_amb_sem = amb_sem(58);
post_stim7_amb_sem = amb_sem(65);
post_stim8_amb_sem = amb_sem(72);
post_stim9_amb_sem = amb_sem(79);
post_stim10_amb_sem = amb_sem(86);
sem_amb_30 = amb_sem;
sem_amb_30_1h = sem_amb_30(1:121);

%freezing
frz_limit = 0.5;

all_frz_1 = [keep.RAW_1_sec_bin.Freezing];
avg_frz_1 = nanmean(all_frz_1,2);
avg_frz_less_1 = avg_frz_1<frz_limit;
avg_frz_greater_1 = avg_frz_1>frz_limit;
frz_true_1 = avg_frz_1<frz_limit;
frz_true_1(avg_frz_less_1) = 0;
frz_true_1(avg_frz_greater_1) = 1;
amb_limit = 0.9;
avg_frz_less_1 = amb_true_1>amb_limit;
frz_true_1(avg_frz_less_1) = 0;
frz_true_1 = frz_true_1(1:14400);


all_frz_30 = [keep.RAW_30_sec_bin.Freezing];
avg_frz_30 = nanmean(all_frz_30,2);
frz_true_30 = avg_frz_30;
avg_frz_1h_30 = frz_true_30(1:121,:);
frz_true_30 = avg_frz_30(1:480);
frz_sem = std(all_frz_30,0,2,'omitnan')/sqrt(cohort_N);
pre_stim1_frz_sem = frz_sem(21);
pre_stim2_frz_sem = frz_sem(28);
pre_stim3_frz_sem = frz_sem(35);
pre_stim4_frz_sem = frz_sem(42);
pre_stim5_frz_sem = frz_sem(49);
pre_stim6_frz_sem = frz_sem(56);
pre_stim7_frz_sem = frz_sem(63);
pre_stim8_frz_sem = frz_sem(70);
pre_stim9_frz_sem = frz_sem(77);
pre_stim10_frz_sem = frz_sem(84);
stim1_frz_sem = frz_sem(22);
stim2_frz_sem = frz_sem(29);
stim3_frz_sem = frz_sem(36);
stim4_frz_sem = frz_sem(43);
stim5_frz_sem = frz_sem(50);
stim6_frz_sem = frz_sem(57);
stim7_frz_sem = frz_sem(64);
stim8_frz_sem = frz_sem(71);
stim9_frz_sem = frz_sem(78);
stim10_frz_sem = frz_sem(85);
post_stim1_frz_sem = frz_sem(23);
post_stim2_frz_sem = frz_sem(30);
post_stim3_frz_sem = frz_sem(37);
post_stim4_frz_sem = frz_sem(44);
post_stim5_frz_sem = frz_sem(51);
post_stim6_frz_sem = frz_sem(58);
post_stim7_frz_sem = frz_sem(65);
post_stim8_frz_sem = frz_sem(72);
post_stim9_frz_sem = frz_sem(79);
post_stim10_frz_sem = frz_sem(86);
sem_frz_30 = frz_sem;
sem_frz_30_1h = sem_frz_30(1:121);


%fine movement

all_fm_1 = [keep.RAW_1_sec_bin.Fine_Movement];
avg_fm_1 = nanmean(all_fm_1,2);
fm_true_1 = ~any([amb_true_1 frz_true_1],2);
avg_fm_1h_1 = fm_true_1(1:121,:);
amb_limit = 0.9;
avg_fm_less_1 = amb_true_1>amb_limit;
fm_true_1(avg_fm_less_1) = 0;
fm_true_1 = fm_true_1(1:14400);

all_fm_30 = [keep.RAW_30_sec_bin.Fine_Movement];
avg_fm_30 = nanmean(all_fm_30,2);
fm_true_30 = avg_fm_30;
avg_fm_1h_30 = fm_true_30(1:121,:);
fm_true_30 = avg_fm_30(1:480);
fm_sem = std(all_fm_30,0,2,'omitnan')/sqrt(cohort_N);
pre_stim1_fm_sem = fm_sem(21);
pre_stim2_fm_sem = fm_sem(28);
pre_stim3_fm_sem = fm_sem(35);
pre_stim4_fm_sem = fm_sem(42);
pre_stim5_fm_sem = fm_sem(49);
pre_stim6_fm_sem = fm_sem(56);
pre_stim7_fm_sem = fm_sem(63);
pre_stim8_fm_sem = fm_sem(70);
pre_stim9_fm_sem = fm_sem(77);
pre_stim10_fm_sem = fm_sem(84);
stim1_fm_sem = fm_sem(22);
stim2_fm_sem = fm_sem(29);
stim3_fm_sem = fm_sem(36);
stim4_fm_sem = fm_sem(43);
stim5_fm_sem = fm_sem(50);
stim6_fm_sem = fm_sem(57);
stim7_fm_sem = fm_sem(64);
stim8_fm_sem = fm_sem(71);
stim9_fm_sem = fm_sem(78);
stim10_fm_sem = fm_sem(85);
post_stim1_fm_sem = fm_sem(23);
post_stim2_fm_sem = fm_sem(30);
post_stim3_fm_sem = fm_sem(37);
post_stim4_fm_sem = fm_sem(44);
post_stim5_fm_sem = fm_sem(51);
post_stim6_fm_sem = fm_sem(58);
post_stim7_fm_sem = fm_sem(65);
post_stim8_fm_sem = fm_sem(72);
post_stim9_fm_sem = fm_sem(79);
post_stim10_fm_sem = fm_sem(86);
sem_fm_30 = fm_sem;
sem_fm_30_1h = sem_fm_30(1:121);

%immobility
imm_limit = 0.9;

all_imm_1 = [keep.RAW_1_sec_bin.P_Immobile];
avg_imm_1 = nanmean(all_imm_1,2);
sem_imm_1 = nanstd(all_imm_1,[],2)/sqrt(cohort_N);
imm_true_1 = avg_imm_1; 
avg_imm_less_1 = frz_true_1<imm_limit;
imm_true_1(avg_frz_less_1) = 0;
imm_true_1 = imm_true_1(1:14400);

all_imm_30 = [keep.RAW_30_sec_bin.P_Immobile];
avg_imm_30 = nanmean(all_imm_30,2);
sem_imm_30 = nanstd(all_imm_30,[],2)/sqrt(cohort_N);
imm_true_30 = avg_imm_30; 
imm_true_30 = imm_true_30(1:480);
imm_sem = std(all_imm_30,0,2,'omitnan')/sqrt(cohort_N);
pre_stim1_imm_sem = imm_sem(21);
pre_stim2_imm_sem = imm_sem(28);
pre_stim3_imm_sem = imm_sem(35);
pre_stim4_imm_sem = imm_sem(43);
pre_stim5_imm_sem = imm_sem(49);
pre_stim6_imm_sem = imm_sem(56);
pre_stim7_imm_sem = imm_sem(63);
pre_stim8_imm_sem = imm_sem(70);
pre_stim9_imm_sem = imm_sem(77);
pre_stim10_imm_sem = imm_sem(84);
stim1_imm_sem = imm_sem(22);
stim2_imm_sem = imm_sem(29);
stim3_imm_sem = imm_sem(36);
stim4_imm_sem = imm_sem(43);
stim5_imm_sem = imm_sem(50);
stim6_imm_sem = imm_sem(57);
stim7_imm_sem = imm_sem(64);
stim8_imm_sem = imm_sem(71);
stim9_imm_sem = imm_sem(78);
stim10_imm_sem = imm_sem(85);
post_stim1_imm_sem = imm_sem(23);
post_stim2_imm_sem = imm_sem(30);
post_stim3_imm_sem = imm_sem(37);
post_stim4_imm_sem = imm_sem(44);
post_stim5_imm_sem = imm_sem(51);
post_stim6_imm_sem = imm_sem(58);
post_stim7_imm_sem = imm_sem(65);
post_stim8_imm_sem = imm_sem(72);
post_stim9_imm_sem = imm_sem(79);
post_stim10_imm_sem = imm_sem(86);
sem_imm_30 = imm_sem;
sem_imm_30_1h = sem_imm_30(1:121);


% convert decimal to time format in matlab
a = datetime(keep.RAW_30_sec_bin(1).time,'convertfrom','excel');
a.Format = 'HH.mm.ss';

d = datetime(datestr(keep.RAW_1_sec_bin(1).time,'HH:MM:SS'),'InputFormat','HH:mm:ss');
sec_1 = (d-d(1)) * (24 * 60 * 60);
min_1 = (d-d(1)) * (24 * 60);
hrs_1 = (d-d(1));
t_1 = hrs_1;
t_1 = t_1(1:14400);
t_1h_1 = t_1(1:630,:);

% bin the data!
bin_size = 30; % 30 = 30sec bins;
time_bin_times = [1:30:14400]; % time needs to be every 30 sec rather than the average of each 30 seconds
time_bin = t_1(time_bin_times);
time_bin_1h = time_bin(1:121);

imm_bin = imm_true_30;
imm_bin_1h = imm_bin(1:121);
vel_bin = vel_true_30;
vel_bin_1h = vel_bin(1:121);
dist_bin = dist_true_30;
dist_bin_1h = dist_bin(1:121);
amb_bin = amb_true_30;
amb_bin_1h = amb_bin(1:121);
fm_bin = fm_true_30;
fm_bin_1h = fm_bin(1:121);
frz_bin = frz_true_30;
frz_bin_1h = frz_bin(1:121);


% stim overlay variables
% stim 1
pre_stim1_time = datenum(time_bin(21,:));
stim1_time = datenum(time_bin(22,:));
post_stim1_time = datenum(time_bin(23,:));
stim1_color = [.04170 0 0];
% immobility
pre_stim1_imm = mean(imm_bin(21));    
stim1_imm = mean(imm_bin(22));    
post_stim1_imm = mean(imm_bin(23));
% velocity
pre_stim1_vel = mean(vel_bin(21));
stim1_vel = mean(vel_bin(22));
post_stim1_vel = mean(vel_bin(23));
% ambulation
pre_stim1_amb = mean(amb_bin(21));
stim1_amb = mean(amb_bin(22));
post_stim1_amb = mean(amb_bin(23));
off_stim1_amb = mean(amb_bin(26));
% fine movement
pre_stim1_fm = mean(fm_bin(21));
stim1_fm = mean(fm_bin(22));
post_stim1_fm = mean(fm_bin(23));
off_stim1_fm = mean(fm_bin(26));
% freezing
pre_stim1_frz = mean(frz_bin(21));
stim1_frz = mean(frz_bin(22));
post_stim1_frz = mean(frz_bin(23));
% distance
pre_stim1_dist = sum(dist_bin(21));
stim1_dist = sum(dist_bin(22));
post_stim1_dist = sum(dist_bin(23));

% stim 2
pre_stim2_time = datenum(time_bin(28,:));    
stim2_time = datenum(time_bin(29,:));    
post_stim2_time = datenum(time_bin(30,:));    
stim2_color = [.2500 0 0];
% immobility
pre_stim2_imm = mean(imm_bin(28));
stim2_imm = mean(imm_bin(29));
post_stim2_imm = mean(imm_bin(30));
% velocity
pre_stim2_vel = mean(vel_bin(28));
stim2_vel = mean(vel_bin(29));
post_stim2_vel = mean(vel_bin(30));
% ambulation
pre_stim2_amb = mean(amb_bin(28));
stim2_amb = mean(amb_bin(29));
post_stim2_amb = mean(amb_bin(30));
off_stim2_amb = mean(amb_bin(33));
% fine movement
pre_stim2_fm = mean(fm_bin(28));
stim2_fm = mean(fm_bin(29));
post_stim2_fm = mean(fm_bin(30));
off_stim2_fm = mean(fm_bin(33));
% freezing
pre_stim2_frz = mean(frz_bin(28));
stim2_frz = mean(frz_bin(29));
post_stim2_frz = mean(frz_bin(30));
% distance
pre_stim2_dist = sum(dist_bin(28));
stim2_dist = sum(dist_bin(29));
post_stim2_dist = sum(dist_bin(30));

% stim 3
pre_stim3_time = datenum(time_bin(35,:));    
stim3_time = datenum(time_bin(36,:));    
post_stim3_time = datenum(time_bin(37,:));    
stim3_color = [.4583 0 0];
% immobility
pre_stim3_imm = mean(imm_bin(35));
stim3_imm = mean(imm_bin(36));
post_stim3_imm = mean(imm_bin(37));
% velocity
pre_stim3_vel = mean(vel_bin(35));
stim3_vel = mean(vel_bin(36));
post_stim3_vel = mean(vel_bin(37));
% ambulation
pre_stim3_amb = mean(amb_bin(35));
stim3_amb = mean(amb_bin(36));
post_stim3_amb = mean(amb_bin(37));
off_stim3_amb = mean(amb_bin(40));
% fine movement
pre_stim3_fm = mean(fm_bin(35));
stim3_fm = mean(fm_bin(36));
post_stim3_fm = mean(fm_bin(37));
off_stim3_fm = mean(fm_bin(40));
% freezing
pre_stim3_frz = mean(frz_bin(35));
stim3_frz = mean(frz_bin(36));
post_stim3_frz = mean(frz_bin(37));
% distance
pre_stim3_dist = sum(dist_bin(35));
stim3_dist = sum(dist_bin(36));
post_stim3_dist = sum(dist_bin(37));

% stim 4
pre_stim4_time = datenum(time_bin(42,:));    
stim4_time = datenum(time_bin(43,:));    
post_stim4_time = datenum(time_bin(44,:));    
stim4_color = [.6667 0 0];
% immobility
pre_stim4_imm = mean(imm_bin(42));
stim4_imm = mean(imm_bin(43));
post_stim4_imm = mean(imm_bin(44));
% velocity
pre_stim4_vel = mean(vel_bin(42));
stim4_vel = mean(vel_bin(43));
post_stim4_vel = mean(vel_bin(44));
% ambulation
pre_stim4_amb = mean(amb_bin(42));
stim4_amb = mean(amb_bin(43));
post_stim4_amb = mean(amb_bin(44));
off_stim4_amb = mean(amb_bin(47));
% fine movement
pre_stim4_fm = mean(fm_bin(42));
stim4_fm = mean(fm_bin(43));
post_stim4_fm = mean(fm_bin(44));
off_stim4_fm = mean(fm_bin(47));
% freezing
pre_stim4_frz = mean(frz_bin(42));
stim4_frz = mean(frz_bin(43));
post_stim4_frz = mean(frz_bin(44));
% distance
pre_stim4_dist = sum(dist_bin(42));
stim4_dist = sum(dist_bin(43));
post_stim4_dist = sum(dist_bin(44));

% stim 5
pre_stim5_time = datenum(time_bin(49,:));    
stim5_time = datenum(time_bin(50,:));    
post_stim5_time = datenum(time_bin(51,:));    
stim5_color = [.8750 0 0];
% immobility
pre_stim5_imm = mean(imm_bin(49));
stim5_imm = mean(imm_bin(50));
post_stim5_imm = mean(imm_bin(51));
% velocity
pre_stim5_vel = mean(vel_bin(49));
stim5_vel = mean(vel_bin(50));
post_stim5_vel = mean(vel_bin(51));
% ambulation
pre_stim5_amb = mean(amb_bin(49));
stim5_amb = mean(amb_bin(50));
post_stim5_amb = mean(amb_bin(51));
off_stim5_amb = mean(amb_bin(54));
% fine movement
pre_stim5_fm = mean(fm_bin(49));
stim5_fm = mean(fm_bin(50));
post_stim5_fm = mean(fm_bin(51));
off_stim5_fm = mean(fm_bin(54));
% freezing
pre_stim5_frz = mean(frz_bin(49));
stim5_frz = mean(frz_bin(50));
post_stim5_frz = mean(frz_bin(51));
% distance
pre_stim5_dist = sum(dist_bin(49));
stim5_dist = sum(dist_bin(50));
post_stim5_dist = sum(dist_bin(51));

% stim 6
pre_stim6_time = datenum(time_bin(56,:));    
stim6_time = datenum(time_bin(57,:));    
post_stim6_time = datenum(time_bin(58,:));
stim6_color = [1 .0833 0];
% immobility
pre_stim6_imm = mean(imm_bin(56));
stim6_imm = mean(imm_bin(57));
post_stim6_imm = mean(imm_bin(58));
% velocity
pre_stim6_vel = mean(vel_bin(56));
stim6_vel = mean(vel_bin(57));
post_stim6_vel = mean(vel_bin(58));
% ambulation
pre_stim6_amb = mean(amb_bin(56));
stim6_amb = mean(amb_bin(57));
post_stim6_amb = mean(amb_bin(58));
off_stim6_amb = mean(amb_bin(61));
% fine movement
pre_stim6_fm = mean(fm_bin(56));
stim6_fm = mean(fm_bin(57));
post_stim6_fm = mean(fm_bin(58));
off_stim6_fm = mean(fm_bin(61));
% freezing
pre_stim6_frz = mean(frz_bin(56));
stim6_frz = mean(frz_bin(57));
post_stim6_frz = mean(frz_bin(58));
% distance
pre_stim6_dist = sum(dist_bin(56));
stim6_dist = sum(dist_bin(57));
post_stim6_dist = sum(dist_bin(58));

% stim 7
pre_stim7_time = datenum(time_bin(63,:));    
stim7_time = datenum(time_bin(64,:));    
post_stim7_time = datenum(time_bin(65,:));    
stim7_color = [1 .2917 0];
% immobility
pre_stim7_imm = mean(imm_bin(63));
stim7_imm = mean(imm_bin(64));
post_stim7_imm = mean(imm_bin(65));
% velocity
pre_stim7_vel = mean(vel_bin(63));
stim7_vel = mean(vel_bin(64));
post_stim7_vel = mean(vel_bin(65));
% ambulation
pre_stim7_amb = mean(amb_bin(63));
stim7_amb = mean(amb_bin(64));
post_stim7_amb = mean(amb_bin(65));
off_stim7_amb = mean(amb_bin(68));
% fine movement
pre_stim7_fm = mean(fm_bin(63));
stim7_fm = mean(fm_bin(64));
post_stim7_fm = mean(fm_bin(65));
off_stim7_fm = mean(fm_bin(68));
% freezing
pre_stim7_frz = mean(frz_bin(63));
stim7_frz = mean(frz_bin(64));
post_stim7_frz = mean(frz_bin(65));
% distance
pre_stim7_dist = sum(dist_bin(63));
stim7_dist = sum(dist_bin(64));
post_stim7_dist = sum(dist_bin(65));

% stim 8
pre_stim8_time = datenum(time_bin(70,:));    
stim8_time = datenum(time_bin(71,:));
post_stim8_time = datenum(time_bin(72,:));    
stim8_color = [1 .5000 0];
% immobility
pre_stim8_imm = mean(imm_bin(70));
stim8_imm = mean(imm_bin(71));
post_stim8_imm = mean(imm_bin(72));
% velocity
pre_stim8_vel = mean(vel_bin(70));
stim8_vel = mean(vel_bin(71));
post_stim8_vel = mean(vel_bin(72));   
% ambulation
pre_stim8_amb = mean(amb_bin(70));
stim8_amb = mean(amb_bin(71));
post_stim8_amb = mean(amb_bin(72));
off_stim8_amb = mean(amb_bin(75));
% fine movement
pre_stim8_fm = mean(fm_bin(70));
stim8_fm = mean(fm_bin(71));
post_stim8_fm = mean(fm_bin(72));
off_stim8_fm = mean(fm_bin(75));
% freezing
pre_stim8_frz = mean(frz_bin(70));
stim8_frz = mean(frz_bin(71));
post_stim8_frz = mean(frz_bin(72));
% distance
pre_stim8_dist = sum(dist_bin(70));
stim8_dist = sum(dist_bin(71));
post_stim8_dist = sum(dist_bin(72));

% stim 9
pre_stim9_time = datenum(time_bin(77,:));    
stim9_time = datenum(time_bin(78,:));    
post_stim9_time = datenum(time_bin(79,:));    
stim9_color = [1 .7083 0];
% immobility
pre_stim9_imm = mean(imm_bin(77));
stim9_imm = mean(imm_bin(78));
post_stim9_imm = mean(imm_bin(79));
% velocity
pre_stim9_vel = mean(vel_bin(77));
stim9_vel = mean(vel_bin(78));
post_stim9_vel = mean(vel_bin(79));
% ambulation
pre_stim9_amb = mean(amb_bin(77));
stim9_amb = mean(amb_bin(78));
post_stim9_amb = mean(amb_bin(79));
off_stim9_amb = mean(amb_bin(82));
% fine movement
pre_stim9_fm = mean(fm_bin(77));
stim9_fm = mean(fm_bin(78));
post_stim9_fm = mean(fm_bin(79));
off_stim9_fm = mean(fm_bin(82));
% freezing
pre_stim9_frz = mean(frz_bin(77));
stim9_frz = mean(frz_bin(78));
post_stim9_frz = mean(frz_bin(79));
% distance
pre_stim9_dist = sum(dist_bin(77));
stim9_dist = sum(dist_bin(78));
post_stim9_dist = sum(dist_bin(79));

% stim 10
pre_stim10_time = datenum(time_bin(84,:));    
stim10_time = datenum(time_bin(85,:));    
post_stim10_time = datenum(time_bin(86,:));    
stim10_color = [1 .9167 0];
% immobility
pre_stim10_imm = mean(imm_bin(84));
stim10_imm = mean(imm_bin(85));
post_stim10_imm = mean(imm_bin(86));
% velocity
pre_stim10_vel = mean(vel_bin(84));
stim10_vel = mean(vel_bin(85));
post_stim10_vel = mean(vel_bin(86));
% ambulation
pre_stim10_amb = mean(amb_bin(84));
stim10_amb = mean(amb_bin(84));
post_stim10_amb = mean(amb_bin(86));
off_stim10_amb = mean(amb_bin(88));
% fine movement
pre_stim10_fm = mean(fm_bin(84));
stim10_fm = mean(fm_bin(85));
post_stim10_fm = mean(fm_bin(86));
off_stim10_fm = mean(fm_bin(88));
% freezing
pre_stim10_frz = mean(frz_bin(77));
stim10_frz = mean(frz_bin(85));
post_stim10_frz = mean(frz_bin(86));
% distance
pre_stim10_dist = sum(dist_bin(84));
stim10_dist = sum(dist_bin(85));
post_stim10_dist = sum(dist_bin(86));


% stim averages
pre_stim_amb_avg = mean(amb_bin(pre_stim_times));
stim_amb_avg = mean(amb_bin(stim_times));
post_stim_amb_avg = mean(amb_bin(post_stim_times));
pre_stim_fm_avg = mean(fm_bin(pre_stim_times));
stim_fm_avg = mean(fm_bin(stim_times));
post_stim_fm_avg = mean(fm_bin(post_stim_times));
pre_stim_frz_avg = mean(frz_bin(pre_stim_times));
stim_frz_avg = mean(frz_bin(stim_times));
post_stim_frz_avg = mean(frz_bin(post_stim_times));

% movement average variables
% P_ambulation averages
base_amb = mean(amb_bin(11:20)); % avg of 5 min before stim paradigm
all_base_amb = mean(amb_bin(1:20)); % avg of 10 min before stim paradigm
pre_amb = mean(amb_bin(pre_stim_times)); % avg of 30 sec before each stim
stim_amb = mean(amb_bin(stim_times)); % avg of 30 sec stims
early_stim_times = stim_times(1:3);  
stim_early_amb = mean(amb_bin(early_stim_times));
late_stim_times = stim_times(8:10);
stim_late_amb = mean(amb_bin(late_stim_times));
stim_off_amb =  mean(amb_bin(stim_off_times)); %2 minutes after each stim
early_stim_off_times = stim_off_times(1:3);
stim_early_off_amb = mean(amb_bin(early_stim_off_times));
late_stim_off_times = stim_off_times(8:10);
stim_late_off_amb = mean(amb_bin(late_stim_off_times));
post_amb = mean(amb_bin(post_stim_times)); % avg of 30 sec after each stim
post5_amb = mean(amb_bin(86:95)); % avg of 5 min after stim paradigm
amb_10post = mean(amb_bin(96:105));
amb_10post_all = mean(amb_bin(86:105)); % avg up to 10 min post stim paradigm
amb_30post = mean(amb_bin(141:150));
amb_30post_all = mean(amb_bin(86:145));
amb_1hrpost = mean(amb_bin(261:270));
amb_1hrpost_all = mean(amb_bin(86:205));
amb_2hrpost = mean(amb_bin(361:370));

pre_amb = mean(amb_bin(pre_stim_times));
stim_amb = mean(amb_bin(stim_times)); 
early_stim_times = stim_times(1:3);  
stim_early_amb = mean(amb_bin(early_stim_times));
late_stim_times = stim_times(8:10);
stim_late_amb = mean(amb_bin(late_stim_times));
stim_off_amb =  mean(amb_bin(stim_off_times));
early_stim_off_times = stim_off_times(1:3);
stim_early_off_amb = mean(amb_bin(early_stim_off_times));
late_stim_off_times = stim_off_times(8:10);
stim_late_off_amb = mean(amb_bin(late_stim_off_times));
post_amb = mean(amb_bin(post_stim_times));

pre_amb_sem = mean(amb_sem(pre_stim_times));
stim_amb_sem = mean(amb_sem(stim_times));
stim_early_amb_sem = mean(amb_sem(early_stim_times));
stim_late_amb_sem = mean(amb_sem(late_stim_times));
stim_off_amb_sem = mean(amb_sem(stim_off_times));
stim_early_off_amb_sem = mean(amb_sem(early_stim_off_times));
stim_late_off_amb_sem = mean(amb_sem(post_stim_times));
post_amb_sem = mean(amb_sem(late_stim_off_times));
base_amb_sem = mean(amb_sem(11:20));
all_base_amb_sem = mean(amb_sem(1:20));
post5_amb_sem = mean(amb_sem(86:90));
amb_10post_sem = mean(amb_sem(86:95));
amb_10post_all_sem = mean(amb_sem(86:105));
amb_30post_sem = mean(amb_sem(141:150));
amb_30post_all_sem = mean(amb_sem(86:145));
amb_1hrpost_sem = mean(amb_sem(261:270));
amb_1hrpost_all_sem = mean(amb_sem(86:205));
amb_2hrpost_sem = mean(amb_sem(361:370));


stim1_time = datenum(t_1(630,:));
stim1_amb_avg = mean(amb_true_1(630:660));
stim2_time = datenum(t_1(840,:));
stim2_amb_avg = mean(amb_true_1(840:870));
stim3_time = datenum(t_1(1050,:));
stim3_amb_avg = mean(amb_true_1(1050:1080));
stim4_time = datenum(t_1(1260,:));
stim4_amb_avg = mean(amb_true_1(1260:1290));
stim5_time = datenum(t_1(1470,:));
stim5_amb_avg = mean(amb_true_1(1470:1500));
stim6_time = datenum(t_1(1680,:));
stim6_amb_avg = mean(amb_true_1(1680:1710));
stim7_time = datenum(t_1(1890,:));
stim7_amb_avg = mean(amb_true_1(1890:1920));
stim8_time = datenum(t_1(2100,:));
stim8_amb_avg = mean(amb_true_1(2100:2130));
stim9_time = datenum(t_1(2310,:));
stim9_amb_avg = mean(amb_true_1(2310:2340));
stim10_time = datenum(t_1(2520,:));
stim10_amb_avg = mean(amb_true_1(2520:2550));

% movement averages of first 10 seconds of all stims
stim_time_1 = datenum(t_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520])); % first second of all stims
stim_amb_1 = mean(amb_true_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520]));
stim_time_2 = datenum(t_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521])); % second second of all stims
stim_amb_2 = mean(amb_true_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_time_3 = datenum(t_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_amb_3 = mean(amb_true_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_time_4 = datenum(t_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_amb_4 = mean(amb_true_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_time_5 = datenum(t_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_amb_5 = mean(amb_true_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_time_6 = datenum(t_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_amb_6 = mean(amb_true_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_time_7 = datenum(t_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_amb_7 = mean(amb_true_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_time_8 = datenum(t_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_amb_8 = mean(amb_true_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_time_9 = datenum(t_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_amb_9 = mean(amb_true_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_time_10 = datenum(t_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));
stim_amb_10 = mean(amb_true_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));

% P_fine_movement averages
base_fm = mean(fm_bin(11:20)); % avg of 5 min before stim paradigm
all_base_fm = mean(fm_bin(1:20));
pre_fm = mean(fm_bin(pre_stim_times)); % avg of 30 sec before each stim
stim_fm = mean(fm_bin(stim_times)); % avg of 30 sec stims
stim_off_fm =  mean(fm_bin(stim_off_times)); %2 minutes after each stim
early_stim_times = stim_times(1:3);  
stim_early_fm = mean(fm_bin(early_stim_times));
late_stim_times = stim_times(8:10);
stim_late_fm = mean(fm_bin(late_stim_times));
early_stim_off_times = stim_off_times(1:3);
stim_early_off_fm = mean(fm_bin(early_stim_off_times));
late_stim_off_times = stim_off_times(8:10);
stim_late_off_fm = mean(fm_bin(late_stim_off_times));
post_fm = mean(fm_bin(post_stim_times)); % avg of 30 sec after each stim
post5_fm = mean(fm_bin(86:96)); % avg of 5 min after stim paradigm
fm_10post = mean(fm_bin(96:105));
fm_10post_all = mean(fm_bin(86:105));
fm_30post = mean(fm_bin(141:150));
fm_30post_all = mean(fm_bin(86:145));
fm_1hrpost = mean(fm_bin(261:270));
fm_1hrpost_all = mean(fm_bin(86:205));
fm_2hrpost = mean(fm_bin(361:370));

pre_fm_sem = mean(fm_sem(pre_stim_times));
stim_fm_sem = mean(fm_sem(stim_times));
stim_early_fm_sem = mean(fm_sem(early_stim_times));
stim_late_fm_sem = mean(fm_sem(late_stim_times));
stim_off_fm_sem = mean(fm_sem(stim_off_times));
stim_early_off_fm_sem = mean(fm_sem(early_stim_off_times));
stim_late_off_fm_sem = mean(fm_sem(post_stim_times));
post_fm_sem = mean(fm_sem(late_stim_off_times));
base_fm_sem = mean(fm_sem(11:20));
all_base_fm_sem = mean(fm_sem(1:20));
post5_fm_sem = mean(fm_sem(86:90));
fm_10post_sem = mean(fm_sem(86:95));
fm_10post_all_sem = mean(fm_sem(86:105));
fm_30post_sem = mean(fm_sem(141:150));
fm_30post_all_sem = mean(fm_sem(86:145));
fm_1hrpost_sem = mean(fm_sem(261:270));
fm_1hrpost_all_sem = mean(fm_sem(86:205));
fm_2hrpost_sem = mean(fm_sem(361:370));


stim1_time = datenum(t_1(630,:));
stim1_fm_avg = mean(fm_true_1(630:660));
stim2_time = datenum(t_1(840,:));
stim2_fm_avg = mean(fm_true_1(840:870));
stim3_time = datenum(t_1(1050,:));
stim3_fm_avg = mean(fm_true_1(1050:1080));
stim4_time = datenum(t_1(1260,:));
stim4_fm_avg = mean(fm_true_1(1260:1290));
stim5_time = datenum(t_1(1470,:));
stim5_fm_avg = mean(fm_true_1(1470:1500));
stim6_time = datenum(t_1(1680,:));
stim6_fm_avg = mean(fm_true_1(1680:1710));
stim7_time = datenum(t_1(1890,:));
stim7_fm_avg = mean(fm_true_1(1890:1920));
stim8_time = datenum(t_1(2100,:));
stim8_fm_avg = mean(fm_true_1(2100:2130));
stim9_time = datenum(t_1(2310,:));
stim9_fm_avg = mean(fm_true_1(2310:2340));
stim10_time = datenum(t_1(2520,:));
stim10_fm_avg = mean(fm_true_1(2520:2550));

stim_time_1 = datenum(t_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520])); % first second of all stims
stim_fm_1 = mean(fm_true_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520]));
stim_time_2 = datenum(t_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_fm_2 = mean(fm_true_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_time_3 = datenum(t_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_fm_3 = mean(fm_true_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_time_4 = datenum(t_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_fm_4 = mean(fm_true_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_time_5 = datenum(t_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_fm_5 = mean(fm_true_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_time_6 = datenum(t_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_fm_6 = mean(fm_true_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_time_7 = datenum(t_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_fm_7 = mean(fm_true_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_time_8 = datenum(t_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_fm_8 = mean(fm_true_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_time_9 = datenum(t_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_fm_9 = mean(fm_true_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_time_10 = datenum(t_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));
stim_fm_10 = mean(fm_true_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));

% P_freezing averages
base_frz = mean(frz_bin(11:20));% avg of 5 min before stim paradigm
all_base_frz = mean(frz_bin(1:20));
pre_frz = mean(frz_bin(pre_stim_times)); % avg of 30 sec before each stim
stim_frz = mean(frz_bin(stim_times)); % avg of 30 sec stims
stim_off_frz =  mean(frz_bin(stim_off_times)); %2 minutes after each stim
early_stim_times = stim_times(1:3);  
stim_early_frz = mean(frz_bin(early_stim_times));
late_stim_times = stim_times(8:10);
stim_late_frz = mean(frz_bin(late_stim_times));
early_stim_off_times = stim_off_times(1:3);
stim_early_off_frz = mean(frz_bin(early_stim_off_times));
late_stim_off_times = stim_off_times(8:10);
stim_late_off_frz = mean(frz_bin(late_stim_off_times));
post_frz = mean(frz_bin(post_stim_times)); % avg of 30 sec after each stim
post5_frz = mean(frz_bin(86:96)); % avg of 5 min after stim paradigm
frz_10post = mean(frz_bin(96:105));
frz_10post_all = mean(frz_bin(86:105));
frz_30post = mean(frz_bin(141:150));
frz_30post_all = mean(frz_bin(86:145));
frz_1hrpost = mean(frz_bin(261:270));
frz_1hrpost_all = mean(frz_bin(86:205));
frz_2hrpost = mean(frz_bin(361:370));

pre_frz_sem = mean(frz_sem(pre_stim_times));
stim_frz_sem = mean(frz_sem(stim_times));
stim_early_frz_sem = mean(frz_sem(early_stim_times));
stim_late_frz_sem = mean(frz_sem(late_stim_times));
stim_off_frz_sem = mean(frz_sem(stim_off_times));
stim_early_off_frz_sem = mean(frz_sem(early_stim_off_times));
stim_late_off_frz_sem = mean(frz_sem(post_stim_times));
post_frz_sem = mean(frz_sem(late_stim_off_times));
base_frz_sem = mean(frz_sem(11:20));
all_base_frz_sem = mean(frz_sem(1:20));
post5_frz_sem = mean(frz_sem(86:90));
frz_10post_sem = mean(frz_sem(86:95));
frz_10post_all_sem = mean(frz_sem(86:105));
frz_30post_sem = mean(frz_sem(141:150));
frz_30post_all_sem = mean(frz_sem(86:145));
frz_1hrpost_sem = mean(frz_sem(261:270));
frz_1hrpost_all_sem = mean(frz_sem(86:205));
frz_2hrpost_sem = mean(frz_sem(361:370));


stim1_time = datenum(t_1(630,:));
stim1_frz_avg = mean(frz_true_1(630:660));
stim2_time = datenum(t_1(840,:));
stim2_frz_avg = mean(frz_true_1(840:870));
stim3_time = datenum(t_1(1050,:));
stim3_frz_avg = mean(frz_true_1(1050:1080));
stim4_time = datenum(t_1(1260,:));
stim4_frz_avg = mean(frz_true_1(1260:1290));
stim5_time = datenum(t_1(1470,:));
stim5_frz_avg = mean(frz_true_1(1470:1500));
stim6_time = datenum(t_1(1680,:));
stim6_frz_avg = mean(frz_true_1(1680:1710));
stim7_time = datenum(t_1(1890,:));
stim7_frz_avg = mean(frz_true_1(1890:1920));
stim8_time = datenum(t_1(2100,:));
stim8_frz_avg = mean(frz_true_1(2100:2130));
stim9_time = datenum(t_1(2310,:));
stim9_frz_avg = mean(frz_true_1(2310:2340));
stim10_time = datenum(t_1(2520,:));
stim10_frz_avg = mean(frz_true_1(2520:2550));

stim_time_1 = datenum(t_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520])); % first second of all stims
stim_frz_1 = mean(frz_true_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520]));
stim_time_2 = datenum(t_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_frz_2 = mean(frz_true_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_time_3 = datenum(t_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_frz_3 = mean(frz_true_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_time_4 = datenum(t_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_frz_4 = mean(frz_true_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_time_5 = datenum(t_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_frz_5 = mean(frz_true_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_time_6 = datenum(t_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_frz_6 = mean(frz_true_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_time_7 = datenum(t_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_frz_7 = mean(frz_true_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_time_8 = datenum(t_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_frz_8 = mean(frz_true_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_time_9 = datenum(t_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_frz_9 = mean(frz_true_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_time_10 = datenum(t_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));
stim_frz_10 = mean(frz_true_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));

% total distance traveled variables
dist_base = sum(dist_bin(1:11)); % total distance traveled (TDT) in first 5 minutes of trial
dist_pre = sum(dist_bin(pre_stim_times)); % TDT PRE all stims combined (5 minutes total)
dist_stims = sum(dist_bin(stim_times)); % TDT in all stims combined (5 minutes total)
dist_post = sum(dist_bin(post_stim_times)); % TDT POST all stims combined (5 minutes total)
dist_5post = sum(dist_bin(86:96)); % TDT in 5 minutes after stim paradigm
dist_10post = sum(dist_bin(101:111)); % TDT 10 minutes after stim paradigm (5 minute average 5 - 15 minutes out)
dist_30post = sum(dist_bin(141:151)); % TDT 30 minutes after stim paradigm (5 minute average 25 - 35 minutes out)
dist_1hrpost = sum(dist_bin(201:211)); % TDT 1 hr after stim paradigm (5 minute average 55 - 65 minutes out)

base_fm = 1 - (base_amb + base_frz);
pre_fm =1 - (pre_amb + pre_frz);
stim_fm = 1 - (stim_amb + stim_frz);
stim_off_fm =  1 - (stim_off_amb + stim_off_frz);
stim_early_fm = 1 - (stim_early_amb + stim_early_frz);
stim_late_fm = 1 - (stim_late_amb + stim_late_frz);
stim_early_off_fm = 1 - (stim_early_off_amb + stim_early_off_frz);
stim_late_off_fm = 1 - (stim_late_off_amb + stim_late_off_frz);
post_fm = 1 - (post_amb + post_frz);
post5_fm = 1 - (post5_amb + post5_frz);
fm_10post = 1 - (amb_10post + frz_10post);
fm_30post = 1 - (amb_30post + frz_30post);
fm_1hrpost = 1 - (amb_1hrpost + frz_1hrpost);
fm_2hrpost = 1 - (amb_2hrpost + frz_2hrpost);


% ambulation
base_amb = mean(amb_bin(1:21));
stim_early_amb = mean([stim1_amb stim2_amb stim3_amb stim4_amb]);
stim_late_amb = mean([stim7_amb stim8_amb stim9_amb stim10_amb]);
post1hr_amb_ = mean(amb_bin(87:207));
post4hr_amb_ = mean(amb_bin(360:480));


%% PERSISTENCE
figure('color','white'); hold on;

% average immobility at several time points after stim paradigm
subplot(4,4,[6 7 10 11]); hold on;

imm_bin_test = avg_imm_30(1:480);


% persistence variables (AVERAGE)
x_pre = mean(datenum(time_bin(12:21,:))); %first 5 min
y_pre = mean(imm_bin_test(12:21));
y_pre_sem = mean(imm_sem(12:21));
% avg of all stims
x_stim_all = mean(datenum(time_bin(85,:))); % x value is the time of the 10th stim but the y value is the average of all stims (5 min)
y_stim_all = mean(imm_bin_test(stim_times));
y_stim_all_sem = nanstd(imm_bin_test(stim_times))/sqrt(cohort_N);
% 10th stim
x_stim_last = mean(datenum(time_bin(85,:))); 
y_stim_last = mean(imm_bin_test(85,:));
y_stim_last_sem = mean(imm_sem(85,:));
% 1 hour post stim
x_1hour = mean(datenum(time_bin(112:131,:))); 
y_1hour = mean(imm_bin_test(112:131));
y_1hour_sem = mean(imm_sem(112:131));
% 1.5 hour post stim
x_midhour = mean(datenum(time_bin(172:191,:)));
y_midhour = mean(imm_bin_test(172:191));
y_midhour_sem = mean(imm_sem(172:191));
% 2 hour post stim
x_2hour = mean(datenum(time_bin(232:251,:)));
y_2hour = mean(imm_bin_test(232:251));
y_2hour_sem = mean(imm_sem(232:251));
% 3 hour post stim
x_3hour = mean(datenum(time_bin(352:371,:)));
y_3hour = mean(imm_bin_test(352:371));
y_3hour_sem = mean(imm_sem(352:371));
% 4 hour post stim
x_4hour = mean(datenum(time_bin(462:480,:)));
y_4hour = mean(imm_bin_test(462:480));
y_4hour_sem = mean(imm_sem(462:480));


% plot the data
x = [x_pre x_stim_last x_1hour x_midhour x_2hour x_3hour x_4hour];
y = [y_pre y_stim_last y_1hour y_midhour y_2hour y_3hour y_4hour];
avg = plot(x,y,'-o','Color',[0 0 0],'LineWidth',5,'MarkerSize',20);
avg.MarkerFaceColor = [0 0 0];
avg.MarkerSize = 3;

err = [y_pre_sem y_stim_last_sem y_1hour_sem y_midhour_sem y_2hour_sem y_3hour_sem y_4hour_sem];
e = errorbar(x,y,err,'LineWidth',1.5,'CapSize',10);
e.Color = 'black';

xlim([0 .1646]);
xticks([.003472 .0292 .0382 .0625 .0833 .1250 .1646]);
xticklabels({'pre','st','1','1.5','2','3','4'});
ylabel('% Immobile');
title('Persistence');

% patch for stim period
patch_start = 0.0240;
patch_end = 0.0344;
xp = [patch_start patch_start patch_end patch_end];
yp = [0 100 100 0];
patch(xp,yp,stim_color,'EdgeColor','none','facealpha',0.5);
hold on;

% MAKE THINGS PRETTIER
set(findall(gcf,'-property','FontSize'),'FontSize',12);
set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');

%% COHORT SUMMARY FIGURE 1 (for DD animals)
figure('color','white'); hold on;

% IMMOBILITY 4 HOURS
% P_time immobile over 4 hour trial
subplot(7,4,[1:8]); hold on;
p = plot(time_bin,imm_bin,'-o','linewidth',2,'color',[0,0,0]);
p.MarkerSize = 2;
ylim([0 100]);
stim_times = [22:7:85];

    for st = 1:length(stim_times)
        x = datenum([time_bin(stim_times(st)-1) time_bin(stim_times(st)-1) time_bin(stim_times(st)+1) time_bin(stim_times(st)+1)]);
        y = [0 100 100 0];
        patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
    end

p=patch(datenum([time_bin; flipud(time_bin)]), [avg_imm_30-imm_sem;  flipud(avg_imm_30+imm_sem)],...
    [0.6  0.7  0.8],'FaceAlpha',0.5, 'EdgeColor','none');
uistack(p,'bottom');

xlabel('time (hours)');
ylabel('% Immobile');
set(findall(gcf,'-property','TickDir'),'TickDir','out');
title(name);

% IMMOBILITY 1 HOUR
% zoom in on stimulations for immobility
subplot(7,4,[9:10 13:14]); hold on;
p = plot(time_bin_1h,imm_bin_1h,'-o','linewidth',2,'color',[0,0,0]);
p.MarkerSize = 2;
ylim([0 100]);

    for st = 1:length(stim_times)
        x = datenum([time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)+1) time_bin_1h(stim_times(st)+1)]);
        y = [0 100 100 0];
        patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
    end

    
avg_imm_30_1h = avg_imm_30(1:121);
sem_imm_30_1h = imm_sem(1:121);
p=patch(datenum([time_bin_1h; flipud(time_bin_1h)]), [avg_imm_30_1h-sem_imm_30_1h;  flipud(avg_imm_30_1h+sem_imm_30_1h)],...
    [0.6  0.7  0.8],'FaceAlpha',0.5, 'EdgeColor','none');
uistack(p,'bottom');

xlabel('time (min)');
ylabel('% Immobile');
% title('% Time Immobile');
set(findall(gcf,'-property','TickDir'),'TickDir','out');

% PERSISTENCE
% average immobility at several time points after stim paradigm
subplot(7,4,[11 15]); hold on;
% plot

for animal_num = 1:length(cohort_total)
    %immobility
    indiv_imm = [keep.RAW_30_sec_bin(animal_num).P_Immobile];
    avg_indiv_imm = nanmean(indiv_imm,2);
    indiv_imm_bin = avg_indiv_imm(1:480);
    

    % INDIVIDUAL persistence variables
    x_pre = mean(datenum(time_bin(12:21,:)));
    y_pre = mean(indiv_imm_bin(12:21));
    % avg of all stims
    x_stim_all = mean(datenum(time_bin(85,:))); % x value is the time of the 10th stim but the y value is the average of all stims
    y_stim_all = mean(indiv_imm_bin(stim_times));
    % 1 hour post stim
    x_1hour = mean(datenum(time_bin(117:126,:)));
    y_1hour = mean(indiv_imm_bin(117:126));
    % 1.5 hour post stim
    x_midhour = mean(datenum(time_bin(178:187,:)));
    y_midhour = mean(indiv_imm_bin(178:187));
    % 2 hour post stim
    x_2hour = mean(datenum(time_bin(237:246,:)));
    y_2hour = mean(indiv_imm_bin(237:246));
    % 3 hour post stim
    x_3hour = mean(datenum(time_bin(357:366,:)));
    y_3hour = mean(indiv_imm_bin(357:366));
    % 4 hour post stim
    x_4hour = mean(datenum(time_bin(471:480,:)));
    y_4hour = mean(indiv_imm_bin(471:480));
    
    x = [x_pre x_stim_all x_1hour x_midhour x_2hour x_3hour x_4hour];
    y = [y_pre y_stim_all y_1hour y_midhour y_2hour y_3hour y_4hour];
    p = plot(x,y,'-o','Color',[0.5 0.5 0.5],'LineWidth',1);
    p.MarkerFaceColor = [0.5 0.5 0.5];
    p.MarkerSize = 2;
    
    hold on;
end

imm_bin_test = avg_imm_30(1:480);

% persistence variables
x_pre = mean(datenum(time_bin(12:21,:))); %first 5 min
y_pre = mean(imm_bin_test(12:21));
% avg of all stims
x_stim_all = mean(datenum(time_bin(85,:))); % x value is the time of the 10th stim but the y value is the average of all stims (5 min)
y_stim_all = mean(imm_bin_test(stim_times));
% 1 hour post stim
x_1hour = mean(datenum(time_bin(117:126,:))); 
y_1hour = mean(imm_bin_test(117:126));
% 1.5 hour post stim
x_midhour = mean(datenum(time_bin(178:187,:)));
y_midhour = mean(imm_bin_test(178:187));
% 2 hour post stim
x_2hour = mean(datenum(time_bin(237:246,:)));
y_2hour = mean(imm_bin_test(237:246));
% 3 hour post stim
x_3hour = mean(datenum(time_bin(357:366,:)));
y_3hour = mean(imm_bin_test(357:366));
% 4 hour post stim
x_4hour = mean(datenum(time_bin(471:480,:)));
y_4hour = mean(imm_bin_test(471:480));


x = [x_pre x_stim_all x_1hour x_midhour x_2hour x_3hour x_4hour];
y = [y_pre y_stim_all y_1hour y_midhour y_2hour y_3hour y_4hour];
avg = plot(x,y,'-o','Color',[0 0 0],'LineWidth',3);
avg.MarkerFaceColor = [0 0 0];
avg.MarkerSize = 3;

xlim([0 .1646]);
xticks([.003472 .0292 .0382 .0625 .0833 .1250 .1646]);
xticklabels({'pre','st','1','1.5','2','3','4'});
ylabel('% Immobile');
% title('Persistence');

% patch for stim period
patch_start = 0.0240;
patch_end = 0.0344;
xp = [patch_start patch_start patch_end patch_end];
yp = [0 100 100 0];
patch(xp,yp,stim_color,'EdgeColor','none','facealpha',0.5);
hold on;
        
% STIM RESPONSE
% overlay of immobility immediately before (pre), during (stim), and after (post) each light pulse
subplot(7,4,[12 16]); hold on;

% STIM 1
x = [pre_stim1_time stim1_time post_stim1_time]; % all x = time1 to allow for overlay
y = [pre_stim1_imm stim1_imm post_stim1_imm];
plot(x,y,'-o','Color',stim1_color,'LineWidth',2);
p.MarkerFaceColor = stim1_color;
p.MarkerSize = 2;
hold on;

% STIM 2
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim2_imm stim2_imm post_stim2_imm];
plot(x,y,'-o','Color',stim2_color,'LineWidth',2);
p.MarkerFaceColor = stim2_color;
p.MarkerSize = 2;
hold on;

% STIM 3
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim3_imm stim3_imm post_stim3_imm];
plot(x,y,'-o','Color',stim3_color,'LineWidth',2);
p.MarkerFaceColor = stim3_color;
p.MarkerSize = 2;
hold on;

% STIM 4
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim4_imm stim4_imm post_stim4_imm];
plot(x,y,'-o','Color',stim4_color,'LineWidth',2);
p.MarkerFaceColor = stim4_color;
p.MarkerSize = 2;
hold on;

% STIM 5
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim5_imm stim5_imm post_stim5_imm];
plot(x,y,'-o','Color',stim5_color,'LineWidth',2);
p.MarkerFaceColor = stim5_color;
p.MarkerSize = 2;
hold on;

% STIM 6
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim6_imm stim6_imm post_stim6_imm];
plot(x,y,'-o','Color',stim6_color,'LineWidth',2);
p.MarkerFaceColor = stim6_color;
p.MarkerSize = 2;
hold on;

% STIM 7
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim7_imm stim7_imm post_stim7_imm];
plot(x,y,'-o','Color',stim7_color,'LineWidth',2);
p.MarkerFaceColor = stim7_color;
p.MarkerSize = 2;
hold on;

% STIM 8
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim8_imm stim8_imm post_stim8_imm];
plot(x,y,'-o','Color',stim8_color,'LineWidth',2);
p.MarkerFaceColor = stim8_color;
p.MarkerSize = 2;
hold on;

% STIM 9
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim9_imm stim9_imm post_stim9_imm];
plot(x,y,'-o','Color',stim9_color,'LineWidth',2);
p.MarkerFaceColor = stim9_color;
p.MarkerSize = 2;
hold on;

% STIM 10
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim10_imm stim10_imm post_stim10_imm];
plot(x,y,'-o','Color',stim10_color,'LineWidth',2);
p.MarkerFaceColor = stim10_color;
p.MarkerSize = 2;
hold on;

% patch for stim period
patch_start = 0.0071;
patch_end = 0.00745;
x = [patch_start patch_start patch_end patch_end];
y = [0 100 100 0];
patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
xticks([0.00695 0.0073 0.00765]);
xticklabels({'PRE','STIM','POST'});
ylabel('% Immobile');
title('Stim Response');
legend('stim 1','stim 2','stim 3','stim 4','stim 5','stim 6','stim 7',...
    'stim 8','stim 9','stim 10');

% AMBULATION
% avg P_time locomoting at specific time points
subplot(7,4,[17 18]); hold on;
p = plot(time_bin_1h,amb_bin_1h,'-o','linewidth',2,'color',D1);
p.MarkerSize = 2;
ylim([0 0.6]);
% ylim([0 1]);


    for st = 1:length(stim_times)
        x = datenum([time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)+1) time_bin_1h(stim_times(st)+1)]);
        y = [0 100 100 0];
        patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
    end

sem_amb_30_1h = amb_sem(1:121);
p=patch(datenum([time_bin_1h; flipud(time_bin_1h)]), [avg_amb_1h_30-sem_amb_30_1h;  flipud(avg_amb_1h_30+sem_amb_30_1h)],...
    [0.6  0.7  0.8],'FaceAlpha',0.5, 'EdgeColor','none');
uistack(p,'bottom');

% xlabel('time (min)');
xticklabels({'','',''});
ylabel('Ambulation');
set(findall(gcf,'-property','TickDir'),'TickDir','out');

% FINE MOVEMENT
% avg P_time performing fine movements at specific time points
subplot(7,4,[21 22]); hold on;
p = plot(time_bin_1h,fm_bin_1h,'-o','linewidth',2,'color',crimson);
p.MarkerSize = 2;
ylim([0 0.6]);
% ylim([0 1]);

% xlim(datenum([0 .0417]));

    for st = 1:length(stim_times)
        x = datenum([time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)+1) time_bin_1h(stim_times(st)+1)]);
        y = [0 100 100 0];
        patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
    end

sem_fm_30_1h = fm_sem(1:121);
p=patch(datenum([time_bin_1h; flipud(time_bin_1h)]), [avg_fm_1h_30-sem_fm_30_1h;  flipud(avg_fm_1h_30+sem_fm_30_1h)],...
    [0.6  0.7  0.8],'FaceAlpha',0.5, 'EdgeColor','none');
uistack(p,'bottom');

% xlabel('time (min)');
xticklabels({'','',''});
ylabel('Fine Movement');
set(findall(gcf,'-property','TickDir'),'TickDir','out');

% IMMOBILE
% avg P_time not mobile at specific time points
subplot(7,4,[25 26]); hold on;
p = plot(time_bin_1h,frz_bin_1h,'-o','linewidth',2,'color',[0,0,0]);
p.MarkerSize = 2;
ylim([0 1]);


    for st = 1:length(stim_times)
        x = datenum([time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)+1) time_bin_1h(stim_times(st)+1)]);
        y = [0 100 100 0];
        patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
    end

sem_frz_30_1h = frz_sem(1:121);    
p=patch(datenum([time_bin_1h; flipud(time_bin_1h)]), [avg_frz_1h_30-sem_frz_30_1h;  flipud(avg_frz_1h_30+sem_frz_30_1h)],...
    [0.6  0.7  0.8],'FaceAlpha',0.5, 'EdgeColor','none');
uistack(p,'bottom');

xlabel('time');
ylabel('Immobile');
set(findall(gcf,'-property','TickDir'),'TickDir','out');

% MOTOR BEHAVIOR BAR GRAPH
% bar graph of all movement parameters
subplot(7,4,[19 20 23 24 27 28]); hold on;

base_amb = mean(amb_bin(11:21));
post5_amb = mean(amb_bin(87:95));
amb_10post = mean(amb_bin(87:100));
amb_30post = mean(amb_bin(110:155));
amb_1hrpost = mean(amb_bin(87:205));
amb_2hrpost = mean(amb_bin(275:375));

base_amb_sem = mean(amb_sem(11:21));
post5_amb_sem = mean(amb_sem(87:95));
amb_10post_sem = mean(amb_sem(87:100));
amb_30post_sem = mean(amb_sem(110:155));
amb_1hrpost_sem = mean(amb_sem(87:205));
amb_2hrpost_sem = mean(amb_sem(275:375));

base_frz = mean(frz_bin(11:21));
post5_frz = mean(frz_bin(87:95));
frz_10post = mean(frz_bin(87:100));
frz_30post = mean(frz_bin(110:155));
frz_1hrpost = mean(frz_bin(87:205));
frz_2hrpost = mean(frz_bin(275:375));
frz_2hrpost = 1 - amb_2hrpost;

base_frz_sem = mean(frz_sem(11:21));
post5_frz_sem = mean(frz_sem(87:95));
frz_10post_sem = mean(frz_sem(87:100));
frz_30post_sem = mean(frz_sem(110:155));
frz_1hrpost_sem = mean(frz_sem(87:205));
frz_2hrpost_sem = mean(frz_sem(275:375));

base_fm = 1 - (base_amb + base_frz);
post5_fm = 1 - (post5_amb + post5_frz);
fm_10post = 1 - (amb_10post + frz_10post);
fm_30post = 1 - (amb_30post + frz_30post);
fm_1hrpost = 1 - (amb_1hrpost + frz_1hrpost);
fm_2hrpost = 1 - (amb_2hrpost + frz_2hrpost);

base_fm_sem = mean(fm_sem(11:21));
post5_fm_sem = mean(fm_sem(87:95));
fm_10post_sem = mean(fm_sem(87:100));
fm_30post_sem = mean(fm_sem(110:155));
fm_1hrpost_sem = mean(fm_sem(87:205));
fm_2hrpost_sem = mean(fm_sem(275:375));

% rough graph
% subplot(2,2,[1 3]); hold on;
m = [base_amb base_fm base_frz; [0 0 0]; stim_early_amb stim_early_fm stim_early_frz; stim_early_off_amb stim_early_off_fm stim_early_off_frz; [0 0 0]; stim_late_amb stim_late_fm stim_late_frz;...
   stim_late_off_amb stim_late_off_fm stim_late_off_frz; [0 0 0]; amb_10post fm_10post frz_10post; amb_30post fm_30post frz_30post; amb_2hrpost fm_2hrpost frz_2hrpost;];
e = [base_amb_sem base_fm_sem base_frz_sem; [0 0 0]; stim_early_amb_sem stim_early_fm_sem stim_early_frz_sem; stim_early_off_amb_sem stim_early_off_fm_sem stim_early_off_frz_sem; [0 0 0]; stim_late_amb_sem stim_late_fm_sem stim_late_frz_sem;...
   stim_late_off_amb_sem stim_late_off_fm_sem stim_late_off_frz_sem; [0 0 0]; amb_10post_sem fm_10post_sem frz_10post_sem; amb_30post_sem fm_30post_sem frz_30post_sem; amb_2hrpost_sem fm_2hrpost_sem frz_2hrpost_sem;];
b = bar(m,'stacked','LineWidth',1);

hold on; 

b(1).FaceColor = [0 0.4470 0.7410]; % ambulation color
b(2).FaceColor = [0.8500 0.3250 0.0980]; % fine movement color
b(3).FaceColor = [.5 .5 .5]; % immobile color

% error bars
er = errorbar(cumsum(m')',e,'LineWidth',1.5);
er(1).Color = [0 0 0];
er(2).Color = [0 0 0]; 
er(3).Color = [0 0 0]; 
er(1).LineStyle = 'none'; 
er(2).LineStyle = 'none'; 
er(3).LineStyle = 'none'; 

title(name);
ylabel('% Movement');
yticks([0 .5 1]);
yticklabels({'0','50','100'});
ylim([0 1.25]);
xlabel('');
xticks([0 1 2 3 4 5 6 7 8 9 10 11 12 13]);
xticklabels({'','PRE','','early ON','early OFF','','late ON','late OFF','','10','30','2HR',''});
legend('ambulation','fine movement','immobile');


% MAKE THINGS PRETTIER
set(findall(gcf,'-property','FontSize'),'FontSize',12);
set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');

%% Baseline Only - mobility stacked bar graph

base_amb = mean(amb_bin(11:21));
base_amb_sem = mean(amb_sem(11:21));
base_frz = mean(frz_bin(11:21));
base_frz_sem = mean(frz_sem(11:21));
base_fm = 1 - (base_amb + base_frz);
base_fm_sem = mean(fm_sem(11:21));


% plot the data
figure('color','white'); hold on;

m = [base_amb base_fm base_frz];
e = [base_amb_sem base_fm_sem base_frz_sem];
b = bar(m,'LineWidth',1);

b(1).FaceColor = PV;
b.FaceColor = 'flat';
b.CData(1,:) = [0.6350 0.0780 0.1840];
b.CData(2,:) = [0.3010 0.7450 0.9330];
b.CData(3,:) = [0.5 0.5 0.5];

hold on;

% % error bars
er = errorbar(m,e,'LineWidth',1.5,'LineStyle','none');
er.Color = [0 0 0];  
er.LineStyle = 'none'; 


title('Baseline Mobility');
ylabel('AVG %Movement');
yticks([0 .5 1]);
yticklabels({'0','50','100'});
ylim([0 1.25]);
xlabel('');
xticks([0 1 2 3 4]);
xticklabels({'','ambulation','fine movement','immobile',''});
% legend('ambulation','fine movement','immobile');

% MAKE THINGS PRETTIER
set(findall(gcf,'-property','FontSize'),'FontSize',12);
set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');

%% MOBILITY PERSISTENCE BAR GRAPHS

% ambulation
interv_stim1_amb = mean(amb_bin(23:28));
interv_stim2_amb = mean(amb_bin(30:35));
interv_stim3_amb = mean(amb_bin(37:42));
interv_stim4_amb = mean(amb_bin(44:49));

interv_stim7_amb = mean(amb_bin(65:70));
interv_stim8_amb = mean(amb_bin(30:35));
interv_stim9_amb = mean(amb_bin(72:77));
interv_stim10_amb = mean(amb_bin(86:91));

interv_stim1_amb_sem = mean(amb_sem(23:28));
interv_stim2_amb_sem = mean(amb_sem(30:35));
interv_stim3_amb_sem = mean(amb_sem(37:42));
interv_stim4_amb_sem = mean(amb_sem(44:49));

interv_stim7_amb_sem = mean(amb_sem(65:70));
interv_stim8_amb_sem = mean(amb_sem(30:35));
interv_stim9_amb_sem = mean(amb_sem(72:77));
interv_stim10_amb_sem = mean(amb_sem(86:91));

base_amb = mean(amb_bin(1:21));
stim_early_amb = mean([stim1_amb stim2_amb stim3_amb stim4_amb]);
interv_early_amb = mean([interv_stim1_amb interv_stim2_amb interv_stim3_amb interv_stim4_amb]); % intervals after early stims
stim_late_amb = mean([stim7_amb stim8_amb stim9_amb stim10_amb]);
interv_late_amb = mean([interv_stim7_amb interv_stim8_amb interv_stim9_amb interv_stim10_amb]); % intervals after late stims
post10_amb = mean(amb_bin(87:107));
post1hr_amb = mean(amb_bin(207:227));
post2hr_amb = mean(amb_bin(327:347));
post3hr_amb = mean(amb_bin(411:431));
post4hr_amb = mean(amb_bin(455:475));

base_amb_sem = mean(amb_sem(1:21));
stim_early_amb_sem = mean([stim1_amb_sem stim2_amb_sem stim3_amb_sem stim4_amb_sem]);
interv_early_amb_sem = mean([interv_stim1_amb_sem interv_stim2_amb_sem interv_stim3_amb_sem interv_stim4_amb_sem]);
stim_late_amb_sem = mean([stim7_amb_sem stim8_amb_sem stim9_amb_sem stim10_amb_sem])/sqrt(cohort_N);
interv_late_amb_sem = mean([interv_stim7_amb_sem interv_stim8_amb_sem interv_stim9_amb_sem interv_stim10_amb_sem]);
post10_amb_sem = mean(amb_bin(87:107));
post1hr_amb_sem = mean(amb_sem(207:227));
post2hr_amb_sem = mean(amb_sem(327:347));
post3hr_amb_sem = mean(amb_sem(411:431));
post4hr_amb_sem = mean(amb_sem(455:475));

% fine movement
interv_stim1_fm = mean(fm_bin(23:28));
interv_stim2_fm = mean(fm_bin(30:35));
interv_stim3_fm = mean(fm_bin(37:42));
interv_stim4_fm = mean(fm_bin(44:49));

interv_stim7_fm = mean(fm_bin(65:70));
interv_stim8_fm = mean(fm_bin(30:35));
interv_stim9_fm = mean(fm_bin(79:84));
interv_stim10_fm = mean(fm_bin(86:91));

interv_stim1_fm_sem = mean(fm_sem(23:28));
interv_stim2_fm_sem = mean(fm_sem(30:35));
interv_stim3_fm_sem = mean(fm_sem(37:42));
interv_stim4_fm_sem = mean(fm_sem(44:49));

interv_stim7_fm_sem = mean(fm_sem(65:70));
interv_stim8_fm_sem = mean(fm_sem(30:35));
interv_stim9_fm_sem = mean(fm_sem(79:84));
interv_stim10_fm_sem = mean(fm_sem(86:91));

base_fm = mean(fm_bin(1:21));
stim_early_fm = mean([stim1_fm stim2_fm stim3_fm stim4_fm]);
interv_early_fm = mean([interv_stim1_fm interv_stim2_fm interv_stim3_fm interv_stim4_fm]); % intervals after early stims
stim_late_fm = mean([stim7_fm stim8_fm stim9_fm stim10_fm]);
interv_late_fm = mean([interv_stim7_fm interv_stim8_fm interv_stim9_fm interv_stim10_fm]); % intervals after late stims
post10_fm = mean(fm_bin(87:107));
post1hr_fm = mean(fm_bin(207:227));
post2hr_fm = mean(fm_bin(327:347));
post3hr_fm = mean(fm_bin(411:431));
post4hr_fm = mean(fm_bin(455:475));

base_fm_sem = mean(fm_sem(1:21))/sqrt(cohort_N);
stim_early_fm_sem = mean([stim1_fm_sem stim2_fm_sem stim3_fm_sem stim4_fm_sem]);
interv_early_fm_sem = mean([interv_stim1_fm_sem interv_stim2_fm_sem interv_stim3_fm_sem interv_stim4_fm_sem]);
stim_late_fm_sem = mean([stim7_fm_sem stim8_fm_sem stim9_fm_sem stim10_fm_sem]);
interv_late_fm_sem = mean([interv_stim7_fm_sem interv_stim8_fm_sem interv_stim9_fm_sem interv_stim10_fm_sem]);
post10_fm_sem = mean(fm_sem(87:107));
post1hr_fm_sem = mean(fm_sem(207:227));
post2hr_fm_sem = mean(fm_sem(327:347));
post3hr_fm_sem = mean(fm_sem(411:431));
post4hr_fm_sem = mean(fm_sem(455:475));


% plot the data!
figure('color','white'); hold on;
subplot(4,4,[1:8]); hold on;
m = [base_amb; stim_early_amb; interv_early_amb; stim_late_amb; interv_late_amb;...
    post10_amb; post1hr_amb; post2hr_amb; post3hr_amb; post4hr_amb];
e = [base_amb_sem; stim_early_amb_sem; interv_early_amb_sem; stim_late_amb_sem; interv_late_amb_sem;...
    post10_amb_sem; post1hr_amb_sem; post2hr_amb_sem; post3hr_amb_sem; post4hr_amb_sem];
b = bar(m,'LineWidth',1,'BarWidth', 0.75);
b(1).FaceColor = PV; % ambulation color
b.FaceColor = 'flat';
b.CData(2,:) = [0.2 1 1];
b.CData(4,:) = [0.2 1 1];

hold on;

er = errorbar(m,e,'LineWidth',1.5);
er.Color = [0 0 0];  
er.LineStyle = 'none';  

xticks([1 2 3 4 5 6 7 8 9 10]);
xticklabels({'','','','','','','','','',''});
% xticklabels({'BASE','EARLY STIM','EARLY INTERVAL','LATE STIM','LATE INTERVAL',...
%     '10min POST','1hr POST','2hr POST','3hr POST','4hr POST'});
yticks([0 0.25 0.5]);
yticklabels({'0','25','50'});
ylim([0 0.6]);
ylabel('% Time');
title('Ambulation');
% legend('ambulation');

hold on;

subplot(4,4,[9:16]); hold on;
m = [base_fm; stim_early_fm; interv_early_fm; stim_late_fm; interv_late_fm;...
    post10_fm; post1hr_fm; post2hr_fm; post3hr_fm; post4hr_fm];
e = [base_fm_sem; stim_early_fm_sem; interv_early_fm_sem; stim_late_fm_sem; interv_late_fm_sem;...
    post10_fm_sem; post1hr_fm_sem; post2hr_fm_sem; post3hr_fm_sem; post4hr_fm_sem];
b = bar(m,'LineWidth',1,'BarWidth', 0.75);
b(1).FaceColor = ChR2;% fine movement color
b.FaceColor = 'flat';
b.CData(2,:) = [0.2 1 1];
b.CData(4,:) = [0.2 1 1];

hold on; 

% error bars
er = errorbar(m,e,'LineWidth',1.5);
er.Color = [0 0 0];  
er.LineStyle = 'none';  

xticks([1 2 3 4 5 6 7 8 9 10]);
xticklabels({'BASE','EARLY STIM','EARLY INTERVAL','LATE STIM','LATE INTERVAL',...
    '10min POST','1hr POST','2hr POST','3hr POST','4hr POST'});
yticks([0 0.25 0.5]);
yticklabels({'0','25','50'});
ylim([0 0.7]);
ylabel('% Time');
title('Fine Movement');
% legend('fine movement');

% MAKE THINGS PRETTIER
set(findall(gcf,'-property','FontSize'),'FontSize',12);
set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');

%% Early vs. Late Stim

% immobility
pre_stim_early_imm = mean([pre_stim1_imm pre_stim2_imm pre_stim3_imm pre_stim4_imm]);
stim_early_imm = mean([stim1_imm stim2_imm stim3_imm stim4_imm]);
post_stim_early_imm = mean([post_stim1_imm post_stim2_imm post_stim3_imm post_stim4_imm]);
pre_stim_early_imm_sem = mean([pre_stim1_imm_sem pre_stim2_imm_sem pre_stim3_imm_sem pre_stim4_imm_sem]);
stim_early_imm_sem = mean([stim1_imm_sem stim2_imm_sem stim3_imm stim4_imm_sem]);
post_stim_early_imm_sem = mean([post_stim1_imm_sem post_stim2_imm_sem post_stim3_imm_sem post_stim4_imm_sem]);

pre_stim_late_imm = mean([pre_stim7_imm pre_stim8_imm pre_stim9_imm pre_stim10_imm]);
stim_late_imm = mean([stim7_imm stim8_imm stim9_imm stim10_imm]);
post_stim_late_imm = mean([post_stim7_imm post_stim8_imm post_stim9_imm post_stim10_imm]);
pre_stim_late_imm_sem = mean([pre_stim7_imm_sem pre_stim8_imm_sem pre_stim9_imm_sem pre_stim10_imm_sem]);
stim_late_imm_sem = mean([stim7_imm_sem stim8_imm_sem stim9_imm_sem stim10_imm_sem]);
post_stim_late_imm_sem = mean([post_stim7_imm_sem post_stim8_imm_sem post_stim9_imm_sem post_stim10_imm_sem]);

% ambulation
pre_stim_early_amb = mean([pre_stim1_amb pre_stim2_amb pre_stim3_amb pre_stim4_amb]);
stim_early_amb = mean([stim1_amb stim2_amb stim3_amb stim4_amb]);
post_stim_early_amb = mean([post_stim1_amb post_stim2_amb post_stim3_amb post_stim4_amb]);
pre_stim_early_amb_sem = mean([pre_stim1_amb_sem pre_stim2_amb_sem pre_stim3_amb_sem pre_stim4_amb_sem]);
stim_early_amb_sem = mean([stim1_amb_sem stim2_amb_sem stim3_amb_sem stim4_amb_sem]);
post_stim_early_amb_sem = mean([post_stim1_amb_sem post_stim2_amb_sem post_stim3_amb_sem post_stim4_amb_sem]);

pre_stim_late_amb = mean([pre_stim7_amb pre_stim8_amb pre_stim9_amb pre_stim10_amb]);
stim_late_amb = mean([stim7_amb stim8_amb stim9_amb stim10_amb]);
post_stim_late_amb = mean([post_stim7_amb post_stim8_amb post_stim9_amb post_stim10_amb]);
pre_stim_late_amb_sem = mean([pre_stim7_amb_sem pre_stim8_amb_sem pre_stim9_amb_sem pre_stim10_amb_sem]);
stim_late_amb_sem = mean([stim7_amb_sem stim8_amb_sem stim9_amb_sem stim10_amb_sem]);
post_stim_late_amb_sem = mean([post_stim7_amb_sem post_stim8_amb_sem post_stim9_amb_sem post_stim10_amb_sem]);

% fine movement
pre_stim_early_fm = mean([pre_stim1_fm pre_stim2_fm pre_stim3_fm pre_stim4_fm]);
stim_early_fm = mean([stim1_fm stim2_fm stim3_fm stim4_fm]);
post_stim_early_fm = mean([post_stim1_fm post_stim2_fm post_stim3_fm post_stim4_fm]);
pre_stim_early_fm_sem = mean([pre_stim1_fm_sem pre_stim2_fm_sem pre_stim3_fm_sem pre_stim4_fm_sem]);
stim_early_fm_sem = mean([stim1_fm_sem stim2_fm_sem stim3_fm_sem stim4_fm_sem]);
post_stim_early_fm_sem = mean([post_stim1_fm_sem post_stim2_fm_sem post_stim3_fm_sem post_stim4_fm_sem]);

pre_stim_late_fm = mean([pre_stim7_fm pre_stim8_fm pre_stim9_fm pre_stim10_fm]);
stim_late_fm = mean([stim7_fm stim8_fm stim9_fm stim10_fm]);
post_stim_late_fm = mean([post_stim7_fm post_stim8_fm post_stim9_fm post_stim10_fm]);
pre_stim_late_fm_sem = mean([pre_stim7_fm_sem pre_stim8_fm_sem pre_stim9_fm_sem pre_stim10_fm_sem]);
stim_late_fm_sem = mean([stim7_fm_sem stim8_fm_sem stim9_fm_sem stim10_fm_sem]);
post_stim_late_fm_sem = mean([post_stim7_fm_sem post_stim8_fm_sem post_stim9_fm_sem post_stim10_fm_sem]);


figure('color','white'); hold on;
subplot(9,3,[2 5 8]); hold on;
black = [0 0 0];
%immobility
% STIM 1
x = [pre_stim1_time stim1_time post_stim1_time]; % all x = time1 to allow for overlay
y = [pre_stim1_imm stim1_imm post_stim1_imm];
plot(x,y,'','Color',stim1_color,'LineWidth',1);
p.MarkerFaceColor = stim1_color;
% p.MarkerSize = 2;
hold on;

% STIM 2
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim2_imm stim2_imm post_stim2_imm];
plot(x,y,'','Color',stim2_color,'LineWidth',1);
p.MarkerFaceColor = stim2_color;
% p.MarkerSize = 2;
hold on;

% STIM 3
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim3_imm stim3_imm post_stim3_imm];
plot(x,y,'','Color',stim3_color,'LineWidth',1);
p.MarkerFaceColor = stim3_color;
% p.MarkerSize = 2;
hold on;

% STIM 4
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim4_imm stim4_imm post_stim4_imm];
plot(x,y,'','Color',stim4_color,'LineWidth',1);
p.MarkerFaceColor = black;
% p.MarkerSize = 2;
hold on;

% STIM 5
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim5_imm stim5_imm post_stim5_imm];
plot(x,y,'','Color',stim5_color,'LineWidth',1);
p.MarkerFaceColor = stim4_color;
% p.MarkerSize = 2;
hold on;

% STIM 6
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim6_imm stim6_imm post_stim6_imm];
plot(x,y,'','Color',stim6_color,'LineWidth',1);
p.MarkerFaceColor = stim6_color;
% p.MarkerSize = 2;
hold on;

% STIM 7
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim7_imm stim7_imm post_stim7_imm];
plot(x,y,'','Color',stim7_color,'LineWidth',1);
p.MarkerFaceColor = stim7_color;
% p.MarkerSize = 2;
hold on;

% STIM 8
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim8_imm stim8_imm post_stim8_imm];
plot(x,y,'','Color',stim8_color,'LineWidth',1);
p.MarkerFaceColor = stim8_color;
% p.MarkerSize = 2;
hold on;

% STIM 9
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim9_imm stim9_imm post_stim9_imm];
plot(x,y,'','Color',stim9_color,'LineWidth',1);
p.MarkerFaceColor = stim9_color;
% p.MarkerSize = 2;
hold on;

% STIM 10
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim10_imm stim10_imm post_stim10_imm];
plot(x,y,'','Color',stim10_color,'LineWidth',1);
p.MarkerFaceColor = stim10_color;
% p.MarkerSize = 2;
hold on;


%ambulation
subplot(9,3,[11 14 17]); hold on;
% STIM 1
x = [pre_stim1_time stim1_time post_stim1_time]; % all x = time1 to allow for overlay
y = [pre_stim1_amb stim1_amb post_stim1_amb];
plot(x,y,'','Color',stim1_color,'LineWidth',1);
p.MarkerFaceColor = stim1_color;
% p.MarkerSize = 2;
hold on;

% STIM 2
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim2_amb stim2_amb post_stim2_amb];
plot(x,y,'','Color',stim2_color,'LineWidth',1);
p.MarkerFaceColor = stim2_color;
% p.MarkerSize = 2;
hold on;

% STIM 3
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim3_amb stim3_amb post_stim3_amb];
plot(x,y,'','Color',stim3_color,'LineWidth',1);
p.MarkerFaceColor = stim3_color;
% p.MarkerSize = 2;
hold on;

% STIM 4
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim4_amb stim4_amb post_stim4_amb];
plot(x,y,'','Color',stim4_color,'LineWidth',1);
p.MarkerFaceColor = stim4_color;
% p.MarkerSize = 2;
hold on;

% STIM 5
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim5_amb stim5_amb post_stim5_amb];
plot(x,y,'','Color',stim5_color,'LineWidth',1);
p.MarkerFaceColor = stim5_color;
% p.MarkerSize = 2;
hold on;

% STIM 6
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim6_amb stim6_amb post_stim6_amb];
plot(x,y,'','Color',stim6_color,'LineWidth',1);
p.MarkerFaceColor = stim6_color;
% p.MarkerSize = 2;
hold on;

% STIM 7
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim7_amb stim7_amb post_stim7_amb];
plot(x,y,'','Color',stim7_color,'LineWidth',1);
p.MarkerFaceColor = stim7_color;
% p.MarkerSize = 2;
hold on;

% STIM 8
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim8_amb stim8_amb post_stim8_amb];
plot(x,y,'','Color',stim8_color,'LineWidth',1);
p.MarkerFaceColor = stim8_color;
% p.MarkerSize = 2;
hold on;

% STIM 9
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim9_amb stim9_amb post_stim9_amb];
plot(x,y,'','Color',stim9_color,'LineWidth',1);
p.MarkerFaceColor = stim9_color;
% p.MarkerSize = 2;
hold on;

% STIM 10
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim10_amb stim10_amb post_stim10_amb];
plot(x,y,'','Color',stim10_color,'LineWidth',1);
p.MarkerFaceColor = stim10_color;
% p.MarkerSize = 2;
hold on;


%fine movement
subplot(9,3,[20 23 26]); hold on;

% STIM 1
x = [pre_stim1_time stim1_time post_stim1_time]; % all x = time1 to allow for overlay
y = [pre_stim1_fm stim1_fm post_stim1_fm];
plot(x,y,'','Color',stim1_color,'LineWidth',1);
p.MarkerFaceColor = stim1_color;
% p.MarkerSize = 2;
hold on;

% STIM 2
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim2_fm stim2_fm post_stim2_fm];
plot(x,y,'','Color',stim2_color,'LineWidth',1);
p.MarkerFaceColor = stim2_color;
% p.MarkerSize = 2;
hold on;

% STIM 3
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim3_fm stim3_fm post_stim3_fm];
plot(x,y,'','Color',stim3_color,'LineWidth',1);
p.MarkerFaceColor = stim3_color;
% p.MarkerSize = 2;
hold on;

% STIM 4
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim4_fm stim4_fm post_stim4_fm];
plot(x,y,'','Color',stim4_color,'LineWidth',1);
p.MarkerFaceColor = stim4_color;
% p.MarkerSize = 2;
hold on;

% STIM 5
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim5_fm stim5_fm post_stim5_fm];
plot(x,y,'','Color',stim5_color,'LineWidth',1);
p.MarkerFaceColor = stim5_color;
% p.MarkerSize = 2;
hold on;

% STIM 6
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim6_fm stim6_fm post_stim6_fm];
plot(x,y,'','Color',stim6_color,'LineWidth',1);
p.MarkerFaceColor = stim6_color;
% p.MarkerSize = 2;
hold on;

% STIM 7
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim7_fm stim7_fm post_stim7_fm];
plot(x,y,'','Color',stim7_color,'LineWidth',1);
p.MarkerFaceColor = stim7_color;
% p.MarkerSize = 2;
hold on;

% STIM 8
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim8_fm stim8_fm post_stim8_fm];
plot(x,y,'','Color',stim8_color,'LineWidth',1);
p.MarkerFaceColor = stim8_color;
% p.MarkerSize = 2;
hold on;

% STIM 9
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim9_fm stim9_fm post_stim9_fm];
plot(x,y,'','Color',stim9_color,'LineWidth',1);
p.MarkerFaceColor = stim9_color;
% p.MarkerSize = 2;
hold on;

% STIM 10
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim10_fm stim10_fm post_stim10_fm];
plot(x,y,'','Color',stim10_color,'LineWidth',1);
p.MarkerFaceColor = stim10_color;
% p.MarkerSize = 2;
hold on;


% PLOT EARLY VS LATE
% immobility
subplot(9,3,[2 5 8]); hold on;
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim_early_imm stim_early_imm post_stim_early_imm];
plot(x,y,'-o','Color',black,'LineWidth',4);
p.MarkerFaceColor = black;
p.MarkerSize = 2;
hold on; 

e = [pre_stim_early_imm_sem stim_early_imm_sem post_stim_early_imm_sem];
er = errorbar(x,y,e,'LineWidth',2,'CapSize',6);
er.Color = [0 0 0];    
hold on;

x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim_late_imm stim_late_imm post_stim_late_imm];
plot(x,y,'-o','Color',ChR2,'LineWidth',4);
p.MarkerFaceColor = ChR2;
p.MarkerSize = 2;
hold on;

e = [pre_stim_late_imm_sem stim_late_imm_sem post_stim_late_imm_sem];
er = errorbar(x,y,e,'LineWidth',2,'CapSize',6);
er.Color = [0 0 0];    
hold on;

% patch for stim period
patch_start = 0.0071;
patch_end = 0.00745;
x = [patch_start patch_start patch_end patch_end];
y = [0 100 100 0];
patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
xticks([0.00695 0.0073 0.00765]);
xticklabels({'','',''});
yticks([0 50 100]);
ylabel('% Time');
title('Immobility');
% legend('stim 1','stim 2','stim 3','stim 4','stim 5','stim 6','stim 7',...
%     'stim 8','stim 9','stim 10');

% ambulation
subplot(9,3,[11 14 17]); hold on;
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim_early_amb stim_early_amb post_stim_early_amb];
plot(x,y,'-o','Color',black,'LineWidth',4);
p.MarkerFaceColor = black;
p.MarkerSize = 2;
hold on;

e = [pre_stim_early_amb_sem stim_early_amb_sem post_stim_early_amb_sem];
er = errorbar(x,y,e,'LineWidth',2,'CapSize',6);
er.Color = [0 0 0];    
hold on;

x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim_late_amb stim_late_amb post_stim_late_amb];
plot(x,y,'-o','Color',ChR2,'LineWidth',4);
p.MarkerFaceColor = ChR2;
p.MarkerSize = 2;
hold on;

e = [pre_stim_late_amb_sem stim_late_amb_sem post_stim_late_amb_sem];
er = errorbar(x,y,e,'LineWidth',2,'CapSize',6);
er.Color = [0 0 0];    
hold on;

% patch for stim period
patch_start = 0.0071;
patch_end = 0.00745;
x = [patch_start patch_start patch_end patch_end];
y = [0 1 1 0];
patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
xticks([0.00695 0.0073 0.00765]);
xticklabels({'','',''});
yticks([0 0.5 1]);
ylabel('% Time');
title('Ambulation');
% legend('stim 1','stim 2','stim 3','stim 4','stim 5','stim 6','stim 7',...
%     'stim 8','stim 9','stim 10');

% fine movement
subplot(9,3,[20 23 26]); hold on;
x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim_early_fm stim_early_fm post_stim_early_fm];
plot(x,y,'-o','Color',black,'LineWidth',4);
p.MarkerFaceColor = black;
p.MarkerSize = 2;
hold on;

e = [pre_stim_early_fm_sem stim_early_fm_sem post_stim_early_fm_sem];
er = errorbar(x,y,e,'LineWidth',2,'CapSize',6);
er.Color = [0 0 0];    
hold on;

x = [pre_stim1_time stim1_time post_stim1_time];
y = [pre_stim_late_fm stim_late_fm post_stim_late_fm];
plot(x,y,'-o','Color',ChR2,'LineWidth',4);
p.MarkerFaceColor = ChR2;
p.MarkerSize = 2;
hold on;

e = [pre_stim_late_fm_sem stim_late_fm_sem post_stim_late_fm_sem];
er = errorbar(x,y,e,'LineWidth',2,'CapSize',6);
er.Color = [0 0 0];    
hold on;

% patch for stim period
patch_start = 0.0071;
patch_end = 0.00745;
x = [patch_start patch_start patch_end patch_end];
y = [0 1 1 0];
patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
xticks([0.00695 0.0073 0.00765]);
xticklabels({'PRE','STIM','POST'});
yticks([0 0.5 1]);
ylabel('% Time');
title('Fine Movement');
legend('stim 1','stim 2','stim 3','stim 4','stim 5','stim 6','stim 7',...
    'stim 8','stim 9','stim 10','early','late');

%% Mobility Bar Graphs
% bar graph of all movement parameters
figure('color','white'); hold on;

amb_sem = std(all_amb_30,0,2,'omitnan')/sqrt(cohort_N);
stim1_amb_sem = amb_sem(22);
stim2_amb_sem = amb_sem(29);
stim3_amb_sem = amb_sem(36);
stim4_amb_sem = amb_sem(43);
stim5_amb_sem = amb_sem(50);
stim6_amb_sem = amb_sem(57);
stim7_amb_sem = amb_sem(64);
stim8_amb_sem = amb_sem(71);
stim9_amb_sem = amb_sem(78);
stim10_amb_sem = amb_sem(85);

fm_sem = std(all_fm_30,0,2,'omitnan')/sqrt(cohort_N);
stim1_fm_sem = fm_sem(22);
stim2_fm_sem = fm_sem(29);
stim3_fm_sem = fm_sem(36);
stim4_fm_sem = fm_sem(43);
stim5_fm_sem = fm_sem(50);
stim6_fm_sem = fm_sem(57);
stim7_fm_sem = fm_sem(64);
stim8_fm_sem = fm_sem(71);
stim9_fm_sem = fm_sem(78);
stim10_fm_sem = fm_sem(85);

frz_sem = std(all_frz_30,0,2,'omitnan')/sqrt(cohort_N);
stim1_frz_sem = frz_sem(22);
stim2_frz_sem = frz_sem(29);
stim3_frz_sem = frz_sem(36);
stim4_frz_sem = frz_sem(43);
stim5_frz_sem = frz_sem(50);
stim6_frz_sem = frz_sem(57);
stim7_frz_sem = frz_sem(64);
stim8_frz_sem = frz_sem(71);
stim9_frz_sem = frz_sem(78);
stim10_frz_sem = frz_sem(85);


% ambulation
base_amb = mean(amb_bin(1:21));
stim_early_amb = mean([stim1_amb stim2_amb stim3_amb stim4_amb]);
stim_late_amb = mean([stim7_amb stim8_amb stim9_amb stim10_amb]);
post1hr_amb_ = mean(amb_bin(87:207));
post4hr_amb_ = mean(amb_bin(360:480));

base_amb_sem = mean(amb_sem(1:21));
stim_early_amb_sem = mean([stim1_amb_sem stim2_amb_sem stim3_amb_sem stim4_amb_sem]);
stim_late_amb_sem = mean([stim7_amb_sem stim8_amb_sem stim9_amb_sem stim10_amb_sem]);
post1hr_amb_sem_ = mean(amb_sem(87:207));
post4hr_amb_sem_ = mean(amb_sem(360:480));

% fine movement
base_fm = mean(fm_bin(1:21));
stim_early_fm = mean([stim1_fm stim2_fm stim3_fm stim4_fm]);
stim_late_fm = mean([stim7_fm stim8_fm stim9_fm stim10_fm]);
post1hr_fm_ = mean(fm_bin(87:207));
post4hr_fm_ = mean(fm_bin(360:480));

base_fm_sem = mean(fm_sem(1:21));
stim_early_fm_sem = mean([stim1_fm_sem stim2_fm_sem stim3_fm_sem stim4_fm_sem]);
stim_late_fm_sem = mean([stim7_fm_sem stim8_fm_sem stim9_fm_sem stim10_fm_sem]);
post1hr_fm_sem_ = mean(fm_sem(87:207));
post4hr_fm_sem_ = mean(fm_sem(360:480));

% freezing
stim1_frz = 1 - (stim1_amb + stim1_fm);
stim2_frz = 1 - (stim2_amb + stim2_fm);
stim3_frz = 1 - (stim3_amb + stim3_fm);
stim4_frz = 1 - (stim4_amb + stim4_fm);

stim7_frz = 1 - (stim7_amb + stim7_fm);
stim8_frz = 1 - (stim8_amb + stim8_fm);
stim9_frz = 1 - (stim9_amb + stim9_fm);
stim10_frz = 1 - (stim10_amb + stim10_fm);

base_frz = mean(frz_bin(1:21));
stim_early_frz = mean([stim1_frz stim2_frz stim3_frz stim4_frz]);
stim_late_frz = mean([stim7_frz stim8_frz stim9_frz stim10_frz]);
post1hr_frz_ = mean(frz_bin(87:207));
post4hr_frz_ = mean(frz_bin(360:480));

base_frz_sem = mean(frz_sem(1:21));
stim_early_frz_sem = mean([stim1_frz_sem stim2_frz_sem stim3_frz_sem stim4_frz_sem]);
stim_late_frz_sem = mean([stim7_frz_sem stim8_frz_sem stim9_frz_sem stim10_frz_sem]);
post1hr_frz_sem_ = mean(frz_sem(87:207));
post4hr_frz_sem_ = mean(frz_sem(360:480));


% plot the data
m = [base_amb base_fm base_frz; stim_early_amb stim_early_fm stim_early_frz;...
    stim_late_amb stim_late_fm stim_late_frz; [0 0 0]; post1hr_amb_ post1hr_fm_ post1hr_frz_;...
    post4hr_amb_ post4hr_fm_ post4hr_frz_;];
e = [base_amb_sem base_fm_sem base_frz_sem; stim_early_amb_sem stim_early_fm_sem stim_early_frz_sem;...
    stim_late_amb_sem stim_late_fm_sem stim_late_frz_sem; [0 0 0]; post1hr_amb_sem_ post1hr_fm_sem_ post1hr_frz_sem_;...
    post4hr_amb_sem_ post4hr_fm_sem_ post4hr_frz_sem_;];
b = bar(m,'stacked');

b(1).FaceColor = [0 0.4470 0.7410]; % ambulation color
b(2).FaceColor = [0.8500 0.3250 0.0980]; % fine movement color
b(3).FaceColor = [0.5 0.5 0.5]; % immobile color

hold on; 

% error bars
er = errorbar(cumsum(m')',e,'LineWidth',1.5);
er(1).Color = [0 0 0];
er(2).Color = [0 0 0]; 
er(3).Color = [0 0 0]; 
er(1).LineStyle = 'none'; 
er(2).LineStyle = 'none'; 
er(3).LineStyle = 'none'; 

ylabel('% Movement');
yticks([0 .5 1]);
yticklabels({'0','50','100'});
xlabel('');
xticks([0 1 2 3 4 5 6 7]);
xticklabels({'','BASE','EARLY','LATE','','1HR','4HR',''});
legend('ambulation','fine movement','immobile');


% MAKE THINGS PRETTIER
set(findall(gcf,'-property','FontSize'),'FontSize',15);
set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');

%% GRAPH INDIVIDUAL MICE

for animal_num = 1:length(cohort_total)
    figure('color','white'); hold on;
    
    %% INDIVIDUAL MOUSE VARIABLES
    
    % stim related times
    pre_stim_times = [21:7:84];
    stim_times = [22:7:85];
    post_stim_times = [23:7:86];
    stim_off_times = [26:7:89];

    % cohort averages
    %velocity
    vel_limit = 1.2;
    all_vel_1 = [keep.RAW_1_sec_bin(animal_num).Velocity_Center_point_Mean_cm_s];
    avg_vel_1 = nanmean(all_vel_1,2);
    vel_true_1 = avg_vel_1;
    avg_vel_less_1 = avg_vel_1<vel_limit;
    vel_true_1(avg_vel_less_1) = 0;
    all_vel_1h_1 = vel_true_1(1:121,:);
    vel_true_1 = vel_true_1(1:14400);
    all_vel_30 = [keep.RAW_30_sec_bin(animal_num).Velocity_Center_point_Mean_cm_s];
    avg_vel_30 = nanmean(all_vel_30,2);
    vel_true_30 = avg_vel_30;
    avg_vel_less_30 = avg_vel_30<vel_limit;
    vel_true_30(avg_vel_less_30) = 0;
    all_vel_1h_30 = vel_true_30(1:121,:);
    vel_true_30 = vel_true_30(1:480);

    %distance
    vel_limit = 1.2;
    all_dist_1 = [keep.RAW_1_sec_bin(animal_num).Distance_Moved_center_point_total_cm];
    avg_dist_1 = nanmean(all_dist_1,2);
	dist_true_1 = avg_dist_1;
    avg_vel_less_1 = avg_vel_1<vel_limit;
    avg_vel_greater = avg_vel_1>vel_limit;
    dist_true_1(avg_vel_less_1) = 0;
    avg_dist_1h_1 = dist_true_1(1:3600,:);
    dist_true_1 = dist_true_1(1:14400);
    all_dist_30 = [keep.RAW_30_sec_bin(animal_num).Distance_Moved_center_point_total_cm];
    avg_dist_30 = nanmean(all_dist_30,2);
    dist_true_30 = avg_dist_30;
    avg_vel_less_30 = avg_vel_30<vel_limit;
    avg_vel_greater = avg_vel_30>vel_limit;
    dist_true_30(avg_vel_less_30) = 0;
    avg_dist_1h_30 = dist_true_30(1:121,:);
    dist_true_30 = dist_true_30(1:480);

    %ambulation
    vel_limit = 1.2;
    all_amb_1 = [keep.RAW_1_sec_bin(animal_num).Ambulation];
    avg_amb_1 = nanmean(all_amb_1,2);
    amb_true_1 = avg_amb_1;
    avg_vel_less_1 = avg_vel_1<vel_limit;
    avg_vel_greater = avg_vel_1>vel_limit;
    amb_true_1(avg_vel_less_1) = 0;
    amb_true_1(avg_vel_greater) = 1;
    avg_amb_1h_1 = amb_true_1(1:3600,:);
    amb_true_1 = amb_true_1(1:14400);
    all_amb_30 = [keep.RAW_30_sec_bin(animal_num).Ambulation];
    avg_amb_30 = nanmean(all_amb_30,2);
    amb_true_30 = avg_amb_30;
    avg_amb_1h_30 = amb_true_30(1:121,:);
    amb_true_30 = amb_true_30(1:480);
    sem_amb_30 = nanstd(all_amb_30,[],2)/sqrt(cohort_N);
    sem_amb_30_1h = sem_amb_30(1:121);

    %freezing
    all_frz_1 = [keep.RAW_1_sec_bin(animal_num).Freezing];
    avg_frz_1 = nanmean(all_frz_1,2);
    avg_frz_less_1 = avg_frz_1<frz_limit;
    avg_frz_greater_1 = avg_frz_1>frz_limit;
    frz_true_1 = avg_frz_1<frz_limit;
    frz_true_1(avg_frz_less_1) = 0;
    frz_true_1(avg_frz_greater_1) = 1;
    amb_limit = 0.9;
    avg_frz_less_1 = amb_true_1>amb_limit;
    frz_true_1(avg_frz_less_1) = 0;
    frz_true_1 = frz_true_1(1:14400);
    all_frz_30 = [keep.RAW_30_sec_bin(animal_num).Freezing];
    avg_frz_30 = nanmean(all_frz_30,2);
    frz_true_30 = avg_frz_30;
    avg_frz_1h_30 = frz_true_30(1:121,:);
    frz_true_30 = avg_frz_30(1:480);
    sem_frz_30 = nanstd(all_frz_30,[],2)/sqrt(cohort_N);
    sem_frz_30_1h = sem_frz_30(1:121);

    %fine movement
    all_fm_1 = [keep.RAW_1_sec_bin(animal_num).Fine_Movement];
    avg_fm_1 = nanmean(all_fm_1,2);
    fm_true_1 = ~any([amb_true_1 frz_true_1],2);
    avg_fm_1h_1 = fm_true_1(1:121,:);
    amb_limit = 0.9;
    avg_fm_less_1 = amb_true_1>amb_limit;
    fm_true_1(avg_fm_less_1) = 0;
    fm_true_1 = fm_true_1(1:14400);
    all_fm_30 = [keep.RAW_30_sec_bin(animal_num).Fine_Movement];
    avg_fm_30 = nanmean(all_fm_30,2);
    fm_true_30 = avg_fm_30;
    avg_fm_1h_30 = fm_true_30(1:121,:);
    fm_true_30 = avg_fm_30(1:480);
    sem_fm_30 = nanstd(all_fm_30,[],2)/sqrt(cohort_N);
    sem_fm_30_1h = sem_fm_30(1:121);

    %immobility
    imm_limit = 0.9;
    all_imm_1 = [keep.RAW_1_sec_bin(animal_num).P_Immobile];
    avg_imm_1 = nanmean(all_imm_1,2);
    sem_imm_1 = nanstd(all_imm_1,[],2)/sqrt(cohort_N);
    imm_true_1 = avg_imm_1; 
    avg_imm_less_1 = frz_true_1<imm_limit;
    imm_true_1(avg_frz_less_1) = 0;
    imm_true_1 = imm_true_1(1:14400);
    all_imm_30 = [keep.RAW_30_sec_bin(animal_num).P_Immobile];
    avg_imm_30 = nanmean(all_imm_30,2);
    sem_imm_30 = nanstd(all_imm_30,[],2)/sqrt(cohort_N);
    imm_true_30 = avg_imm_30; 
    imm_true_30 = imm_true_30(1:480);

    % convert decimal to time format in matlab
    a = datetime(keep.RAW_30_sec_bin(1).time,'convertfrom','excel');
    a.Format = 'HH.mm.ss';

    % time variables
    d = datetime(datestr(keep.RAW_1_sec_bin(1).time,'HH:MM:SS'),'InputFormat','HH:mm:ss');
    sec_1 = (d-d(1)) * (24 * 60 * 60);
    min_1 = (d-d(1)) * (24 * 60);
    hrs_1 = (d-d(1));
    t_1 = hrs_1;
    t_1 = t_1(1:14400);
    t_1h_1 = t_1(1:630,:);

    % bin the data!
    bin_size = 30; % 30 = 30sec bins;
    time_bin_times = [1:30:14400]; % time needs to be every 30 sec rather than the average of each 30 seconds
    time_bin = t_1(time_bin_times);
    time_bin_1h = time_bin(1:121);
    imm_bin = imm_true_30;
    imm_bin_1h = imm_bin(1:121);
    vel_bin = vel_true_30;
    vel_bin_1h = vel_bin(1:121);
    dist_bin = dist_true_30;
    dist_bin_1h = dist_bin(1:121);
    amb_bin = amb_true_30;
    amb_bin_1h = amb_bin(1:121);
    fm_bin = fm_true_30;
    fm_bin_1h = fm_bin(1:121);
    frz_bin = frz_true_30;
    frz_bin_1h = frz_bin(1:121);

    % stim overlay variables
    % stim 1
    pre_stim1_time = datenum(time_bin(21,:));
    stim1_time = datenum(time_bin(22,:));
    post_stim1_time = datenum(time_bin(23,:));
    stim1_color = [.04170 0 0];
    % immobility
    pre_stim1_imm = mean(imm_bin(21));    
    stim1_imm = mean(imm_bin(22));    
    post_stim1_imm = mean(imm_bin(23));
    % velocity
    pre_stim1_vel = mean(vel_bin(21));
    stim1_vel = mean(vel_bin(22));
    post_stim1_vel = mean(vel_bin(23));
    % ambulation
    pre_stim1_amb = mean(amb_bin(21));
    stim1_amb = mean(amb_bin(22));
    post_stim1_amb = mean(amb_bin(23));
    off_stim1_amb = mean(amb_bin(26));
    % fine movement
    pre_stim1_fm = mean(fm_bin(21));
    stim1_fm = mean(fm_bin(22));
    post_stim1_fm = mean(fm_bin(23));
    off_stim1_fm = mean(fm_bin(26));
    % freezing
    pre_stim1_frz = mean(frz_bin(21));
    stim1_frz = mean(frz_bin(22));
    post_stim1_frz = mean(frz_bin(23));
    % distance
    pre_stim1_dist = sum(dist_bin(21));
    stim1_dist = sum(dist_bin(22));
    post_stim1_dist = sum(dist_bin(23));

    % stim 2
    pre_stim2_time = datenum(time_bin(28,:));    
    stim2_time = datenum(time_bin(29,:));    
    post_stim2_time = datenum(time_bin(30,:));    
    stim2_color = [.2500 0 0];
    % immobility
    pre_stim2_imm = mean(imm_bin(28));
    stim2_imm = mean(imm_bin(29));
    post_stim2_imm = mean(imm_bin(30));
    % velocity
    pre_stim2_vel = mean(vel_bin(28));
    stim2_vel = mean(vel_bin(29));
    post_stim2_vel = mean(vel_bin(30));
    % ambulation
    pre_stim2_amb = mean(amb_bin(28));
    stim2_amb = mean(amb_bin(29));
    post_stim2_amb = mean(amb_bin(30));
    off_stim2_amb = mean(amb_bin(33));
    % fine movement
    pre_stim2_fm = mean(fm_bin(28));
    stim2_fm = mean(fm_bin(29));
    post_stim2_fm = mean(fm_bin(30));
    off_stim2_fm = mean(fm_bin(33));
    % freezing
    pre_stim2_frz = mean(frz_bin(28));
    stim2_frz = mean(frz_bin(29));
    post_stim2_frz = mean(frz_bin(30));
    % distance
    pre_stim2_dist = sum(dist_bin(28));
    stim2_dist = sum(dist_bin(29));
    post_stim2_dist = sum(dist_bin(30));

    % stim 3
    pre_stim3_time = datenum(time_bin(35,:));    
    stim3_time = datenum(time_bin(36,:));    
    post_stim3_time = datenum(time_bin(37,:));    
    stim3_color = [.4583 0 0];
    % immobility
    pre_stim3_imm = mean(imm_bin(35));
    stim3_imm = mean(imm_bin(36));
    post_stim3_imm = mean(imm_bin(37));
    % velocity
    pre_stim3_vel = mean(vel_bin(35));
    stim3_vel = mean(vel_bin(36));
    post_stim3_vel = mean(vel_bin(37));
    % ambulation
    pre_stim3_amb = mean(amb_bin(35));
    stim3_amb = mean(amb_bin(36));
    post_stim3_amb = mean(amb_bin(37));
    off_stim3_amb = mean(amb_bin(40));
    % fine movement
    pre_stim3_fm = mean(fm_bin(35));
    stim3_fm = mean(fm_bin(36));
    post_stim3_fm = mean(fm_bin(37));
    off_stim3_fm = mean(fm_bin(40));
    % freezing
    pre_stim3_frz = mean(frz_bin(35));
    stim3_frz = mean(frz_bin(36));
    post_stim3_frz = mean(frz_bin(37));
    % distance
    pre_stim3_dist = sum(dist_bin(35));
    stim3_dist = sum(dist_bin(36));
    post_stim3_dist = sum(dist_bin(37));

    % stim 4
    pre_stim4_time = datenum(time_bin(42,:));    
    stim4_time = datenum(time_bin(43,:));    
    post_stim4_time = datenum(time_bin(44,:));    
    stim4_color = [.6667 0 0];
    % immobility
    pre_stim4_imm = mean(imm_bin(42));
    stim4_imm = mean(imm_bin(43));
    post_stim4_imm = mean(imm_bin(44));
    % velocity
    pre_stim4_vel = mean(vel_bin(42));
    stim4_vel = mean(vel_bin(43));
    post_stim4_vel = mean(vel_bin(44));
    % ambulation
    pre_stim4_amb = mean(amb_bin(42));
    stim4_amb = mean(amb_bin(43));
    post_stim4_amb = mean(amb_bin(44));
    off_stim4_amb = mean(amb_bin(47));
    % fine movement
    pre_stim4_fm = mean(fm_bin(42));
    stim4_fm = mean(fm_bin(43));
    post_stim4_fm = mean(fm_bin(44));
    off_stim4_fm = mean(fm_bin(47));
    % freezing
    pre_stim4_frz = mean(frz_bin(42));
    stim4_frz = mean(frz_bin(43));
    post_stim4_frz = mean(frz_bin(44));
    % distance
    pre_stim4_dist = sum(dist_bin(42));
    stim4_dist = sum(dist_bin(43));
    post_stim4_dist = sum(dist_bin(44));

    % stim 5
    pre_stim5_time = datenum(time_bin(49,:));    
    stim5_time = datenum(time_bin(50,:));    
    post_stim5_time = datenum(time_bin(51,:));    
    stim5_color = [.8750 0 0];
    % immobility
    pre_stim5_imm = mean(imm_bin(49));
    stim5_imm = mean(imm_bin(50));
    post_stim5_imm = mean(imm_bin(51));
    % velocity
    pre_stim5_vel = mean(vel_bin(49));
    stim5_vel = mean(vel_bin(50));
    post_stim5_vel = mean(vel_bin(51));
    % ambulation
    pre_stim5_amb = mean(amb_bin(49));
    stim5_amb = mean(amb_bin(50));
    post_stim5_amb = mean(amb_bin(51));
    off_stim5_amb = mean(amb_bin(54));
    % fine movement
    pre_stim5_fm = mean(fm_bin(49));
    stim5_fm = mean(fm_bin(50));
    post_stim5_fm = mean(fm_bin(51));
    off_stim5_fm = mean(fm_bin(54));
    % freezing
    pre_stim5_frz = mean(frz_bin(49));
    stim5_frz = mean(frz_bin(50));
    post_stim5_frz = mean(frz_bin(51));
    % distance
    pre_stim5_dist = sum(dist_bin(49));
    stim5_dist = sum(dist_bin(50));
    post_stim5_dist = sum(dist_bin(51));

    % stim 6
    pre_stim6_time = datenum(time_bin(56,:));    
    stim6_time = datenum(time_bin(57,:));    
    post_stim6_time = datenum(time_bin(58,:));
    stim6_color = [1 .0833 0];
    % immobility
    pre_stim6_imm = mean(imm_bin(56));
    stim6_imm = mean(imm_bin(57));
    post_stim6_imm = mean(imm_bin(58));
    % velocity
    pre_stim6_vel = mean(vel_bin(56));
    stim6_vel = mean(vel_bin(57));
    post_stim6_vel = mean(vel_bin(58));
    % ambulation
    pre_stim6_amb = mean(amb_bin(56));
    stim6_amb = mean(amb_bin(57));
    post_stim6_amb = mean(amb_bin(58));
    off_stim6_amb = mean(amb_bin(61));
    % fine movement
    pre_stim6_fm = mean(fm_bin(56));
    stim6_fm = mean(fm_bin(57));
    post_stim6_fm = mean(fm_bin(58));
    off_stim6_fm = mean(fm_bin(61));
    % freezing
    pre_stim6_frz = mean(frz_bin(56));
    stim6_frz = mean(frz_bin(57));
    post_stim6_frz = mean(frz_bin(58));
    % distance
    pre_stim6_dist = sum(dist_bin(56));
    stim6_dist = sum(dist_bin(57));
    post_stim6_dist = sum(dist_bin(58));

    % stim 7
    pre_stim7_time = datenum(time_bin(63,:));    
    stim7_time = datenum(time_bin(64,:));    
    post_stim7_time = datenum(time_bin(65,:));    
    stim7_color = [1 .2917 0];
    % immobility
    pre_stim7_imm = mean(imm_bin(63));
    stim7_imm = mean(imm_bin(64));
    post_stim7_imm = mean(imm_bin(65));
    % velocity
    pre_stim7_vel = mean(vel_bin(63));
    stim7_vel = mean(vel_bin(64));
    post_stim7_vel = mean(vel_bin(65));
    % ambulation
    pre_stim7_amb = mean(amb_bin(63));
    stim7_amb = mean(amb_bin(64));
    post_stim7_amb = mean(amb_bin(65));
    off_stim7_amb = mean(amb_bin(68));
    % fine movement
    pre_stim7_fm = mean(fm_bin(63));
    stim7_fm = mean(fm_bin(64));
    post_stim7_fm = mean(fm_bin(65));
    off_stim7_fm = mean(fm_bin(68));
    % freezing
    pre_stim7_frz = mean(frz_bin(63));
    stim7_frz = mean(frz_bin(64));
    post_stim7_frz = mean(frz_bin(65));
    % distance
    pre_stim7_dist = sum(dist_bin(63));
    stim7_dist = sum(dist_bin(64));
    post_stim7_dist = sum(dist_bin(65));

    % stim 8
    pre_stim8_time = datenum(time_bin(70,:));    
    stim8_time = datenum(time_bin(71,:));
    post_stim8_time = datenum(time_bin(72,:));    
    stim8_color = [1 .5000 0];
    % immobility
    pre_stim8_imm = mean(imm_bin(70));
    stim8_imm = mean(imm_bin(71));
    post_stim8_imm = mean(imm_bin(72));
    % velocity
    pre_stim8_vel = mean(vel_bin(70));
    stim8_vel = mean(vel_bin(71));
    post_stim8_vel = mean(vel_bin(72));   
    % ambulation
    pre_stim8_amb = mean(amb_bin(70));
    stim8_amb = mean(amb_bin(71));
    post_stim8_amb = mean(amb_bin(72));
    off_stim8_amb = mean(amb_bin(75));
    % fine movement
    pre_stim8_fm = mean(fm_bin(70));
    stim8_fm = mean(fm_bin(71));
    post_stim8_fm = mean(fm_bin(72));
    off_stim8_fm = mean(fm_bin(75));
    % freezing
    pre_stim8_frz = mean(frz_bin(70));
    stim8_frz = mean(frz_bin(71));
    post_stim8_frz = mean(frz_bin(72));
    % distance
    pre_stim8_dist = sum(dist_bin(70));
    stim8_dist = sum(dist_bin(71));
    post_stim8_dist = sum(dist_bin(72));

    % stim 9
    pre_stim9_time = datenum(time_bin(77,:));    
    stim9_time = datenum(time_bin(78,:));    
    post_stim9_time = datenum(time_bin(79,:));    
    stim9_color = [1 .7083 0];
    % immobility
    pre_stim9_imm = mean(imm_bin(77));
    stim9_imm = mean(imm_bin(78));
    post_stim9_imm = mean(imm_bin(79));
    % velocity
    pre_stim9_vel = mean(vel_bin(77));
    stim9_vel = mean(vel_bin(78));
    post_stim9_vel = mean(vel_bin(79));
    % ambulation
    pre_stim9_amb = mean(amb_bin(77));
    stim9_amb = mean(amb_bin(78));
    post_stim9_amb = mean(amb_bin(79));
    off_stim9_amb = mean(amb_bin(82));
    % fine movement
    pre_stim9_fm = mean(fm_bin(77));
    stim9_fm = mean(fm_bin(78));
    post_stim9_fm = mean(fm_bin(79));
    off_stim9_fm = mean(fm_bin(82));
    % freezing
    pre_stim9_frz = mean(frz_bin(77));
    stim9_frz = mean(frz_bin(78));
    post_stim9_frz = mean(frz_bin(79));
    % distance
    pre_stim9_dist = sum(dist_bin(77));
    stim9_dist = sum(dist_bin(78));
    post_stim9_dist = sum(dist_bin(79));

    % stim 10
    pre_stim10_time = datenum(time_bin(84,:));    
    stim10_time = datenum(time_bin(85,:));    
    post_stim10_time = datenum(time_bin(86,:));    
    stim10_color = [1 .9167 0];
    % immobility
    pre_stim10_imm = mean(imm_bin(84));
    stim10_imm = mean(imm_bin(85));
    post_stim10_imm = mean(imm_bin(86));
    % velocity
    pre_stim10_vel = mean(vel_bin(84));
    stim10_vel = mean(vel_bin(85));
    post_stim10_vel = mean(vel_bin(86));
    % ambulation
    pre_stim10_amb = mean(amb_bin(84));
    stim10_amb = mean(amb_bin(84));
    post_stim10_amb = mean(amb_bin(86));
    off_stim10_amb = mean(amb_bin(88));
    % fine movement
    pre_stim10_fm = mean(fm_bin(84));
    stim10_fm = mean(fm_bin(85));
    post_stim10_fm = mean(fm_bin(86));
    off_stim10_fm = mean(fm_bin(88));
    % freezing
    pre_stim10_frz = mean(frz_bin(77));
    stim10_frz = mean(frz_bin(85));
    post_stim10_frz = mean(frz_bin(86));
    % distance
    pre_stim10_dist = sum(dist_bin(84));
    stim10_dist = sum(dist_bin(85));
    post_stim10_dist = sum(dist_bin(86));

   % stim averages
    pre_stim_amb_avg = mean(amb_bin(pre_stim_times));
    stim_amb_avg = mean(amb_bin(stim_times));
    post_stim_amb_avg = mean(amb_bin(post_stim_times));
    pre_stim_fm_avg = mean(fm_bin(pre_stim_times));
    stim_fm_avg = mean(fm_bin(stim_times));
    post_stim_fm_avg = mean(fm_bin(post_stim_times));
    pre_stim_frz_avg = mean(frz_bin(pre_stim_times));
    stim_frz_avg = mean(frz_bin(stim_times));
    post_stim_frz_avg = mean(frz_bin(post_stim_times));

% movement average variables
% P_ambulation averages
base_amb = mean(amb_bin(11:20)); % avg of 5 min before stim paradigm
all_base_amb = mean(amb_bin(1:20)); % avg of 10 min before stim paradigm
pre_amb = mean(amb_bin(pre_stim_times)); % avg of 30 sec before each stim
stim_amb = mean(amb_bin(stim_times)); % avg of 30 sec stims
early_stim_times = stim_times(1:3);  
stim_early_amb = mean(amb_bin(early_stim_times));
late_stim_times = stim_times(8:10);
stim_late_amb = mean(amb_bin(late_stim_times));
stim_off_amb =  mean(amb_bin(stim_off_times)); %2 minutes after each stim
early_stim_off_times = stim_off_times(1:3);
stim_early_off_amb = mean(amb_bin(early_stim_off_times));
late_stim_off_times = stim_off_times(8:10);
stim_late_off_amb = mean(amb_bin(late_stim_off_times));
post_amb = mean(amb_bin(post_stim_times)); % avg of 30 sec after each stim
post5_amb = mean(amb_bin(86:95)); % avg of 5 min after stim paradigm
amb_10post = mean(amb_bin(96:105));
amb_10post_all = mean(amb_bin(86:105)); % avg up to 10 min post stim paradigm
amb_30post = mean(amb_bin(141:150));
amb_30post_all = mean(amb_bin(86:145));
amb_1hrpost = mean(amb_bin(261:270));
amb_1hrpost_all = mean(amb_bin(86:205));
amb_2hrpost = mean(amb_bin(361:370));

pre_amb = mean(amb_bin(pre_stim_times));
stim_amb = mean(amb_bin(stim_times)); 
early_stim_times = stim_times(1:3);  
stim_early_amb = mean(amb_bin(early_stim_times));
late_stim_times = stim_times(8:10);
stim_late_amb = mean(amb_bin(late_stim_times));
stim_off_amb =  mean(amb_bin(stim_off_times));
early_stim_off_times = stim_off_times(1:3);
stim_early_off_amb = mean(amb_bin(early_stim_off_times));
late_stim_off_times = stim_off_times(8:10);
stim_late_off_amb = mean(amb_bin(late_stim_off_times));
post_amb = mean(amb_bin(post_stim_times));

pre_amb_sem = nanstd(all_amb_30(pre_stim_times),[],2)/sqrt(cohort_N);
stim_amb_sem = nanstd(all_amb_30(stim_times),[],2)/sqrt(cohort_N);
stim_early_amb_sem = nanstd(all_amb_30(early_stim_times),[],2)/sqrt(cohort_N);
stim_late_amb_sem = nanstd(all_amb_30(late_stim_times),[],2)/sqrt(cohort_N);
stim_off_amb_sem = nanstd(all_amb_30(stim_off_times),[],2)/sqrt(cohort_N);
stim_early_off_amb_sem = nanstd(all_amb_30(early_stim_off_times),[],2)/sqrt(cohort_N);
stim_late_off_amb_sem = nanstd(all_amb_30(post_stim_times),[],2)/sqrt(cohort_N);
post_amb_sem = nanstd(all_amb_30(late_stim_off_times),[],2)/sqrt(cohort_N);
base_amb_sem = nanstd(all_amb_30(11:20),[],2)/sqrt(cohort_N);
all_base_amb_sem = nanstd(all_amb_30(1:20),[],2)/sqrt(cohort_N);
post5_amb_sem = nanstd(all_amb_30(86:90),[],2)/sqrt(cohort_N);
amb_10post_sem = nanstd(all_amb_30(86:95),[],2)/sqrt(cohort_N);
amb_10post_all_sem = nanstd(all_amb_30(86:105),[],2)/sqrt(cohort_N);
amb_30post_sem = nanstd(all_amb_30(141:150),[],2)/sqrt(cohort_N);
amb_30post_all_sem = nanstd(all_amb_30(86:145),[],2)/sqrt(cohort_N);
amb_1hrpost_sem = nanstd(all_amb_30(261:270),[],2)/sqrt(cohort_N);
amb_1hrpost_all_sem = nanstd(all_amb_30(86:205),[],2)/sqrt(cohort_N);
amb_2hrpost_sem = nanstd(all_amb_30(361:370),[],2)/sqrt(cohort_N);


stim1_time = datenum(t_1(630,:));
stim1_amb_avg = mean(amb_true_1(630:660));
stim2_time = datenum(t_1(840,:));
stim2_amb_avg = mean(amb_true_1(840:870));
stim3_time = datenum(t_1(1050,:));
stim3_amb_avg = mean(amb_true_1(1050:1080));
stim4_time = datenum(t_1(1260,:));
stim4_amb_avg = mean(amb_true_1(1260:1290));
stim5_time = datenum(t_1(1470,:));
stim5_amb_avg = mean(amb_true_1(1470:1500));
stim6_time = datenum(t_1(1680,:));
stim6_amb_avg = mean(amb_true_1(1680:1710));
stim7_time = datenum(t_1(1890,:));
stim7_amb_avg = mean(amb_true_1(1890:1920));
stim8_time = datenum(t_1(2100,:));
stim8_amb_avg = mean(amb_true_1(2100:2130));
stim9_time = datenum(t_1(2310,:));
stim9_amb_avg = mean(amb_true_1(2310:2340));
stim10_time = datenum(t_1(2520,:));
stim10_amb_avg = mean(amb_true_1(2520:2550));

% movement averages of first 10 seconds of all stims
stim_time_1 = datenum(t_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520])); % first second of all stims
stim_amb_1 = sum(amb_true_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520]));
stim_time_2 = datenum(t_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521])); % second second of all stims
stim_amb_2 = sum(amb_true_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_time_3 = datenum(t_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_amb_3 = sum(amb_true_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_time_4 = datenum(t_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_amb_4 = sum(amb_true_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_time_5 = datenum(t_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_amb_5 = sum(amb_true_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_time_6 = datenum(t_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_amb_6 = sum(amb_true_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_time_7 = datenum(t_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_amb_7 = sum(amb_true_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_time_8 = datenum(t_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_amb_8 = sum(amb_true_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_time_9 = datenum(t_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_amb_9 = sum(amb_true_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_time_10 = datenum(t_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));
stim_amb_10 = sum(amb_true_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));

% P_fine_movement averages
base_fm = mean(fm_bin(11:20)); % avg of 5 min before stim paradigm
all_base_fm = mean(fm_bin(1:20));
pre_fm = mean(fm_bin(pre_stim_times)); % avg of 30 sec before each stim
stim_fm = mean(fm_bin(stim_times)); % avg of 30 sec stims
stim_off_fm =  mean(fm_bin(stim_off_times)); %2 minutes after each stim
early_stim_times = stim_times(1:3);  
stim_early_fm = mean(fm_bin(early_stim_times));
late_stim_times = stim_times(8:10);
stim_late_fm = mean(fm_bin(late_stim_times));
early_stim_off_times = stim_off_times(1:3);
stim_early_off_fm = mean(fm_bin(early_stim_off_times));
late_stim_off_times = stim_off_times(8:10);
stim_late_off_fm = mean(fm_bin(late_stim_off_times));
post_fm = mean(fm_bin(post_stim_times)); % avg of 30 sec after each stim
post5_fm = mean(fm_bin(86:96)); % avg of 5 min after stim paradigm
fm_10post = mean(fm_bin(96:105));
fm_10post_all = mean(fm_bin(86:105));
fm_30post = mean(fm_bin(141:150));
fm_30post_all = mean(fm_bin(86:145));
fm_1hrpost = mean(fm_bin(261:270));
fm_1hrpost_all = mean(fm_bin(86:205));
fm_2hrpost = mean(fm_bin(361:370));

pre_fm_sem = nanstd(all_fm_30(pre_stim_times),[],2)/sqrt(cohort_N);
stim_fm_sem = nanstd(all_fm_30(stim_times),[],2)/sqrt(cohort_N);
stim_early_fm_sem = nanstd(all_fm_30(early_stim_times),[],2)/sqrt(cohort_N);
stim_late_fm_sem = nanstd(all_fm_30(late_stim_times),[],2)/sqrt(cohort_N);
stim_off_fm_sem = nanstd(all_fm_30(stim_off_times),[],2)/sqrt(cohort_N);
stim_early_off_fm_sem = nanstd(all_fm_30(early_stim_off_times),[],2)/sqrt(cohort_N);
stim_late_off_fm_sem = nanstd(all_fm_30(post_stim_times),[],2)/sqrt(cohort_N);
post_fm_sem = nanstd(all_fm_30(late_stim_off_times),[],2)/sqrt(cohort_N);
base_fm_sem = nanstd(all_fm_30(11:20),[],2)/sqrt(cohort_N);
all_base_fm_sem = nanstd(all_fm_30(1:20),[],2)/sqrt(cohort_N);
post5_fm_sem = nanstd(all_fm_30(86:90),[],2)/sqrt(cohort_N);
fm_10post_sem = nanstd(all_fm_30(86:95),[],2)/sqrt(cohort_N);
fm_10post_all_sem = nanstd(all_fm_30(86:105),[],2)/sqrt(cohort_N);
fm_30post_sem = nanstd(all_fm_30(141:150),[],2)/sqrt(cohort_N);
fm_30post_all_sem = nanstd(all_fm_30(86:145),[],2)/sqrt(cohort_N);
fm_1hrpost_sem = nanstd(all_fm_30(261:270),[],2)/sqrt(cohort_N);
fm_1hrpost_all_sem = nanstd(all_fm_30(86:205),[],2)/sqrt(cohort_N);
fm_2hrpost_sem = nanstd(all_fm_30(361:370),[],2)/sqrt(cohort_N);


stim1_time = datenum(t_1(630,:));
stim1_fm_avg = mean(fm_true_1(630:660));
stim2_time = datenum(t_1(840,:));
stim2_fm_avg = mean(fm_true_1(840:870));
stim3_time = datenum(t_1(1050,:));
stim3_fm_avg = mean(fm_true_1(1050:1080));
stim4_time = datenum(t_1(1260,:));
stim4_fm_avg = mean(fm_true_1(1260:1290));
stim5_time = datenum(t_1(1470,:));
stim5_fm_avg = mean(fm_true_1(1470:1500));
stim6_time = datenum(t_1(1680,:));
stim6_fm_avg = mean(fm_true_1(1680:1710));
stim7_time = datenum(t_1(1890,:));
stim7_fm_avg = mean(fm_true_1(1890:1920));
stim8_time = datenum(t_1(2100,:));
stim8_fm_avg = mean(fm_true_1(2100:2130));
stim9_time = datenum(t_1(2310,:));
stim9_fm_avg = mean(fm_true_1(2310:2340));
stim10_time = datenum(t_1(2520,:));
stim10_fm_avg = mean(fm_true_1(2520:2550));

stim_time_1 = datenum(t_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520])); % first second of all stims
stim_fm_1 = sum(fm_true_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520]));
stim_time_2 = datenum(t_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_fm_2 = sum(fm_true_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_time_3 = datenum(t_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_fm_3 = sum(fm_true_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_time_4 = datenum(t_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_fm_4 = sum(fm_true_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_time_5 = datenum(t_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_fm_5 = sum(fm_true_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_time_6 = datenum(t_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_fm_6 = sum(fm_true_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_time_7 = datenum(t_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_fm_7 = sum(fm_true_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_time_8 = datenum(t_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_fm_8 = sum(fm_true_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_time_9 = datenum(t_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_fm_9 = sum(fm_true_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_time_10 = datenum(t_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));
stim_fm_10 = sum(fm_true_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));

% P_freezing averages
base_frz = mean(frz_bin(11:20));% avg of 5 min before stim paradigm
all_base_frz = mean(frz_bin(1:20));
pre_frz = mean(frz_bin(pre_stim_times)); % avg of 30 sec before each stim
stim_frz = mean(frz_bin(stim_times)); % avg of 30 sec stims
stim_off_frz =  mean(frz_bin(stim_off_times)); %2 minutes after each stim
early_stim_times = stim_times(1:3);  
stim_early_frz = mean(frz_bin(early_stim_times));
late_stim_times = stim_times(8:10);
stim_late_frz = mean(frz_bin(late_stim_times));
early_stim_off_times = stim_off_times(1:3);
stim_early_off_frz = mean(frz_bin(early_stim_off_times));
late_stim_off_times = stim_off_times(8:10);
stim_late_off_frz = mean(frz_bin(late_stim_off_times));
post_frz = mean(frz_bin(post_stim_times)); % avg of 30 sec after each stim
post5_frz = mean(frz_bin(86:96)); % avg of 5 min after stim paradigm
frz_10post = mean(frz_bin(96:105));
frz_10post_all = mean(frz_bin(86:105));
frz_30post = mean(frz_bin(141:150));
frz_30post_all = mean(frz_bin(86:145));
frz_1hrpost = mean(frz_bin(261:270));
frz_1hrpost_all = mean(frz_bin(86:205));
frz_2hrpost = mean(frz_bin(361:370));

pre_frz_sem = nanstd(all_frz_30(pre_stim_times),[],2)/sqrt(cohort_N);
stim_frz_sem = nanstd(all_frz_30(stim_times),[],2)/sqrt(cohort_N);
stim_early_frz_sem = nanstd(all_frz_30(early_stim_times),[],2)/sqrt(cohort_N);
stim_late_frz_sem = nanstd(all_frz_30(late_stim_times),[],2)/sqrt(cohort_N);
stim_off_frz_sem = nanstd(all_frz_30(stim_off_times),[],2)/sqrt(cohort_N);
stim_early_off_frz_sem = nanstd(all_frz_30(early_stim_off_times),[],2)/sqrt(cohort_N);
stim_late_off_frz_sem = nanstd(all_frz_30(post_stim_times),[],2)/sqrt(cohort_N);
post_frz_sem = nanstd(all_frz_30(late_stim_off_times),[],2)/sqrt(cohort_N);
base_frz_sem = nanstd(all_frz_30(11:20),[],2)/sqrt(cohort_N);
all_base_frz_sem = nanstd(all_frz_30(1:20),[],2)/sqrt(cohort_N);
post5_frz_sem = nanstd(all_frz_30(86:90),[],2)/sqrt(cohort_N);
frz_10post_sem = nanstd(all_frz_30(86:95),[],2)/sqrt(cohort_N);
frz_10post_all_sem = nanstd(all_frz_30(86:105),[],2)/sqrt(cohort_N);
frz_30post_sem = nanstd(all_frz_30(141:150),[],2)/sqrt(cohort_N);
frz_30post_all_sem = nanstd(all_frz_30(86:145),[],2)/sqrt(cohort_N);
frz_1hrpost_sem = nanstd(all_frz_30(261:270),[],2)/sqrt(cohort_N);
frz_1hrpost_all_sem = nanstd(all_frz_30(86:205),[],2)/sqrt(cohort_N);
frz_2hrpost_sem = nanstd(all_frz_30(361:370),[],2)/sqrt(cohort_N);

stim1_time = datenum(t_1(630,:));
stim1_frz_avg = mean(frz_true_1(630:660));
stim2_time = datenum(t_1(840,:));
stim2_frz_avg = mean(frz_true_1(840:870));
stim3_time = datenum(t_1(1050,:));
stim3_frz_avg = mean(frz_true_1(1050:1080));
stim4_time = datenum(t_1(1260,:));
stim4_frz_avg = mean(frz_true_1(1260:1290));
stim5_time = datenum(t_1(1470,:));
stim5_frz_avg = mean(frz_true_1(1470:1500));
stim6_time = datenum(t_1(1680,:));
stim6_frz_avg = mean(frz_true_1(1680:1710));
stim7_time = datenum(t_1(1890,:));
stim7_frz_avg = mean(frz_true_1(1890:1920));
stim8_time = datenum(t_1(2100,:));
stim8_frz_avg = mean(frz_true_1(2100:2130));
stim9_time = datenum(t_1(2310,:));
stim9_frz_avg = mean(frz_true_1(2310:2340));
stim10_time = datenum(t_1(2520,:));
stim10_frz_avg = mean(frz_true_1(2520:2550));

stim_time_1 = datenum(t_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520])); % first second of all stims
stim_frz_1 = sum(frz_true_1([630 840 1050 1260 1470 1680 1890 2100 2310 2520]));
stim_time_2 = datenum(t_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_frz_2 = sum(frz_true_1([631 841 1051 1261 1471 1681 1891 2101 2311 2521]));
stim_time_3 = datenum(t_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_frz_3 = sum(frz_true_1([632 842 1052 1262 1472 1682 1892 2102 2312 2522]));
stim_time_4 = datenum(t_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_frz_4 = sum(frz_true_1([633 843 1053 1263 1473 1683 1893 2103 2313 2523]));
stim_time_5 = datenum(t_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_frz_5 = sum(frz_true_1([634 844 1054 1264 1474 1684 1894 2104 2314 2524]));
stim_time_6 = datenum(t_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_frz_6 = sum(frz_true_1([635 845 1055 1265 1475 1685 1895 2105 2315 2525]));
stim_time_7 = datenum(t_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_frz_7 = sum(frz_true_1([636 846 1056 1266 1476 1686 1896 2106 2316 2526]));
stim_time_8 = datenum(t_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_frz_8 = sum(frz_true_1([637 847 1057 1267 1477 1687 1897 2107 2317 2527]));
stim_time_9 = datenum(t_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_frz_9 = sum(frz_true_1([638 848 1058 1268 1478 1688 1898 2108 2318 2528]));
stim_time_10 = datenum(t_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));
stim_frz_10 = sum(frz_true_1([639 849 1059 1269 1479 1689 1899 2109 2319 2529]));

    % total distance traveled variables
    dist_base = sum(dist_bin(1:11)); % total distance traveled (TDT) in first 5 minutes of trial
    dist_pre = sum(dist_bin(pre_stim_times)); % TDT PRE all stims combined (5 minutes total)
    dist_stims = sum(dist_bin(stim_times)); % TDT in all stims combined (5 minutes total)
    dist_post = sum(dist_bin(post_stim_times)); % TDT POST all stims combined (5 minutes total)
    dist_5post = sum(dist_bin(86:96)); % TDT in 5 minutes after stim paradigm
    dist_10post = sum(dist_bin(101:111)); % TDT 10 minutes after stim paradigm (5 minute average 5 - 15 minutes out)
    dist_30post = sum(dist_bin(141:151)); % TDT 30 minutes after stim paradigm (5 minute average 25 - 35 minutes out)
    dist_1hrpost = sum(dist_bin(201:211)); % TDT 1 hr after stim paradigm (5 minute average 55 - 65 minutes out)
    
    base_fm = 1 - (base_amb + base_frz);
    pre_fm =1 - (pre_amb + pre_frz);
    stim_fm = 1 - (stim_amb + stim_frz);
    stim_off_fm =  1 - (stim_off_amb + stim_off_frz);
    stim_early_fm = 1 - (stim_early_amb + stim_early_frz);
    stim_late_fm = 1 - (stim_late_amb + stim_late_frz);
    stim_early_off_fm = 1 - (stim_early_off_amb + stim_early_off_frz);
    stim_late_off_fm = 1 - (stim_late_off_amb + stim_late_off_frz);
    post_fm = 1 - (post_amb + post_frz);
    post5_fm = 1 - (post5_amb + post5_frz);
    fm_10post = 1 - (amb_10post + frz_10post);
    fm_30post = 1 - (amb_30post + frz_30post);
    fm_1hrpost = 1 - (amb_1hrpost + frz_1hrpost);
    fm_2hrpost = 1 - (amb_2hrpost + frz_2hrpost);
    
    imm_bin_test = avg_imm_30(1:480);
    indiv_imm = [keep.RAW_30_sec_bin(animal_num).P_Immobile];
    avg_indiv_imm = nanmean(indiv_imm,2);
    indiv_imm_bin = avg_indiv_imm(1:480);
    
    %persistence variables
    x_pre = mean(datenum(time_bin(12:21,:)));
    y_pre = mean(indiv_imm_bin(12:21));
    % avg of all stims
    x_stim_all = mean(datenum(time_bin(85,:))); % x value is the time of the 10th stim but the y value is the average of all stims
    y_stim_all = mean(indiv_imm_bin(stim_times));
    % 10th stim
    x_stim_last = mean(datenum(time_bin(85,:)));
    y_stim_last = mean(indiv_imm_bin(85,:));
    % 1 hour post stim
    x_1hour = mean(datenum(time_bin(112:131,:)));
    y_1hour = mean(indiv_imm_bin(112:131));
    % 1.5 hour post stim
    x_midhour = mean(datenum(time_bin(172:191,:)));
    y_midhour = mean(indiv_imm_bin(172:191));
    % 2 hour post stim
    x_2hour = mean(datenum(time_bin(232:251,:)));
    y_2hour = mean(indiv_imm_bin(232:251));
    % 3 hour post stim
    x_3hour = mean(datenum(time_bin(352:371,:)));
    y_3hour = mean(indiv_imm_bin(352:371));
    % 4 hour post stim
    x_4hour = mean(datenum(time_bin(462:480,:)));
    y_4hour = mean(indiv_imm_bin(462:480));
    
    x = [x_pre x_stim_all x_1hour x_midhour x_2hour x_3hour x_4hour];
    y = [y_pre y_stim_all y_1hour y_midhour y_2hour y_3hour y_4hour];
    avg = plot(x,y,'-o','Color',[0 0 0],'LineWidth',3.5);
    avg.MarkerFaceColor = [0 0 0];
    avg.MarkerSize = 3;
    
    xlim([0 .1646]);
    xticks([.003472 .0292 .0382 .0625 .0833 .1250 .1646]);
    xticklabels({'pre','st','1','1.5','2','3','4'});
    ylabel('% Immobile');
    % title('Persistence');

    % patch for stim period
    patch_start = 0.0240;
    patch_end = 0.0344;
    xp = [patch_start patch_start patch_end patch_end];
    yp = [0 100 100 0];
    patch(xp,yp,stim_color,'EdgeColor','none','facealpha',0.5);
    hold on;
    
    %% SUMMARY FIGURE
    % IMMOBILITY 4 HOURS
    % P_time immobile over 4 hour trial
    subplot(7,4,[1:8]); hold on;
    p = plot(time_bin,imm_bin,'-o','linewidth',2,'color',[0,0,0]);
    p.MarkerSize = 2;
    ylim([0 100]);
    stim_times = [22:7:85];

        for st = 1:length(stim_times)
            x = datenum([time_bin(stim_times(st)-1) time_bin(stim_times(st)-1) time_bin(stim_times(st)+1) time_bin(stim_times(st)+1)]);
            y = [0 100 100 0];
            patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
        end
        
    xlabel('time (min)');
    ylabel('% Immobile');
    set(findall(gcf,'-property','TickDir'),'TickDir','out');
    graph_title = strcat(keep.RAW_1_sec_bin(animal_num).animal_ID);
    title(graph_title);

    % IMMOBILITY 1 HOUR
    % zoom in on stimulations for immobility
    subplot(7,4,[9:10 13:14]); hold on;
    p = plot(time_bin_1h,imm_bin_1h,'-o','linewidth',2,'color',[0,0,0]);
    p.MarkerSize = 2;
    ylim([0 100]);

    for st = 1:length(stim_times)
            x = datenum([time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)+1) time_bin_1h(stim_times(st)+1)]);
            y = [0 100 100 0];
            patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
        end

    xlabel('time (min)');
    ylabel('% Immobile');
    set(findall(gcf,'-property','TickDir'),'TickDir','out');

    % PERSISTENCE
    % average immobility at several time points after stim paradigm
    subplot(7,4,[11 15]); hold on;
    
    %immobility
    imm_bin_test = avg_imm_30(1:480);
    indiv_imm = [keep.RAW_30_sec_bin(animal_num).P_Immobile];
    avg_indiv_imm = nanmean(indiv_imm,2);
    indiv_imm_bin = avg_indiv_imm(1:480);
    
    %persistence variables
    x_pre = mean(datenum(time_bin(12:21,:)));
    y_pre = mean(indiv_imm_bin(12:21));
    % avg of all stims
    x_stim_all = mean(datenum(time_bin(85,:))); % x value is the time of the 10th stim but the y value is the average of all stims
    y_stim_all = mean(indiv_imm_bin(stim_times));
    % 10th stim
    x_stim_last = mean(datenum(time_bin(85,:)));
    y_stim_last = mean(indiv_imm_bin(85,:));
    % 1 hour post stim
    x_1hour = mean(datenum(time_bin(112:131,:)));
    y_1hour = mean(indiv_imm_bin(112:131));
    % 1.5 hour post stim
    x_midhour = mean(datenum(time_bin(172:191,:)));
    y_midhour = mean(indiv_imm_bin(172:191));
    % 2 hour post stim
    x_2hour = mean(datenum(time_bin(232:251,:)));
    y_2hour = mean(indiv_imm_bin(232:251));
    % 3 hour post stim
    x_3hour = mean(datenum(time_bin(352:371,:)));
    y_3hour = mean(indiv_imm_bin(352:371));
    % 4 hour post stim
    x_4hour = mean(datenum(time_bin(462:480,:)));
    y_4hour = mean(indiv_imm_bin(462:480));
    
    x = [x_pre x_stim_all x_1hour x_midhour x_2hour x_3hour x_4hour];
    y = [y_pre y_stim_all y_1hour y_midhour y_2hour y_3hour y_4hour];
    avg = plot(x,y,'-o','Color',[0 0 0],'LineWidth',3.5);
    avg.MarkerFaceColor = [0 0 0];
    avg.MarkerSize = 3;
    
    xlim([0 .1646]);
    xticks([.003472 .0292 .0382 .0625 .0833 .1250 .1646]);
    xticklabels({'pre','st','1','1.5','2','3','4'});
    ylabel('% Immobile');
    % title('Persistence');

    % patch for stim period
    patch_start = 0.0240;
    patch_end = 0.0344;
    xp = [patch_start patch_start patch_end patch_end];
    yp = [0 100 100 0];
    patch(xp,yp,stim_color,'EdgeColor','none','facealpha',0.5);
    hold on;

    % STIM RESPONSE
    % overlay of immobility immediately before (pre), during (stim), and after (post) each light pulse
    subplot(7,4,[12 16]); hold on;

    % STIM 1
    x = [pre_stim1_time stim1_time post_stim1_time]; % all x = time1 to allow for overlay
    y = [pre_stim1_imm stim1_imm post_stim1_imm];
    plot(x,y,'-o','Color',stim1_color,'LineWidth',2);
    p.MarkerFaceColor = stim1_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 2
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim2_imm stim2_imm post_stim2_imm];
    plot(x,y,'-o','Color',stim2_color,'LineWidth',2);
    p.MarkerFaceColor = stim2_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 3
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim3_imm stim3_imm post_stim3_imm];
    plot(x,y,'-o','Color',stim3_color,'LineWidth',2);
    p.MarkerFaceColor = stim3_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 4
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim4_imm stim4_imm post_stim4_imm];
    plot(x,y,'-o','Color',stim4_color,'LineWidth',2);
    p.MarkerFaceColor = stim4_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 5
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim5_imm stim5_imm post_stim5_imm];
    plot(x,y,'-o','Color',stim5_color,'LineWidth',2);
    p.MarkerFaceColor = stim5_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 6
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim6_imm stim6_imm post_stim6_imm];
    plot(x,y,'-o','Color',stim6_color,'LineWidth',2);
    p.MarkerFaceColor = stim6_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 7
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim7_imm stim7_imm post_stim7_imm];
    plot(x,y,'-o','Color',stim7_color,'LineWidth',2);
    p.MarkerFaceColor = stim7_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 8
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim8_imm stim8_imm post_stim8_imm];
    plot(x,y,'-o','Color',stim8_color,'LineWidth',2);
    p.MarkerFaceColor = stim8_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 9
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim9_imm stim9_imm post_stim9_imm];
    plot(x,y,'-o','Color',stim9_color,'LineWidth',2);
    p.MarkerFaceColor = stim9_color;
    p.MarkerSize = 2;
    hold on;

    % STIM 10
    x = [pre_stim1_time stim1_time post_stim1_time];
    y = [pre_stim10_imm stim10_imm post_stim10_imm];
    plot(x,y,'-o','Color',stim10_color,'LineWidth',2);
    p.MarkerFaceColor = stim10_color;
    p.MarkerSize = 2;
    hold on;

    % patch for stim period
    patch_start = 0.0071;
    patch_end = 0.00745;
    x = [patch_start patch_start patch_end patch_end];
    y = [0 100 100 0];
    patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
    xticks([0.00695 0.0073 0.00765]);
    xticklabels({'PRE','STIM','POST'});
    legend('stim 1','stim 2','stim 3','stim 4','stim 5','stim 6','stim 7',...
        'stim 8','stim 9','stim 10');

    % AMBULATION
    % avg P_time locomoting at specific time points
    subplot(7,4,[17 18]); hold on;
    p = plot(time_bin_1h,amb_bin_1h,'-o','linewidth',2,'color',[0.6350 0.0780 0.1840]);
    p.MarkerSize = 2;
    ylim([0 1]);

        for st = 1:length(stim_times)
            x = datenum([time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)+1) time_bin_1h(stim_times(st)+1)]);
            y = [0 100 100 0];
            patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
        end

    % xlabel('time (min)');
    xticklabels({'','',''});
    ylabel('Ambulation');
    set(findall(gcf,'-property','TickDir'),'TickDir','out');

    % FINE MOVEMENT
    % avg P_time performing fine movements at specific time points
    subplot(7,4,[21 22]); hold on;
    p = plot(time_bin_1h,fm_bin_1h,'-o','linewidth',2,'color',[0 0 0.6]);
    p.MarkerSize = 2;
    ylim([0 1]);

        for st = 1:length(stim_times)
            x = datenum([time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)+1) time_bin_1h(stim_times(st)+1)]);
            y = [0 100 100 0];
            patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
        end

    % xlabel('time (min)');
    xticklabels({'','',''});
    ylabel('Fine Movement');
    set(findall(gcf,'-property','TickDir'),'TickDir','out');

    % FREEZING
    % avg P_time not mobile at specific time points
    subplot(7,4,[25 26]); hold on;
    p = plot(time_bin_1h,frz_bin_1h,'-o','linewidth',2,'color',[0,0,0]);
    p.MarkerSize = 2;
    ylim([0 1]);

        for st = 1:length(stim_times)
            x = datenum([time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)-1) time_bin_1h(stim_times(st)+1) time_bin_1h(stim_times(st)+1)]);
            y = [0 100 100 0];
            patch(x,y,stim_color,'EdgeColor','none','facealpha',0.5);
        end

    xlabel('time (min)');
    ylabel('Freezing');
    set(findall(gcf,'-property','TickDir'),'TickDir','out');
    
    
    % MOTOR BEHAVIOR BAR GRAPH
    % bar graph of all movement parameters
    subplot(7,4,[19 23 27]); hold on;
    
    m = [all_base_amb all_base_fm all_base_frz; [0 0 0]; pre_amb pre_fm pre_frz; stim_amb stim_fm stim_frz; post_amb post_fm post_frz; [0 0 0];...
    amb_10post_all fm_10post_all frz_10post_all; amb_30post_all fm_30post_all frz_30post_all; amb_1hrpost_all fm_1hrpost_all frz_1hrpost_all;];
    b = bar(m,'stacked');

    b(1).FaceColor = [0.6350 0.0780 0.1840]; % ambulation color
    b(2).FaceColor = [0 0 0.6]; % fine movement color
    b(3).FaceColor = [0.5 0.5 0.5]; % immobile color

    hold on; 

    ylabel('% Movement');
    yticks([0 .5 1]);
    yticklabels({'0','50','100'});
    xlabel('');
    xticks([0 1 2 3 4 5 6 7 8 9]);
    xticklabels({'','BASE','','PRE','STIM','POST','','10','30','1HR',''});
    legend('ambulation','fine movement','immobile');


    % make things prettier
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');

    % Normalized Therapeutic Loss
    subplot(7,4,[20 24 28]); hold on;
    
% ambulation persistence variables (AVERAGE)
amb_bin_test = avg_amb_30(1:480);
x_pre = mean(datenum(time_bin(12:21,:))); %first 5 min
y_pre_amb = mean(amb_bin_test(12:21));
y_pre_amb_sem = nanstd(amb_bin_test(12:21))/sqrt(cohort_N);
% avg of all stims
x_stim_all = mean(datenum(time_bin(85,:))); % x value is the time of the 10th stim but the y value is the average of all stims (5 min)
y_stim_all_amb = mean(amb_bin_test(stim_times));
y_stim_all_amb_sem = nanstd(amb_bin_test(stim_times))/sqrt(cohort_N);
% 10th stim
x_stim_last = mean(datenum(time_bin(85,:))); 
y_stim_last_amb = mean(amb_bin_test(85,:));
y_stim_last_amb_sem = nanstd(amb_bin_test(85,:))/sqrt(cohort_N);
x_1hour = mean(datenum(time_bin(112:131,:))); 
y_1hour_amb = mean(amb_bin_test(112:131));
y_1hour_amb_sem = nanstd(amb_bin_test(112:131))/sqrt(cohort_N);
x_midhour = mean(datenum(time_bin(172:191,:)));
y_midhour_amb = mean(amb_bin_test(172:191));
y_midhour_amb_sem = nanstd(amb_bin_test(172:191))/sqrt(cohort_N);
x_2hour = mean(datenum(time_bin(232:251,:)));
y_2hour_amb = mean(amb_bin_test(232:251));
y_2hour_amb_sem = nanstd(amb_bin_test(232:251))/sqrt(cohort_N);
x_3hour = mean(datenum(time_bin(352:371,:)));
y_3hour_amb = mean(amb_bin_test(352:371));
y_3hour_amb_sem = nanstd(amb_bin_test(352:371))/sqrt(cohort_N);
x_4hour = mean(datenum(time_bin(462:480,:)));
y_4hour_amb = mean(amb_bin_test(462:480));
y_4hour_amb_sem = nanstd(amb_bin_test(462:480))/sqrt(cohort_N);
x_stim_early = mean(datenum(time_bin(15,:))); 
x_stim_late = mean(datenum(time_bin(85,:))); 
y_stim_early_amb = mean([stim1_amb stim2_amb stim3_amb stim4_amb]);
y_stim_late_amb = mean([stim9_amb stim10_amb]);

% fine movement persistence variables (AVERAGE)
fm_bin_test = avg_fm_30(1:480);
x_pre = mean(datenum(time_bin(12:21,:))); %first 5 min
y_pre_fm = mean(fm_bin_test(12:21));
y_pre_fm_sem = nanstd(fm_bin_test(12:21))/sqrt(cohort_N);
% avg of all stims
x_stim_all = mean(datenum(time_bin(85,:))); % x value is the time of the 10th stim but the y value is the average of all stims (5 min)
y_stim_all_fm = mean(fm_bin_test(stim_times));
y_stim_all_fm_sem = nanstd(fm_bin_test(stim_times))/sqrt(cohort_N);
% 10th stim
x_stim_last = mean(datenum(time_bin(85,:))); 
y_stim_last_fm = mean(fm_bin_test(85,:));
y_stim_last_fm_sem = nanstd(fm_bin_test(85,:))/sqrt(cohort_N);
x_1hour = mean(datenum(time_bin(112:131,:))); 
y_1hour_fm = mean(fm_bin_test(112:131));
y_1hour_fm_sem = nanstd(fm_bin_test(112:131))/sqrt(cohort_N);
x_midhour = mean(datenum(time_bin(172:191,:)));
y_midhour_fm = mean(fm_bin_test(172:191));
y_midhour_fm_sem = nanstd(fm_bin_test(172:191))/sqrt(cohort_N);
x_2hour = mean(datenum(time_bin(232:251,:)));
y_2hour_fm = mean(fm_bin_test(232:251));
y_2hour_fm_sem = nanstd(fm_bin_test(232:251))/sqrt(cohort_N);
x_3hour = mean(datenum(time_bin(352:371,:)));
y_3hour_fm = mean(fm_bin_test(352:371));
y_3hour_fm_sem = nanstd(fm_bin_test(352:371))/sqrt(cohort_N);
x_4hour = mean(datenum(time_bin(462:480,:)));
y_4hour_fm = mean(fm_bin_test(462:480));
y_4hour_fm_sem = nanstd(fm_bin_test(462:480))/sqrt(cohort_N);
y_stim_early_fm = mean([stim1_fm stim2_fm stim3_fm stim4_fm]);
y_stim_late_fm = mean([stim9_fm stim10_fm]);


% normalized to late stim avg
y_stim_late_amb_norm = y_stim_late_amb/y_stim_late_amb;
y_stim_late_amb_norm_sem = (sqrt(sum(y_stim_late_amb_norm - y_stim_late_amb)^2) / cohort_N);
y_pre_amb_norm = y_pre_amb/y_stim_late_amb;
y_pre_amb_norm_sem = (sqrt(sum(y_pre_amb_norm - y_pre_amb)^2) / cohort_N);
y_1hour_amb_norm = y_1hour_amb/y_stim_late_amb;
y_1hour_amb_norm_sem = (sqrt(sum(y_1hour_amb_norm - y_1hour_amb)^2) / cohort_N);
y_midhour_amb_norm = y_midhour_amb/y_stim_late_amb;
y_midhour_amb_norm_sem = (sqrt(sum(y_midhour_amb_norm - y_midhour_amb)^2) / cohort_N);
y_2hour_amb_norm = y_2hour_amb/y_stim_late_amb;
y_2hour_amb_norm_sem = (sqrt(sum(y_2hour_amb_norm - y_2hour_amb)^2) / cohort_N);
y_3hour_amb_norm = y_3hour_amb/y_stim_late_amb;
y_3hour_amb_norm_sem = (sqrt(sum(y_3hour_amb_norm - y_3hour_amb)^2) / cohort_N);
y_4hour_amb_norm = y_4hour_amb/y_stim_late_amb;
y_4hour_amb_norm_sem = (sqrt(sum(y_4hour_amb_norm - y_4hour_amb)^2) / cohort_N);

y_stim_late_fm_norm = y_stim_late_fm/y_stim_late_fm;
y_stim_late_fm_norm_sem = (sqrt(sum(y_stim_late_fm_norm - y_stim_late_fm)^2) / cohort_N);
y_pre_fm_norm = y_pre_fm/y_stim_late_fm;
y_pre_fm_norm_sem = (sqrt(sum(y_pre_fm_norm - y_pre_fm)^2) / cohort_N);
y_1hour_fm_norm = y_1hour_fm/y_stim_late_fm;
y_1hour_fm_norm_sem = (sqrt(sum(y_1hour_fm_norm - y_1hour_fm)^2) / cohort_N);
y_midhour_fm_norm = y_midhour_fm/y_stim_late_fm;
y_midhour_fm_norm_sem = (sqrt(sum(y_midhour_fm_norm - y_midhour_fm)^2) / cohort_N);
y_2hour_fm_norm = y_2hour_fm/y_stim_late_fm;
y_2hour_fm_norm_sem = (sqrt(sum(y_2hour_fm_norm - y_2hour_fm)^2) / cohort_N);
y_3hour_fm_norm = y_3hour_fm/y_stim_late_fm;
y_3hour_fm_norm_sem = (sqrt(sum(y_3hour_fm_norm - y_3hour_fm)^2) / cohort_N);
y_4hour_fm_norm = y_4hour_fm/y_stim_late_fm;
y_4hour_fm_norm_sem = (sqrt(sum(y_4hour_fm_norm - y_4hour_fm)^2) / cohort_N);


% 3 hour only
x = [x_pre x_stim_late x_1hour x_midhour x_2hour x_3hour];
y = [y_pre_amb_norm y_stim_late_amb_norm y_1hour_amb_norm y_midhour_amb_norm y_2hour_amb_norm y_3hour_amb_norm];
avg = plot(x,y,'-o','Color',[0.6350 0.0780 0.1840],'LineWidth',5);
avg.MarkerFaceColor = [0.6350 0.0780 0.1840];
avg.MarkerSize = 3;
err_amb = [y_pre_amb_norm_sem y_stim_late_amb_norm_sem y_1hour_amb_norm_sem y_midhour_amb_norm_sem y_2hour_amb_norm_sem y_3hour_amb_norm_sem ];
e_amb = errorbar(x,y,err_amb,'LineWidth',1.5,'CapSize',10,'Color',[0.6350 0.0780 0.1840]);


hold on;
x = [x_pre x_stim_late x_1hour x_midhour x_2hour x_3hour];
y = [y_pre_fm_norm y_stim_late_fm_norm y_1hour_fm_norm y_midhour_fm_norm y_2hour_fm_norm y_3hour_fm_norm];
avg = plot(x,y,'-o','Color',[0 0 0.6],'LineWidth',5);
avg.MarkerFaceColor = [0 0 0.6];
avg.MarkerSize = 3;
err_fm = [y_pre_fm_norm_sem y_stim_late_fm_norm_sem y_1hour_fm_norm_sem y_midhour_fm_norm_sem y_2hour_fm_norm_sem y_3hour_fm_norm_sem ];
e_fm = errorbar(x,y,err_fm,'LineWidth',1.5,'CapSize',10,'Color',[0 0 0.6]);


patch_start = 0.024;
patch_end = 0.034;
xp = [patch_start patch_start patch_end patch_end];
yp = [0 1.5 1.5 0];
patch(xp,yp,stim_color,'EdgeColor','none','facealpha',0.5);

yline(1,'--');
yticks([0 0.5 1 1.5 2 2.5 3]);
yticklabels({'0','50','100','150','200','250','300'});

xlim([0 .1255]);
xticks([0.005 .0292 .0418 .0625 .0833 .1250]);
xticklabels({'baseline','stim','1','1.5','2','3'});
ylabel('% Time');
title('Therapeutic Persistence');

    
    % MAKE THINGS PRETTIER
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    set(findall(gcf,'-property','FontWeight'),'FontWeight','bold');  

    end
