  
## **Project Title: Behavioural Analysis for Cybersecurity of IoT Devices**



## **Project description and significance** 

The project's objective is to produce a data product that identifies Internet of Things (IoT) devices which are connected to the network by examining their network behaviour. We aim to aid cybersecurity practices through supplying this data product which can be used for a spectra of inferencing models. IoT devices are pieces of hardware that can transmit data over networks. We analyse network traffic data in the form of IPFIX records to classify devices to determine which devices are present on the network, detect anomalies and identify any potential cybersecurity threats. IoT devices are known for their vulnerability to cyber attacks due to limited embedded security features. As most home users are likely to be without the skills and knowledge towards protecting their network security, it is important that these risks can be managed by internet service providers (ISPs) (Pashamokhtari et al., 2021). Cyberattacks can affect network performance or carry malicious traffic, therefore making ISPs a liability. Furthermore, as device vulnerability fluctuates over time, ISPs must be aware of the identities of devices on their network in order to monitor network traffic and to alert subscribers of potentially high-risk devices. 

However, limited device-level visibility into subscriber homes poses a significant challenge for ISPs due to Network Address Translation (NAT) technology which significantly impacts the difficulty of this identification task. It should be noted that pre-NAT telemetry is much harder to gather but provides more information about connected devices on the network, in comparison to post-NAT telemetry which often conceals the identities of its devices. 

Our project will be utilising pre-NAT data from the KDDI Research’s 2019 dataset. We strive to provide a data product which can be used for classification models which predict the identities of connected devices using IPFIX telemetry. This device classification problem can help ensure that ISPs are able to identify vulnerable devices in order to anticipate and defend from incoming cyberattacks. Future projects may investigate methods on collecting post-NAT telemetry and use the data to build for similar inferencing models as this is likely more practical for ISPs in regards to more efficient large-scale deployment.

*Previous work*  
With the growing popularity of smart homes and adoption of IoT devices into homes and workspaces, the importance for network cybersecurity has escalated. Previous research (Meidan, et al. 2020, Guo and Heidemann, 2020\) have employed methods that require alterations to home gateways and reliance on local traffic. However, as ISPs have hundreds of thousands of subscribers, access to and deployment in homes is not feasible on such a scale. Other methods include utilising the MAC or IP addresses of devices (Miettinen et al. 2017, Thangavelu et al. 2019\) which must be gathered pre-NAT and is similarly difficult to gather on a large scale such as in the case for ISPs. Our project uses IPFIX telemetry for the dataset which has historically been used for flow-based anomaly detection as well as device classification and has several leverages over these previously mentioned techniques. This includes no alterations to private networks, reduced inferencing complexity, mitigated privacy concerns and ability for post-NAT inferencing (Pashamokhtari et al., 2023). 

A major limitation for data-driven models is the notion of concept drift which refers to the changing of the data distribution over time. As a result, models may see an increase in the model error rate over time. To mitigate concept drift in their models, some prior studies (Bifet et al. 2009\) suggested utilising the true labelled data as a validation set during the training phase to correct the model preemptively. Alternatively, other approaches (Gama et al., 2009, Yang et al., 2005\) use the true labels to examine and compare the performance of different models in order to select the best model. As access to the true labels is provided in our dataset, users may employ either of these two suggested methods to handle concept drift in their models.

## **Sources**

The dataset used for this project comes from the KDDI-IoT-2019 dataset. The dataset contains various devices such as smart speakers, cameras, sensors, robot cleaners, TV’s and more. Smart Speakers are a voice activated virtual assistant which are connected to wifi and to other smart devices through bluetooth making them an IoT device as they communicate with other devices at a network level. They can assist their user in multiple ways such as playing music, calling people and are personal organisation tools. Network Camera delivers digital video surveillance to users by not only sending the footage over the internet but also by receiving footage. Since they connect to wifi and are able to send footage across to other devices, they are an IoT device. They are mainly used by businesses, banks and offices. There are also a few IoT Gateway/Hubs in our dataset. This is a device where multiple IoT devices can be connected to if they have little storage and they are also a pathway for IoT devices to gain internet access. We also have a robot cleaner device in our dataset by IRobot Roomba. This cleaning device can be connected to wifi to have access to scheduled cleaning, cleaning reports and can be connected to smart speakers also making them an IoT device. We also have a Smart TV in our dataset which can connect to streaming services such as Netflix, Amazon Prime and display these services on the TV. Hence, the Smart TV is also an IoT device as it is connected to wifi to be able to have access to streaming services and even smart speakers. All of these devices are IoT devices with various purposes but communicate with networks and these actions are stored as IPFIX records which are our datasets. 

Each IoT device has IPFIX records which conveys information about the flows of the IoT devices with other networks. Some of the fields in the packets from the IPFIX records hold significance and are important for us in the formation of our final cleaned dataset. These include the protocol identifier which is the protocol that is being used to establish a specific communication exchange. We can use these numbers to identify if the protocol is TCP or UDP.  A port number is used to identify the process or application to another network. We need the source and destination transport port numbers. We also include information about the packet counts which is the size or length of the packets transmitted by the IoT to an internet server.

## **Workflow**

**Provided below is a weekly breakdown of how the project will be carried out:**  
**Data Acquisition and preparation (Week 1\)**

* Understanding the project itself: Understand the motivations and the goal of the data project. This means watching the video provided by the industry partner, trying to understand the sponsor’s concern and objective and coming up with questions to ask the industry partner in class in week 2 for clarification.  
* Accessing Dataset: The second step is to access the IPFIX records dataset provided by the industry partner. Try to understand the dataset and its attributes.


**Pre Data Cleaning and Preprocessing (Week 2\)**

* Converting TAR files: We need to convert the TAR files into csv files in order to read them into Python, before we are able to map and clean them.  
* Pre Data Cleaning: We are choosing 2 IoT devices initially to analyse the IPFIX records. Two group members working on one IoT device and the other two group members working on the second IoT device.The motivation behind this is to analyse any errors that are similar between the two IoT devices.

**Data Cleaning and Preprocessing (Week 3\)** 

* Data Cleaning: Identify any missing values and understand if there is a reason for their missingness. Handle the missing data. Remove any irrelevant features from the dataset, focusing on more significant features and ensuring clarity within the datasets.   
* Standardisation: Ensure that the data is standardised to maintain consistency in formatting of variables.  
   

**Manipulation of the data (Week 4-5)**

* Read through any feedback written on the draft README and implement the feedback accordingly.  
* Exploratory Data Analysis: Conduct Exploratory Data Analysis (EDA) to analyse trends. This includes understanding the distribution of the data through histograms and boxplots of quantitative variables. Univariate and bivariate plots to identify outliers and underlining which variables tend to be strongly associated with the response variable. These basic trends help to understand device communication patterns (e.g. frequent communication with a specific IP), packet size distribution and overall traffic volumes.  
* Select Key features: Select features that are similar between the different IPFIX records. These features should best characterise the device behaviour. For instance:  
- Source destination IP and Port  
- Packet Count and Size  
- Flow Duration  
* Create additional features: Create derived features that could help improve classification accuracy.  
* Justification: Justify why certain columns were removed 

## **Data Description**

Our data will consist of approximately 11.7 million observations on network flows sent by household IoT devices. These flows are derived from 25 different types of IoT devices collected over an approximate 6 month period. Each flow (row) will consist of 45 descriptive features that have either been constructed from, or directly extracted from our original IPFIX records. However, it should be noted that our dataset has fewer observations than the original IPFIX records (18 million), because we have chosen to only include flows that have been initiated by the IoT device. While this limits the scope of our classification model (only models well on flows originating from our IoT device), it ensures the validity of our model such that it does not confuse the behaviours between the two types of flow (IoT to server, and server to IoT). Now, we have created 2 target variables which we aim to potentially classify, device name and type. We have also included 43 useful predictors regarding flow timing, data packets, network addresses, protocols, services, TCP flags and overall flow behaviours. All of these features are described in detail, along with its construction (if method not mentioned, then it was directly taken from IPFIX records), in a series of tables in the appendix. Notably, we have constructed serviceType and protocolName features that’ve been mapped from the most common protocol id’s and server/destination transport port combinations, as protocol and service type are important for determining device behaviour. These have been added for higher interpretability, but for the sake of flexibility, we have left protocolIdentifier and serverTransportPort in our dataset. 

Furthermore, in order to identify what features to include and exclude in our final dataset, we conducted exploratory data analysis largely through the construction of histograms for each device (examples of these histograms are included in the appendix, if not visible it may need to be downloaded or found in the Github repo). Upon visual inspection, along with a more thorough count, we found that 8 columns of our original IPFIX records had the same value for every observation of all 25 devices. These included ingressInterface, egressInterface, observationDomainId, silkAppLabel and tcpUrgTotalCount, which were consistently ‘0’,  vlanId, which was consistently ‘0x000’, collectorName, which was consistently ‘C1’, and ipClassOfService, which was ‘0x00’ for approximately 99.5% of the records. Because of this lack of variation in values, it would not be of use when modelling so it is excluded from our final dataset. Moreover, the columns tcpSequenceNumber and reverseTcpSequenceNumber, much like our other TCP predictors, had around 70% of their observations as ‘0x00000000’, because these observations are not TCP protocol flows. However, unlike other TCP features, there is extreme variation within TCP devices, as for the approximate 5 million TCP protocol flows, the most common sequence number made up a relative frequency of only 0.0006%. Hence, because these features basically act as a dummy for whether a flow is or isn’t using a TCP protocol, they would introduce unnecessary noise and are thus excluded in our final dataset. Also, even though our histograms for devices such as Mouse Computer Hub and Sony Network Camera both consistently have zero values for all their reverse flow features such as reverseFlowAttributes and reversePacketTotalCount, we observed that these columns don’t have a complete zero presence for other devices (e.g. JVC Kenwood HDTV IP Camera and Link Japan Eremot). Hence, we concluded that this information indicates whether a reverse flow occurs from the network server back to the IoT device and should be added to our final dataset as a potential predictor. Finally, all other columns of our original IPFIX records were included upon inspecting significant differences in histograms between devices.

## **Usage**

The project’s data product can be used for a spectra of analysis due to its flexibility and range of recorded devices. The data product is sourced from the KDDI 2019 study of IoT devices, which is currently publicly accessible. Our data product is a collection of datasets, with each unique device’s IPFIX telemetry in each dataset. This enables user flexibility in choosing which datasets they would like to use for building their model. For instance, users may opt to build a specialist model in cameras which can identify and infer different brand models of cameras by training using only the datasets with device class ‘network camera’. Furthermore, users will find it easier to access and process our collection of individual datasets rather than a single collated dataset which would feature millions of records thus potentially causing memory or performance issues. If users would like to sample a portion of a given dataset, they could, for example, choose to filter records within a certain time frame, say within a week or a month, as we have provided a separate column for flow dates for accessibility. Thus, our data product provides users freedom to manipulate and filter the datasets, tailored to their specific needs.

As previously mentioned, the true labels of the data have been provided. These include most critically, the device Mac address, which should be hidden from the model during training. If used, this will lead to overfitting in the model and will likely be unable to make accurate classifications when given unseen data. Instead, these true labels have been provided for validation, model selection or can also be used for early correction during the training and testing phase to counteract concept drift \- see Project description,  Previous work for details.

Analysis of these models can be very broad. One possible analysis may include monitoring network traffic and data packet information of certain devices to investigate potential performance issues or aid the troubleshooting process. Analysis of peak usage times of certain categories of devices may also be helpful information for ISP resource allocations and maintaining network stability and performance during busy periods. This data product can also be particularly useful for upkeeping the network’s cyber health as monitoring and analysis of network traffic can reveal anomalies or potential risks within. ISPs may be able to utilise this information to alert subscribers and provide advice to those with vulnerable devices. 

## **Appendix:**

**Explanation of Dataset Features**

| *Target variables* | *Description* |
| :---- | :---- |
| deviceName | Name of the IoT device (e.g. amazonEchoGen2, auNetworkCamera). 25 recorded devices. |
| deviceClass | Type of IoT device (e.g. smartSpeaker, camera, IoTHub, etc). 10 recorded types.  |

| *Network Address features* | *Description* |
| :---- | :---- |
| IoTMacAddress | Unique number identifier built into the IoT device's network hardware (to identify different devices). In format of letter number pairs (e.g. B0:EA:BC:EA:AC:86) |
| IoTIPAddress | Unique number identifier for the connection between an IoT device and its network (to identify different device connections to the internet/network). These are IPv4 addresses (e.g. 192.168.1.1) |
| serverMacAddress | Unique number identifier built into the server device's network hardware (to identify different devices) |
| serverIPAddress | Unique number identifier for the connection between the server device and its network (to identify different device connections to the internet/network). These are IPv4 addresses. |

| *Protocol and network features* | *Description* |
| :---- | :---- |
| IoTTransportPort | The port number in which data is sent from the IoT device. This feature is a renamed sourceTransportPort column from the original IPFIX records. |
| serverTransportPort | The port number in which data is received by the server. This feature is a renamed destinationTransportPort column from the original IPFIX records. |
| protocolIdentifier | Number identifier for the type of protocol used in the flow (e.g. p\_id \= 6 is the TCP protocol) |
| protocolName | Name of the protocol type. This constructed feature is mapped from the four most common protocol ids in our 25 devices (TCP, UDP, ICMP, ICMPv6). If a flow protocol is neither of these, the feature is labelled as ‘Other’    |
| serviceType | Name of the service achieved during flow (HTTP/S, DNS, NTP, SSDP, NetBIOS or MQTT). This constructed feature is mapped from the most common combinations of protocolIdentifier and serverTransportPort in our 25 devices. If a flow protocol is neither of these, the feature is labelled as ‘Other’.   |

| *Flow timing features* | *Description* |
| :---- | :---- |
| flowStartMillisecondsDate | Date of flow start (dd/mm/2019)  |
| flowEndMillisecondsDate | Date of flow end (dd/mm/2019)  |
| flowStartMillisecondsTime | Exact 24 hr time of when flow started, to the nearest millisecond  (Hour: Minute: Second(3dp)).  |
| flowEndMillisecondsTime | Exact 24 hr time of when flow ended, to the nearest millisecond  (Hour: Minute: Second(3dp)).  |
| flowDurationMilliseconds | Time length for forward and reverse flows combined, in milliseconds. |
| reverseFlowDeltaMilliseconds | Time delay between forward and reverse flows in milliseconds. |
| averageInterarrivalTime  | Average time gap between the arrival of consecutive packets sent in the forward direction (milliseconds). |
| standardDeviationInterarrivalTime  | Variation in packet arrival times for forward direction flows, in milliseconds. |
| reverseAverageInterarrivalTime | Average time gap between the arrival of consecutive packets sent in the reverse direction (milliseconds). |
| reverseStandardDeviationInterarrivalTime | Variation in packet arrival times for reverse direction flows, in milliseconds. |

| *Flow behaviour features* | *Description* |
| :---- | :---- |
| flowAttributes | Sequence of bits based on the characteristics of the forward flow (e.g. if flowAttributes \= 1, flow was terminated  prematurely/ while active) |
| reverseFlowAttributes | Sequence of bits based on the characteristics of the reverse flow |
| flowEndReason | Why the flow ended (e.g. ‘Idle’ means flow was terminated due to inactivity/ communication was completed) |

| *TCP Flags features* | *Description* |
| :---- | :---- |
| initialTCPFlags | The flag of our first packet in the forward flow, given a tcp connection (e.g. S is the synchronization flag, indicating that a server connection is to be established).  |
| unionTCPFlags | Represents all the TCP flags that appeared in the packets of the flow. |
| reverseInitialTCPFlags | The flag of our first packet in the reverse flow, given a tcp connection.  |

| *Data packet features* | *Description* |
| :---- | :---- |
| packetTotalCount | \# packets sent in forward direction (from IoT). |
| octetTotalCount | \# octets/bytes sent in forward direction. |
| smallPacketCount | \# of packets in forward direction containing less than 60 bytes. |
| largePacketCount | \# of packets in forward direction containing more than 220 bytes. |
| nonEmptyPacketCount | \# packets in forward flow with non-empty payload. |
| firstNonEmptyPacketSize | Payload size of the first non-empty packet in the forward flow (bytes). |
| maxPacketSize | Largest payload size of all packets in forward direction (bytes). |
| dataByteCount | Total size of payload transmitted in forward direction (bytes). |
| bytesPerPacket | Average size, in bytes, of packets in forward direction. |
| reversePacketTotalCount | \# packets sent in reverse direction (back to IoT). |
| reverseOctetTotalCount | \# octets/bytes sent in reverse direction (back to IoT). |
| reverseSmallPacketCount | \# of packets in forward reverse containing less than 60 bytes. |
| reverseLargePacketCount | \# of packets in forward reverse containing more than 220 bytes |
| reverseNonEmptyPacketCount | \# packets in reverse flow with non-empty payload. |
| reverseFirstNonEmptyPacketSize | Payload size of the first non-empty packet in the reverse flow (bytes). |
| reverseMaxPacketSize | Largest payload size of all packets in reverse direction (bytes). |
| reverseDataByteCount | Total size of payload transmitted in reverse direction (bytes). |
| reverseBytesPerPacket | Average size, in bytes, of packets in reverse direction. |

