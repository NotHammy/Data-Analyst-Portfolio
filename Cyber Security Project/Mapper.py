import pandas as pd
import glob
import os

protocol_map = {
    '1': 'ICMP', 
    '6': 'TCP', 
    '17': 'UDP', 
    '58': 'ICMPv6'
}

service_map = {
   # services for TCP protocol (pid = 6)
    ('6', '80'): "HTTP", ('6', '8888'): "HTTP", ('6', '8008'): "HTTP", ('6', '8080'): "HTTP", ('6', '443'): "HTTPS", 
    ('6', '1443'): "HTTPS", ('6', '8443'): "HTTPS", ('6', '55443'): "HTTPS", ('6', '8883'): "MQTT",
    
    # services for UDP protocol (pid = 17)
    ('17', '53'): "DNS", ('17', '5353'): "DNS", ('17', '123'): "NTP",('17', '1900'): "SSDP", ('17', '137'): "NetBIOS"
}

# maps protocol name using protocol id
def get_protocol(row):
    p_id = row['protocolIdentifier']
    
    # Maps pid to a name, defaulting to 'Other' if not found
    p_name = protocol_map.get(p_id, 'Other ')
    return p_name 


# maps service type using protocol id and transport ports
def get_service(row):
    p_id = row['protocolIdentifier']
    dest_port = row['destinationTransportPort']
    
    # Ensures that if any protocol id's are 1 or 58, they are matched with ICMP irregardless of destTransportPort
    if p_id == 1 or p_id == 58:
        return "ICMP"
    
    # Maps pid and tranport pot to a service name, defaulting to 'Other' if not found
    service = service_map.get((p_id, dest_port), 'Other')   
    return service



for csv_file in glob.glob("*.csv"):
    
    df_chunks = pd.read_csv(csv_file, chunksize=100000)
    
    for i, chunk in enumerate(df_chunks):
    
        chunk['protocolName'] = chunk.apply(get_protocol, axis=1)
        chunk['serviceType'] = chunk.apply(get_service, axis=1)
        chunk.insert(5, 'protocolName', chunk.pop('protocolName')) 
        chunk.insert(14, 'serviceType', chunk.pop('serviceType'))  
        
        if i == 0:
            # For the first chunk, overwrite the file (write mode)
            chunk.to_csv(csv_file, mode='w', header=True, index=False)
        else:
            # For subsequent chunks, apend to the same file (append mode)
            chunk.to_csv(csv_file, mode='a', header=False, index=False)
    
    print(f"Updated: {os.path.basename(csv_file)}")
