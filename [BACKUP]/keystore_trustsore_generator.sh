#!/bin/bash

# Configuration
KEYSTORE_PASSWORD="bigdata"
TRUSTSTORE_PASSWORD="bigdata"
VALIDITY_DAYS=3600
KEY_SIZE=2048

# List of hosts (modify as needed)
HOSTS=('vm1' 'vm2' 'vm3')

# Output directories
OUTPUT_DIR="./certs_vm"
mkdir -p "$OUTPUT_DIR"

# Step 1: Generate keystores and certificates
for HOST in "${HOSTS[@]}"; do
    echo "Generating keystore for $HOST..."
    
    keytool -genkeypair -keyalg RSA \
        -alias "$HOST" \
        -keystore "$OUTPUT_DIR/$HOST-keystore.jks" \
        -storepass "$KEYSTORE_PASSWORD" \
        -validity "$VALIDITY_DAYS" \
        -keysize "$KEY_SIZE" \
        -dname "CN=$HOST, OU=Hadoop, O=kahovec, L=vienna, ST=vienna, C=austria" \
        -noprompt
    
    echo "Exporting certificate for $HOST..."
    keytool -export -alias "$HOST" \
        -file "$OUTPUT_DIR/$HOST.crt" \
        -keystore "$OUTPUT_DIR/$HOST-keystore.jks" \
        -storepass "$KEYSTORE_PASSWORD" \
        -rfc
done

# Step 2: Create a truststore and import all certificates
echo "Creating truststore..."
TRUSTSTORE_FILE="$OUTPUT_DIR/truststore.jks"
rm -f "$TRUSTSTORE_FILE"

for HOST in "${HOSTS[@]}"; do
    echo "Importing $HOST certificate into truststore..."
    keytool -import -alias "$HOST" \
        -file "$OUTPUT_DIR/$HOST.crt" \
        -keystore "$TRUSTSTORE_FILE" \
        -storepass "$TRUSTSTORE_PASSWORD" \
        -noprompt
done

echo "Done!"
