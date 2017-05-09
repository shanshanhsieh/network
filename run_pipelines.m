clear all;
% All the parameters besides the internal diameter are defined inside the
% pipe model
D1   = 0.39;
D2   = 0.58;    % External diameter (m)

Vdot = 0.25;    % Volumetric flow rate (m^3/s)
length = 30;  % Length (m)
kInsulant = 0.0350;
rho0 = 840;

% production plant
TUpstream = 333; % Plant Supply temperature (K)


kSoil = 1.56;
TSoil = 300;    % Soil temperature (K)
z = 1.1;        % Soil thickness (m)

% Buildings


% Initialization
load_system('pipelines');
sim('pipelines');
% simlog.print  
% Retrieve values from the Simscape data logging
%PhiW = simlog.Pipe_TL.pipe_model.Phi_W.series.values; % in W%
pipe_inlet_P = simlog.Pipe_TL.pipe_model.A.p.series.values;
pipe_outlet_P = simlog.Pipe_TL.pipe_model.B.p.series.values;
pipe_inlet_T = simlog.Pipe_TL.pipe_model.A.T.series.values;
pipe_outlet_T = simlog.Pipe_TL.pipe_model.B.T.series.values;

pipe_inlet_P1 = simlog.Pipe_TL1.pipe_model.A.p.series.values;
pipe_outlet_P1 = simlog.Pipe_TL1.pipe_model.B.p.series.values;
pipe_inlet_T1 = simlog.Pipe_TL1.pipe_model.A.T.series.values;
pipe_outlet_T1 = simlog.Pipe_TL1.pipe_model.B.T.series.values;
%daltaP  = simlog.Pipe_TL.pipe_model.A.p.series.values - simlog.Pipe_TL.pipe_model.B.p.series.values; % in bar
% daltaP  = daltaP * 1e5; % conversion to Pa

%P1 = simlog.Pipe_TL.pipe_model.B.p.series.values * 1e5; % conversion to Pa
%P2 = simlog.Pipe_TL1.pipe_model.B.p.series.values * 1e5; % conversion to Pa

%P = [P1; P2];

%T = table(P);
% writetable(T, 'result.csv')
% type 'result.csv'
%csvwrite('C:\Users\fcl2\Documents\MATLAB\result.csv', P)
disp(pipe_inlet_P)
disp(pipe_outlet_P)
disp(pipe_inlet_T)
disp(pipe_outlet_T)

disp(pipe_inlet_P1)
disp(pipe_outlet_P1)
disp(pipe_inlet_T1)
disp(pipe_outlet_T1)
