clear all;
% All the parameters besides the internal diameter are defined inside the
T_initial = 350; %K


% production plant
TUpstream = 65 + 273.15; % Plant Supply temperature (K)
TDownstream = 65 + 273.15; 

% Soil properties
kSoil = 1.6;   % (W/mK)
TSoil = 283;    % Soil temperature (K)
z = 1;        % Soil thickness (m)

% pipe model
length = 125;  % Length (m)
pipe_roughness = 2e-5; % steel pipe roughness (m)

edge = xlsread('network1_edge_input.xlsx');
node = xlsread('network1_node_input.xlsx');

Di = zeros(1,size(edge,1)); % inner diameter
Do = zeros(1,size(edge,1)); % outer diameter
Ac = zeros(1,size(edge,1)); % cross section area, inner diameter
Ai = zeros(1,size(edge,1)); % pipe surface area, inner diameter
Ao = zeros(1,size(edge,1)); % pipe surface area, outer diameter
Thi = zeros(1,size(edge,1)); % thickness of insulation
Tho = zeros(1,size(edge,1)); % thickness of soil
for j = 1:size(edge,1)
    Di(j) = edge(j,1);
    Do(j) = edge(j,2);
    Ac(j) = pi*Di(j)^2/4;
    Ai(j) = length * pi * Di(j);
    Ao(j) = length * pi * Do(j);
    Thi(j) = Di(j) / 2 * log(Do(j) / Di(j));
    Tho(j) = Do(j)/2*log(2*z/Do(j) + sqrt((2*z/Do(j))^2 - 1));
end

mdot = zeros(1,size(node,1)); 
for j = 1:size(node,1)
    mdot(j) = node(j,1); % mass flow rate {kg/s)
end

kInsulant = 0.023; % (W/mK)
%rho0 = 998;  %water density


% Initialization
load_system('pipelines_network1');
sim('pipelines_network1');
% simlog.print  

% Retrieve values from the Simscape data logging
Pi(1) = simlog.E0.pipe_model.A.p.series.values* 1e5; % Pa
Po(1) = simlog.E0.pipe_model.B.p.series.values* 1e5; % Pa
Ti(1) = simlog.E0.pipe_model.A.T.series.values; % K
To(1) = simlog.E0.pipe_model.B.T.series.values; % K
mdot_pipe(1) = simlog.E0.pipe_model.mdot_A.series.values;

Pi(2) = simlog.E1.pipe_model.A.p.series.values* 1e5; % Pa
Po(2) = simlog.E1.pipe_model.B.p.series.values* 1e5; % Pa
Ti(2) = simlog.E1.pipe_model.A.T.series.values; % K
To(2) = simlog.E1.pipe_model.B.T.series.values; % K
mdot_pipe(2) = simlog.E1.pipe_model.mdot_A.series.values;

Pi(3) = simlog.E2.pipe_model.A.p.series.values* 1e5; % Pa
Po(3) = simlog.E2.pipe_model.B.p.series.values* 1e5; % Pa
Ti(3) = simlog.E2.pipe_model.A.T.series.values; % K
To(3) = simlog.E2.pipe_model.B.T.series.values; % K
mdot_pipe(3) = simlog.E2.pipe_model.mdot_A.series.values;

Pi(4) = simlog.E3.pipe_model.A.p.series.values* 1e5; % Pa
Po(4) = simlog.E3.pipe_model.B.p.series.values* 1e5; % Pa
Ti(4) = simlog.E3.pipe_model.A.T.series.values; % K
To(4) = simlog.E3.pipe_model.B.T.series.values; % K
mdot_pipe(4) = simlog.E3.pipe_model.mdot_A.series.values;

Pi(5) = simlog.E4.pipe_model.A.p.series.values* 1e5; % Pa
Po(5) = simlog.E4.pipe_model.B.p.series.values* 1e5; % Pa
Ti(5) = simlog.E4.pipe_model.A.T.series.values; % K
To(5) = simlog.E4.pipe_model.B.T.series.values; % K
mdot_pipe(5) = simlog.E4.pipe_model.mdot_A.series.values;

Pi(6) = simlog.E5.pipe_model.A.p.series.values* 1e5; % Pa
Po(6) = simlog.E5.pipe_model.B.p.series.values* 1e5; % Pa
Ti(6) = simlog.E5.pipe_model.A.T.series.values; % K
To(6) = simlog.E5.pipe_model.B.T.series.values; % K
mdot_pipe(6) = simlog.E5.pipe_model.mdot_A.series.values;

Pi(7) = simlog.E6.pipe_model.A.p.series.values* 1e5; % Pa
Po(7) = simlog.E6.pipe_model.B.p.series.values* 1e5; % Pa
Ti(7) = simlog.E6.pipe_model.A.T.series.values; % K
To(7) = simlog.E6.pipe_model.B.T.series.values; % K
mdot_pipe(7) = simlog.E6.pipe_model.mdot_A.series.values;

Pi(8) = simlog.E7.pipe_model.A.p.series.values* 1e5; % Pa
Po(8) = simlog.E7.pipe_model.B.p.series.values* 1e5; % Pa
Ti(8) = simlog.E7.pipe_model.A.T.series.values; % K
To(8) = simlog.E7.pipe_model.B.T.series.values; % K
mdot_pipe(8) = simlog.E7.pipe_model.mdot_A.series.values;


% E = {'E0', 'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7'};
% Pi = zeros(1,size(edge,1));
% Po = zeros(1,size(edge,1));
% Ti = zeros(1,size(edge,1));
% To = zeros(1,size(edge,1));
% for i=1:8
%     E = genvarname({E{i}});
%     Pi(i) = simlog.E(i).pipe_model.A.p.series.values* 1e5; % Pa
%     Po(i) = simlog.E(i).pipe_model.B.p.series.values* 1e5; % Pa
%     Ti(i) = simlog.E(i).pipe_model.A.T.series.values; % K
%     To(i) = simlog.E(i).pipe_model.B.T.series.values; % K
% end

T = table(transpose(Di), transpose(Do), transpose(mdot_pipe), transpose(Pi),transpose(Po),transpose(Ti),transpose(To),...
'VariableNames', {'Di' 'Do' 'mdot_pipe' 'Pi' 'Po' 'Ti' 'To'});
writetable(T, 'C:\Users\fcl2\Documents\MATLAB\network\network1_results.csv')




