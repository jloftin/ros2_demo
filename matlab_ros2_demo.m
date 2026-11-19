%[text] # Connect MATLAB to ROS 2
%[text] Run this tutorial as provided without ROS 2 or ROS Toolbox. The default mode illustrates the workflow without network traffic. With ROS Toolbox, enable live mode to exchange actual ROS 2 messages between two MATLAB nodes; a separate ROS 2 installation is not required for this basic example. Plain-text Live Editor formatting requires MATLAB R2025a or later.
%%
%[text] ## 1. Choose a domain and topic
%[text] ROS 2 uses DDS discovery. Nodes discover reachable peers in the same domain; there is no ROS master or `rosinit` step. A domain ID groups participants; it is not an IP address or a security boundary.
runLiveROS2 = false;
domainID = 42;
topicName = '/matlab_demo/chatter';
messageType = 'std_msgs/String';
disp("Domain: " + domainID) %[output:836922ef]
disp("Topic: " + string(topicName)) %[output:6484b02f]
disp("Message type in MATLAB: " + string(messageType)) %[output:2389921c]
%%
%[text] ## 2. Offline message illustration
%[text] A publisher sends a typed message on a topic; a subscriber receives it. This section uses an ordinary MATLAB structure to illustrate the payload. It does not create ROS nodes or transmit data.
previewMessage = struct('data', 'Hello from MATLAB');
disp("OFFLINE illustration: MATLAB publisher -> topic -> subscriber") %[output:890e203f]
disp(previewMessage) %[output:51f2ead1]
disp("Illustrated received text: " + string(previewMessage.data)) %[output:77593943]
%%
%[text] ## 3. Optional live connection
%[text] Set `runLiveROS2 = true` above and run the entire file when ROS Toolbox is available. The function at the end creates two nodes in domain 42 and exchanges five messages. It waits briefly for discovery and limits each receive to five seconds. Its local ROS object references are released when the function exits, including after an error. If initial discovery takes longer, check the network configuration and rerun.
%[text] Both endpoints use reliable delivery and volatile durability. Volatile subscribers receive new messages rather than retained history. External endpoints need compatible Quality of Service (QoS); sensor streams often use best-effort delivery.
if runLiveROS2 %[output:group:4c621b4d]
    if isempty(which('ros2node'))
        error('MATLABROS2Demo:MissingToolbox', ...
            'Live mode requires ROS Toolbox. Use runLiveROS2 = false for the offline tutorial.');
    end
    runROS2Exchange(domainID, topicName, messageType);
else
    disp("Live exchange skipped. Set runLiveROS2 = true when ready.") %[output:863d6439]
end %[output:group:4c621b4d]
%%
%[text] ## 4. Join from an external ROS 2 computer later
%[text] On a computer with a compatible ROS 2 distribution, initialize the distribution's terminal environment and set domain 42. In Linux/Bash use `export ROS_DOMAIN_ID=42`; in Windows PowerShell use `\\$env:ROS_DOMAIN_ID = '42'`. These are terminal commands, not MATLAB code. This tutorial only displays the commands below.
%[text] Start the echo command before running MATLAB live mode to receive MATLAB's five messages. The CLI uses `std_msgs/msg/String`; MATLAB uses `std_msgs/String` for the same message type.
disp("External ROS 2 terminal commands (for later):") %[output:4b99211a]
disp('ros2 node list') %[output:41332086]
disp('ros2 topic list -t') %[output:82d8883e]
disp('ros2 topic echo /matlab_demo/chatter std_msgs/msg/String') %[output:0fbac6af]
%[text] For the opposite direction, create this subscriber in the MATLAB Command Window, start the external terminal publisher, then call `receive`. The subscriber remains alive in the workspace. Run the cleanup after receiving, or after a timeout.
disp("MATLAB Command Window recipe (for later):") %[output:94ab2412]
disp("externalNode = ros2node('/matlab_external_listener', 42);") %[output:2b991275]
disp("externalSub = ros2subscriber(externalNode, '/matlab_demo/from_ros', 'std_msgs/String', 'Reliability', 'reliable');") %[output:008e8987]
disp("incoming = receive(externalSub, 10);") %[output:35e38c6c]
disp("disp(incoming.data)") %[output:0fca958b]
disp("clear externalSub externalNode") %[output:7ff5bc3d]
disp("External ROS 2 terminal publisher (for later):") %[output:013e236e]
disp('ros2 topic pub --rate 1 /matlab_demo/from_ros std_msgs/msg/String "{data: ''Hello from ROS 2''}"') %[output:83377acb]
%[text] Across computers, match domain IDs, topic names, message definitions, and compatible QoS. Firewalls must permit DDS discovery and traffic, and multicast discovery must reach peers. VPNs, containers, Wi-Fi isolation, and local-only discovery settings can prevent discovery. Check your MATLAB release's ROS Toolbox system requirements for supported ROS 2 distributions and additional setup for custom messages or code generation.
%%
%[text] ## 5. The live MATLAB code
%[text] The calls below create nodes, subscribe, create a publisher and message, send data, and receive data. For installed documentation, use `doc ros2node`, `doc ros2publisher`, `doc ros2subscriber`, and `doc ros2message`. See also the [ROS Toolbox documentation](https://www.mathworks.com/help/ros/).
function runROS2Exchange(domainID, topicName, messageType)
    publisherNode = ros2node('/matlab_demo_talker', domainID);
    subscriberNode = ros2node('/matlab_demo_listener', domainID);
    subscriber = ros2subscriber(subscriberNode, topicName, messageType, ...
        'Reliability', 'reliable', 'Durability', 'volatile', 'Depth', 10);
    publisher = ros2publisher(publisherNode, topicName, messageType, ...
        'Reliability', 'reliable', 'Durability', 'volatile', 'Depth', 10);
    outgoing = ros2message(publisher);
    pause(2);  % Allow time for DDS endpoint discovery.
    for messageIndex = 1:5
        outgoing.data = char("Hello from MATLAB, message " + messageIndex);
        send(publisher, outgoing);
        incoming = receive(subscriber, 5);
        disp("Received over ROS 2: " + string(incoming.data))
        pause(1);
    end
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:836922ef]
%   data: {"dataType":"text","outputData":{"text":"Domain: 42\n","truncated":false}}
%---
%[output:6484b02f]
%   data: {"dataType":"text","outputData":{"text":"Topic: \/matlab_demo\/chatter\n","truncated":false}}
%---
%[output:2389921c]
%   data: {"dataType":"text","outputData":{"text":"Message type in MATLAB: std_msgs\/String\n","truncated":false}}
%---
%[output:890e203f]
%   data: {"dataType":"text","outputData":{"text":"OFFLINE illustration: MATLAB publisher -> topic -> subscriber\n","truncated":false}}
%---
%[output:51f2ead1]
%   data: {"dataType":"text","outputData":{"text":"    data: 'Hello from MATLAB'\n\n","truncated":false}}
%---
%[output:77593943]
%   data: {"dataType":"text","outputData":{"text":"Illustrated received text: Hello from MATLAB\n","truncated":false}}
%---
%[output:863d6439]
%   data: {"dataType":"text","outputData":{"text":"Live exchange skipped. Set runLiveROS2 = true when ready.\n","truncated":false}}
%---
%[output:4b99211a]
%   data: {"dataType":"text","outputData":{"text":"External ROS 2 terminal commands (for later):\n","truncated":false}}
%---
%[output:41332086]
%   data: {"dataType":"text","outputData":{"text":"ros2 node list\n","truncated":false}}
%---
%[output:82d8883e]
%   data: {"dataType":"text","outputData":{"text":"ros2 topic list -t\n","truncated":false}}
%---
%[output:0fbac6af]
%   data: {"dataType":"text","outputData":{"text":"ros2 topic echo \/matlab_demo\/chatter std_msgs\/msg\/String\n","truncated":false}}
%---
%[output:94ab2412]
%   data: {"dataType":"text","outputData":{"text":"MATLAB Command Window recipe (for later):\n","truncated":false}}
%---
%[output:2b991275]
%   data: {"dataType":"text","outputData":{"text":"externalNode = ros2node('\/matlab_external_listener', 42);\n","truncated":false}}
%---
%[output:008e8987]
%   data: {"dataType":"text","outputData":{"text":"externalSub = ros2subscriber(externalNode, '\/matlab_demo\/from_ros', 'std_msgs\/String', 'Reliability', 'reliable');\n","truncated":false}}
%---
%[output:35e38c6c]
%   data: {"dataType":"text","outputData":{"text":"incoming = receive(externalSub, 10);\n","truncated":false}}
%---
%[output:0fca958b]
%   data: {"dataType":"text","outputData":{"text":"disp(incoming.data)\n","truncated":false}}
%---
%[output:7ff5bc3d]
%   data: {"dataType":"text","outputData":{"text":"clear externalSub externalNode\n","truncated":false}}
%---
%[output:013e236e]
%   data: {"dataType":"text","outputData":{"text":"External ROS 2 terminal publisher (for later):\n","truncated":false}}
%---
%[output:83377acb]
%   data: {"dataType":"text","outputData":{"text":"ros2 topic pub --rate 1 \/matlab_demo\/from_ros std_msgs\/msg\/String \"{data: 'Hello from ROS 2'}\"\n","truncated":false}}
%---
