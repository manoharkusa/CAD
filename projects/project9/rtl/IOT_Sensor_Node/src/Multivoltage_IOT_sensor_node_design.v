module iot_sensor_node (
    input wire clk,             // Clock input
    input wire rst,             // Reset input
    input wire [1:0] sensor_select, // Sensor selection (2 bits)
    input wire [7:0] sensor_data,   // Sensor data input (8 bits)
    output wire [7:0] output_data  // Output data (8 bits)
);

// Define sensor IDs
parameter SENSOR_1 = 2'b00;
parameter SENSOR_2 = 2'b01;
parameter SENSOR_3 = 2'b10;

// Define voltage levels
parameter VOLTAGE_LEVEL_1 = 1'b0; // 3.3V
parameter VOLTAGE_LEVEL_2 = 1'b1; // 5V

// Sensor-specific voltage level selection
wire sensor_1_voltage_level = (sensor_select == SENSOR_1) ? VOLTAGE_LEVEL_1 : VOLTAGE_LEVEL_2;
wire sensor_2_voltage_level = (sensor_select == SENSOR_2) ? VOLTAGE_LEVEL_1 : VOLTAGE_LEVEL_2;
wire sensor_3_voltage_level = (sensor_select == SENSOR_3) ? VOLTAGE_LEVEL_1 : VOLTAGE_LEVEL_2;

// Sensor data processing based on voltage level
reg [7:0] processed_data;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        processed_data <= 8'b0;
    end else begin
        case({sensor_select, sensor_data})
            {SENSOR_1, VOLTAGE_LEVEL_1}: begin
                // Process data from SENSOR_1 at VOLTAGE_LEVEL_1
                processed_data <= sensor_data; // Example: No processing
            end
            {SENSOR_1, VOLTAGE_LEVEL_2}: begin
                // Process data from SENSOR_1 at VOLTAGE_LEVEL_2
                processed_data <= sensor_data * 2; // Example: Scale data
            end
            {SENSOR_2, VOLTAGE_LEVEL_1}: begin
                // Process data from SENSOR_2 at VOLTAGE_LEVEL_1
                processed_data <= sensor_data + 10; // Example: Offset data
            end
            {SENSOR_2, VOLTAGE_LEVEL_2}: begin
                // Process data from SENSOR_2 at VOLTAGE_LEVEL_2
                processed_data <= sensor_data - 5; // Example: Offset data
            end
            {SENSOR_3, VOLTAGE_LEVEL_1}: begin
                // Process data from SENSOR_3 at VOLTAGE_LEVEL_1
                processed_data <= sensor_data * 3; // Example: Scale data
            end
            {SENSOR_3, VOLTAGE_LEVEL_2}: begin
                // Process data from SENSOR_3 at VOLTAGE_LEVEL_2
                processed_data <= sensor_data; // Example: No processing
            end
            default: processed_data <= 8'b0;
        endcase
    end
end

assign output_data = processed_data;

endmodule