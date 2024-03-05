# I2C Master module (1 master - 1 slave)
## I. Wave Form 
### 1. Start, Stop, Repeat start condition
![condition wave](/illustrating%20images/Spec_condition.png)
### 2. Read, Write
![Read/Write wave](/illustrating%20images/Read_write_wave.png)
## II. Specification
### 1. Block diagram
![Master block diagram](/illustrating%20images/master_block.png)
### 2. FSM
![FSM Master](/illustrating%20images/fsm_master.png)
### 3. Register map and APB slave interface
#### a. Register list
|NAME|ADDRESS|WIDTH|ACCESS|DESCRIPTION|
|:----:|:---:|:---:|:----:|:------|
|prescaler|0x00|8|RW|Equal to i2c_core_clock / (2 * scl_clock)| 
|cmd|0x01|8|RW|Command from cpu to i2c core|
|transmit|0x02|8|R|Save data from cpu to master for transfer to slave|
|receive|0x03|8|R|Save data in from slave to master|
|address_rw|0x04|8|RW|Address of slave and read write bit cpu send to i2c master|
|status|0x05|8|R|Status of fifo, bus,...| 
#### b. Register details
##### * Prescaler register
|Bit|Access|Description|
|:-:|:----:|:---------|
|7:0|RW|Value of division clock equal to i2c_core_clock / (2 * scl_clock)|

##### * Cmd register 
|Bit|Access|Description|
|:-:|:----:|:---------|
|7|RW|Repeat start bit active high|
|6|RW|Enable i2c core active high|
|5|RW|Reset i2c core active low|
|4:0|RW|Reserved|

##### * Transmit register 
|Bit|Access|Description|
|:-:|:----:|:---------|
|7:0|RW|Save data cpu want to transfer to i2c slave|

##### * Receive register 
|Bit|Access|Description|
|:-:|:----:|:---------|
|7:0|R|Save data i2c slave send|

##### * Address register 
|Bit|Access|Description|
|:-:|:----:|:---------|
|7:1|RW|Address of i2c slave|
|0|RW|Read write bit: "1" - read, "0" - write|

##### * Status register 
|Bit|Access|Description|
|:-:|:----:|:---------|
|7|R|Read ACK, "1" - NACK, "0" - ACK|
|6|R|Busy bus, "1" after Start condition, "0" after Stop condition|

#### c. APB interface
##### * Waveform write
![apb write data](/illustrating%20images/apb_write.png)
##### * Waveform read
![apb read data](/illustrating%20images/apb_read.png)
##### * Simulates combined reading and writing
![apb simulation](/illustrating%20images/abp_simulation.png)

## III. Simulation I2C Top
### 1. Configuration for I2C Core
 - APB master write to the prescaler register(0x00) the value 0x04
 - APB master write to the cmd register(0x01) the value 0x20 to disable reset i2c core
 - APB master write to the address_rw register(0x04) - address of slave and read/write bit
 - APB master write to the transmit register(0x02) - data cpu want to send to i2c slave and this data is saved in tx fifo
 - APB master write to the cmd register(0x01) the value 0x60 to enable i2c core
![simulation apb - i2c top](/illustrating%20images/apb_i2c_top.png)
### 2. I2C master write adrress, read write bit, and data
 - I2C master write address and read write bit, i2c slave (build in testbench) read address to check and write ACK
 - I2C master write data until tx fifo empty, subsequently, if repeat start bit is seted, i2c master generate the repeat start condition
![simulation i2c write data](/illustrating%20images/i2c_write_data.png)
### 3. I2C master read data from i2c slave
 - I2C master write address and read write bit, i2c slave (build in testbench) read address to check and write ACK
 - I2C slave write data want to send to master in the sda line, i2c master get data and save this data in rx fifo until rx fifo full
![simulation i2c read data](/illustrating%20images/i2c_read_data.png)
## IV. User Guide 
 - First register need to be configured is prescaler register
 - Next, enable reset i2c core to set all variables, reg to the default value
 - Disable reset i2c core, and transfer address of i2c slave and read write bit (if cpu wants to write, cpu can transfer data before writing phase)
 - Next enable i2c core and i2c core will perform its tasks
 - After stop condition, if cpu want to communicate with i2c slave, cpu have to reconfigure i2c core