clear all;
% All the parameters besides the internal diameter are defined inside the
Cpw = 4.184; %kJ/kgK


% production plant
% TUpstream = 338.3564; % Plant Supply temperature (K)
% TDownstream = 60 + 273.15; 
PUpstream = 1.01325*4; % bar

% Soil properties
kSoil = 1.6;   % (W/mK)
TSoil = 283;    % Soil temperature (K)
z = 1;        % Soil thickness (m)

% pipe model
length = 125;  % Length (m)
pipe_roughness = 2e-5; % steel pipe roughness (m)
kInsulant = 0.023; % (W/mK)
%rho0 = 998;  %water density

% production plant
plant_node = 6;
[num,text,T_supply] = xlsread('network1_input.xlsx','T_Supply_DH');
T_Upstream_array = T_supply(2:end,plant_node(1));


% Read pipe properties and substation flow rates
edge = xlsread('network1_input.xlsx','Edge_DH');     % pipe properties
% node = xlsread('network1_input.xlsx','node');
node_mass_flow = xlsread('network1_input.xlsx','Node_MassFlow_DH');    % substation flow rate
node_mass_flow(:,1)=[]; % delete the first column
node_mass_flow(:,plant_node) = 0; % set mass flow at plants to zero



% intializing parameters
Di = zeros(1,size(edge,1)); % inner diameter
Do = zeros(1,size(edge,1)); % outer diameter
Ac = zeros(1,size(edge,1)); % cross section area, inner diameter
Ai = zeros(1,size(edge,1)); % pipe surface area, inner diameter
Ao = zeros(1,size(edge,1)); % pipe surface area, outer diameter
Thi = zeros(1,size(edge,1)); % thickness of insulation
Tho = zeros(1,size(edge,1)); % thickness of soil
% read parameters
for j = 1:size(edge,1)
    Di(j) = edge(j,1);
    Do(j) = edge(j,2);
    Ac(j) = pi*Di(j)^2/4;
    Ai(j) = length * pi * Di(j);
    Ao(j) = length * pi * Do(j);
    Thi(j) = Di(j) / 2 * log(Do(j) / Di(j));
    Tho(j) = Do(j)/2*log(2*z/Do(j) + sqrt((2*z/Do(j))^2 - 1));
end

T_node_supply = zeros(8760,size(node_mass_flow,2));
q_loss_supply = zeros(8760,size(edge,1));
dP_supply = zeros(8760,1);
load_system('pipelines_network1');

for t=1:8760
    TUpstream = T_Upstream_array{t};
    T_initial = T_Upstream_array{t}; %K
    TDownstream = T_Upstream_array{t}-0.05; 
    if isnumeric(TUpstream)
        mdot = zeros(1,size(node_mass_flow,2));  
        for j = 1:size(node_mass_flow,2)
            mdot(j) = node_mass_flow(t,j); % mass flow rate {kg/s)
        end

        % Initialization
        sim('pipelines_network1');
        % simlog.print  

        % Retrieve values from the Simscape data logging
        Pi(1) = simlog.E0.pipe_model.A.p.series.values* 1e6; % Pa
        Po(1) = simlog.E0.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(1) = simlog.E0.pipe_model.A.T.series.values; % K
        To(1) = simlog.E0.pipe_model.B.T.series.values; % K
        mdot_pipe(1) = simlog.E0.pipe_model.mdot_A.series.values;

        Pi(2) = simlog.E1.pipe_model.A.p.series.values* 1e6; % Pa
        Po(2) = simlog.E1.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(2) = simlog.E1.pipe_model.A.T.series.values; % K
        To(2) = simlog.E1.pipe_model.B.T.series.values; % K
        mdot_pipe(2) = simlog.E1.pipe_model.mdot_A.series.values;

        Pi(3) = simlog.E2.pipe_model.A.p.series.values* 1e6; % Pa
        Po(3) = simlog.E2.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(3) = simlog.E2.pipe_model.A.T.series.values; % K
        To(3) = simlog.E2.pipe_model.B.T.series.values; % K
        mdot_pipe(3) = simlog.E2.pipe_model.mdot_A.series.values;

        Pi(4) = simlog.E3.pipe_model.A.p.series.values* 1e6; % Pa
        Po(4) = simlog.E3.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(4) = simlog.E3.pipe_model.A.T.series.values; % K
        To(4) = simlog.E3.pipe_model.B.T.series.values; % K
        mdot_pipe(4) = simlog.E3.pipe_model.mdot_A.series.values;

        Pi(5) = simlog.E4.pipe_model.A.p.series.values* 1e6; % Pa
        Po(5) = simlog.E4.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(5) = simlog.E4.pipe_model.A.T.series.values; % K
        To(5) = simlog.E4.pipe_model.B.T.series.values; % K
        mdot_pipe(5) = simlog.E4.pipe_model.mdot_A.series.values;

        Pi(6) = simlog.E5.pipe_model.A.p.series.values* 1e6; % Pa
        Po(6) = simlog.E5.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(6) = simlog.E5.pipe_model.A.T.series.values; % K
        To(6) = simlog.E5.pipe_model.B.T.series.values; % K
        mdot_pipe(6) = simlog.E5.pipe_model.mdot_A.series.values;

        Pi(7) = simlog.E6.pipe_model.A.p.series.values* 1e6; % Pa
        Po(7) = simlog.E6.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(7) = simlog.E6.pipe_model.A.T.series.values; % K
        To(7) = simlog.E6.pipe_model.B.T.series.values; % K
        mdot_pipe(7) = simlog.E6.pipe_model.mdot_A.series.values;

        Pi(8) = simlog.E7.pipe_model.A.p.series.values* 1e6; % Pa
        Po(8) = simlog.E7.pipe_model.B.p.series.values* 1e6; % Pa
        Ti(8) = simlog.E7.pipe_model.A.T.series.values; % K
        To(8) = simlog.E7.pipe_model.B.T.series.values; % K
        mdot_pipe(8) = simlog.E7.pipe_model.mdot_A.series.values;

        dP(1) = Pi(1)-Po(1);
        dP(2) = Pi(2)-Po(2);
        dP(3) = Pi(3)-Po(3);
        dP(4) = Pi(4)-Po(4);
        dP(5) = Pi(5)-Po(5);
        dP(6) = Pi(6)-Po(6);
        dP(7) = Pi(7)-Po(7);
        dP(8) = Pi(8)-Po(8);

        dT(1) = Ti(1)-To(1);
        dT(2) = Ti(2)-To(2);
        dT(3) = Ti(3)-To(3);
        dT(4) = Ti(4)-To(4);
        dT(5) = Ti(5)-To(5);
        dT(6) = Ti(6)-To(6);
        dT(7) = Ti(7)-To(7);
        dT(8) = Ti(8)-To(8);
        
        q_loss(1) = mdot_pipe(1) * Cpw * dT(1);
        q_loss(2) = mdot_pipe(2) * Cpw * dT(2);
        q_loss(3) = mdot_pipe(3) * Cpw * dT(3);
        q_loss(4) = mdot_pipe(4) * Cpw * dT(4);   
        q_loss(5) = mdot_pipe(5) * Cpw * dT(5);
        q_loss(6) = mdot_pipe(6) * Cpw * dT(6);
        q_loss(7) = mdot_pipe(7) * Cpw * dT(7);  
        q_loss(8) = mdot_pipe(8) * Cpw * dT(8);

        T_node(1) = simlog.N0.A.T.series.values; % K
        T_node(2) = simlog.N1.A.T.series.values; % K
        T_node(3) = simlog.N2.A.T.series.values; % K
        T_node(4) = simlog.N3.A.T.series.values; % K
        T_node(5) = simlog.N4.A.T.series.values; % K
        T_node(6) = simlog.N5.A.T.series.values; % K
        T_node(7) = simlog.N6.A.T.series.values; % K
        T_node(8) = simlog.N7.A.T.series.values; % K
        T_node(9) = simlog.N8.A.T.series.values; % K

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

        T = table(transpose(Di), transpose(Do), transpose(mdot_pipe), transpose(Pi), transpose(Po), transpose(dP), transpose(Ti),transpose(To), transpose(dT),...
        'VariableNames', {'Di' 'Do' 'mdot_pipe' 'Pi' 'Po' 'dP' 'Ti' 'To' 'dT'});

        T_node_supply(t,:) = vec2mat(T_node,size(T_node_supply,2));
        q_loss_supply(t,:) = vec2mat(q_loss,size(q_loss_supply,2));
        dP_supply(t) = sum(dP);
    else
        T_node_supply(t,:) = str2double(T_supply(t+1,:));
        q_loss_supply(t,:) = 0;
        dP_supply(t) = 0;
    end
end
%writetable(T, 'network1_results.csv')
csvwrite('network1_T_node_supply.csv', T_node_supply)
csvwrite('network1_qloss_supply.csv', q_loss_supply)
csvwrite('network1_dP_supply.csv', dP_supply)




