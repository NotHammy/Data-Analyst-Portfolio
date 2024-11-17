# **Behavioral Analysis for Cybersecurity of IoT Devices**

## **Project Description and Significance**

This project aims to enhance cybersecurity by identifying Internet of Things (IoT) devices based on their network behavior. By analyzing IPFIX records, we provide crucial data products that ISPs can use to detect anomalies, classify device types, and address vulnerabilities in IoT devices which are particularly prone to cyber attacks due to their inherent security weaknesses.

## **Challenges and Data Source**

IoT devices transmit significant amounts of data, yet identifying them within subscriber networks is challenging due to NAT technology that masks device identities. Our analysis uses the pre-NAT telemetry from the KDDI Research’s 2019 dataset, offering detailed visibility into network behavior that is typically lost post-NAT.

## **Previous Work**

Earlier approaches to device identification have required invasive changes to user networks or were limited by scale when deploying across numerous subscriber networks. Our non-intrusive method uses existing network flow data (IPFIX records) to classify devices and detect anomalies without altering network settings, simplifying deployment for ISPs.

## **Project Goals and Dataset Utilization**

Our goal is to provide ISPs with actionable insights to monitor and manage device vulnerabilities effectively. We use IPFIX records to classify IoT devices and monitor their network traffic, aiding in proactive cybersecurity measures.

## **Data Handling and Analysis**

- **Data Preparation**: Initial steps involve converting TAR files into accessible formats and preliminary cleaning to remove inconsistencies.
- **Detailed Cleaning and Feature Selection**: We focus on refining the dataset by removing irrelevant features and standardizing the remaining data for analysis.
- **Exploratory Data Analysis**: We conduct EDA to identify key patterns and behaviors in device communication, using these insights to select features that best represent each device type.

## **Data Description**

The dataset comprises approximately 11.7 million network flow records from 25 different IoT devices, capturing diverse behaviors and interactions over a six-month period. Features extracted from these flows include network addresses, protocols, service types, and detailed flow characteristics. This comprehensive dataset is crucial for understanding and predicting device behavior on networks.

## **Usage**

This data product can be adapted for various analyses, from performance monitoring to anomaly detection,
