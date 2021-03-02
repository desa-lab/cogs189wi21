

% addpath(genpath('/mnt/cube/home/lkueida/Documents/MATLAB/bcitools'))
eeglab
close all

subband = zeros(11,2);
subband(1,:) = [1 3];
subband(2,:) = [2 5];
subband(3,:) = [4 7];
subband(4,:) = [6 10];
subband(5,:) = [7 12];
subband(6,:) = [10 15];
subband(7,:) = [12 19];
subband(8,:) = [15 25];
subband(9,:) = [19 30];
subband(10,:) = [25 35];
subband(11,:) = [30 40];

selected_22 = [17,26:30,36:42,48:52,60:62,70,1:3];
loc = readlocs('/home/lkueida/Documents/MATLAB/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/Standard-10-20-Cap81.ced');
selected_loc = loc(selected_22);

users = {'01','02','03','04','05','06','07','08','09'};


for user = 1:length(users)
  EEG = pop_biosig([pwd,'/BCICIV_2a_gdf/A',users{user},'T.gdf']);
  EEG.chanlocs = selected_loc;
  EEG.urchanlocs = selected_loc;
  EEG = pop_select( EEG,'nochannel',{'Fp1' 'Fpz' 'Fp2'});
  for band = 1:11
    EEG_band = pop_firws(EEG, 'fcutoff', subband(band, 1:2), 'ftype', 'bandpass', 'wtype', 'kaiser', 'warg', 3.39532, 'forder', 996, 'minphase', 0);

    EEGL(user, band) = pop_epoch( EEG_band, {  '769'  }, [0.3  2.5], 'newname', 'GDF file left epochs', 'epochinfo', 'yes');
%     EEGL(user, band) = pop_rmbase( EEGL(user, band), [300    500]);

    EEGR(user, band) = pop_epoch( EEG_band, {  '770'  }, [0.3  2.5], 'newname', 'GDF file right epochs', 'epochinfo', 'yes');
%     EEGR(user, band)= pop_rmbase( EEGR(user, band), [300    500]);
  end
 

end

save('MI_Comp_LR_new.mat','EEGL','EEGR')